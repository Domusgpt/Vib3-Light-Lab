---
name: vib3-light-lab-dev
description: Develops VIB3 Light Lab Flutter app controlling 4D WebGL visualizations with VIB34D quaternion shaders and MVEP kernel. Use for Flutter+Riverpod+WebGL development, VIB34D/MVEP integration, 4D rotation parameters (rot4dXW/YW/ZW), audio reactivity FFT, MIDI/OSC protocols, Syphon/Spout/NDI video output, vaporwave holographic UI, live performance controllers, VJ software features, or when user mentions VIB3, VIB34D, MVEP, quaternion shaders, 4D visualization, or live visual performance.
---

# VIB3 Light Lab Development

Flutter app controlling 4D WebGL visualizations (VIB34D/MVEP systems) for live VJ performances.

**Stack**: Flutter + Riverpod + InAppWebView + VIB34D quaternion shaders
**Architecture**: Flutter UI ↔ WebGL Bridge ↔ VIB34D ↔ GLSL Shaders

## Quick Reference

### 11 Universal Parameters

All parameter names MUST match between Flutter and VIB34D JavaScript exactly:

```dart
geometry       // 0-7 (8 4D shapes)
rot4dXW        // -6.28 to 6.28 (4D rotation X-W plane)
rot4dYW        // -6.28 to 6.28 (4D rotation Y-W plane)
rot4dZW        // -6.28 to 6.28 (4D rotation Z-W plane)
gridDensity    // 5-100
morphFactor    // 0-2
chaos          // 0-1
speed          // 0.1-3
hue            // 0-360
intensity      // 0-1
saturation     // 0-1
```

### 4 Visualization Systems

- `faceted` - 2D geometric patterns
- `quantum` - 3D lattice effects
- `holographic` - Audio-reactive
- `polychora` - 4D polytope math

### 8 Geometries (geometry: 0-7)

Hypercube, Hypertetrahedron, Hypersphere, Torus, Klein Bottle, Crystal, Fractal, Wave

### VIB34D Integration Points

**Parameter sync required**: Flutter const names = VIB34D JavaScript property names

**Bridge communication pattern**:
```dart
// Flutter → VIB34D
await bridge.updateParameters({'rot4dXW': 1.57, 'hue': 240});

// VIB34D → Flutter (add to HTML)
window.FlutterBridge.postMessage(JSON.stringify({
  type: 'parameterChanged',
  name: 'rot4dXW',
  value: 1.57
}));
```

**Required JavaScript additions to VIB34D HTML**:
See [docs/WEBGL_INTEGRATION.md](docs/WEBGL_INTEGRATION.md) section "Required JavaScript Additions"

### Quaternion Shader Pipeline

Flutter slider → Bridge → VIB34D uniform → GLSL shader:

```glsl
// In shader: 4D rotation applied
vec4 rotated = rotate4D(position, rot4dXW, rot4dYW, rot4dZW);
vec3 projected = project4Dto3D(rotated);
```

**6-plane rotation system**: XY, XZ, XW, YZ, YW, ZW

### Vaporwave Design System

**Colors** (`lib/config/theme.dart`):
```dart
cyan: 0xFF00FFFF, magenta: 0xFFFF00FF, purple: 0xFF9D00FF,
pink: 0xFFFF0099, deepPurple: 0xFF2D033B, darkNavy: 0xFF0A0E27
```

**Glassmorphic containers**:
- Gradient: `[Color(0x22FF00FF), Color(0x1100FFFF)]`
- Border: `Color(0x44FF00FF), width: 2`
- Shadow: `blurRadius: 20, spreadRadius: 2`

**Typography**: Orbitron font with glow effects (shadow blur: 6-10)

### Performance Targets

- Parameter update: < 16ms (60 FPS)
- System switch: < 300ms
- Preset load: < 2 seconds
- Touch targets: 60-80px (WCAG AAA)

### Critical Patterns

**Batch parameter updates** (performance-critical):
```dart
// ✅ Single WebGL call
await bridge.updateParameters({'rot4dXW': 1.57, 'rot4dYW': 0.78});

// ❌ Multiple calls (slower)
await bridge.updateParameter('rot4dXW', 1.57);
await bridge.updateParameter('rot4dYW', 0.78);
```

**Throttle UI updates** (16ms = 60 FPS):
```dart
Timer? _throttle;
void onSliderChanged(String param, double value) {
  _throttle?.cancel();
  _throttle = Timer(Duration(milliseconds: 16), () {
    ref.read(engineProvider.notifier).updateParameter(param, value);
  });
}
```

**Immutable state** (always use copyWith):
```dart
state = state.copyWith(
  parameters: {...state.parameters, 'hue': 240},
);
```

## File Locations

```
vib3_light_lab/lib/
├── bridges/webgl_bridge.dart       # Flutter ↔ WebGL communication
├── config/
│   ├── constants.dart              # VIB3Parameters, VIB3Systems
│   └── theme.dart                  # VIB3Colors, glassmorphic styles
├── models/engine_state.dart        # Immutable EngineState, Preset
├── providers/                      # Riverpod providers (pending)
├── services/{audio,midi}/          # FFT, MIDI (pending)
└── widgets/{controls,displays,panels}/  # UI components (pending)
```

## Audio Reactivity

**7 frequency bands**: sub (20-60Hz), bass (60-250Hz), low-mid (250-500Hz), mid (500-2000Hz), high-mid (2000-6000Hz), high (6000-16000Hz), air (16000-20000Hz)

**FFT config**: size: 4096, smoothing: 0.8, target: 60 FPS

## Development Workflow

**Phase 1-2 complete**: Flutter project, WebGL bridge, models, config
**Phase 3 (current)**: Riverpod providers integrating WebGLBridge
**Phase 4-5 (pending)**: UI widgets, audio/MIDI services

## Comprehensive Documentation

All detailed implementation guides in `docs/`:

- **[UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md)** - Architecture analysis, framework comparison
- **[IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md)** - 20-week plan, complete code examples
- **[PRODUCTION_DESIGN.md](docs/PRODUCTION_DESIGN.md)** - Industry standards, SDK architecture
- **[WEBGL_INTEGRATION.md](docs/WEBGL_INTEGRATION.md)** - VIB34D/MVEP integration, quaternion shaders
- **[SYSTEM_TEST_RESULTS.md](docs/SYSTEM_TEST_RESULTS.md)** - Bugs, quality gates, testing

**Flutter setup**: See `FLUTTER_SETUP.md` in project root

## Dependencies

State: `flutter_riverpod`, WebGL: `flutter_inappwebview`, Audio: `flutter_sound`, MIDI: `flutter_midi_command`, UI: `flutter_colorpicker`, `fl_chart`

## Common Tasks

**Create parameter slider**:
```dart
class VIB3Slider extends ConsumerWidget {
  final String parameter;
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(engineProvider).parameters[parameter] ?? 0.0;
    final range = VIB3Parameters.ranges[parameter]!;
    return Slider(
      value: value, min: range.min, max: range.max,
      onChanged: (v) => ref.read(engineProvider.notifier)
        .updateParameter(parameter, v),
    );
  }
}
```

**System switch button**:
```dart
ElevatedButton(
  onPressed: () => ref.read(engineProvider.notifier).switchSystem('quantum'),
  child: Text(VIB3Systems.names['quantum']!),
)
```

## VIB34D Presets

Available: `hypercube-focus`, `fractal-dreams`, `chaos-mode`, `crystal-lattice`, `wave-interference`

Load via: `await bridge.evaluateJavaScript('window.vib34d.presetDatabase.loadPreset("hypercube-focus")')`

## MVEP Kernel (Optional)

Data-driven visualization layer. Maps data properties → parameters:
- complexity → dimension
- structure → morphFactor
- variety → hue
- changeRate → rotation
- detail → gridDensity

See WEBGL_INTEGRATION.md "MVEP Kernel Integration" for configuration.

---

**© 2025 Paul Phillips - Clear Seas Solutions LLC**
