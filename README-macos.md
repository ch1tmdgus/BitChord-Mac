# BitChord macOS 빌드

## 방법 A: GitHub Actions (Mac 없이)
1. 이 저장소의 GitHub 페이지를 열거나 본인 포크를 사용합니다.
2. Actions 탭 → **Build macOS (dmg)** → Run workflow.
3. 끝나면 Artifacts에서 `BitChord-macOS-arm64`(Apple Silicon) 또는 `BitChord-macOS-x64`(Intel)을 선택합니다.

## 방법 B: 내 Mac에서 직접
```bash
brew install --cask temurin@21
./gradlew :desktopApp:run
./gradlew :desktopApp:packageDmg
```

DMG는 `desktopApp/build/compose/binaries/main/dmg/`에 생성됩니다.

## 첫 실행 (서명 안 된 앱)
DMG에서 BitChord를 Applications로 복사한 후 실행합니다.

## 알려진 제한
- 이 macOS 빌드에는 AutoMix 네이티브 분석기가 포함되지 않습니다.
- macOS 미디어 키 및 Now Playing 연동은 지원하지 않습니다.
- 암호화된 Chromium 쿠키는 가져오지 못할 수 있습니다. 앱 내 로그인을 이용할 수 있습니다.
- 자동 업데이트는 지원하지 않습니다.
