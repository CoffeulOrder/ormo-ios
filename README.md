# ORMO iOS

대학 내 카페 모바일 오더 서비스 **ORMO**의 iOS 사용자 앱입니다. 이 레포는 프론트엔드(iOS 앱)만 다루며, 백엔드는 별도 팀에서 개발합니다.

## 기술 스택 · 요구 사항

- Swift, SwiftUI
- iOS 17+, iPhone 전용, 세로 고정
- 패키지 관리: SPM만 사용
- 네트워크: `URLSession` + `async/await`
- Xcode (레포가 신규 `.xcodeproj` 포맷을 사용하므로 최신 버전 권장)

## 시작하기

```sh
git clone <repo-url>
cd ormo-ios
open ORMO.xcodeproj
```

필요하면 `Config/Secrets.xcconfig.example`을 복사해 `Secrets.xcconfig`를 만들고 값을 채웁니다 (이 파일은 git에 커밋되지 않습니다).

```sh
cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig
```

### 빌드

```sh
xcodebuild -project ORMO.xcodeproj -scheme ORMO -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build
```

### 테스트

```sh
xcodebuild -project ORMO.xcodeproj -scheme ORMO -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test
```

시뮬레이터 이름이 없다면 아래로 확인합니다.

```sh
xcrun simctl list devices available
```

## 환경 설정

빌드 설정 값은 `Config/*.xcconfig → Info.plist → AppConfig` 순서로만 전달됩니다.

| 파일 | 역할 |
|---|---|
| `Config/Base.xcconfig` | Debug/Release 공통 설정 |
| `Config/Debug.xcconfig` | `API_BASE_URL`, `USE_MOCK=YES` |
| `Config/Release.xcconfig` | `API_BASE_URL`, `USE_MOCK=NO` |
| `Config/Secrets.xcconfig` | 비밀 값 (git에 커밋되지 않음, `.example` 파일을 복사해서 생성) |

`ORMO/Info.plist`가 `API_BASE_URL`, `USE_MOCK` 키로 xcconfig 값을 받고, `ORMO/Core/AppConfig.swift`가 이를 읽어 `AppConfig.apiBaseURL`, `AppConfig.useMock`으로 앱 전체에 노출합니다.

## 폴더 구조

```
ORMO/
├── App/            # 앱 진입점 (ORMOApp, RootTabView)
├── Core/           # 네트워크, 저장소, 확장, AppConfig
├── DesignSystem/   # 색·타이포·간격, 공통 컴포넌트
├── Domain/         # 모델, Repository 프로토콜
├── Data/           # Remote/Mock Repository 구현, DTO ↔ Domain 매핑
├── Features/       # 화면 단위 폴더 (View, ViewModel)
└── Resources/      # Assets 등

ORMOTests/          # 유닛 테스트
ORMOUITests/        # UI 테스트
Config/             # xcconfig (Base/Debug/Release/Secrets)
docs/               # 컨벤션·디자인 시스템 문서
.github/            # PR 템플릿
```

## 아키텍처

MVVM(`@Observable`) + Repository 패턴을 사용합니다.

```
View → ViewModel → Repository(프로토콜) → Remote/Mock Repository
```

- 화면은 Mock Repository로 먼저 완성하고, 서버 연동은 Remote Repository로 분리합니다.
- 서버 응답(DTO)과 앱 내부 모델(Domain)을 분리합니다.

자세한 규칙은 [docs/CONVENTIONS.md](docs/CONVENTIONS.md)를 참고하세요.

## 협업 규칙

- 브랜치: `develop`에서 `feature/이슈번호-설명`으로 분기
- PR은 `develop`으로, **Squash merge**
- 커밋 메시지: `타입: 내용 (#이슈번호)` (`feat`, `fix`, `refactor`, `style`, `chore`, `docs`, `test`)
- PR 생성 시 [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md) 체크리스트를 따릅니다.

## 문서

- [docs/CONVENTIONS.md](docs/CONVENTIONS.md) — 기술 스택, 코드 규칙, Git 규칙 전문
- [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) — 컬러·타이포·spacing·컴포넌트 디자인 시스템
