/// VIB34D Parameter Model
/// Represents all 11 visualizer parameters with validation and serialization
class ParameterModel {
  // 4D Rotation Parameters
  double rot4dXW;
  double rot4dYW;
  double rot4dZW;

  // Structure Parameters
  double gridDensity;
  double morphFactor;
  double chaos;

  // Dynamics Parameters
  double speed;

  // Color Parameters
  double hue;
  double intensity;
  double saturation;

  // Geometry Selection
  int geometry;

  ParameterModel({
    this.rot4dXW = 0.0,
    this.rot4dYW = 0.0,
    this.rot4dZW = 0.0,
    this.gridDensity = 15.0,
    this.morphFactor = 1.0,
    this.chaos = 0.2,
    this.speed = 1.0,
    this.hue = 200.0,
    this.intensity = 0.5,
    this.saturation = 0.8,
    this.geometry = 0,
  });

  /// Parameter definitions with ranges and metadata
  static const Map<String, ParameterDefinition> definitions = {
    'rot4dXW': ParameterDefinition(
      min: -6.28,
      max: 6.28,
      defaultValue: 0.0,
      label: 'Rotation X↔W',
      group: ParameterGroup.rotation,
      unit: 'rad',
    ),
    'rot4dYW': ParameterDefinition(
      min: -6.28,
      max: 6.28,
      defaultValue: 0.0,
      label: 'Rotation Y↔W',
      group: ParameterGroup.rotation,
      unit: 'rad',
    ),
    'rot4dZW': ParameterDefinition(
      min: -6.28,
      max: 6.28,
      defaultValue: 0.0,
      label: 'Rotation Z↔W',
      group: ParameterGroup.rotation,
      unit: 'rad',
    ),
    'gridDensity': ParameterDefinition(
      min: 5.0,
      max: 100.0,
      defaultValue: 15.0,
      label: 'Grid Density',
      group: ParameterGroup.structure,
      unit: '',
    ),
    'morphFactor': ParameterDefinition(
      min: 0.0,
      max: 2.0,
      defaultValue: 1.0,
      label: 'Morph Factor',
      group: ParameterGroup.structure,
      unit: '',
    ),
    'chaos': ParameterDefinition(
      min: 0.0,
      max: 1.0,
      defaultValue: 0.2,
      label: 'Chaos',
      group: ParameterGroup.structure,
      unit: '',
    ),
    'speed': ParameterDefinition(
      min: 0.1,
      max: 3.0,
      defaultValue: 1.0,
      label: 'Speed',
      group: ParameterGroup.dynamics,
      unit: 'x',
    ),
    'hue': ParameterDefinition(
      min: 0.0,
      max: 360.0,
      defaultValue: 200.0,
      label: 'Hue',
      group: ParameterGroup.color,
      unit: '°',
    ),
    'intensity': ParameterDefinition(
      min: 0.0,
      max: 1.0,
      defaultValue: 0.5,
      label: 'Intensity',
      group: ParameterGroup.color,
      unit: '',
    ),
    'saturation': ParameterDefinition(
      min: 0.0,
      max: 1.0,
      defaultValue: 0.8,
      label: 'Saturation',
      group: ParameterGroup.color,
      unit: '',
    ),
  };

  /// Get parameter value by name
  double getValue(String paramName) {
    switch (paramName) {
      case 'rot4dXW': return rot4dXW;
      case 'rot4dYW': return rot4dYW;
      case 'rot4dZW': return rot4dZW;
      case 'gridDensity': return gridDensity;
      case 'morphFactor': return morphFactor;
      case 'chaos': return chaos;
      case 'speed': return speed;
      case 'hue': return hue;
      case 'intensity': return intensity;
      case 'saturation': return saturation;
      default: return 0.0;
    }
  }

  /// Set parameter value by name with validation
  void setValue(String paramName, double value) {
    final def = definitions[paramName];
    if (def != null) {
      value = value.clamp(def.min, def.max);
    }

    switch (paramName) {
      case 'rot4dXW': rot4dXW = value; break;
      case 'rot4dYW': rot4dYW = value; break;
      case 'rot4dZW': rot4dZW = value; break;
      case 'gridDensity': gridDensity = value; break;
      case 'morphFactor': morphFactor = value; break;
      case 'chaos': chaos = value; break;
      case 'speed': speed = value; break;
      case 'hue': hue = value; break;
      case 'intensity': intensity = value; break;
      case 'saturation': saturation = value; break;
    }
  }

  /// Randomize all parameters
  void randomize({bool includeGeometry = false, bool includeHue = false}) {
    rot4dXW = _randomInRange(-6.28, 6.28);
    rot4dYW = _randomInRange(-6.28, 6.28);
    rot4dZW = _randomInRange(-6.28, 6.28);
    gridDensity = _randomInRange(5.0, 100.0);
    morphFactor = _randomInRange(0.0, 2.0);
    chaos = _randomInRange(0.0, 1.0);
    speed = _randomInRange(0.1, 3.0);
    intensity = _randomInRange(0.0, 1.0);
    saturation = _randomInRange(0.0, 1.0);

    if (includeHue) {
      hue = _randomInRange(0.0, 360.0);
    }

    if (includeGeometry) {
      geometry = (_randomInRange(0.0, 8.0)).floor();
    }
  }

  double _randomInRange(double min, double max) {
    return min + (max - min) * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
  }

  /// Reset to defaults
  void reset() {
    rot4dXW = 0.0;
    rot4dYW = 0.0;
    rot4dZW = 0.0;
    gridDensity = 15.0;
    morphFactor = 1.0;
    chaos = 0.2;
    speed = 1.0;
    hue = 200.0;
    intensity = 0.5;
    saturation = 0.8;
    geometry = 0;
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'rot4dXW': rot4dXW,
      'rot4dYW': rot4dYW,
      'rot4dZW': rot4dZW,
      'gridDensity': gridDensity,
      'morphFactor': morphFactor,
      'chaos': chaos,
      'speed': speed,
      'hue': hue,
      'intensity': intensity,
      'saturation': saturation,
      'geometry': geometry,
    };
  }

  /// Deserialize from JSON
  factory ParameterModel.fromJson(Map<String, dynamic> json) {
    return ParameterModel(
      rot4dXW: (json['rot4dXW'] ?? 0.0).toDouble(),
      rot4dYW: (json['rot4dYW'] ?? 0.0).toDouble(),
      rot4dZW: (json['rot4dZW'] ?? 0.0).toDouble(),
      gridDensity: (json['gridDensity'] ?? 15.0).toDouble(),
      morphFactor: (json['morphFactor'] ?? 1.0).toDouble(),
      chaos: (json['chaos'] ?? 0.2).toDouble(),
      speed: (json['speed'] ?? 1.0).toDouble(),
      hue: (json['hue'] ?? 200.0).toDouble(),
      intensity: (json['intensity'] ?? 0.5).toDouble(),
      saturation: (json['saturation'] ?? 0.8).toDouble(),
      geometry: json['geometry'] ?? 0,
    );
  }

  /// Copy with modifications
  ParameterModel copyWith({
    double? rot4dXW,
    double? rot4dYW,
    double? rot4dZW,
    double? gridDensity,
    double? morphFactor,
    double? chaos,
    double? speed,
    double? hue,
    double? intensity,
    double? saturation,
    int? geometry,
  }) {
    return ParameterModel(
      rot4dXW: rot4dXW ?? this.rot4dXW,
      rot4dYW: rot4dYW ?? this.rot4dYW,
      rot4dZW: rot4dZW ?? this.rot4dZW,
      gridDensity: gridDensity ?? this.gridDensity,
      morphFactor: morphFactor ?? this.morphFactor,
      chaos: chaos ?? this.chaos,
      speed: speed ?? this.speed,
      hue: hue ?? this.hue,
      intensity: intensity ?? this.intensity,
      saturation: saturation ?? this.saturation,
      geometry: geometry ?? this.geometry,
    );
  }
}

/// Parameter definition metadata
class ParameterDefinition {
  final double min;
  final double max;
  final double defaultValue;
  final String label;
  final ParameterGroup group;
  final String unit;

  const ParameterDefinition({
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.label,
    required this.group,
    this.unit = '',
  });
}

/// Parameter grouping for UI organization
enum ParameterGroup {
  rotation,
  structure,
  dynamics,
  color,
}
