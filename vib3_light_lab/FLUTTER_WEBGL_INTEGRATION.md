# Flutter ↔ VIB34D/MVEP WebGL Integration Guide

**Integration Strategy**: Flutter UI controls VIB34D/MVEP visualization engines via WebGL bridge

---

## 🎯 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter UI Layer                         │
│  (Riverpod State, Vaporwave Design, Touch Controls)         │
└──────────────────────┬──────────────────────────────────────┘
                       │ WebGL Bridge (InAppWebView)
                       │ JavaScript Channels
                       ↓
┌─────────────────────────────────────────────────────────────┐
│              VIB34D System Architecture                     │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  VIB3HomeMaster (Parameter Authority)                │  │
│  │  - Single source of truth                            │  │
│  │  - Cross-visualizer sync                             │  │
│  │  - Parameter validation                              │  │
│  └──────────────────────────────────────────────────────┘  │
│                       ↕                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  VIB3SystemController (Orchestrator)                 │  │
│  │  - Module coordination                               │  │
│  │  - Event routing                                     │  │
│  │  - Performance monitoring                            │  │
│  └──────────────────────────────────────────────────────┘  │
│                       ↕                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  VisualizerPool (Multi-Instance Management)          │  │
│  │  - Dynamic creation/destruction                      │  │
│  │  - WebGL context pooling                             │  │
│  │  - Parameter propagation                             │  │
│  └──────────────────────────────────────────────────────┘  │
│                       ↕                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  InteractionCoordinator (Input Mapping)              │  │
│  │  - Mouse, touch, keyboard handlers                   │  │
│  │  - Gesture recognition                               │  │
│  │  - Event throttling                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                       ↕                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  PresetDatabase (Configuration)                      │  │
│  │  - Store/load presets                                │  │
│  │  - Category organization                             │  │
│  │  - Real-time switching                               │  │
│  └──────────────────────────────────────────────────────┘  │
│                       ↕                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  GeometryRegistry (4D Shape Generators)              │  │
│  │  - 8 geometries: Hypercube, Tetrahedron, etc.       │  │
│  │  - Mathematical generators                           │  │
│  │  - Morphing between shapes                           │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│              MVEP Kernel (Optional Layer)                   │
│  - Data-driven visualization encoding                       │
│  - Dynamic shader generation                                │
│  - N-dimensional rotation matrices                          │
└─────────────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│              WebGL Shader Layer                             │
│  - 4D rotation matrices (6 planes: XY, XZ, XW, YZ, YW, ZW) │
│  - Quaternion transformations                               │
│  - Moiré patterns & interference                            │
│  - RGB splitting / chromatic aberration                     │
│  - 4D to 3D perspective projection                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔌 Bridge Integration Points

### 1. Flutter → VIB34D Communication

**Flutter sends commands via WebGL bridge:**

```dart
// lib/bridges/webgl_bridge.dart

// Switch visualization system
await webglBridge.switchSystem('quantum');
// Calls: window.vib34d.switchVisualizerType('quantum')

// Update parameter
await webglBridge.updateParameter('rot4dXW', 1.57);
// Calls: window.vib34d.homeMaster.updateParameter('rot4dXW', 1.57)

// Batch update (performance-optimized)
await webglBridge.updateParameters({
  'rot4dXW': 1.57,
  'rot4dYW': 0.78,
  'gridDensity': 50,
});
// Calls: window.vib34d.homeMaster.updateParameters({...})

// Load preset
await webglBridge.loadPreset('hypercube-focus');
// Calls: window.vib34d.presetDatabase.loadPreset('hypercube-focus')
```

### 2. VIB34D → Flutter Events

**VIB34D sends events back to Flutter:**

```javascript
// In VIB34D JavaScript (index-clean.html or similar)

// When parameter changes internally
window.vib34d.homeMaster.on('parameterChanged', (param, value) => {
    window.FlutterBridge.postMessage(JSON.stringify({
        type: 'parameterChanged',
        name: param,
        value: value,
        timestamp: Date.now()
    }));
});

// When system switches
window.vib34d.systemController.on('systemSwitched', (fromSystem, toSystem) => {
    window.FlutterBridge.postMessage(JSON.stringify({
        type: 'systemSwitched',
        from: fromSystem,
        to: toSystem,
        timestamp: Date.now()
    }));
});

// When visualizer initializes
window.vib34d.on('visualizerReady', (visualizerId) => {
    window.FlutterBridge.postMessage(JSON.stringify({
        type: 'engineInitialized',
        system: window.vib34d.currentSystem,
        visualizerId: visualizerId,
        timestamp: Date.now()
    }));
});

// When error occurs
window.vib34d.on('error', (error) => {
    window.FlutterBridge.postMessage(JSON.stringify({
        type: 'error',
        message: error.message,
        stack: error.stack,
        timestamp: Date.now()
    }));
});
```

---

## 🎨 VIB34D Parameter Mapping

### Universal Parameters (11 Total)

**Flutter constants match VIB34D parameter names:**

```dart
// lib/config/constants.dart
class VIB3Parameters {
  static const String geometry = 'geometry';          // 0-7 (8 geometries)
  static const String rot4dXW = 'rot4dXW';            // -6.28 to 6.28
  static const String rot4dYW = 'rot4dYW';            // -6.28 to 6.28
  static const String rot4dZW = 'rot4dZW';            // -6.28 to 6.28
  static const String gridDensity = 'gridDensity';    // 5 to 100
  static const String morphFactor = 'morphFactor';    // 0 to 2
  static const String chaos = 'chaos';                // 0 to 1
  static const String speed = 'speed';                // 0.1 to 3
  static const String hue = 'hue';                    // 0 to 360
  static const String intensity = 'intensity';        // 0 to 1
  static const String saturation = 'saturation';      // 0 to 1
}
```

**VIB34D JavaScript parameter names (MUST MATCH):**

```javascript
// In VIB34D HomeMaster
const parameterDefinitions = {
    geometry: { min: 0, max: 7, default: 0 },
    rot4dXW: { min: -6.28, max: 6.28, default: 0 },
    rot4dYW: { min: -6.28, max: 6.28, default: 0 },
    rot4dZW: { min: -6.28, max: 6.28, default: 0 },
    gridDensity: { min: 5, max: 100, default: 20 },
    morphFactor: { min: 0, max: 2, default: 1 },
    chaos: { min: 0, max: 1, default: 0.3 },
    speed: { min: 0.1, max: 3, default: 1 },
    hue: { min: 0, max: 360, default: 240 },
    intensity: { min: 0, max: 1, default: 0.8 },
    saturation: { min: 0, max: 1, default: 0.9 }
};
```

---

## 🔬 Quaternion Shader Integration

### 4D Rotation Matrices

**VIB34D uses 6-plane rotation system:**

```glsl
// GLSL shader code (in VIB34D WebGL engines)

// 4D rotation matrices for 6 planes
mat4 rotateXY(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat4(
        c, -s, 0, 0,
        s,  c, 0, 0,
        0,  0, 1, 0,
        0,  0, 0, 1
    );
}

mat4 rotateXZ(float angle) { /* ... */ }
mat4 rotateXW(float angle) { /* ... */ }
mat4 rotateYZ(float angle) { /* ... */ }
mat4 rotateYW(float angle) { /* ... */ }
mat4 rotateZW(float angle) { /* ... */ }

// Combine rotations
vec4 rotate4D(vec4 p, float angleXW, float angleYW, float angleZW) {
    p = rotateXW(angleXW) * p;
    p = rotateYW(angleYW) * p;
    p = rotateZW(angleZW) * p;
    return p;
}

// Project 4D to 3D
vec3 project4Dto3D(vec4 p4d) {
    float w = 2.0; // Viewing distance
    float scale = w / (w + p4d.w);
    return p4d.xyz * scale;
}
```

**Flutter parameters control these rotations:**

```dart
// User adjusts slider in Flutter UI
ref.read(engineProvider.notifier).updateParameter('rot4dXW', 1.57);

// ↓ Bridge sends to WebGL
await webglBridge.updateParameter('rot4dXW', 1.57);

// ↓ VIB34D updates shader uniform
gl.uniform1f(shaderProgram.uniforms.rot4dXW, 1.57);

// ↓ Shader applies 4D rotation
vec4 rotated = rotate4D(position4D, rot4dXW, rot4dYW, rot4dZW);
vec3 projected = project4Dto3D(rotated);
```

---

## 🌀 MVEP Kernel Integration

### Data-Driven Visualizations

**MVEP Kernel can be optionally enabled for data-driven encoding:**

```dart
// Flutter side - send data to MVEP
class MVEPService {
  final WebGLBridge bridge;

  Future<void> updateDataVisualization(Map<String, dynamic> data) async {
    // Send data to MVEP kernel
    await bridge.evaluateJavaScript(
      'window.mvepKernel.updateData(${jsonEncode(data)})'
    );

    // MVEP analyzes data and updates parameters automatically
    // Example: data complexity → dimension parameter
    //          data structure → morphing parameter
    //          data variety → color parameter
  }

  Future<void> configureEncoding(MVEPEncodingConfig config) async {
    await bridge.evaluateJavaScript(
      'window.mvepKernel.configure(${jsonEncode(config.toJson())})'
    );
  }
}

// MVEP encoding configuration
class MVEPEncodingConfig {
  final DataPropertyMapping dimension;
  final DataPropertyMapping morphing;
  final DataPropertyMapping color;
  final DataPropertyMapping rotation;
  final DataPropertyMapping density;

  Map<String, dynamic> toJson() {
    return {
      'dimension': dimension.toJson(),
      'morphing': morphing.toJson(),
      'color': color.toJson(),
      'rotation': rotation.toJson(),
      'density': density.toJson(),
    };
  }
}
```

---

## 📊 Preset Database Integration

### Loading VIB34D Presets

**Flutter can load VIB34D presets directly:**

```dart
// Flutter side
class PresetService {
  final WebGLBridge bridge;

  Future<List<Preset>> getAvailablePresets() async {
    final result = await bridge.evaluateJavaScript(
      'window.vib34d.presetDatabase.getAllPresets()'
    );

    return (result as List)
        .map((json) => Preset.fromJson(json))
        .toList();
  }

  Future<void> loadPreset(String presetId) async {
    await bridge.evaluateJavaScript(
      'window.vib34d.presetDatabase.loadPreset("$presetId")'
    );

    // VIB34D automatically updates all parameters
    // Flutter state will sync via parameter change events
  }

  Future<void> savePreset(Preset preset) async {
    await bridge.evaluateJavaScript(
      'window.vib34d.presetDatabase.savePreset(${jsonEncode(preset.toJson())})'
    );
  }
}
```

**VIB34D default presets:**
- `hypercube-focus` - Emphasizes tesseract rotation
- `fractal-dreams` - Chaotic fractal patterns
- `chaos-mode` - Maximum randomization
- `crystal-lattice` - Ordered geometric structures
- `wave-interference` - Moiré pattern emphasis

---

## 🎮 InteractionCoordinator Integration

### Handling User Interactions

**VIB34D InteractionCoordinator can be controlled or overridden:**

```dart
// Option 1: Let VIB34D handle interactions (mouse parallax, etc.)
await bridge.evaluateJavaScript(
  'window.vib34d.interactionCoordinator.enable()'
);

// Option 2: Flutter handles interactions, sends to VIB34D
class FlutterInteractionHandler {
  final WebGLBridge bridge;

  void onPanUpdate(DragUpdateDetails details) {
    // Convert Flutter gesture to parameter changes
    final deltaX = details.delta.dx / 100;
    final deltaY = details.delta.dy / 100;

    bridge.updateParameters({
      'rot4dXW': currentRotXW + deltaX,
      'rot4dYW': currentRotYW + deltaY,
    });
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    // Convert pinch gesture to zoom/density
    bridge.updateParameter(
      'gridDensity',
      currentDensity * details.scale,
    );
  }

  void onDoubleTap() {
    // Trigger randomization
    bridge.evaluateJavaScript('window.randomizeAll()');
  }
}
```

---

## 🚀 Performance Optimization

### Batching Parameter Updates

**Always batch multiple parameter updates:**

```dart
// ❌ BAD: Multiple individual updates
await bridge.updateParameter('rot4dXW', 1.57);
await bridge.updateParameter('rot4dYW', 0.78);
await bridge.updateParameter('hue', 240);

// ✅ GOOD: Single batched update
await bridge.updateParameters({
  'rot4dXW': 1.57,
  'rot4dYW': 0.78,
  'hue': 240,
});
```

### Throttling UI Updates

```dart
// Throttle slider updates to 60 FPS (16ms)
Timer? _throttleTimer;

void onSliderChanged(String param, double value) {
  _throttleTimer?.cancel();
  _throttleTimer = Timer(Duration(milliseconds: 16), () {
    ref.read(engineProvider.notifier).updateParameter(param, value);
  });
}
```

### WebGL Context Management

```dart
// VisualizerPool manages WebGL contexts automatically
// Flutter should not create/destroy contexts directly

// Request number of visualizer instances
await bridge.evaluateJavaScript(
  'window.vib34d.visualizerPool.setInstanceCount(3)'
);
```

---

## 🔍 Debugging & Monitoring

### Enable VIB34D Debug Mode

```dart
// Enable debug logging in VIB34D
await bridge.evaluateJavaScript(
  'window.vib34d.systemController.enableDebugMode(true)'
);

// Listen for debug events
bridge.eventStream.listen((event) {
  if (event.type == 'debug') {
    debugPrint('[VIB34D Debug] ${event.data['message']}');
  }
});
```

### Performance Monitoring

```dart
// Get VIB34D performance metrics
class PerformanceMonitor {
  Future<PerformanceMetrics> getMetrics() async {
    final result = await bridge.evaluateJavaScript(
      'window.vib34d.systemController.getPerformanceMetrics()'
    );

    return PerformanceMetrics(
      fps: result['fps'],
      frameTime: result['frameTime'],
      parameterUpdateLatency: result['parameterUpdateLatency'],
      visualizerCount: result['visualizerCount'],
    );
  }
}
```

---

## 📝 Required JavaScript Additions

### Add Flutter Bridge Handler to VIB34D

**In your VIB34D HTML file (index-clean.html or similar):**

```javascript
// Add after VIB34D initialization

// Create Flutter Bridge communication
if (window.FlutterBridge) {
    // Listen for parameter changes
    window.vib34d.homeMaster.on('parameterChanged', (param, value) => {
        window.FlutterBridge.postMessage(JSON.stringify({
            type: 'parameterChanged',
            name: param,
            value: value,
            timestamp: Date.now()
        }));
    });

    // Listen for system switches
    window.vib34d.systemController.on('systemSwitched', (from, to) => {
        window.FlutterBridge.postMessage(JSON.stringify({
            type: 'systemSwitched',
            from: from,
            to: to,
            timestamp: Date.now()
        }));
    });

    // Expose functions for Flutter to call
    window.vib34dFlutterAPI = {
        switchSystem: (system) => window.vib34d.switchVisualizerType(system),
        updateParameter: (name, value) => window.vib34d.homeMaster.updateParameter(name, value),
        updateParameters: (params) => window.vib34d.homeMaster.updateParameters(params),
        loadPreset: (id) => window.vib34d.presetDatabase.loadPreset(id),
        randomizeAll: () => window.randomizeAll(),
        resetAll: () => window.resetAll(),
        getCurrentState: () => ({
            currentSystem: window.currentSystem,
            parameters: window.vib34d.homeMaster.getAllParameters(),
            isInitialized: true
        })
    };
}
```

---

## ✅ Integration Checklist

### Setup Phase
- [x] Flutter project created with WebView dependencies
- [x] WebGL bridge implemented with bidirectional communication
- [ ] VIB34D HTML file updated with Flutter bridge handlers
- [ ] Parameter names synchronized between Flutter and VIB34D
- [ ] Event handlers connected (parameterChanged, systemSwitched, etc.)

### Testing Phase
- [ ] Test parameter updates (single and batched)
- [ ] Test system switching (faceted, quantum, holographic, polychora)
- [ ] Test preset loading from VIB34D PresetDatabase
- [ ] Test 4D rotation with quaternion shaders
- [ ] Test Flutter → VIB34D → Flutter state synchronization
- [ ] Test performance (target: <16ms parameter update latency)

### Performance Phase
- [ ] Enable parameter batching (updateParameters)
- [ ] Add UI update throttling (16ms / 60 FPS)
- [ ] Monitor WebGL context usage (VisualizerPool)
- [ ] Profile frame times and shader performance
- [ ] Test on mobile devices (adaptive quality)

### Production Phase
- [ ] Add error handling and recovery
- [ ] Implement preset cloud sync (Firebase)
- [ ] Add analytics and telemetry
- [ ] Test MVEP kernel integration (if using data-driven viz)
- [ ] Comprehensive testing across all 4 systems + 8 geometries

---

## 🎯 Next Steps

1. **Update VIB34D HTML** - Add Flutter bridge handlers to existing WebGL code
2. **Test Basic Communication** - Verify Flutter can send commands to VIB34D
3. **Test State Sync** - Verify VIB34D events reach Flutter
4. **Build Riverpod Providers** - Create EngineProvider that uses WebGLBridge
5. **Create UI Widgets** - Parameter sliders, system buttons, preset selector
6. **Test Full Flow** - User interaction → Flutter → Bridge → VIB34D → Shader update
7. **Optimize Performance** - Batch updates, throttle UI, monitor FPS
8. **Add MVEP Support** - Optional data-driven visualization layer

---

**🌟 A Paul Phillips Manifestation**

Flutter integration with VIB34D quaternion shader systems and MVEP kernel. Professional bridge architecture for 4D visualization control.

**Contact**: Paul@clearseassolutions.com
**Join The Movement**: [Parserator.com](https://parserator.com)

> *"The Revolution Will Not be in a Structured Format"*

**© 2025 Paul Phillips - Clear Seas Solutions LLC**
