# ORMO iOS 컨벤션

대학 내 카페 모바일 오더 서비스 ORMO의 iOS 사용자 앱 개발 컨벤션 문서입니다. 자세한 배경은 루트의 `CLAUDE.md`를 참고하세요.

## 기술 스택

- Swift, SwiftUI, iOS 17+, iPhone 전용, 세로 고정
- 아키텍처: MVVM(`@Observable`) + Repository
- 패키지 관리: SPM만 사용. 새 의존성 추가 전 반드시 논의
- 네트워크: `URLSession` + `async/await`

## 폴더 구조

```
ORMO/
├── App/            # 앱 진입점 (ORMOApp, RootTabView), AppContainer
├── Core/           # 네트워크, 저장소, 확장, AppConfig
├── DesignSystem/   # 색·타이포·간격, 공통 컴포넌트 (색·폰트·간격은 여기서만 정의)
├── Domain/         # 모델, Repository 프로토콜
├── Data/           # Remote/Mock Repository 구현, DTO ↔ Domain 매핑
├── Features/       # 화면 단위 폴더 (각 폴더에 View, ViewModel)
└── Resources/      # Assets 등
```

`ORMO/` 폴더는 Xcode와 자동 동기화(file system synchronized group)되므로, 폴더/파일을 추가할 때 `ORMO.xcodeproj`를 수정할 필요가 없습니다.

## 코드 규칙

- 의존 방향: `View → ViewModel → Repository(프로토콜) → Remote/Mock`
- 화면은 Mock Repository로 먼저 완성하고, 서버 연동은 Remote Repository로 분리
- 서버 응답(DTO)과 앱 내부 모델(Domain)을 분리
- 파일명은 타입명과 같게 하고 `View`, `ViewModel` 접미사를 붙임
- 하드코딩된 색·폰트·간격 대신 DesignSystem 값을 사용
- 환경 값(API 주소, Mock 여부)은 `Config/*.xcconfig → Info.plist → AppConfig` 순서로만 읽음

## 절대 하지 말 것

- `ORMO.xcodeproj/project.pbxproj` 직접 수정 금지 — 빌드 설정, Info.plist 키, Signing, Capability 변경은 Xcode에서 직접
- `Config/Secrets.xcconfig`, 비밀값(`.p12`, `.p8`, `.env` 등) 생성·커밋 금지
- 사용자 요청 없는 commit/push 금지, `main`/`develop` 직접 작업 금지

## Git 규칙

- 브랜치: `develop`에서 `feature/이슈번호-설명`으로 분기
- PR은 `develop`으로, Squash merge
- 커밋 메시지: `타입: 내용 (#이슈번호)` (`feat`, `fix`, `refactor`, `style`, `chore`, `docs`, `test`)

## 빌드·테스트

```sh
# 빌드
xcodebuild -project ORMO.xcodeproj -scheme ORMO -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build

# 테스트
xcodebuild -project ORMO.xcodeproj -scheme ORMO -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test
```

시뮬레이터 이름이 없으면 `xcrun simctl list devices available`로 확인합니다.
