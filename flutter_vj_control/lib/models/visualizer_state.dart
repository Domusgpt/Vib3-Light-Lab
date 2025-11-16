import 'package:flutter/foundation.dart';
import 'parameter_model.dart';
import 'preset_model.dart';

/// Global visualizer state management
class VisualizerState extends ChangeNotifier {
  VisualizerSystem _currentSystem = VisualizerSystem.faceted;
  ParameterModel _parameters = ParameterModel();
  PresetModel? _activePreset;

  // Interactivity states
  bool _mouseReactive = true;
  bool _deviceTilt = true;
  bool _audioReactive = false;
  bool _enhancedFX = true;
  bool _accentTwin = false;

  // Audio reactivity settings
  AudioSensitivity _audioSensitivity = AudioSensitivity.medium;
  Set<AudioVisualMode> _activeAudioModes = {AudioVisualMode.color};

  // Getters
  VisualizerSystem get currentSystem => _currentSystem;
  ParameterModel get parameters => _parameters;
  PresetModel? get activePreset => _activePreset;
  bool get mouseReactive => _mouseReactive;
  bool get deviceTilt => _deviceTilt;
  bool get audioReactive => _audioReactive;
  bool get enhancedFX => _enhancedFX;
  bool get accentTwin => _accentTwin;
  AudioSensitivity get audioSensitivity => _audioSensitivity;
  Set<AudioVisualMode> get activeAudioModes => _activeAudioModes;

  // System switching
  void switchSystem(VisualizerSystem system) {
    _currentSystem = system;
    notifyListeners();
  }

  // Parameter updates
  void updateParameter(String paramName, double value) {
    _parameters.setValue(paramName, value);
    notifyListeners();
  }

  void setParameters(ParameterModel params) {
    _parameters = params;
    notifyListeners();
  }

  void randomizeParameters({bool includeGeometry = false, bool includeHue = false}) {
    _parameters.randomize(
      includeGeometry: includeGeometry,
      includeHue: includeHue,
    );
    notifyListeners();
  }

  void resetParameters() {
    _parameters.reset();
    notifyListeners();
  }

  // Preset management
  void loadPreset(PresetModel preset) {
    _activePreset = preset;
    _currentSystem = preset.system;
    _parameters = ParameterModel.fromJson(preset.parameters.toJson());
    notifyListeners();
  }

  void clearPreset() {
    _activePreset = null;
    notifyListeners();
  }

  // Interactivity toggles
  void toggleMouseReactive() {
    _mouseReactive = !_mouseReactive;
    notifyListeners();
  }

  void toggleDeviceTilt() {
    _deviceTilt = !_deviceTilt;
    notifyListeners();
  }

  void toggleAudioReactive() {
    _audioReactive = !_audioReactive;
    notifyListeners();
  }

  void toggleEnhancedFX() {
    _enhancedFX = !_enhancedFX;
    notifyListeners();
  }

  void toggleAccentTwin() {
    _accentTwin = !_accentTwin;
    notifyListeners();
  }

  // Audio reactivity settings
  void setAudioSensitivity(AudioSensitivity sensitivity) {
    _audioSensitivity = sensitivity;
    notifyListeners();
  }

  void toggleAudioMode(AudioVisualMode mode) {
    if (_activeAudioModes.contains(mode)) {
      _activeAudioModes.remove(mode);
    } else {
      _activeAudioModes.add(mode);
    }
    notifyListeners();
  }

  void setAudioModes(Set<AudioVisualMode> modes) {
    _activeAudioModes = modes;
    notifyListeners();
  }

  // Serialize current state
  Map<String, dynamic> toJson() {
    return {
      'system': _currentSystem.name,
      'parameters': _parameters.toJson(),
      'activePreset': _activePreset?.toJson(),
      'mouseReactive': _mouseReactive,
      'deviceTilt': _deviceTilt,
      'audioReactive': _audioReactive,
      'enhancedFX': _enhancedFX,
      'accentTwin': _accentTwin,
      'audioSensitivity': _audioSensitivity.name,
      'activeAudioModes': _activeAudioModes.map((m) => m.name).toList(),
    };
  }

  // Deserialize state
  void fromJson(Map<String, dynamic> json) {
    _currentSystem = VisualizerSystem.values.firstWhere(
      (s) => s.name == json['system'],
      orElse: () => VisualizerSystem.faceted,
    );
    _parameters = ParameterModel.fromJson(json['parameters'] ?? {});
    if (json['activePreset'] != null) {
      _activePreset = PresetModel.fromJson(json['activePreset']);
    }
    _mouseReactive = json['mouseReactive'] ?? true;
    _deviceTilt = json['deviceTilt'] ?? true;
    _audioReactive = json['audioReactive'] ?? false;
    _enhancedFX = json['enhancedFX'] ?? true;
    _accentTwin = json['accentTwin'] ?? false;
    _audioSensitivity = AudioSensitivity.values.firstWhere(
      (s) => s.name == json['audioSensitivity'],
      orElse: () => AudioSensitivity.medium,
    );
    _activeAudioModes = (json['activeAudioModes'] as List? ?? [])
        .map((name) => AudioVisualMode.values.firstWhere(
              (m) => m.name == name,
              orElse: () => AudioVisualMode.color,
            ))
        .toSet();
    notifyListeners();
  }
}

/// Audio sensitivity levels
enum AudioSensitivity {
  low,
  medium,
  high,
}

extension AudioSensitivityExtension on AudioSensitivity {
  String get displayName {
    switch (this) {
      case AudioSensitivity.low:
        return 'Low';
      case AudioSensitivity.medium:
        return 'Medium';
      case AudioSensitivity.high:
        return 'High';
    }
  }

  double get multiplier {
    switch (this) {
      case AudioSensitivity.low:
        return 0.3;
      case AudioSensitivity.medium:
        return 1.0;
      case AudioSensitivity.high:
        return 2.0;
    }
  }
}

/// Audio visual modes
enum AudioVisualMode {
  color,
  geometry,
  movement,
}

extension AudioVisualModeExtension on AudioVisualMode {
  String get displayName {
    switch (this) {
      case AudioVisualMode.color:
        return 'Color';
      case AudioVisualMode.geometry:
        return 'Geometry';
      case AudioVisualMode.movement:
        return 'Movement';
    }
  }

  List<String> get affectedParameters {
    switch (this) {
      case AudioVisualMode.color:
        return ['hue', 'saturation', 'intensity'];
      case AudioVisualMode.geometry:
        return ['morphFactor', 'gridDensity', 'chaos'];
      case AudioVisualMode.movement:
        return ['speed', 'rot4dXW', 'rot4dYW', 'rot4dZW'];
    }
  }
}
