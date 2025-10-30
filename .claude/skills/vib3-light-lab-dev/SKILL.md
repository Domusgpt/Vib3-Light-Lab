---
name: VIB3 Light Lab Development
description: Specialized development skill for VIB3 Light Lab - Flutter-based live performance controller for 4D WebGL visualization systems with audio reactivity, MIDI/OSC integration, and professional VJ workflows.
---

# VIB3 Light Lab Development Skill

## Overview

VIB3 Light Lab is a **Flutter-based live performance controller** for 4D WebGL visualization engines. This skill provides comprehensive guidance for building a professional-grade visual performance instrument with modular UI, haptic control, and industry-standard protocol integration (OSC, MIDI, Syphon/Spout, NDI).

**Project Type**: Flutter + WebGL2 hybrid application
**Target Platforms**: Desktop (Windows, macOS, Linux) + Mobile companion apps
**Architecture**: Flutter UI ↔ WebGL Bridge ↔ WebGL2 Visualization Engines
**Use Cases**: Live VJ performances, projection mapping, creative coding, visual art

## Core Project Documentation

This skill references comprehensive analysis and planning documents:

### 📊 Analysis Documents

**[VIB3_LIGHT_LAB_UI_ARCHITECTURE_ANALYSIS.md](../../VIB3_LIGHT_LAB_UI_ARCHITECTURE_ANALYSIS.md)** (18KB)
- Current UI architecture deep dive
- Framework comparison: Flutter 8.5/10 vs React 7/10
- Discovered 400KB unused PerformanceSuite code
- Critical UI limitations requiring Flutter's modular widget system
- **Key Finding**: Fixed 300px panel unsuitable for live performance

**[SYSTEM_TEST_RESULTS.md](../../SYSTEM_TEST_RESULTS.md)** (22KB)
- Comprehensive testing methodology
- 2 critical bugs documented (toggle state sync, gallery saves)
- Quality gates for production readiness
- Performance metrics and success criteria
- Week 1 stabilization priorities

**[IMPLEMENTATION_ROADMAP.md](../../IMPLEMENTATION_ROADMAP.md)** (41KB)
- **Complete Flutter implementation with Riverpod**
- WebGL Bridge architecture for Flutter ↔ WebGL2 communication
- Widget library specifications
- State management patterns
- 20-week implementation timeline
- Full code examples for all components

**[PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md](../../PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md)** (65KB)
- Industry research: Resolume, TouchDesigner, lighting consoles
- 8 essential UI elements for live performance controllers
- Complete SDK/plugin architecture
- Protocol handlers: OSC, MIDI, DMX, ArtNet
- Video output standards: Syphon (macOS), Spout (Windows), NDI (network)
- Audio reactivity engine with FFT and 7-band frequency analysis
- Beat detection algorithms (kick, snare, hi-hat)
- Vaporwave holographic design system rules
- Agent-friendly async architecture

**[EXECUTIVE_SUMMARY.md](../../EXECUTIVE_SUMMARY.md)** (31KB)
- Concise overview of all findings
- Clear Flutter recommendation for haptic control
- Three strategic paths with timelines
- Immediate next steps guide

## VIB3-Specific Architecture

### 4 Visualization Systems

VIB3 Light Lab controls 4 distinct WebGL2 visualization engines:

1. **🔷 FACETED** - Simple 2D geometric patterns
2. **🌌 QUANTUM** - Complex 3D lattice effects
3. **✨ HOLOGRAPHIC** - Audio-reactive pink/magenta visualizations
4. **🔮 POLYCHORA** - 4D polytope mathematics with projection

Each system shares 11 universal parameters:
- `geometry` (0-7): 8 different polytope types
- `rot4dXW`, `rot4dYW`, `rot4dZW`: 4D rotation angles (-6.28 to 6.28)
- `gridDensity` (5-100): Detail/complexity level
- `morphFactor` (0-2): Shape transformation
- `chaos` (0-1): Randomization factor
- `speed` (0.1-3): Animation speed
- `hue` (0-360): Color hue
- `intensity` (0-1): Brightness
- `saturation` (0-1): Color saturation

### Flutter ↔ WebGL Bridge Architecture

**Critical Component**: The bridge enables Flutter to control WebGL2 rendering

```dart
// lib/bridges/webgl_bridge.dart
class WebGLBridge {
  final WebViewController _webViewController;
  final StreamController<EngineState> _stateController;

  // Send commands to WebGL
  Future<void> switchSystem(String system) async {
    await _webViewController.runJavascriptReturningResult(
      'window.switchSystem("$system")'
    );
  }

  Future<void> updateParameter(String name, double value) async {
    await _webViewController.runJavascriptReturningResult(
      'window.updateParameter("$name", $value)'
    );
  }

  // Receive events from WebGL
  void setupBridge() {
    _webViewController.addJavaScriptChannel(
      'FlutterBridge',
      onMessageReceived: (message) {
        final event = jsonDecode(message.message);
        _handleWebGLEvent(event);
      },
    );
  }
}
```

**Reference**: See IMPLEMENTATION_ROADMAP.md section "Phase 3: WebGL Bridge" for complete implementation

### State Management with Riverpod

**Why Riverpod**: Type-safe, compile-time checked, excellent for complex parameter systems

```dart
// lib/providers/engine_provider.dart
final engineProvider = StateNotifierProvider<EngineNotifier, EngineState>((ref) {
  return EngineNotifier(ref.read(webglBridgeProvider));
});

class EngineState {
  final String currentSystem;
  final Map<String, double> parameters;
  final bool audioEnabled;
  final bool interactivityEnabled;

  // Immutable state pattern
  EngineState copyWith({
    String? currentSystem,
    Map<String, double>? parameters,
    bool? audioEnabled,
  }) {
    return EngineState(
      currentSystem: currentSystem ?? this.currentSystem,
      parameters: parameters ?? this.parameters,
      audioEnabled: audioEnabled ?? this.audioEnabled,
    );
  }
}
```

**Reference**: See IMPLEMENTATION_ROADMAP.md "Phase 4: Parameter System"

## Professional Performance Features

### 8 Essential UI Elements

Based on industry standards (Resolume, TouchDesigner, ETC Eos):

1. **Layer Management System**
   - Multiple visualization layers with blend modes
   - Opacity control, solo/mute per layer
   - Drag-to-reorder layers

2. **Preset/Scene Management**
   - Quick-save current state (< 1 second)
   - Instant recall (< 2 seconds)
   - Crossfade between presets
   - Organization in banks/folders

3. **BPM Sync & Timeline**
   - Manual tap tempo
   - Auto beat detection from audio
   - Time-based automation curves

4. **Audio Reactivity Control**
   - 7 frequency bands (sub, bass, low-mid, mid, high-mid, high, air)
   - Envelope followers (RMS, peak, LUFS)
   - Beat detection (kick, snare, hi-hat)
   - FFT visualization
   - Per-parameter audio mapping

5. **Effect Routing & Modulation**
   - LFOs (sine, square, saw, random)
   - Envelope generators (ADSR)
   - Parameter → parameter modulation

6. **Multi-Output Management**
   - Syphon server (macOS)
   - Spout server (Windows)
   - NDI streaming (network)
   - Multiple display outputs

7. **Macro/Gesture Recorder**
   - Record multi-parameter gestures
   - Playback with speed control
   - Loop/trigger modes

8. **Hardware I/O Panel**
   - MIDI controller mapping (learn mode)
   - OSC endpoint configuration
   - DMX output for lighting sync

**Reference**: See PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md "8 Essential UI Elements"

### Vaporwave Holographic Design System

**Color Palette**:
```dart
class VIB3Colors {
  static const cyan = Color(0xFF00FFFF);
  static const magenta = Color(0xFFFF00FF);
  static const purple = Color(0xFF9D00FF);
  static const pink = Color(0xFFFF0099);
  static const deepPurple = Color(0xFF2D033B);
  static const darkNavy = Color(0xFF0A0E27);
}
```

**Typography**:
```dart
class VIB3TextStyles {
  static const heading = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    shadows: [
      Shadow(color: Color(0xFFFF00FF), blurRadius: 10),
    ],
  );
}
```

**Glassmorphic Containers**:
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0x22FF00FF),
        Color(0x1100FFFF),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0x44FF00FF), width: 2),
    boxShadow: [
      BoxShadow(
        color: Color(0x44FF00FF),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  ),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: child,
  ),
)
```

**Reference**: See PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md "Vaporwave Holographic Design System"

## Audio Reactivity Integration

### FFT Analysis Pipeline

```dart
// lib/audio/fft_analyzer.dart
class FFTAnalyzer {
  static const int fftSize = 4096;
  static const double smoothing = 0.8;

  final List<FrequencyBand> bands = [
    FrequencyBand(name: 'sub', min: 20, max: 60),
    FrequencyBand(name: 'bass', min: 60, max: 250),
    FrequencyBand(name: 'low-mid', min: 250, max: 500),
    FrequencyBand(name: 'mid', min: 500, max: 2000),
    FrequencyBand(name: 'high-mid', min: 2000, max: 6000),
    FrequencyBand(name: 'high', min: 6000, max: 16000),
    FrequencyBand(name: 'air', min: 16000, max: 20000),
  ];

  Stream<Map<String, double>> analyzeMicrophone() async* {
    // FFT analysis implementation
    // Returns normalized values (0.0-1.0) for each band
  }
}
```

### Beat Detection

```dart
// lib/audio/beat_detector.dart
class BeatDetector {
  double kickThreshold = 0.6;
  double snareThreshold = 0.5;
  double hihatThreshold = 0.4;

  Stream<BeatEvent> detectBeats(Stream<Map<String, double>> fftStream) async* {
    // Energy-based beat detection
    // Analyzes sub (kick), mid (snare), high (hi-hat)
  }
}
```

**Reference**: See PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md "Audio Reactivity Engine"

## SDK/Plugin Architecture

### For Integration with Host Software

VIB3 Light Lab can operate as both:
1. **Standalone application** (desktop + mobile)
2. **Plugin/SDK** for other VJ software (Resolume, TouchDesigner, etc.)

```dart
// lib/sdk/vib3_sdk.dart
class VIB3SDK {
  // Initialize VIB3 engines
  Future<void> initialize() async { }

  // Parameter control
  void setParameter(String name, double value) { }
  Map<String, double> getParameters() { }

  // System control
  void switchSystem(String system) { }

  // Video output
  VideoFrame captureFrame() { }

  // OSC/MIDI input
  void sendOSCMessage(String address, List<dynamic> args) { }
  void sendMIDICC(int controller, int value) { }
}
```

**Video Output Plugins**:
- **Syphon** (macOS): GPU-accelerated texture sharing
- **Spout** (Windows): DirectX texture sharing
- **NDI**: Network video streaming

**Reference**: See PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md "SDK Architecture"

## Development Workflow

### Phase-by-Phase Implementation

**Phase 1: Flutter Project Setup** (Week 1)
```bash
flutter create vib3_light_lab --org com.clearseassolutions
cd vib3_light_lab
flutter pub add flutter_riverpod webview_flutter
```

**Phase 2: Core Widget Library** (Weeks 2-3)
- VIB3Button, VIB3Slider, VIB3Panel
- Glassmorphic containers
- Holographic text effects

**Phase 3: WebGL Bridge** (Week 4)
- Bidirectional JavaScript bridge
- State synchronization
- Event handling

**Phase 4: Parameter System** (Weeks 5-6)
- 11 universal parameters
- Parameter groups and organization
- Preset save/load

**Phase 5: Audio Reactivity** (Weeks 7-9)
- FFT analysis with flutter_sound
- Beat detection
- Audio → parameter mapping UI

**Phase 6: Hardware I/O** (Weeks 10-13)
- MIDI with flutter_midi_command
- OSC with dart_osc
- Controller mapping interface

**Phase 7: Advanced Features** (Weeks 14-20)
- Multi-output video (Syphon/Spout/NDI)
- Gesture recorder
- Show planner
- Cloud preset library

**Reference**: See IMPLEMENTATION_ROADMAP.md for complete timeline with code examples

## Common Development Patterns

### Parameter Update Pattern

```dart
// UI widget updates parameter
ref.read(engineProvider.notifier).updateParameter('hue', 180.0);

// Provider updates state and notifies bridge
class EngineNotifier extends StateNotifier<EngineState> {
  final WebGLBridge bridge;

  void updateParameter(String name, double value) {
    state = state.copyWith(
      parameters: {...state.parameters, name: value},
    );
    bridge.updateParameter(name, value); // Send to WebGL
  }
}

// WebGL receives update via bridge
window.updateParameter = function(name, value) {
  const engine = engines[window.currentSystem];
  engine.setParameter(name, value);
};
```

### System Switch Pattern

```dart
// User clicks system button
ref.read(engineProvider.notifier).switchSystem('quantum');

// Provider orchestrates switch
void switchSystem(String system) async {
  state = state.copyWith(currentSystem: system);
  await bridge.switchSystem(system);
  // Re-apply all current parameters to new system
  for (var entry in state.parameters.entries) {
    await bridge.updateParameter(entry.key, entry.value);
  }
}
```

### Audio Mapping Pattern

```dart
// User maps audio band to parameter
ref.read(audioMappingProvider.notifier).mapBandToParameter(
  band: 'bass',
  parameter: 'intensity',
  min: 0.3,
  max: 1.0,
);

// Audio stream updates parameters
audioStream.listen((bands) {
  final mappings = ref.read(audioMappingProvider);
  for (var mapping in mappings) {
    final audioValue = bands[mapping.band]!;
    final paramValue = mapping.min + (audioValue * (mapping.max - mapping.min));
    ref.read(engineProvider.notifier).updateParameter(
      mapping.parameter,
      paramValue,
    );
  }
});
```

## Critical Bug Fixes (Week 1)

Before starting Flutter development, fix 2 critical bugs in existing WebGL codebase:

### Bug #1: Toggle State Synchronization
**File**: `index.html` lines 1895-1921 (toggleAudio)
**Problem**: UI buttons show incorrect state after system switch
**Fix Duration**: 4 hours

### Bug #2: Gallery Save Failures
**File**: `src/core/UnifiedSaveManager.js`
**Problem**: Inconsistent parameter capture across 4 systems
**Fix Duration**: 4 hours

**Reference**: See SYSTEM_TEST_RESULTS.md "Critical Issues"

## Testing Strategy

### Unit Tests
```dart
test('parameter update triggers WebGL bridge', () async {
  final bridge = MockWebGLBridge();
  final notifier = EngineNotifier(bridge);

  notifier.updateParameter('hue', 240.0);

  verify(bridge.updateParameter('hue', 240.0)).called(1);
  expect(notifier.state.parameters['hue'], 240.0);
});
```

### Widget Tests
```dart
testWidgets('slider updates parameter', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: VIB3Slider(parameter: 'intensity'),
    ),
  );

  await tester.drag(find.byType(Slider), Offset(100, 0));
  await tester.pumpAndSettle();

  // Verify parameter value updated
});
```

### Integration Tests
```dart
testWidgets('system switch preserves parameters', (tester) async {
  // Set parameters in faceted system
  // Switch to quantum system
  // Verify parameters applied correctly
});
```

## Performance Targets

- **Parameter Update Latency**: < 16ms (60 FPS)
- **System Switch Time**: < 300ms
- **Preset Load Time**: < 2 seconds
- **Audio FFT Analysis**: 60 FPS (16.67ms per frame)
- **Touch Target Size**: 60-80px (WCAG AAA)
- **App Bundle Size**: < 50MB

**Reference**: See SYSTEM_TEST_RESULTS.md "Success Metrics"

## Agent-Friendly Architecture

Design for AI agent control and future platform integration:

### REST API
```dart
// Expose HTTP endpoints for agent control
@Get('/api/parameter/:name')
Future<Response> getParameter(String name) async { }

@Post('/api/parameter/:name')
Future<Response> setParameter(String name, double value) async { }

@Post('/api/sequence')
Future<Response> executeSequence(List<Command> commands) async { }
```

### WebSocket for Real-Time Control
```dart
// Bidirectional communication for live agent control
websocket.stream.listen((message) {
  final command = Command.fromJson(message);
  commandQueue.add(command);
});
```

### Event-Driven Architecture
```dart
// Agents can subscribe to telemetry events
eventBus.on<ParameterChangedEvent>().listen((event) {
  telemetryService.log(event);
});
```

**Reference**: See PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md "Agent Architecture"

## Integration with Other Skills

This skill works alongside:

- **flutter-expert**: Core Flutter development patterns, Firebase, deployment
- **visual-codex-styles**: Holographic visual effects and shader systems
- **github-scanner**: Repository analysis and activity tracking

## When to Use This Skill

Invoke this skill for VIB3 Light Lab development:

- ✅ Flutter UI development with WebGL integration
- ✅ Parameter system and state management
- ✅ Audio reactivity implementation
- ✅ MIDI/OSC hardware integration
- ✅ Video output (Syphon/Spout/NDI)
- ✅ Preset management and gallery system
- ✅ Vaporwave holographic design system
- ✅ SDK/plugin architecture
- ✅ Agent-friendly API design
- ✅ Performance optimization for live use

## Quick Command Reference

```bash
# Start local WebGL server
python3 -m http.server 8151

# Create Flutter app
flutter create vib3_light_lab --org com.clearseassolutions

# Run Flutter app
flutter run -d windows  # or macos, linux

# Install dependencies
flutter pub add flutter_riverpod webview_flutter flutter_sound dart_osc

# Run tests
flutter test

# Build release
flutter build windows --release
flutter build macos --release
```

## Documentation Checklist

When working on VIB3 Light Lab, always reference:

- [ ] VIB3_LIGHT_LAB_UI_ARCHITECTURE_ANALYSIS.md - Current system analysis
- [ ] SYSTEM_TEST_RESULTS.md - Known bugs and quality gates
- [ ] IMPLEMENTATION_ROADMAP.md - Phase-by-phase plan with code examples
- [ ] PROFESSIONAL_PRODUCTION_PLATFORM_DESIGN.md - Industry standards and protocols
- [ ] EXECUTIVE_SUMMARY.md - Quick reference and decision framework

---

**🌟 A Paul Phillips Manifestation**

VIB3 Light Lab - Professional 4D visualization performance controller built with Flutter, WebGL2, and revolutionary exoditical design thinking.

**Send Love, Hate, or Opportunity to:** Paul@clearseassolutions.com
**Join The Exoditical Moral Architecture Movement:** [Parserator.com](https://parserator.com)

> *"The Revolution Will Not be in a Structured Format"*

**© 2025 Paul Phillips - Clear Seas Solutions LLC**
**All Rights Reserved - Proprietary Technology**
