# Clap iOS Customizations

> Element X iOS 기반 Clap 메신저 커스터마이징 내역

## 목차

1. [앱 설정 및 브랜딩](#1-앱-설정-및-브랜딩)
2. [CompoundDesignTokens 내재화](#2-compounddesigntokens-내재화)
3. [메시지 버블 UI 재설계](#3-메시지-버블-ui-재설계)
4. [홈 화면 UI 변경](#4-홈-화면-ui-변경)
5. [메시지 작성기 재설계](#5-메시지-작성기-재설계)
6. [타임라인 UI 개선](#6-타임라인-ui-개선)
7. [장문 메시지 전체 보기 기능](#7-장문-메시지-전체-보기-기능)
8. [기타 스타일 변경](#8-기타-스타일-변경)
9. [개발자 모드 설정](#9-개발자-모드-설정)
10. [빌드 구성](#10-빌드-구성)
11. [홈서버 설정](#11-홈서버-설정)
12. [인증 화면 커스터마이징](#12-인증-화면-커스터마이징)
13. [Space 채널 그룹화 기능](#13-space-채널-그룹화-기능)
14. [딥링크 설정](#14-딥링크-설정)
15. [CI/CD 설정](#15-cicd-설정)
16. [푸시 알림 설정](#16-푸시-알림-설정)
17. [Space 내 룸 생성/삭제 기능](#17-space-내-룸-생성삭제-기능)

---

## 1. 앱 설정 및 브랜딩

Clap 앱의 기본 설정 및 브랜딩 구성

### 변경 내용

- Bundle Identifier
  - Production: `ac.clap.app`
  - Development: `ac.clap.app.dev`
- App Group
  - Production: `group.ac.clap.app`
  - Development: `group.ac.clap.app.dev`
- Display Name
  - Production: `Clap`
  - Development: `Clap Dev`
- Development Team 업데이트
- NSE에서 `usernotifications.filtering` entitlement 제거
- Clap 전용 앱 아이콘으로 교체

### 관련 커밋

- `f0e4394f9` chore: Configure app settings for Clap
- `fed39187c` chore: Update app icon to Clap icon

---

## 2. CompoundDesignTokens 내재화

Element 디자인 토큰 패키지를 외부 의존성에서 로컬로 내재화하여 커스텀 컬러/아이콘 수정 가능하도록 변경

### 변경 내용

- 외부 `compound-design-tokens` SPM 의존성 제거
- `CompoundDesignTokens`를 로컬 타겟으로 추가 (Colors.xcassets, Icons.xcassets 포함)
- `compound-ios/Package.swift`에서 로컬 토큰 소스 참조하도록 수정
- 모든 디자인 토큰(컬러, 아이콘, 폰트)을 프로젝트 내에서 완전히 제어 가능

### 관련 파일

- [compound-ios/](compound-ios/) - 로컬화된 Compound 패키지
- [compound-ios/Sources/CompoundDesignTokens/](compound-ios/Sources/CompoundDesignTokens/) - 디자인 토큰

### 관련 커밋

- `7a2de0783` chore: Vendor CompoundDesignTokens locally

---

## 3. 메시지 버블 UI 재설계

메시지 버블 레이아웃 및 스타일 전면 재설계

### 변경 내용

- 메시지 버블 레이아웃 업데이트 (`TimelineItemBubbledStylerView`)
- 버블 인식 텍스트 스타일 환경 값 추가 (`TimelineBubbleTextStyle`)
- 답장 뷰 스타일 개선 (`TimelineReplyView`)
- 버블 인식 컬러 시스템 적용 (`FormattedBodyText`)
- 타임스탬프를 버블 외부로 이동
- 수신/발신 메시지에 따른 텍스트 컬러 분리
- 텍스트 클리핑 및 불필요한 여백 문제 해결

### 수신/발신 버블 컬러

```swift
// 수신 메시지 (incoming)
.textBubble         // 기본 텍스트
.textBubbleSecondary // 보조 텍스트
.iconBubble         // 아이콘

// 발신 메시지 (outgoing)
.textBubbleOutgoing
.textBubbleSecondaryOutgoing
.iconBubbleOutgoing
```

### 적용 범위

- 텍스트 메시지
- 파일 첨부 메시지 (파일명, 설명, 아이콘)
- 음성 메시지 (재생 시간 라벨)
- 투표 (Poll)
- 미디어 캡션
- 삭제된 메시지

### 관련 파일

- [TimelineItemBubbledStylerView.swift](ElementX/Sources/Screens/Timeline/View/Style/TimelineItemBubbledStylerView.swift)
- [FormattedBodyText.swift](ElementX/Sources/Screens/Timeline/View/TimelineItemViews/FormattedBodyText.swift)
- [TimelineReplyView.swift](ElementX/Sources/Screens/Timeline/View/Replies/TimelineReplyView.swift)

### 관련 커밋

- `7e8c8acb2` feat: Redesign message bubble UI and timeline styling
- `fd24d0baa` feat: Move timestamp outside message bubble
- `d957ccfe7` fix: Resolve text clipping and unnecessary whitespace in message bubbles
- `d554c653d` fix: Apply incoming/outgoing text color to file and voice message bubbles

---

## 4. 홈 화면 UI 변경

홈 화면 레이아웃 및 스타일 변경

### 변경 내용

- 네비게이션 바 타이틀을 인라인 모드로 변경
- 검색 바 설정 조정
- 툴바 그라데이션 제거
- 룸 셀에 멤버 수 표시

### 관련 커밋

- `1fd8285e5` feat: Set home screen navigation bar title to inline mode and adjust search bar settings
- `6a128e22b` feat: Display member count in room header and home screen room list

---

## 5. 메시지 작성기 재설계

메시지 작성 UI 재설계

### 변경 내용

- 통합된 입력 컨테이너 디자인
- 커스텀 테마 컬러 적용

### 관련 파일

- [MessageComposer.swift](ElementX/Sources/Screens/Timeline/View/MessageComposer/MessageComposer.swift)

### 관련 커밋

- `d04d7db79` feat: Redesign message composer

---

## 6. 타임라인 UI 개선

타임라인 전반의 스타일 개선

### 변경 내용

- 투표(Poll) 뷰에 버블 인식 컬러 적용
- Pill 스타일 개선 (멘션, 링크 등)
- 미디어 캡션 스타일 개선
- 삭제된 메시지 스타일 개선
- 스레드(Threads) 기능 활성화

### 관련 커밋

- `00363b30f` feat: Add bubble-aware colors for poll view
- `3ecc012f7` feat: Improve timeline UI
- `6bb1d9e5d` feat: Improve UI styling for pills, polls, media captions, and redacted messages
- `24723230b` feat: Enable threads feature

---

## 7. 장문 메시지 전체 보기 기능

긴 메시지 자르기 및 "더 보기" 버튼으로 전체 내용 모달 표시

### 메시지 자르기 기준

- **25줄** 초과 OR **450자** 초과 시 자름
- "Show more" 버튼 표시

### 전체 메시지 모달 (FullMessageSheetView)

- 전체 메시지 텍스트 표시
- 멘션 지원
- 코드 블록 지원
- 링크 컬러 적용 (`.compound.textLinkExternal`)
- 전체 너비 + 왼쪽 정렬

### 관련 파일

- [TextRoomTimelineView.swift](ElementX/Sources/Screens/Timeline/View/TimelineItemViews/TextRoomTimelineView.swift)
- [FullMessageSheetView.swift](ElementX/Sources/Screens/Timeline/View/TimelineItemViews/FullMessageSheetView.swift)

### 관련 커밋

- `863724ef4` feat: Add "Show more" button for long messages with full message modal
- `756c5dc9a` fix: Apply link color in full message sheet view
- `bdee12a62` refactor: Change message truncation to line count + character limit

---

## 8. 기타 스타일 변경

### 로딩 인디케이터

- 박스 없이 스피너만 표시

### 방 화면 배경색

- 배경색 업데이트

### SuperButton 스타일

- 그라데이션 제거, 플랫 디자인 적용

### 커서 커스터마이징

- `clapIconAccentTertiary` 컬러 토큰 추가

### 관련 커밋

- `fc82e4fb5` style: Show only spinner for loading indicator without box
- `fa2f00721` style: Update room screen background color

---

## 9. 개발자 모드 설정

Settings에서 토글 가능한 개발자 전용 기능

### 설정 항목

```swift
// DeveloperModeSettings.swift
final class DeveloperModeSettings {
    /// 로그인 화면에서 커스텀 홈서버 선택 버튼 표시 여부
    @UserPreference(key: "showCustomHomeserver", defaultValue: false)
    var showCustomHomeserver: Bool

    /// 로그인 화면에서 QR 코드 로그인 버튼 표시 여부
    @UserPreference(key: "showQRCodeLogin", defaultValue: false)
    var showQRCodeLogin: Bool

    /// Space 소속 채널을 채팅 탭에서 숨기고 Space 셀 아래에 표시할지 여부
    @UserPreference(key: "groupSpaceRooms", defaultValue: true)
    var groupSpaceRooms: Bool

    /// Space 설정 및 권한 관리 기능 활성화 여부 (AppSettings에 저장)
    /// @AppStorage("spaceSettingsEnabled")로 바인딩
    // spaceSettingsEnabled: Bool (default: true)

    /// 개발자 전용 설정 옵션 표시 여부
    /// View Source, Hide Invite Avatars, Timeline Media, Labs, Report a Problem 포함
    @UserPreference(key: "showDeveloperSettings", defaultValue: false)
    var showDeveloperSettings: Bool
}
```

| 설정 | 설명 | 기본값 |
|------|------|--------|
| `showCustomHomeserver` | 로그인 시 커스텀 홈서버 선택 UI 표시 | false |
| `showQRCodeLogin` | QR 코드 로그인 버튼 표시 | false |
| `groupSpaceRooms` | Space 채널 그룹화 기능 활성화 | true |
| `spaceSettingsEnabled` | Space 설정 및 권한 관리 기능 활성화 | true |
| `showDeveloperSettings` | 개발자 전용 설정 옵션 표시 | false |

### showDeveloperSettings로 제어되는 항목

- **Advanced Settings**
  - View Source (메시지 소스 보기)
  - Hide avatars in room invite requests (초대 요청 아바타 숨기기)
  - Show media in timeline (타임라인 미디어 표시)
- **Settings**
  - Labs (실험실 기능)
  - Report a Problem (문제 신고)

### 설정 화면 UI

Settings > Developer Mode 섹션:

```
┌─────────────────────────────────────────────────┐
│ Authentication                                   │
├─────────────────────────────────────────────────┤
│ Show Custom Homeserver                   [OFF]  │
│ Show the change account provider button         │
│ in sign-in flow                                 │
├─────────────────────────────────────────────────┤
│ Show QR Code Login                       [OFF]  │
│ Show the sign in with QR code button            │
├─────────────────────────────────────────────────┤
│ Spaces                                          │
├─────────────────────────────────────────────────┤
│ Group Space Rooms                         [ON]  │
│ Hide space-affiliated rooms from chat tab       │
│ and show them under space cells instead         │
├─────────────────────────────────────────────────┤
│ Space Settings                            [ON]  │
│ Enable space settings and permissions           │
│ management features                             │
├─────────────────────────────────────────────────┤
│ Settings                                        │
├─────────────────────────────────────────────────┤
│ Show Developer Settings                  [OFF]  │
│ Show View Source, Hide Invite Avatars,          │
│ Timeline Media, Labs, and Report a Problem      │
│ options                                         │
└─────────────────────────────────────────────────┘
```

### 관련 파일

- [DeveloperModeSettings.swift](ElementX/Sources/Application/Settings/DeveloperModeSettings.swift)
- [DeveloperModeScreen.swift](ElementX/Sources/Screens/Settings/DeveloperModeScreen/View/DeveloperModeScreen.swift)
- [SettingsScreen.swift](ElementX/Sources/Screens/Settings/SettingsScreen/View/SettingsScreen.swift)
- [AdvancedSettingsScreen.swift](ElementX/Sources/Screens/Settings/AdvancedSettingsScreen/View/AdvancedSettingsScreen.swift)

### 관련 커밋

- `b2d84ce0b` feat: Add Developer Mode settings
- `be7605820` feat: Add showQRCodeLogin setting to Developer Mode settings

---

## 10. 빌드 구성

두 개의 스킴(Scheme)으로 개발/프로덕션 빌드 구분

| Scheme | Configuration | Bundle ID | App Group | Homeserver |
|--------|---------------|-----------|-----------|------------|
| Clap Dev | Debug | `ac.clap.app.dev` | `group.ac.clap.app.dev` | `dev.clap.ac` |
| Clap | Release | `ac.clap.app` | `group.ac.clap.app` | `clap.ac` |

### 관련 파일

- [target.yml](ElementX/SupportingFiles/target.yml) - 메인 앱 빌드 설정
- [NSE/target.yml](NSE/SupportingFiles/target.yml) - Notification Service Extension 빌드 설정

### 관련 커밋

- `9ac4c7840` build: Separate Debug/Release schemes with different Bundle IDs

---

## 11. 홈서버 설정

`Info.plist`의 `clapHomeserver` 값 기반 모든 URL 동적 생성

### Info.plist에서 홈서버 읽기

```swift
// InfoPlistReader.swift
var clapHomeserver: String {
    infoPlistValue(forKey: Keys.clapHomeserver)  // "dev.clap.ac" 또는 "clap.ac"
}
```

### 동적 URL 생성

```swift
// AppSettings.swift
private var clapBaseURL: String { "https://\(InfoPlistReader.main.clapHomeserver)" }

private(set) lazy var websiteURL: URL = URL(string: clapBaseURL)!
private(set) lazy var logoURL: URL = URL(string: "\(clapBaseURL)/mobile-icon.png")!
private(set) lazy var copyrightURL: URL = URL(string: "\(clapBaseURL)/copyright")!
private(set) lazy var acceptableUseURL: URL = URL(string: "\(clapBaseURL)/acceptable-use-policy-terms")!
private(set) lazy var privacyURL: URL = URL(string: "\(clapBaseURL)/privacy")!
private(set) lazy var oidcRedirectURL: URL = URL(string: "\(clapBaseURL)/oidc/login")!
```

### 기본 계정 Provider

```swift
// AppSettings.swift
private(set) lazy var accountProviders = [InfoPlistReader.main.clapHomeserver]
```

### 관련 파일

- [InfoPlistReader.swift](ElementX/Sources/Other/InfoPlistReader.swift)
- [AppSettings.swift](ElementX/Sources/Application/Settings/AppSettings.swift)

### 관련 커밋

- `5f0ad41bc` feat: Add scheme-based homeserver configuration
- `07a242ca9` feat: Configure OIDC URLs based on clapHomeserver setting

---

## 12. 인증 화면 커스터마이징

개발자 모드 설정에 따른 로그인 화면 UI 조건부 표시

### QR 코드 로그인 버튼

```swift
// AuthenticationStartScreenViewModel.swift
let isQRCodeScanningSupported = !ProcessInfo.processInfo.isiOSAppOnMac
    && ServiceLocator.shared.developerModeSettings.showQRCodeLogin
```

### 커스텀 홈서버 변경 버튼

```swift
// ServerConfirmationScreenViewModel.swift
showCustomHomeserver: ServiceLocator.shared.developerModeSettings.showCustomHomeserver
```

### 관련 파일

- [AuthenticationStartScreenViewModel.swift](ElementX/Sources/Screens/Authentication/StartScreen/AuthenticationStartScreenViewModel.swift)
- [ServerConfirmationScreenViewModel.swift](ElementX/Sources/Screens/Authentication/ServerConfirmationScreen/ServerConfirmationScreenViewModel.swift)

---

## 13. Space 채널 그룹화 기능

`groupSpaceRooms` 설정 활성화 시 Space 소속 채널을 채팅 탭에서 숨기고 Space 셀 아래에 그룹화

### 기능 동작

1. **채팅 탭 동작**
   - Space 셀이 채팅 목록에 표시
   - Space 소속 채널은 채팅 목록에서 숨김
   - Space 셀은 하위 채널 중 가장 최근 메시지 기준으로 정렬
   - Space 셀에 하위 채널들의 읽지 않음 배지 합산 표시

2. **Space 셀 UI 레이아웃**
   ```
   ┌─────────────────────────────────────────────────┐
   │ [Avatar] SpaceName • 25명              2분 전  │
   │          [ChannelName] Last message text...    │
   │          (최대 2줄)                            │
   └─────────────────────────────────────────────────┘
   ```
   - 1행: Space 이름 + 멤버 수 + 타임스탬프 (메시지 없으면 chevron)
   - 2행: `[채널명] 마지막 메시지...` (최대 2줄)

3. **Space 채널 목록 화면**
   - Space 셀 탭 시 `SpaceChannelListScreen`으로 이동
   - 가입된 채널 표시 (컨텍스트 메뉴: 나가기/설정)
   - 미가입 채널은 Join 버튼과 함께 표시

4. **필터 기능**
   - Spaces 필터 추가 (Space만 표시)
   - Unreads + Spaces 필터 조합 가능

5. **컨텍스트 메뉴**
   - Space 셀 롱프레스 시 "Leave Space" 액션 제공

### 핵심 구현 로직

```swift
// HomeScreenViewModel.swift

// Space 자식 Room ID 추적용 변수
private var spaceChildrenRoomIDs: Set<String> = []
private var spaceRoomListProxies: [String: SpaceRoomListProxyProtocol] = [:]

// 설정 변경 감지
developerModeSettings.$groupSpaceRooms
    .combineLatest(spaceService.joinedSpacesPublisher)
    .sink { [weak self] _, spaces in
        self?.updateSpaces(from: spaces)
    }

// 채널 필터링
if developerModeSettings.groupSpaceRooms, !spaceRoomListProxies.isEmpty {
    // Space에 소속된 Room은 채팅 목록에서 제외
}
```

### 관련 파일

- [HomeScreenViewModel.swift](ElementX/Sources/Screens/HomeScreen/HomeScreenViewModel.swift) - Space 자식 추적, 필터링, 집계 로직
- [HomeScreenSpaceCell.swift](ElementX/Sources/Screens/HomeScreen/View/HomeScreenSpaceCell.swift) - Space 셀 UI
- [SpaceChannelListScreen/](ElementX/Sources/Screens/SpaceChannelListScreen/) - Space 채널 목록 화면

### 관련 커밋

- `c5a85ff01` feat: Add space channel grouping
- `e9e4b7c14` feat: Display last message info on space cells
- `7ed028f65` fix: Prevent space channel list flickering on load
- `a4aada16b` refactor: Rename SpaceChannel to SpaceRoom throughout codebase
- `d1ea9c9fb` feat: Add Spaces filter to room list
- `80cbcaf82` feat: Allow combining Unreads and Spaces filters
- `d042b3f64` feat: Add leave space action to home screen space cell context menu

---

## 14. 딥링크 설정

Associated Domains를 통한 딥링크 처리

### 설정된 도메인

```
applinks:clap.ac
webcredentials:clap.ac
applinks:dev.clap.ac
webcredentials:dev.clap.ac
applinks:matrix.to
```

### 관련 파일

- [target.yml](ElementX/SupportingFiles/target.yml) - Entitlements 설정

### 관련 커밋

- `73d12085c` fix: Sync entitlements config in target.yml with actual entitlements files

---

## 15. CI/CD 설정

Xcode Cloud 기반 CI/CD 파이프라인 구성

### 변경 내용

- Enterprise 서브모듈 제거 (Clap에서 미사용)
- 빌드 번호 포맷: `YYMMDDHHMM`
- 마케팅 버전: `0.0.1`부터 시작
- TestFlight 노트 자동 생성

### 관련 파일

- [ci_scripts/](ci_scripts/) - CI 스크립트

### 관련 커밋

- `dfa9a4c30` chore: Setup Xcode Cloud CI/CD
- `5a1f72f2b` fix: Simplify ci_post_xcodebuild.sh for Clap
- `d1de78b4f` refactor: Simplify ci_common.sh for Clap
- `5e852bcfd` feat: Setup Xcode Cloud CI/CD with TestFlight notes

---

## 16. 푸시 알림 설정

Clap 자체 Sygnal 푸시 게이트웨이 사용

### Push Gateway URL

```swift
// AppSettings.swift
private(set) var pushGatewayBaseURL = URL(string: "https://sygnal.\(InfoPlistReader.main.clapHomeserver)")!
// 결과: https://sygnal.dev.clap.ac 또는 https://sygnal.clap.ac
```

### Pusher App ID

```swift
// AppSettings.swift
var pusherAppID: String {
    if isRunningOnTestFlightOrAppStore {
        return InfoPlistReader.main.baseBundleIdentifier + ".ios"          // TestFlight/AppStore
    } else {
        return InfoPlistReader.main.baseBundleIdentifier + ".ios.sandbox"  // Xcode 빌드
    }
}
```

| 배포 환경 | Pusher App ID |
|----------|---------------|
| Xcode 빌드 (Clap Dev) | `ac.clap.app.dev.ios.sandbox` |
| TestFlight/AppStore (Clap Dev) | `ac.clap.app.dev.ios` |
| TestFlight/AppStore (Clap) | `ac.clap.app.ios` |

### 관련 파일

- [AppSettings.swift](ElementX/Sources/Application/Settings/AppSettings.swift)

### 관련 커밋

- `a41fafac8` feat: Configure push notification settings for Clap

---

## 17. Space 내 룸 생성/삭제 기능

Space 내에서 새 채널(룸)을 생성하고, Space에서 채널을 삭제(제거)하는 기능

> **Note**: Element Web/Desktop에는 구현되어 있지만 Element X iOS에는 미구현된 기능을 Clap에서 직접 추가 구현

### 기능 개요

1. **룸 생성**: Space 내에서 새 채널 생성 시 자동으로 해당 Space의 자식으로 설정
2. **룸 제거**: Space에서 채널을 제거 (연결 해제)

### SDK 제약 및 구현 방식

MatrixRustSDK의 `CreateRoomParameters`에 `initial_state` 파라미터가 없어서 룸 생성 후 REST API로 Space 관계를 설정합니다.

```
# Space에 자식 추가 (m.space.child)
PUT /_matrix/client/v3/rooms/{spaceId}/state/m.space.child/{childRoomId}
Body: {"via": ["clap.ac"], "suggested": false}

# Space에서 자식 제거 (빈 객체로 설정)
PUT /_matrix/client/v3/rooms/{spaceId}/state/m.space.child/{childRoomId}
Body: {}

# 룸에 부모 설정 (m.space.parent)
PUT /_matrix/client/v3/rooms/{roomId}/state/m.space.parent/{spaceId}
Body: {"via": ["clap.ac"], "canonical": true}

# Join Rule 설정 (Space 멤버 전용)
PUT /_matrix/client/v3/rooms/{roomId}/state/m.room.join_rules/
Body: {"join_rule": "restricted", "allow": [{"type": "m.room_membership", "room_id": "{spaceId}"}]}
```

### SpaceChildService

Matrix REST API를 통해 Space-Room 관계를 관리하는 서비스

```swift
// SpaceChildServiceProtocol.swift
protocol SpaceChildServiceProtocol {
    /// Space에 자식 룸 추가
    func addChildToSpace(spaceID: String, childRoomID: String, suggested: Bool) async -> Result<Void, SpaceChildServiceError>

    /// Space에서 룸 제거
    func removeChildFromSpace(spaceID: String, childRoomID: String) async -> Result<Void, SpaceChildServiceError>

    /// 룸에 부모 Space 설정
    func setSpaceParent(roomID: String, spaceID: String, canonical: Bool) async -> Result<Void, SpaceChildServiceError>

    /// Restricted Join Rule 설정 (Space 멤버만 참가 가능)
    func setRestrictedJoinRule(roomID: String, spaceID: String) async -> Result<Void, SpaceChildServiceError>

    /// Public Join Rule 설정
    func setPublicJoinRule(roomID: String) async -> Result<Void, SpaceChildServiceError>
}
```

### SpaceRoomVisibility (룸 공개 설정)

Element Web과 동일한 3가지 옵션

| 옵션 | 설명 | Join Rule |
|------|------|-----------|
| `spaceMembers` | Space 멤버만 참가 가능 | `restricted` |
| `privateRoom` | 초대받은 사용자만 참가 | `invite` |
| `publicRoom` | 누구나 참가 가능 | `public` |

```swift
enum SpaceRoomVisibility: String, CaseIterable {
    case spaceMembers   // Space 멤버 전용
    case privateRoom    // 비공개 (초대만)
    case publicRoom     // 공개
}
```

### CreateRoomInSpaceScreen

Space 내에서 룸을 생성하는 화면

```
┌─────────────────────────────────────────────────┐
│ Create channel in "Engineering Team"            │
├─────────────────────────────────────────────────┤
│ [Avatar]  Room name                             │
│           Topic (optional)                      │
├─────────────────────────────────────────────────┤
│ Room visibility                                 │
│ ○ Space members - Anyone in Engineering Team   │
│   can find and join                             │
│ ○ Private - Only invited users can join        │
│ ○ Public - Anyone can join                     │
├─────────────────────────────────────────────────┤
│ Encryption                              [ON]    │
│ Once enabled, encryption cannot be disabled     │
└─────────────────────────────────────────────────┘
```

- Space 이름 컨텍스트 표시
- 채널 이름, 설명, 아바타 설정
- 공개 설정 선택 (Space Members/Private/Public)
- 암호화 토글 (Public 제외)

### SpaceRoomListScreen 메뉴

Space 채널 목록 화면의 툴바 메뉴에 룸 생성/제거 기능 추가

**메뉴 구조:**
```
┌─────────────────────────────────────────────────┐
│ Members                                         │
│ Share                                           │
│ Settings                                        │
├─────────────────────────────────────────────────┤
│ + Create channel            (권한 필요)          │
├─────────────────────────────────────────────────┤
│ Leave space                                     │
└─────────────────────────────────────────────────┘
```

**컨텍스트 메뉴 (룸 롱프레스):**
```
┌─────────────────────────────────────────────────┐
│ Mark as read / Mark as unread                   │
│ Favourite                                       │
│ Settings                                        │
│ Leave room                                      │
│ Remove from space          (권한 필요)           │
└─────────────────────────────────────────────────┘
```

### 권한 체크

`m.space.child` state event 전송 권한 필요

```swift
// SpaceRoomListScreenViewModel.swift
let canManageSpaceChildren = powerLevels.canOwnUser(sendStateEvent: .spaceChild)
```

### 관련 파일

**신규:**
- [SpaceChildServiceProtocol.swift](ElementX/Sources/Services/Spaces/SpaceChildServiceProtocol.swift) - 프로토콜 정의
- [SpaceChildService.swift](ElementX/Sources/Services/Spaces/SpaceChildService.swift) - REST API 구현
- [CreateRoomInSpaceScreen/](ElementX/Sources/Screens/CreateRoomInSpaceScreen/) - 룸 생성 화면

**수정:**
- [ClientProxyProtocol.swift](ElementX/Sources/Services/Client/ClientProxyProtocol.swift) - `createRoomInSpace()` 추가
- [ClientProxy.swift](ElementX/Sources/Services/Client/ClientProxy.swift) - 구현
- [SpaceRoomListScreenModels.swift](ElementX/Sources/Screens/SpaceRoomListScreen/SpaceRoomListScreenModels.swift) - 액션/상태 추가
- [SpaceRoomListScreenViewModel.swift](ElementX/Sources/Screens/SpaceRoomListScreen/SpaceRoomListScreenViewModel.swift) - 로직
- [SpaceRoomListScreen.swift](ElementX/Sources/Screens/SpaceRoomListScreen/View/SpaceRoomListScreen.swift) - UI

### 로컬라이제이션 키

```
"screen_space_create_room" = "Create channel"
"screen_space_create_room_title" = "Create channel in \"%@\""
"screen_space_create_room_visibility_space_members_title" = "Space members"
"screen_space_create_room_visibility_space_members_description" = "Anyone in %@ can find and join"
"screen_space_create_room_visibility_private_title" = "Private"
"screen_space_create_room_visibility_private_description" = "Only invited users can join"
"screen_space_create_room_visibility_public_title" = "Public"
"screen_space_create_room_visibility_public_description" = "Anyone can join"
"screen_space_remove_room" = "Remove from space"
"screen_space_remove_room_alert_title" = "Remove channel"
"screen_space_remove_room_alert_message" = "Remove \"%@\" from this space?"
```

---

*문서 작성일: 2026-01-06*
