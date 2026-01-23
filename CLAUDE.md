# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Clap Element X iOS** is a customized fork of Element X iOS for the Clap messenger platform. It's a Matrix protocol-based decentralized, end-to-end encrypted messaging client.

- **Base**: Element X iOS
- **Branches**: `clap/develop` (development), `clap/main` (production)
- **Homeserver**: dev.clap.ac (development), clap.ac (production)
- **Stack**: SwiftUI, Combine, Swift 6.1, iOS 18.0+

## Core Architecture

### Three-Layer Structure

1. **MatrixRustSDK** (v25.12.10)
   - Rust implementation of Matrix protocol with Swift bindings
   - Handles client-server communication, E2E encryption, room state
   - Managed as a Swift Package dependency

2. **Element X iOS** (this repository)
   - SwiftUI UI layer built on top of MatrixRustSDK
   - Business logic, state management, UI components
   - Located in `ElementX/Sources/`

3. **Clap Customizations**
   - Branding changes ("Element" → "Clap")
   - Homeserver configuration (via `clapHomeserver` in Info.plist)
   - Separate build configurations (Debug/Release → Clap Dev/Clap)

### Key Directories

```
ElementX/Sources/
├── Application/       # App entry point, AppSettings, AppCoordinator
├── Services/          # Business logic services
│   ├── Client/        # MatrixRustSDK client wrapper
│   ├── Room/          # Room-related logic
│   ├── Timeline/      # Timeline/message management
│   ├── Keychain/      # Keychain access
│   └── Analytics/     # PostHog analytics
├── FlowCoordinators/  # Screen flow management
├── Screens/           # UI screens (MVVM pattern)
├── Other/             # Utilities, extensions, InfoPlistReader, etc.
├── Mocks/             # Test mock objects (Sourcery generated)
└── Generated/         # SwiftGen, Sourcery auto-generated code

compound-ios/          # Element design system (local package)
UnitTests/             # Unit tests
UITests/               # UI tests (with snapshots)
PreviewTests/          # SwiftUI Preview snapshot tests
IntegrationTests/      # Integration tests
NSE/                   # Notification Service Extension
ShareExtension/        # Share extension
Tools/                 # CLI tools, scripts
fastlane/              # CI/CD automation
```

### Screen Structure (MVVM-Coordinator Pattern)

Each screen consists of the following files:

| File | Role |
|------|------|
| `*Screen.swift` | SwiftUI View |
| `*ScreenViewModel.swift` | Business logic, inherits `StateStoreViewModelV2` |
| `*ScreenCoordinator.swift` | Navigation, dependency injection |
| `*ScreenModels.swift` | ViewState, ViewAction, related models |

```
ElementX/Sources/Screens/
├── Authentication/
│   ├── StartScreen/
│   │   ├── AuthenticationStartScreen.swift
│   │   ├── AuthenticationStartScreenViewModel.swift
│   │   ├── AuthenticationStartScreenCoordinator.swift
│   │   └── AuthenticationStartScreenModels.swift
│   └── ...
├── HomeScreen/
├── RoomScreen/
└── Settings/
```

### State Management

ViewModels inherit from `StateStoreViewModelV2<ViewState, ViewAction>`:

```swift
class HomeScreenViewModel: StateStoreViewModelV2<HomeScreenViewState, HomeScreenViewAction> {
    // state: Published<ViewState> - UI state
    // send(_ action: ViewAction) - action handling
}
```

- Combine `PassthroughSubject` for action dispatch
- `@Published` properties for state change notifications
- Protocol-based dependency injection (for testability)

## Development Commands

### Initial Setup

```bash
# Required: Run after Homebrew installation
swift run tools setup-project

# This command performs:
# 1. Install brew dependencies (xcodegen, swiftgen, sourcery, etc.)
# 2. Configure git hooks (.githooks)
# 3. Run xcodegen to generate .xcodeproj
```

### Build and Run

```bash
# Regenerate project file (after modifying project.yml)
xcodegen

# Build for simulator
xcodebuild -scheme "Clap Dev" -destination 'platform=iOS Simulator,name=iPhone 17'

# Production build
xcodebuild -scheme "Clap" -destination 'platform=iOS Simulator,name=iPhone 17'
```

### Testing

```bash
# Unit tests (including Preview tests)
bundle exec fastlane unit_tests

# Unit tests only (skip Preview tests)
bundle exec fastlane unit_tests skip_previews:true

# UI tests (iPhone)
bundle exec fastlane ui_tests device:iPhone

# UI tests (iPad)
bundle exec fastlane ui_tests device:iPad

# Run specific UI test
bundle exec fastlane ui_tests device:iPhone test_name:LoginTests

# Accessibility tests
bundle exec fastlane accessibility_tests

# List all available lanes
bundle exec fastlane
```

### Single Test Execution

```bash
# Run specific test in Xcode
xcodebuild test \
  -scheme UnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:UnitTests/HomeScreenViewModelTests
```

### Code Generation

```bash
# Regenerate mock objects (Sourcery)
sourcery --config Tools/Sourcery/AutoMockableConfig.yml

# Generate resource code (SwiftGen)
swiftgen config run --config Tools/SwiftGen/swiftgen-config.yml

# Create new screen
Tools/Scripts/createScreen.sh ScreenName
```

### Local MatrixRustSDK Development

```bash
# Clone and build SDK
swift run tools build-sdk

# View options
swift run tools build-sdk --help
```

## Build Configuration

### Scheme Settings

| Scheme | Configuration | Bundle ID | Homeserver |
|--------|---------------|-----------|------------|
| Clap Dev | Debug | `ac.clap.app.dev` | dev.clap.ac |
| Clap | Release | `ac.clap.app` | clap.ac |

### Custom Info.plist Keys

Defined in `ElementX/SupportingFiles/target.yml`:

```yaml
configs:
  Debug:
    APP_DISPLAY_NAME: Clap Dev
    APP_GROUP_IDENTIFIER: group.ac.clap.app.dev
    BASE_BUNDLE_IDENTIFIER: ac.clap.app.dev
    CLAP_HOMESERVER: dev.clap.ac
  Release:
    APP_DISPLAY_NAME: Clap
    APP_GROUP_IDENTIFIER: group.ac.clap.app
    BASE_BUNDLE_IDENTIFIER: ac.clap.app
    CLAP_HOMESERVER: clap.ac
```

## Clap Customizations

### Homeserver Configuration

Reading `clapHomeserver` from `InfoPlistReader.swift`:

```swift
// ElementX/Sources/Other/InfoPlistReader.swift
var clapHomeserver: String {
    infoPlistValue(forKey: Keys.clapHomeserver)  // Read from Info.plist
}
```

URL generation in `AppSettings.swift`:

```swift
// ElementX/Sources/Application/Settings/AppSettings.swift
private var clapBaseURL: String { "https://\(InfoPlistReader.main.clapHomeserver)" }

// OIDC, website URLs are generated based on clapBaseURL
private(set) lazy var oidcRedirectURL: URL = URL(string: "\(clapBaseURL)/oidc/login")!
private(set) lazy var websiteURL: URL = URL(string: clapBaseURL)!
```

### Related Files

| File | Role |
|------|------|
| `InfoPlistReader.swift` | Read Info.plist values |
| `AppSettings.swift` | App-wide settings and URL configuration |

## Key Dependencies

### Element/Matrix Packages

| Package | Role |
|---------|------|
| MatrixRustSDK | Matrix protocol implementation |
| Compound | Element design system (local package) |
| WysiwygComposer | Rich text editor |
| EmbeddedElementCall | Element Call integration |
| AnalyticsEvents | Analytics events |

### External Packages

| Package | Role |
|---------|------|
| Kingfisher | Image caching |
| KeychainAccess | Keychain management |
| PostHog | Analytics |
| Sentry | Error tracking |
| Mapbox/MapLibre | Location sharing maps |
| DSWaveformImage | Voice message waveforms |

## Testing

### Test Structure

```
UnitTests/          # Mirrors src structure like Jest
├── Sources/
│   ├── Screens/
│   │   └── HomeScreenViewModelTests.swift
│   └── Services/
PreviewTests/       # SwiftUI Preview snapshots
UITests/            # User flow tests
IntegrationTests/   # E2E tests
AccessibilityTests/ # VoiceOver tests
```

### Snapshot Tests

- **Git LFS**: Snapshot images managed with LFS
- **UITests**: Record snapshots during user flow execution
- **PreviewTests**: Extract snapshots from SwiftUI Previews

If snapshots fail:
```bash
# Verify Git LFS installation
git lfs install

# Pull snapshot files
git lfs pull
```

### Mock Generation

Protocols marked with `@AutoMockable` are automatically mocked by Sourcery:

```swift
// Define @AutoMockable protocol
protocol RoomProxyProtocol: AutoMockable {
    func sendMessage(_ message: String) async throws
}

// Auto-generated Mock (ElementX/Sources/Mocks/)
class RoomProxyMock: RoomProxyProtocol {
    var sendMessageCalled = false
    var sendMessageReceivedMessage: String?
    // ...
}
```

## Code Style

### Swift

- **SwiftLint**: Runs automatically during build
- **Indentation**: 4 spaces
- **Naming**:
  - lowerCamelCase: variables, functions
  - UpperCamelCase: types, protocols
- **Combine** usage (mixed with async/await)
- **@Published, @State, @EnvironmentObject** patterns

### SwiftUI Components

```swift
struct HomeScreen: View {
    @StateObject private var viewModel: HomeScreenViewModel

    var body: some View {
        // View implementation
    }
}
```

### File Naming

- Components: `UpperCamelCase.swift`
- Use folder structure per screen
- Place related files in the same folder

## Important Development Notes

### XcodeGen

Project file `.xcodeproj` is generated by XcodeGen:

- **Do not modify**: Never edit `.xcodeproj` directly
- **Change settings**: Modify `project.yml`, `app.yml`, `target.yml`
- **Apply changes**: Run `xcodegen` command

### Git Hooks

Uses custom hooks from `.githooks/` folder:

```bash
# setup-project configures automatically, for manual setup:
git config core.hooksPath .githooks
```

### Localization (i18n)

- Uses Localazy (shares translations with Android)
- Strings accessed type-safely via SwiftGen

### Network Debugging

```bash
# Set HTTPS_PROXY environment variable in Xcode
# Clap Dev scheme > Edit Scheme > Run > Environment Variables
HTTPS_PROXY=localhost:9090
```

## Pull Request Guidelines

- **Target branch**: `clap/develop`
- **PR labels**: `pr-enhancement`, `pr-bugfix`, etc. (for CHANGES.md auto-generation)
- **Commit messages**: Focus on "why", explain the reason for changes
- **UI changes**: Attach Before/After screenshots
- **Testing**: Tests required for new features

## Updating Element X iOS

Merging upstream changes:

```bash
# Add upstream (first time only)
git remote add upstream https://github.com/element-hq/element-x-ios.git

# Fetch latest tags
git fetch upstream --tags

# Merge
git checkout clap/develop
git merge v1.x.x

# Resolve conflicts and test
```

**Key conflict areas**:
- `ElementX/SupportingFiles/target.yml` (build settings)
- `AppSettings.swift` (URL settings)
- `InfoPlistReader.swift` (custom keys)

## Related Repositories

- **clap-element-web**: Clap web client (Element Web fork)
- **clap-synapse**: Matrix Synapse homeserver
- **clap-infrastructure**: AWS infrastructure (Terraform)
