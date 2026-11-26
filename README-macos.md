# BitChord macOS 빌드

## 방법 A: GitHub Actions (Mac 없이)
1. 이 레포를 본인 GitHub에 push (fork 또는 새 레포).
2. Actions 탭 → **Build macOS (dmg)** → Run workflow.
3. 끝나면 Artifacts에서 `BitChord-macOS-arm64`(M1~M4) 또는 `-x64`(Intel) 다운로드.

## 방법 B: 내 Mac에서 직접
```bash
brew install --cask temurin@21      # JDK 21
./gradlew :desktopApp:run           # 실행 테스트
./gradlew :desktopApp:packageDmg    # desktopApp/build/compose/binaries/main/dmg/
```

## 첫 실행 (서명 안 된 앱)
dmg → Applications로 복사 후:
```bash
xattr -cr /Applications/BitChord.app
```
그래도 막히면 우클릭 → 열기.

## 알려진 제한
- Automix 분석기 없음 (Windows/Linux 전용 C++ 빌드)
- Windows 전용 기능(SMTC, DPAPI, Mica)·Linux 전용 기능(MPRIS) 미지원, 맥 미디어키/Now Playing 연동 없음
- 브라우저 쿠키 가져오기 로그인은 맥에서 동작 안 할 수 있음
- 자동 업데이트 미지원
