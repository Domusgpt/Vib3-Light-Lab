/// Central parameter bank - organizes all VIB34D parameters
class ParameterBank {
  static final ParameterBank _instance = ParameterBank._internal();
  factory ParameterBank() => _instance;
  ParameterBank._internal();

  /// All parameters organized by category
  final Map<ParameterCategory, List<ParameterDef>> _parameters = {
    ParameterCategory.rotation4D: [
      ParameterDef(
        id: 'rot4dXW',
        label: 'X↔W Rotation',
        min: -6.28,
        max: 6.28,
        defaultValue: 0.0,
        unit: 'rad',
        category: ParameterCategory.rotation4D,
        tags: ['4d', 'rotation', 'performance'],
      ),
      ParameterDef(
        id: 'rot4dYW',
        label: 'Y↔W Rotation',
        min: -6.28,
        max: 6.28,
        defaultValue: 0.0,
        unit: 'rad',
        category: ParameterCategory.rotation4D,
        tags: ['4d', 'rotation', 'performance'],
      ),
      ParameterDef(
        id: 'rot4dZW',
        label: 'Z↔W Rotation',
        min: -6.28,
        max: 6.28,
        defaultValue: 0.0,
        unit: 'rad',
        category: ParameterCategory.rotation4D,
        tags: ['4d', 'rotation', 'performance'],
      ),
    ],
    ParameterCategory.structure: [
      ParameterDef(
        id: 'gridDensity',
        label: 'Grid Density',
        min: 5.0,
        max: 100.0,
        defaultValue: 15.0,
        unit: '',
        category: ParameterCategory.structure,
        tags: ['structure', 'detail', 'performance'],
      ),
      ParameterDef(
        id: 'morphFactor',
        label: 'Morph Factor',
        min: 0.0,
        max: 2.0,
        defaultValue: 1.0,
        unit: '',
        category: ParameterCategory.structure,
        tags: ['structure', 'morph', 'audio'],
      ),
      ParameterDef(
        id: 'chaos',
        label: 'Chaos',
        min: 0.0,
        max: 1.0,
        defaultValue: 0.2,
        unit: '',
        category: ParameterCategory.structure,
        tags: ['structure', 'randomness'],
      ),
    ],
    ParameterCategory.color: [
      ParameterDef(
        id: 'hue',
        label: 'Hue',
        min: 0.0,
        max: 360.0,
        defaultValue: 200.0,
        unit: '°',
        category: ParameterCategory.color,
        tags: ['color', 'performance', 'audio'],
      ),
      ParameterDef(
        id: 'saturation',
        label: 'Saturation',
        min: 0.0,
        max: 1.0,
        defaultValue: 0.8,
        unit: '',
        category: ParameterCategory.color,
        tags: ['color', 'performance'],
      ),
      ParameterDef(
        id: 'intensity',
        label: 'Intensity',
        min: 0.0,
        max: 1.0,
        defaultValue: 0.5,
        unit: '',
        category: ParameterCategory.color,
        tags: ['color', 'performance', 'audio'],
      ),
    ],
    ParameterCategory.dynamics: [
      ParameterDef(
        id: 'speed',
        label: 'Speed',
        min: 0.1,
        max: 3.0,
        defaultValue: 1.0,
        unit: 'x',
        category: ParameterCategory.dynamics,
        tags: ['speed', 'time', 'performance', 'audio'],
      ),
    ],
    ParameterCategory.geometry: [
      ParameterDef(
        id: 'geometry',
        label: 'Geometry Type',
        min: 0.0,
        max: 7.0,
        defaultValue: 0.0,
        unit: '',
        category: ParameterCategory.geometry,
        tags: ['geometry', 'structure'],
        type: ParameterType.discrete,
        discreteValues: [
          'Tetrahedron',
          'Hypercube',
          'Sphere',
          'Torus',
          'Klein Bottle',
          'Fractal',
          'Wave',
          'Crystal',
        ],
      ),
    ],
  };

  /// Get all parameters
  List<ParameterDef> getAllParameters() {
    return _parameters.values.expand((list) => list).toList();
  }

  /// Get parameters by category
  List<ParameterDef> getByCategory(ParameterCategory category) {
    return _parameters[category] ?? [];
  }

  /// Get parameter by ID
  ParameterDef? getById(String id) {
    for (var list in _parameters.values) {
      try {
        return list.firstWhere((p) => p.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Get parameters by tags
  List<ParameterDef> getByTags(List<String> tags) {
    return getAllParameters()
        .where((p) => tags.any((tag) => p.tags.contains(tag)))
        .toList();
  }

  /// Get all categories
  List<ParameterCategory> getCategories() {
    return ParameterCategory.values;
  }
}

/// Parameter definition
class ParameterDef {
  final String id;
  final String label;
  final double min;
  final double max;
  final double defaultValue;
  final String unit;
  final ParameterCategory category;
  final List<String> tags;
  final ParameterType type;
  final List<String>? discreteValues; // For discrete parameters

  const ParameterDef({
    required this.id,
    required this.label,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.unit,
    required this.category,
    this.tags = const [],
    this.type = ParameterType.continuous,
    this.discreteValues,
  });

  /// Normalize value to 0-1 range
  double normalize(double value) {
    return (value - min) / (max - min);
  }

  /// Denormalize from 0-1 range
  double denormalize(double normalized) {
    return min + (normalized * (max - min));
  }
}

/// Parameter categories
enum ParameterCategory {
  rotation4D,
  structure,
  color,
  dynamics,
  geometry,
}

extension ParameterCategoryExtension on ParameterCategory {
  String get displayName {
    switch (this) {
      case ParameterCategory.rotation4D:
        return '4D Rotation';
      case ParameterCategory.structure:
        return 'Structure';
      case ParameterCategory.color:
        return 'Color';
      case ParameterCategory.dynamics:
        return 'Dynamics';
      case ParameterCategory.geometry:
        return 'Geometry';
    }
  }

  IconData get icon {
    switch (this) {
      case ParameterCategory.rotation4D:
        return Icons.threed_rotation;
      case ParameterCategory.structure:
        return Icons.grid_on;
      case ParameterCategory.color:
        return Icons.palette;
      case ParameterCategory.dynamics:
        return Icons.speed;
      case ParameterCategory.geometry:
        return Icons.category;
    }
  }
}

/// Parameter type
enum ParameterType {
  continuous, // Smooth range (e.g., hue 0-360)
  discrete, // Fixed values (e.g., geometry types)
}
