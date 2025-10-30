# VIB3 Light Lab - Flutter Development Environment Setup

**Last Updated**: October 30, 2025
**Flutter Version**: 3.35.2+ (stable channel)
**Dart Version**: 3.9.0+

---

## ✅ Prerequisites Checklist

Before starting VIB3 Light Lab development, ensure you have:

- [ ] Flutter SDK installed (3.35.2 or higher)
- [ ] Dart SDK (bundled with Flutter)
- [ ] Git for version control
- [ ] Code editor (VS Code or Android Studio recommended)
- [ ] Platform-specific tools (see below)

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/Domusgpt/Vib3-Light-Lab.git
cd Vib3-Light-Lab

# 2. Checkout Flutter development branch
git checkout flutter/production-controller-ui-refactor

# 3. Copy environment configuration
cp .env.example .env

# 4. Verify Flutter installation
flutter doctor -v

# 5. Get Flutter dependencies (when Flutter project is created)
flutter pub get

# 6. Start WebGL server (in separate terminal)
python3 -m http.server 8151

# 7. Run Flutter app
flutter run -d windows  # or macos, linux
```

---

## 📦 Flutter SDK Installation

### Current Installation Status

Flutter is already installed on this system:
- **Location**: `/snap/bin/flutter`
- **Version**: 3.35.2
- **Channel**: stable
- **Dart**: 3.9.0

### Verify Installation

```bash
# Check Flutter version
flutter --version

# Run Flutter doctor to check setup
flutter doctor -v

# Update Flutter (if needed)
flutter upgrade
```

### Expected `flutter doctor` Output

```
[✓] Flutter (Channel stable, 3.35.2, on Linux, locale en_US.UTF-8)
[✓] Linux toolchain - develop for Linux desktop
[✓] Chrome - develop for the web
[✓] VS Code (version 1.XX.X)
[✓] Connected device (X available)
[✓] Network resources
```

---

## 🖥️ Platform-Specific Setup

### Windows Desktop Development

**Prerequisites**:
- Visual Studio 2022 with "Desktop development with C++" workload
- Windows 10 SDK

**Enable Windows Desktop**:
```bash
flutter config --enable-windows-desktop
```

**Build for Windows**:
```bash
flutter build windows --release
```

**Run on Windows**:
```bash
flutter run -d windows
```

### macOS Desktop Development

**Prerequisites**:
- Xcode 13.0 or higher
- CocoaPods (`sudo gem install cocoapods`)

**Enable macOS Desktop**:
```bash
flutter config --enable-macos-desktop
```

**Build for macOS**:
```bash
flutter build macos --release
```

**Run on macOS**:
```bash
flutter run -d macos
```

### Linux Desktop Development

**Prerequisites**:
```bash
# Ubuntu/Debian
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

# Fedora/RHEL
sudo dnf install clang cmake ninja-build gtk3-devel xz-devel
```

**Enable Linux Desktop**:
```bash
flutter config --enable-linux-desktop
```

**Build for Linux**:
```bash
flutter build linux --release
```

**Run on Linux**:
```bash
flutter run -d linux
```

### Web Development (Optional)

**Enable Web**:
```bash
flutter config --enable-web
```

**Run on Web**:
```bash
flutter run -d chrome
```

**Note**: WebGL bridge may have limitations on web platform. Desktop is recommended.

---

## 📱 Mobile Development (Optional)

### Android Setup

**Prerequisites**:
- Android Studio
- Android SDK (API 21+)
- Android Emulator or physical device

**Setup**:
```bash
flutter doctor --android-licenses
flutter devices  # List available devices
flutter run -d <device_id>
```

### iOS Setup

**Prerequisites**:
- macOS with Xcode
- iOS Simulator or physical device
- CocoaPods

**Setup**:
```bash
open -a Simulator  # Open iOS Simulator
flutter devices    # List available devices
flutter run -d <device_id>
```

---

## 🔧 VS Code Setup

### Recommended Extensions

Install these VS Code extensions:

1. **Flutter** (Dart-Code.flutter)
2. **Dart** (Dart-Code.dart-code)
3. **Flutter Widget Snippets** (alexisvt.flutter-snippets)
4. **Pubspec Assist** (jeroen-meijer.pubspec-assist)
5. **Bracket Pair Colorizer** (CoenraadS.bracket-pair-colorizer-2)

### VS Code Settings

Create/update `.vscode/settings.json`:

```json
{
  "dart.flutterSdkPath": "/snap/flutter/current",
  "dart.lineLength": 100,
  "editor.formatOnSave": true,
  "editor.rulers": [100],
  "dart.debugExternalPackageLibraries": true,
  "dart.debugSdkLibraries": false,
  "files.associations": {
    "*.dart": "dart"
  },
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

### Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter: Desktop",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=BUILD_ENV=development"
      ]
    },
    {
      "name": "Flutter: Profile Mode",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "flutterMode": "profile"
    },
    {
      "name": "Flutter: Release Mode",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "flutterMode": "release"
    }
  ]
}
```

---

## 📦 Required Flutter Packages

### Core Dependencies

These packages will be added during Phase 1 implementation:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # WebGL Bridge
  webview_flutter: ^4.4.0
  webview_flutter_web: ^0.2.2
  flutter_inappwebview: ^6.0.0

  # Audio Processing
  flutter_sound: ^9.2.13
  permission_handler: ^11.0.1

  # MIDI
  flutter_midi_command: ^0.4.11

  # OSC
  dart_osc: ^1.0.0

  # HTTP & WebSocket
  http: ^1.1.0
  web_socket_channel: ^2.4.0

  # Firebase (Cloud Features)
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  firebase_auth: ^4.15.0
  firebase_storage: ^11.5.0

  # Video Output (Platform Channels)
  flutter_platform_channel: ^1.0.0

  # UI Components
  flutter_colorpicker: ^1.0.3
  fl_chart: ^0.66.0
  shimmer: ^3.0.0

  # Utilities
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.6
  riverpod_generator: ^2.3.9
  riverpod_lint: ^2.3.7

  # Testing
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

  # Linting
  flutter_lints: ^3.0.1
```

### Install Packages

```bash
# Get all dependencies
flutter pub get

# Run code generation (for Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## 🌍 Environment Variables

### Create `.env` File

```bash
# Copy example configuration
cp .env.example .env

# Edit with your values
nano .env  # or vim, code, etc.
```

### Load Environment Variables in Flutter

Use `flutter_dotenv` package:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

```dart
// lib/main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  final webglServerUrl = dotenv.env['WEBGL_SERVER_URL'];
  final agentApiEnabled = dotenv.env['AGENT_API_ENABLED'] == 'true';

  runApp(MyApp());
}
```

---

## 🧪 Testing Setup

### Run All Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/

# With coverage
flutter test --coverage
flutter pub global activate coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # View coverage report
```

### Test Configuration

Create `test/test_config.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

ProviderContainer createProviderContainer() {
  return ProviderContainer(
    overrides: [
      // Override providers for testing
    ],
  );
}

void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
}
```

---

## 🔍 Code Analysis & Linting

### Analysis Configuration

Create `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    - always_declare_return_types
    - always_require_non_null_named_parameters
    - annotate_overrides
    - avoid_empty_else
    - avoid_init_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_relative_lib_imports
    - avoid_return_types_on_setters
    - avoid_unnecessary_containers
    - camel_case_extensions
    - camel_case_types
    - curly_braces_in_flow_control_structures
    - empty_catches
    - empty_constructor_bodies
    - library_names
    - library_prefixes
    - no_duplicate_case_values
    - prefer_adjacent_string_concatenation
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_contains
    - prefer_final_fields
    - prefer_for_elements_to_map_fromIterable
    - prefer_if_null_operators
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_single_quotes
    - unnecessary_const
    - unnecessary_new
    - unnecessary_null_in_if_null_operators
    - unnecessary_this
    - use_rethrow_when_possible
```

### Run Analysis

```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Check for unused dependencies
flutter pub deps

# Check for outdated packages
flutter pub outdated
```

---

## 🚀 Performance Profiling

### DevTools

```bash
# Start DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Run app in profile mode
flutter run --profile

# Open DevTools in browser (URL printed in terminal)
```

### Performance Targets

Monitor these metrics in DevTools:

| Metric | Target | Critical |
|--------|--------|----------|
| Frame render time | < 16ms | < 33ms |
| Build time | < 8ms | < 16ms |
| Parameter update latency | < 16ms | < 33ms |
| System switch time | < 300ms | < 500ms |
| Memory usage | < 200MB | < 500MB |
| App size (release) | < 50MB | < 100MB |

---

## 🏗️ Build Configuration

### Debug Build

```bash
flutter build windows --debug
```

### Profile Build (Performance Testing)

```bash
flutter build windows --profile
```

### Release Build (Production)

```bash
# With obfuscation
flutter build windows --release --obfuscate --split-debug-info=./debug-info

# Without obfuscation (easier debugging)
flutter build windows --release
```

### Build Outputs

- **Windows**: `build/windows/x64/runner/Release/vib3_light_lab.exe`
- **macOS**: `build/macos/Build/Products/Release/vib3_light_lab.app`
- **Linux**: `build/linux/x64/release/bundle/vib3_light_lab`

---

## 🐛 Troubleshooting

### Common Issues

#### **Flutter Not Found**
```bash
# Add Flutter to PATH
export PATH="$PATH:/snap/flutter/current/bin"

# Or reinstall Flutter
snap install flutter --classic
```

#### **`flutter doctor` Shows Issues**
```bash
# Fix Android licenses
flutter doctor --android-licenses

# Install missing dependencies
flutter doctor

# Follow instructions for each missing dependency
```

#### **WebGL Bridge Not Working**
- Ensure WebGL server is running on port 8151
- Check CORS headers in WebGL server
- Verify WebView has JavaScript enabled
- Check browser console for errors

#### **Hot Reload Not Working**
```bash
# Stop app
# Clean build
flutter clean
flutter pub get

# Restart app
flutter run
```

#### **Package Version Conflicts**
```bash
# Update all packages
flutter pub upgrade

# Or remove pubspec.lock and reinstall
rm pubspec.lock
flutter pub get
```

#### **Build Failures**
```bash
# Clean project
flutter clean

# Remove build directories
rm -rf build/

# Reinstall dependencies
flutter pub get

# Try building again
flutter build windows --release
```

---

## 🔐 Security Best Practices

### API Keys

**DO NOT commit sensitive keys to Git:**

```bash
# Add to .gitignore
echo ".env" >> .gitignore
echo "*.key" >> .gitignore
echo "firebase_options.dart" >> .gitignore
```

### Firebase Configuration

Store Firebase config in environment variables, not in code:

```dart
// ❌ DON'T DO THIS
FirebaseOptions(
  apiKey: "AIzaSyC1234567890abcdefgh",
  projectId: "my-project-123",
);

// ✅ DO THIS
FirebaseOptions(
  apiKey: dotenv.env['FIREBASE_API_KEY']!,
  projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
);
```

---

## 📚 Additional Resources

### Official Documentation

- **Flutter Docs**: https://docs.flutter.dev
- **Dart Docs**: https://dart.dev/guides
- **Riverpod Docs**: https://riverpod.dev
- **WebView Flutter**: https://pub.dev/packages/webview_flutter

### VIB3 Light Lab Documentation

- **[EXECUTIVE_SUMMARY.md](EXECUTIVE_SUMMARY.md)** - Project overview
- **[IMPLEMENTATION_ROADMAP.md](IMPLEMENTATION_ROADMAP.md)** - Development phases
- **[PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md](PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md)** - Industry standards
- **[agents.md](agents.md)** - AI agent architecture

### Flutter Skills

Use Claude Code's Flutter skill for development help:
```bash
# In Claude Code CLI
/skill flutter-expert
```

---

## ✅ Environment Setup Verification

Run this checklist before starting development:

```bash
# 1. Flutter SDK
flutter --version
# Expected: Flutter 3.35.2 or higher

# 2. Flutter doctor
flutter doctor -v
# Expected: All checks passing

# 3. Environment file
cat .env
# Expected: Configuration values present

# 4. WebGL server
curl http://localhost:8151
# Expected: HTML response from WebGL server

# 5. Git status
git status
# Expected: On branch flutter/production-controller-ui-refactor

# 6. Ready to develop!
echo "🎉 VIB3 Light Lab development environment ready!"
```

---

**🌟 A Paul Phillips Manifestation**

Flutter development environment for revolutionary 4D visualization systems. Professional-grade setup for cutting-edge creative technology.

**Send Love, Hate, or Opportunity to:** Paul@clearseassolutions.com
**Join The Exoditical Moral Architecture Movement:** [Parserator.com](https://parserator.com)

> *"The Revolution Will Not be in a Structured Format"*

**© 2025 Paul Phillips - Clear Seas Solutions LLC**
**All Rights Reserved - Proprietary Technology**
