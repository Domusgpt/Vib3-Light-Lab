# VIB34D VJ Control Suite

**Professional Flutter-based VJ control interface for VIB34D holographic visualizers**

A comprehensive, adaptive, panel-based VJ control system inspired by industry-leading software like Resolume Arena, VDMX, and TouchDesigner.

---

## 🎯 Overview

The VIB34D VJ Control Suite is a complete reimagining of the VIB34D control interface, built from the ground up in Flutter to provide a professional, customizable, and intuitive VJ experience. The system replaces the previous fixed 3-column layout with an adaptive panel-based architecture that gives VJs complete control over their workspace.

### Key Features

- **🎨 Adaptive Panel System**: Resizable, draggable, collapsible, and dockable panels
- **🎹 Multi-Touch XY Pads**: Professional Kaoss Pad-style controllers with visual feedback
- **📊 Workspace Presets**: 4 default layouts (Performance, Setup, Minimal, DJ) + custom workspaces
- **🎛️ Central Parameter Bank**: Organized repository of all VIB34D parameters
- **✨ Effect Chain System**: Drag-and-drop effects with per-layer routing
- **🎵 Audio Reactivity**: Built-in audio analyzer and parameter mapping
- **🎮 MIDI/OSC Support**: Hardware controller integration with learn mode
- **💾 State Management**: Save/load complete workspace configurations
- **📱 Cross-Platform**: Works on mobile, tablet, and desktop

---

## 🏗️ Architecture

### Core Components

```
flutter_vj_control/
├── lib/
│   ├── core/                      # Core systems
│   │   ├── workspace_manager.dart # Central state management
│   │   ├── parameter_bank.dart    # Parameter organization
│   │   └── effect_library.dart    # Effect categorization
│   ├── models/                    # Data models
│   │   ├── panel_config.dart      # Panel state
│   │   ├── workspace.dart         # Workspace layouts
│   │   └── pad_config.dart        # XY pad configuration
│   ├── panels/                    # Panel implementations
│   │   ├── visualizer_panel.dart  # Main output display
│   │   ├── pad_matrix_panel.dart  # XY pad grid
│   │   ├── parameter_inspector_panel.dart
│   │   └── layer_mixer_panel.dart
│   ├── widgets/                   # Reusable widgets
│   │   ├── resizable_panel.dart   # Panel container
│   │   ├── xy_pad.dart            # Multi-touch controller
│   │   └── parameter_slider.dart  # Smart slider
│   └── main.dart                  # App entry point
```

### State Management

The system uses **Provider** for state management with a central `WorkspaceManager` that handles:

- **Workspace State**: Panel positions, sizes, visibility
- **Parameter Values**: All 11 VIB34D parameters
- **Effect Chains**: Per-system effect routing
- **System Selection**: Active visualizer system
- **Mode Switching**: Performance vs. Setup mode

---

## 🎛️ Panel System

### 10 Panel Types

1. **Visualizer Panel** - Main output display with WebView integration
2. **Control Pad Matrix** - Grid of multi-touch XY pads
3. **Effect Bank** - Categorized effect library
4. **Parameter Inspector** - Active parameter controls
5. **Layer Mixer** - System compositing and blending
6. **Timeline** - Automation and cues
7. **Media Browser** - Preset library
8. **Audio Analyzer** - Waveform and spectrum
9. **Hardware Bridge** - MIDI/OSC configuration
10. **Telemetry** - Performance monitoring

Each panel is:
- ✅ **Resizable**: Drag corners/edges
- ✅ **Repositionable**: Drag header to move
- ✅ **Collapsible**: Minimize to title bar
- ✅ **Pop-out Ready**: Separate window support
- ✅ **Dockable**: Snap to edges/other panels

---

## 🎹 XY Pad System

### Multi-Touch Controllers

The XY Pad is the core performance control:

**Features:**
- Up to 3 simultaneous touch points
- X, Y, and Spread axes (pinch/spread gestures)
- Each axis maps to any VIB34D parameter
- Visual feedback: touch points, trails, center indicator
- Real-time value overlays
- Smoothing and inversion per axis

**Pad Sizes:**
- Small: 150×150
- Medium: 250×250 (default)
- Large: 400×400
- Extra Large: 600×600
- Custom: User-defined

**Grid Layouts:**
- 1×1: Single full-screen pad
- 2×1: Two pads side-by-side
- 2×2: Four-pad grid
- 3×2: Six-pad grid

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- VIB34D visualizer server running on `localhost:8080`

### Installation

```bash
# Navigate to directory
cd flutter_vj_control

# Install dependencies
flutter pub get

# Run on desktop
flutter run -d macos
# or
flutter run -d windows
# or
flutter run -d linux

# Run on mobile
flutter run -d android
# or
flutter run -d ios
```

### Building

```bash
# Web
flutter build web

# Android
flutter build apk --release

# iOS
flutter build ios --release

# Desktop
flutter build macos
flutter build windows
flutter build linux
```

---

## 🎯 Usage Guide

### Performance Mode

1. **Launch App**: Opens in Performance workspace by default
2. **Select System**: Click system buttons (🔷🌌✨🔮) in visualizer
3. **Control Parameters**: Use XY pads or parameter sliders
4. **Mix Layers**: Adjust opacity and blend modes in Layer Mixer
5. **Randomize**: Hit shuffle button for instant variation
6. **Save State**: Export workspace configuration

### Setup Mode

1. **Toggle Mode**: Click "Setup" button in menu bar
2. **Configure Pads**: Map X/Y/Spread axes to parameters
3. **Build Effect Chains**: Drag effects from Effect Bank
4. **MIDI Learn**: Click parameter → move MIDI controller
5. **Save Workspace**: Create custom layout preset
6. **Toggle Back**: Return to Performance mode

### Creating Custom Workspaces

1. Arrange panels by dragging headers
2. Resize panels by dragging corners/edges
3. Configure pad mappings
4. Build effect chains
5. Click workspace dropdown → "Save As Custom"
6. Name and save your layout

---

## 🔧 Configuration

### Local Development

Ensure the VIB34D visualizer is running:

```bash
# In the main VIB34D directory
python3 -m http.server 8080
# or
npx serve -p 8080
```

The Visualizer Panel will load from `http://localhost:8080/index-clean.html`.

### Production Deployment

For production, configure the WebView URL in `visualizer_panel.dart`:

```dart
..loadRequest(Uri.parse('https://your-domain.com/visualizer'));
```

---

## 📊 Parameter System

### 11 Core Parameters

| Parameter | Range | Default | Unit | Category |
|-----------|-------|---------|------|----------|
| `geometry` | 0-7 | 0 | - | Geometry |
| `rot4dXW` | -6.28 to 6.28 | 0 | rad | Rotation 4D |
| `rot4dYW` | -6.28 to 6.28 | 0 | rad | Rotation 4D |
| `rot4dZW` | -6.28 to 6.28 | 0 | rad | Rotation 4D |
| `gridDensity` | 5-100 | 15 | - | Structure |
| `morphFactor` | 0-2 | 1 | - | Structure |
| `chaos` | 0-1 | 0.2 | - | Structure |
| `speed` | 0.1-3 | 1 | x | Dynamics |
| `hue` | 0-360 | 200 | ° | Color |
| `saturation` | 0-1 | 0.8 | - | Color |
| `intensity` | 0-1 | 0.5 | - | Color |

**Categories:**
- 🔷 **4D Rotation**: Hyperspace rotation controls
- 📐 **Structure**: Grid, morph, chaos
- 🎨 **Color**: Hue, saturation, intensity
- ⚡ **Dynamics**: Speed control
- 🔮 **Geometry**: 8 shape types

---

## 🐛 Troubleshooting

### WebView Not Loading

- Ensure visualizer server is running on port 8080
- Check network permissions in `AndroidManifest.xml` and `Info.plist`
- Verify CORS settings if using external server

### Touch Not Working

- Enable multi-touch in device settings
- Check touch event permissions
- Verify gesture detector hierarchy

### Parameters Not Syncing

- Check JavaScript bridge initialization
- Verify parameter IDs match between Flutter and JS
- Check console for JavaScript errors

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| 🖥️ macOS | ✅ Fully Supported | Recommended for performance |
| 🪟 Windows | ✅ Fully Supported | |
| 🐧 Linux | ✅ Fully Supported | |
| 🤖 Android | ✅ Supported | Tablet recommended |
| 🍎 iOS | ✅ Supported | iPad recommended |
| 🌐 Web | ⚠️ Partial | WebView limitations |

---

## 🤝 Contributing

This is a professional VJ control system built for the VIB34D project. Contributions welcome for:

- New panel types
- Additional effects
- Performance optimizations
- Bug fixes
- Documentation improvements

---

## 📄 License

Part of the VIB34D Holographic Engine project.

---

## 🙏 Credits

**Architecture Inspired By:**
- Resolume Arena (modular panel system)
- VDMX (flexible routing)
- TouchDesigner (visual feedback)
- CoGe VJ (performance focus)

**Built With:**
- Flutter & Dart
- WebView integration
- Provider state management
- Custom multi-touch controllers

---

## 📞 Support

For issues, questions, or feature requests, consult the main VIB34D documentation.

**System Requirements:**
- Flutter 3.0+
- 4GB RAM minimum (8GB recommended)
- OpenGL 3.0+ compatible GPU
- Multi-touch display (recommended)

---

*Built for VJs, by VJs. Maximum performance, infinite creativity.* ✨🔮🌌
