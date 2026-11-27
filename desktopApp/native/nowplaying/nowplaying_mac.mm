// macOS Now Playing / media-key bridge.
//
// The macOS counterpart of native/smtc/smtc_jni.cpp and exposes the same JNI surface to
// DesktopWindowsMedia (nativeStart / nativeUpdate / nativeStop, plus onButton callbacks), so the
// player side needs no macOS-specific code. Built by CI with clang++ into
// libbitchord_nowplaying.dylib; absent, DesktopWindowsMedia is a no-op.

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#include <jni.h>

#include <atomic>

namespace {

// The button ids Kotlin knows; see DesktopWindowsMedia.
constexpr jint BUTTON_PLAY = 0;
constexpr jint BUTTON_PAUSE = 1;
constexpr jint BUTTON_NEXT = 2;
constexpr jint BUTTON_PREVIOUS = 3;
constexpr jint BUTTON_STOP = 4;

JavaVM* g_vm = nullptr;
jclass g_class = nullptr;       // Global ref, resolved on a Java thread so the app loader is used.
jmethodID g_on_button = nullptr;

std::atomic<bool> g_started{false};
std::atomic<bool> g_playing{false};

NSMutableArray* g_targets = nil;       // Registered command targets, kept to remove on stop.
NSString* g_art_url = nil;             // The artwork URL the current artwork belongs to.
MPMediaItemArtwork* g_artwork = nil;
NSDictionary* g_last_info = nil;

void notify(jint button) {
    if (g_vm == nullptr || g_class == nullptr || g_on_button == nullptr) return;
    JNIEnv* env = nullptr;
    bool attached = false;
    if (g_vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        if (g_vm->AttachCurrentThreadAsDaemon(reinterpret_cast<void**>(&env), nullptr) != JNI_OK) return;
        attached = true;
    }
    env->CallStaticVoidMethod(g_class, g_on_button, button);
    if (env->ExceptionCheck()) env->ExceptionClear();
    if (attached) g_vm->DetachCurrentThread();
}

NSString* to_ns(JNIEnv* env, jstring value) {
    if (value == nullptr) return @"";
    const jchar* chars = env->GetStringChars(value, nullptr);
    const jsize length = env->GetStringLength(value);
    NSString* out = [[NSString alloc] initWithCharacters:reinterpret_cast<const unichar*>(chars)
                                                  length:static_cast<NSUInteger>(length)];
    env->ReleaseStringChars(value, chars);
    return out ?: @"";
}

void add(MPRemoteCommand* command, MPRemoteCommandHandlerStatus (^handler)(MPRemoteCommandEvent*)) {
    command.enabled = YES;
    id target = [command addTargetWithHandler:handler];
    [g_targets addObject:@[ command, target ]];
}

void register_commands() {
    MPRemoteCommandCenter* center = [MPRemoteCommandCenter sharedCommandCenter];
    g_targets = [NSMutableArray array];

    add(center.playCommand, ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent*) {
        notify(BUTTON_PLAY);
        return MPRemoteCommandHandlerStatusSuccess;
    });
    add(center.pauseCommand, ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent*) {
        notify(BUTTON_PAUSE);
        return MPRemoteCommandHandlerStatusSuccess;
    });
    // The keyboard play/pause key arrives as a toggle.
    add(center.togglePlayPauseCommand, ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent*) {
        notify(g_playing.load() ? BUTTON_PAUSE : BUTTON_PLAY);
        return MPRemoteCommandHandlerStatusSuccess;
    });
    add(center.nextTrackCommand, ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent*) {
        notify(BUTTON_NEXT);
        return MPRemoteCommandHandlerStatusSuccess;
    });
    add(center.previousTrackCommand, ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent*) {
        notify(BUTTON_PREVIOUS);
        return MPRemoteCommandHandlerStatusSuccess;
    });
    add(center.stopCommand, ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent*) {
        notify(BUTTON_STOP);
        return MPRemoteCommandHandlerStatusSuccess;
    });
}

void unregister_commands() {
    for (NSArray* pair in g_targets) {
        [(MPRemoteCommand*)pair[0] removeTarget:pair[1]];
    }
    g_targets = nil;
}

void publish_info(NSDictionary* info, BOOL playing) {
    MPNowPlayingInfoCenter* center = [MPNowPlayingInfoCenter defaultCenter];
    center.nowPlayingInfo = info;
    center.playbackState = playing ? MPNowPlayingPlaybackStatePlaying : MPNowPlayingPlaybackStatePaused;
}

void fetch_artwork(NSString* url) {
    NSURL* nsurl = [NSURL URLWithString:url];
    if (nsurl == nil) return;
    [[[NSURLSession sharedSession] dataTaskWithURL:nsurl
                                 completionHandler:^(NSData* data, NSURLResponse*, NSError* error) {
        if (error != nil || data == nil) return;
        NSImage* image = [[NSImage alloc] initWithData:data];
        if (image == nil) return;
        MPMediaItemArtwork* artwork =
            [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size
                                            requestHandler:^NSImage*(CGSize) { return image; }];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Ignore a late answer for a track that is no longer current.
            if (g_art_url == nil || ![g_art_url isEqualToString:url]) return;
            g_artwork = artwork;
            if (g_last_info == nil) return;
            NSMutableDictionary* info = [g_last_info mutableCopy];
            info[MPMediaItemPropertyArtwork] = artwork;
            g_last_info = info;
            publish_info(info, g_playing.load());
        });
    }] resume];
}

}  // namespace

extern "C" {

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void*) {
    g_vm = vm;
    return JNI_VERSION_1_6;
}

JNIEXPORT jboolean JNICALL
Java_com_music_bitchord_desktop_DesktopWindowsMedia_nativeStart(JNIEnv* env, jobject) {
    if (g_started.exchange(true)) return JNI_TRUE;
    if (g_class == nullptr) {
        jclass local = env->FindClass("com/music/bitchord/desktop/DesktopWindowsMedia");
        if (local == nullptr) {
            env->ExceptionClear();
            g_started = false;
            return JNI_FALSE;
        }
        g_class = static_cast<jclass>(env->NewGlobalRef(local));
        env->DeleteLocalRef(local);
        g_on_button = env->GetStaticMethodID(g_class, "onButton", "(I)V");
        if (g_on_button == nullptr) {
            env->ExceptionClear();
            g_started = false;
            return JNI_FALSE;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        register_commands();
    });
    return JNI_TRUE;
}

JNIEXPORT void JNICALL
Java_com_music_bitchord_desktop_DesktopWindowsMedia_nativeUpdate(
    JNIEnv* env, jobject, jstring title, jstring artist, jstring album, jstring art,
    jboolean playing, jlong position_ms, jlong duration_ms) {
    if (!g_started.load()) return;
    NSString* nsTitle = to_ns(env, title);
    NSString* nsArtist = to_ns(env, artist);
    NSString* nsAlbum = to_ns(env, album);
    NSString* nsArt = to_ns(env, art);
    const BOOL isPlaying = playing == JNI_TRUE;
    g_playing = isPlaying;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (nsTitle.length == 0 && nsArtist.length == 0) {
            g_last_info = nil;
            g_art_url = nil;
            g_artwork = nil;
            MPNowPlayingInfoCenter* center = [MPNowPlayingInfoCenter defaultCenter];
            center.nowPlayingInfo = nil;
            center.playbackState = MPNowPlayingPlaybackStateStopped;
            return;
        }
        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        info[MPMediaItemPropertyTitle] = nsTitle;
        info[MPMediaItemPropertyArtist] = nsArtist;
        info[MPMediaItemPropertyAlbumTitle] = nsAlbum;
        info[MPMediaItemPropertyPlaybackDuration] = @(duration_ms / 1000.0);
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(position_ms / 1000.0);
        info[MPNowPlayingInfoPropertyPlaybackRate] = @(isPlaying ? 1.0 : 0.0);
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = @(1.0);
        info[MPNowPlayingInfoPropertyMediaType] = @(MPNowPlayingInfoMediaTypeAudio);

        if (nsArt.length == 0) {
            g_art_url = nil;
            g_artwork = nil;
        } else if (g_art_url == nil || ![g_art_url isEqualToString:nsArt]) {
            g_art_url = nsArt;
            g_artwork = nil;
            fetch_artwork(nsArt);
        }
        if (g_artwork != nil) info[MPMediaItemPropertyArtwork] = g_artwork;

        g_last_info = info;
        publish_info(info, isPlaying);
    });
}

JNIEXPORT void JNICALL
Java_com_music_bitchord_desktop_DesktopWindowsMedia_nativeStop(JNIEnv*, jobject) {
    if (!g_started.exchange(false)) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        unregister_commands();
        g_last_info = nil;
        g_art_url = nil;
        g_artwork = nil;
        MPNowPlayingInfoCenter* center = [MPNowPlayingInfoCenter defaultCenter];
        center.nowPlayingInfo = nil;
        center.playbackState = MPNowPlayingPlaybackStateStopped;
    });
}

}  // extern "C"
