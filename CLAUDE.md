# ORMO iOS

대학 내 카페 모바일 오더 서비스 ORMO의 iOS 사용자 앱 (프론트엔드). 백엔드는 별도 팀이 개발한다.

## 기술 스택
- Swift, SwiftUI, iOS 17+, iPhone 전용, 세로 고정
- 아키텍처: MVVM(@Observable) + Repository
- 패키지 관리는 SPM만 사용한다. 새 의존성은 추가 전에 사용자에게 먼저 묻는다.
- 네트워크는 URLSession + async/await

## 폴더 구조 (ORMO/ 아래)
- App: 앱 진입점, RootTabView, AppContainer
- Core: 네트워크, 저장소, 확장, AppConfig
- DesignSystem: 색·타이포·간격, 공통 컴포넌트 (색·폰트·간격은 여기서만 정의)
- Domain: 모델과 Repository 프로토콜
- Data: Remote/Mock Repository 구현, DTO ↔ Domain 매핑
- Features: 화면 단위 폴더 (각 폴더에 View, ViewModel)
- Resources: Assets 등

## 코드 규칙
- 의존 방향: View → ViewModel → Repository(프로토콜) → Remote/Mock
- 화면은 Mock Repository로 먼저 완성하고, 서버 연동은 Remote Repository로 분리한다.
- 서버 응답(DTO)과 앱 내부 모델(Domain)을 분리한다.
- 파일명은 타입명과 같게 하고 View, ViewModel 접미사를 붙인다.
- 하드코딩된 색·폰트·간격 대신 DesignSystem 값을 쓴다.
- 환경 값(API 주소, Mock 여부)은 Config/*.xcconfig → Info.plist → AppConfig 로만 읽는다.

## 절대 하지 말 것
- ORMO.xcodeproj/project.pbxproj 를 직접 수정하지 않는다. ORMO/ 폴더는 Xcode와 자동 동기화되므로 파일은 폴더에 만들기만 하면 된다. 빌드 설정, Info.plist 키, Signing, Capability 변경이 필요하면 사용자에게 Xcode에서 직접 하도록 안내한다.
- Config/Secrets.xcconfig 와 비밀값(.p12, .p8, .env 등)을 만들거나 커밋하지 않는다.
- 사용자가 요청하기 전에는 commit/push 하지 않는다. main, develop 에서 직접 작업하지 않는다.

## Git 규칙
- 브랜치: develop 에서 feature/이슈번호-설명 으로 분기, PR은 develop 으로, Squash merge
- 커밋 메시지: `타입: 내용 (#이슈번호)` (feat, fix, refactor, style, chore, docs, test)

## 빌드·테스트
- 빌드: xcodebuild -project ORMO.xcodeproj -scheme ORMO -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build
- 테스트: 위 명령의 마지막을 test 로 바꿔 실행
- 시뮬레이터 이름이 없으면 `xcrun simctl list devices available` 로 확인한다.
