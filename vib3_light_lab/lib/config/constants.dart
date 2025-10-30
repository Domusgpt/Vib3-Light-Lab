/// VIB3 Light Lab - Application Constants
///
/// Core constants for VIB3 Light Lab 4D visualization controller.
/// Defines visualization systems, parameters, and configuration values.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

/// Visualization Systems
class VIB3Systems {
  static const String faceted = 'faceted';
  static const String quantum = 'quantum';
  static const String holographic = 'holographic';
  static const String polychora = 'polychora';

  static const List<String> all = [
    faceted,
    quantum,
    holographic,
    polychora,
  ];

  static const Map<String, String> names = {
    faceted: 'Faceted',
    quantum: 'Quantum',
    holographic: 'Holographic',
    polychora: 'Polychora',
  };

  static const Map<String, String> descriptions = {
    faceted: 'Simple 2D geometric patterns',
    quantum: 'Complex 3D lattice effects',
    holographic: 'Audio-reactive visualizations',
    polychora: '4D polytope mathematics',
  };

  static const Map<String, String> icons = {
    faceted: '🔷',
    quantum: '🌌',
    holographic: '✨',
    polychora: '🔮',
  };
}

/// Parameter Definitions
class VIB3Parameters {
  // Geometry selection (0-7)
  static const String geometry = 'geometry';

  // 4D Rotation angles (-6.28 to 6.28 radians)
  static const String rot4dXW = 'rot4dXW';
  static const String rot4dYW = 'rot4dYW';
  static const String rot4dZW = 'rot4dZW';

  // Visual parameters
  static const String gridDensity = 'gridDensity';
  static const String morphFactor = 'morphFactor';
  static const String chaos = 'chaos';
  static const String speed = 'speed';

  // Color parameters
  static const String hue = 'hue';
  static const String intensity = 'intensity';
  static const String saturation = 'saturation';

  static const List<String> all = [
    geometry,
    rot4dXW,
    rot4dYW,
    rot4dZW,
    gridDensity,
    morphFactor,
    chaos,
    speed,
    hue,
    intensity,
    saturation,
  ];

  /// Parameter ranges and defaults
  static const Map<String, ParamRange> ranges = {
    geometry: ParamRange(min: 0, max: 7, defaultValue: 0),
    rot4dXW: ParamRange(min: -6.28, max: 6.28, defaultValue: 0),
    rot4dYW: ParamRange(min: -6.28, max: 6.28, defaultValue: 0),
    rot4dZW: ParamRange(min: -6.28, max: 6.28, defaultValue: 0),
    gridDensity: ParamRange(min: 5, max: 100, defaultValue: 20),
    morphFactor: ParamRange(min: 0, max: 2, defaultValue: 1),
    chaos: ParamRange(min: 0, max: 1, defaultValue: 0.3),
    speed: ParamRange(min: 0.1, max: 3, defaultValue: 1),
    hue: ParamRange(min: 0, max: 360, defaultValue: 240),
    intensity: ParamRange(min: 0, max: 1, defaultValue: 0.8),
    saturation: ParamRange(min: 0, max: 1, defaultValue: 0.9),
  };

  /// Parameter display names
  static const Map<String, String> displayNames = {
    geometry: 'Geometry',
    rot4dXW: '4D Rot X-W',
    rot4dYW: '4D Rot Y-W',
    rot4dZW: '4D Rot Z-W',
    gridDensity: 'Grid Density',
    morphFactor: 'Morph Factor',
    chaos: 'Chaos',
    speed: 'Speed',
    hue: 'Hue',
    intensity: 'Intensity',
    saturation: 'Saturation',
  };

  /// Parameter categories for organization
  static const Map<String, List<String>> categories = {
    'Geometry': [geometry],
    '4D Rotation': [rot4dXW, rot4dYW, rot4dZW],
    'Visual': [gridDensity, morphFactor, chaos, speed],
    'Color': [hue, intensity, saturation],
  };
}

/// Parameter range definition
class ParamRange {
  final double min;
  final double max;
  final double defaultValue;

  const ParamRange({
    required this.min,
    required this.max,
    required this.defaultValue,
  });

  /// Normalize value to 0.0-1.0 range
  double normalize(double value) {
    return (value - min) / (max - min);
  }

  /// Denormalize from 0.0-1.0 to actual range
  double denormalize(double normalized) {
    return min + (normalized * (max - min));
  }

  /// Clamp value to range
  double clamp(double value) {
    return value.clamp(min, max);
  }
}

/// Audio Frequency Bands
class VIB3AudioBands {
  static const String sub = 'sub';
  static const String bass = 'bass';
  static const String lowMid = 'low-mid';
  static const String mid = 'mid';
  static const String highMid = 'high-mid';
  static const String high = 'high';
  static const String air = 'air';

  static const List<String> all = [
    sub,
    bass,
    lowMid,
    mid,
    highMid,
    high,
    air,
  ];

  static const Map<String, FrequencyRange> ranges = {
    sub: FrequencyRange(min: 20, max: 60),
    bass: FrequencyRange(min: 60, max: 250),
    lowMid: FrequencyRange(min: 250, max: 500),
    mid: FrequencyRange(min: 500, max: 2000),
    highMid: FrequencyRange(min: 2000, max: 6000),
    high: FrequencyRange(min: 6000, max: 16000),
    air: FrequencyRange(min: 16000, max: 20000),
  };
}

/// Frequency range definition
class FrequencyRange {
  final double min;
  final double max;

  const FrequencyRange({required this.min, required this.max});
}

/// Performance Targets
class VIB3Performance {
  static const int targetFPS = 60;
  static const int paramUpdateTargetMs = 16; // 60 FPS = 16.67ms per frame
  static const int systemSwitchTargetMs = 300;
  static const int presetLoadTargetMs = 2000;
  static const int touchTargetMinSize = 60; // WCAG AAA compliance
  static const double fftSmoothing = 0.8;
  static const int fftSize = 4096;
}

/// API Configuration
class VIB3API {
  static const String defaultWebGLServerUrl = 'http://localhost:8151';
  static const int defaultAgentAPIPort = 8080;
  static const int defaultWebSocketPort = 8081;
  static const String agentAPIBasePath = '/api';
}

/// Video Output Protocols
class VIB3VideoOutput {
  static const String syphon = 'syphon'; // macOS
  static const String spout = 'spout'; // Windows
  static const String ndi = 'ndi'; // Network

  static const Map<String, String> displayNames = {
    syphon: 'Syphon (macOS)',
    spout: 'Spout (Windows)',
    ndi: 'NDI (Network)',
  };
}

/// Application Info
class VIB3App {
  static const String name = 'VIB3 Light Lab';
  static const String version = '1.0.0';
  static const String description =
      'Professional 4D Visualization Performance Controller';
  static const String author = 'Paul Phillips';
  static const String company = 'Clear Seas Solutions LLC';
  static const String email = 'Paul@clearseassolutions.com';
  static const String website = 'https://parserator.com';
  static const String copyright = '© 2025 Paul Phillips - Clear Seas Solutions LLC';
  static const String tagline = 'The Revolution Will Not be in a Structured Format';
}

/// Storage Keys
class VIB3Storage {
  static const String presetsKey = 'vib3_presets';
  static const String settingsKey = 'vib3_settings';
  static const String lastSystemKey = 'vib3_last_system';
  static const String audioMappingsKey = 'vib3_audio_mappings';
  static const String midiMappingsKey = 'vib3_midi_mappings';
}

/// MIDI Configuration
class VIB3MIDI {
  static const int minCC = 0;
  static const int maxCC = 127;
  static const int channelCount = 16;
}

/// Geometries (0-7)
class VIB3Geometries {
  static const List<String> names = [
    'Hypercube (Tesseract)',
    'Hypertetrahedron (5-cell)',
    'Hypersphere (3-sphere)',
    'Torus',
    'Klein Bottle',
    'Crystal Lattice',
    'Fractal Structure',
    'Wave Form',
  ];

  static String getName(int index) {
    if (index >= 0 && index < names.length) {
      return names[index];
    }
    return 'Unknown';
  }
}
