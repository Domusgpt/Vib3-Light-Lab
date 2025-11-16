# VIB34D VJ Control Suite 🎨✨

A professional Flutter-based VJ (Video Jockey) control interface for the VIB34D holographic visualization engine. Built for live performance with real-time parameter control, audio reactivity, and customizable layouts.

![VJ Control Demo](assets/demo.png)

## Features 🚀

### 🎛️ **Professional Control Deck**
- **11 Real-time Parameters**: Full control over all visualizer parameters
- **4D Rotation Controls**: X↔W, Y↔W, Z↔W plane rotations
- **Structure Controls**: Grid density, morph factor, chaos
- **Color Controls**: Hue, intensity, saturation
- **Dynamics**: Speed control for animation
- **Quick Actions**: Randomize, Reset, and All Random functions

### 🎵 **Audio Reactivity System**
- **3×3 Sensitivity Matrix**: Low/Medium/High × Color/Geometry/Movement
- **Visual Mode Selection**:
  - **Color Mode**: Affects hue, saturation, intensity
  - **Geometry Mode**: Affects morph, density, chaos
  - **Movement Mode**: Affects speed and 4D rotations
- **Quick Audio Presets**: Pre-configured audio reactivity settings

### 💾 **Preset Management**
- **Save/Load System States**: Complete parameter configurations
- **Preset Library**: Organize and search presets
- **Default Presets Included**:
  - Cyan Dreams (Faceted)
  - Purple Quantum (Quantum)
  - Pink Hologram (Holographic)
  - 4D Tesseract (Polychora)
- **Edit & Delete**: Full preset management
- **System Filtering**: Filter presets by visualizer system

### 🎨 **Four Visualizer Systems**
1. **🔷 Faceted**: Simple 2D patterns with 4D rotations
2. **🌌 Quantum**: Complex 3D lattice effects
3. **✨ Holographic**: Audio-reactive holographic visualization
4. **🔮 Polychora**: 4D polytope mathematics

### 📱 **Responsive Design**
- **Landscape Mode**: Split-screen with visualizer + controls
- **Portrait Mode**: Stacked layout optimized for tablets/phones
- **Collapsible Panels**: Smart space management
- **Fullscreen Mode**: Immersive performance mode

### 🎮 **Interactivity Controls**
- **Mouse Reactive**: Mouse tracking for visualizer
- **Device Tilt**: Gyroscope-based 4D perspective
- **Audio Reactive**: Real-time audio input processing
- **Enhanced FX**: Additional visual effects
- **Accent Twin**: Complementary visualization layer

## Architecture 🏗️

```
flutter_vj_control/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   ├── parameter_model.dart     # 11 parameter system
│   │   ├── preset_model.dart        # Preset data structure
│   │   └── visualizer_state.dart    # Global state management
│   ├── widgets/
│   │   ├── collapsible_panel.dart   # Smart collapsible sections
│   │   ├── parameter_slider.dart    # VJ-style parameter control
│   │   ├── audio_grid.dart          # 3×3 audio reactivity grid
│   │   ├── preset_card.dart         # Preset library cards
│   │   └── visualizer_view.dart     # WebView integration
│   ├── screens/
│   │   ├── control_panel.dart       # Main VJ controls
│   │   ├── audio_panel.dart         # Audio reactivity
│   │   └── preset_panel.dart        # Preset library
│   ├── services/
│   │   └── preset_manager.dart      # Preset storage service
│   └── theme/
│       └── vj_theme.dart            # Cyberpunk dark theme
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## Installation 💻

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / Xcode (for mobile deployment)
- VIB34D engine running (http://localhost:8080)

### Setup

1. **Clone the repository**:
   ```bash
   cd Vib3-Light-Lab/flutter_vj_control
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

4. **Build for production**:
   ```bash
   # Android
   flutter build apk --release

   # iOS
   flutter build ios --release

   # Web
   flutter build web --release
   ```

## Configuration ⚙️

### Base URL Configuration
By default, the app connects to `http://localhost:8080` for the visualizer. To change this:

1. Open `lib/widgets/visualizer_view.dart`
2. Modify the `baseUrl` parameter:
   ```dart
   VisualizerView(
     state: state,
     baseUrl: 'http://your-server:port', // Change this
   )
   ```

### WebView Integration
The app uses WebView to display the VIB34D visualizer from `viewer.html`. Communication happens via JavaScript bridges:

**From Flutter to JavaScript**:
```dart
updateParameter('hue', 240.0)
switchSystem(VisualizerSystem.quantum)
toggleInteractivity('audio', true)
```

**From JavaScript to Flutter**:
```javascript
FlutterBridge.postMessage('audioData', data)
```

## Usage 🎯

### Basic VJ Workflow

1. **Select Visualizer System**
   - Tap one of the four system buttons (🔷🌌✨🔮)

2. **Adjust Parameters**
   - Use sliders in the Control Panel
   - Values update in real-time

3. **Enable Audio Reactivity**
   - Toggle "Audio Reactive" in Control Panel
   - Select sensitivity and modes in Audio Panel

4. **Save Your Look**
   - Tap "Save Current State" in Preset Panel
   - Name and describe your preset

5. **Quick Randomization**
   - "Randomize": Random parameters (keeps hue & geometry)
   - "All Random": Randomizes everything
   - "Reset": Return to defaults

### Keyboard Shortcuts
- **F**: Toggle fullscreen mode

### Advanced Features

#### Collapsible Panels
All control sections are collapsible to maximize screen space. Tap panel headers to expand/collapse.

#### System Filtering
In the Preset Panel, filter presets by visualizer system using the chips at the top.

#### Audio Reactivity Matrix
The 3×3 grid allows combining different sensitivity levels with visual modes:
- **Low + Color**: Subtle color shifts
- **Medium + Geometry**: Moderate shape changes
- **High + Movement**: Intense motion

## Customization 🎨

### Theme Customization
Edit `lib/theme/vj_theme.dart` to customize colors:

```dart
colorScheme: const ColorScheme.dark(
  primary: Color(0xFF00FFFF),    // Cyan - change this
  secondary: Color(0xFFFF00FF),  // Magenta - change this
  tertiary: Color(0xFFFFAA00),   // Orange - change this
  // ... more colors
),
```

### Adding New Presets
Default presets are defined in `lib/services/preset_manager.dart`. Add more in the `_getDefaultPresets()` method.

### Layout Customization
Modify `lib/main.dart` to adjust the split ratios:

```dart
// Landscape layout ratio (visualizer:controls)
Expanded(flex: 7, child: VisualizerView(...)),  // 70% visualizer
Expanded(flex: 3, child: Controls()),           // 30% controls
```

## Performance Optimization 🚄

### Mobile Performance
- Limit parameter update frequency
- Use `CompactParameterSlider` for space-constrained layouts
- Enable hardware acceleration in WebView

### Memory Management
- Presets are stored using SharedPreferences (lightweight)
- WebView maintains single instance
- State updates use Provider for efficient reactivity

## Dependencies 📦

Key dependencies:
- **provider**: State management
- **webview_flutter**: Visualizer integration
- **shared_preferences**: Preset storage
- **flutter_sound**: Audio input (optional)
- **flutter_midi_command**: MIDI integration (optional)
- **osc**: OSC protocol support (optional)

See `pubspec.yaml` for complete list.

## Troubleshooting 🔧

### WebView Not Loading
- Ensure VIB34D engine is running at the configured URL
- Check network permissions in `AndroidManifest.xml` / `Info.plist`
- Enable JavaScript in WebView settings

### Audio Not Working
- Grant microphone permissions
- Check `flutter_sound` setup
- Verify audio reactive toggle is ON

### Parameters Not Updating
- Check JavaScript bridge communication
- Verify `window.updateParameter` exists in viewer.html
- Check console logs in WebView debugger

## Contributing 🤝

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License 📄

This project is part of the VIB34D system. See main project for license details.

## Credits 👏

- **VIB34D Engine**: Original holographic visualization system
- **Flutter Team**: Amazing cross-platform framework
- **Community**: For feedback and contributions

## Support 💬

For issues, questions, or feature requests:
- Open an issue on GitHub
- Join our Discord community
- Check the main VIB34D documentation

---

**Built with 💜 for the VJ community**

*Live. Create. Visualize.*
