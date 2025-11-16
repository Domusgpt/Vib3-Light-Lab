/// XY Pad configuration for touch control
class PadConfig {
  final String id;
  String label;
  PadSize size;
  AxisMapping xAxis;
  AxisMapping yAxis;
  AxisMapping spreadAxis;
  bool multiTouchEnabled;
  bool visualFeedbackEnabled;
  Map<String, dynamic> metadata;

  PadConfig({
    required this.id,
    this.label = '',
    this.size = PadSize.medium,
    AxisMapping? xAxis,
    AxisMapping? yAxis,
    AxisMapping? spreadAxis,
    this.multiTouchEnabled = true,
    this.visualFeedbackEnabled = true,
    this.metadata = const {},
  })  : xAxis = xAxis ?? AxisMapping.empty(),
        yAxis = yAxis ?? AxisMapping.empty(),
        spreadAxis = spreadAxis ?? AxisMapping.empty();

  /// Create default pad
  factory PadConfig.createDefault(int index) {
    return PadConfig(
      id: 'pad_${index + 1}',
      label: 'Pad ${index + 1}',
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'size': size.name,
      'xAxis': xAxis.toJson(),
      'yAxis': yAxis.toJson(),
      'spreadAxis': spreadAxis.toJson(),
      'multiTouchEnabled': multiTouchEnabled,
      'visualFeedbackEnabled': visualFeedbackEnabled,
      'metadata': metadata,
    };
  }

  /// Deserialize from JSON
  factory PadConfig.fromJson(Map<String, dynamic> json) {
    return PadConfig(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      size: PadSize.values.firstWhere(
        (s) => s.name == json['size'],
        orElse: () => PadSize.medium,
      ),
      xAxis: AxisMapping.fromJson(json['xAxis'] ?? {}),
      yAxis: AxisMapping.fromJson(json['yAxis'] ?? {}),
      spreadAxis: AxisMapping.fromJson(json['spreadAxis'] ?? {}),
      multiTouchEnabled: json['multiTouchEnabled'] ?? true,
      visualFeedbackEnabled: json['visualFeedbackEnabled'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Copy with modifications
  PadConfig copyWith({
    String? id,
    String? label,
    PadSize? size,
    AxisMapping? xAxis,
    AxisMapping? yAxis,
    AxisMapping? spreadAxis,
    bool? multiTouchEnabled,
    bool? visualFeedbackEnabled,
    Map<String, dynamic>? metadata,
  }) {
    return PadConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      size: size ?? this.size,
      xAxis: xAxis ?? this.xAxis,
      yAxis: yAxis ?? this.yAxis,
      spreadAxis: spreadAxis ?? this.spreadAxis,
      multiTouchEnabled: multiTouchEnabled ?? this.multiTouchEnabled,
      visualFeedbackEnabled: visualFeedbackEnabled ?? this.visualFeedbackEnabled,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if pad has any mappings
  bool get hasMappings {
    return xAxis.parameter.isNotEmpty ||
        yAxis.parameter.isNotEmpty ||
        spreadAxis.parameter.isNotEmpty;
  }
}

/// Axis mapping configuration
class AxisMapping {
  String parameter; // Parameter ID to control
  bool invert; // Invert axis direction
  double smoothing; // 0 (instant) to 1 (max smoothing)
  double min; // Min value (for range limiting)
  double max; // Max value (for range limiting)

  AxisMapping({
    this.parameter = '',
    this.invert = false,
    this.smoothing = 0.2,
    this.min = 0.0,
    this.max = 1.0,
  });

  /// Create empty mapping
  factory AxisMapping.empty() {
    return AxisMapping();
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'invert': invert,
      'smoothing': smoothing,
      'min': min,
      'max': max,
    };
  }

  /// Deserialize from JSON
  factory AxisMapping.fromJson(Map<String, dynamic> json) {
    return AxisMapping(
      parameter: json['parameter'] ?? '',
      invert: json['invert'] ?? false,
      smoothing: (json['smoothing'] ?? 0.2).toDouble(),
      min: (json['min'] ?? 0.0).toDouble(),
      max: (json['max'] ?? 1.0).toDouble(),
    );
  }

  /// Copy with modifications
  AxisMapping copyWith({
    String? parameter,
    bool? invert,
    double? smoothing,
    double? min,
    double? max,
  }) {
    return AxisMapping(
      parameter: parameter ?? this.parameter,
      invert: invert ?? this.invert,
      smoothing: smoothing ?? this.smoothing,
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }

  /// Check if mapping is active
  bool get isActive {
    return parameter.isNotEmpty;
  }
}

/// Pad size presets
enum PadSize {
  small, // 150×150
  medium, // 250×250
  large, // 400×400
  extraLarge, // 600×600
  custom, // User-defined
}

extension PadSizeExtension on PadSize {
  /// Get default dimensions
  Size get dimensions {
    switch (this) {
      case PadSize.small:
        return const Size(150, 150);
      case PadSize.medium:
        return const Size(250, 250);
      case PadSize.large:
        return const Size(400, 400);
      case PadSize.extraLarge:
        return const Size(600, 600);
      case PadSize.custom:
        return const Size(250, 250); // Default for custom
    }
  }

  String get displayName {
    switch (this) {
      case PadSize.small:
        return 'Small (150px)';
      case PadSize.medium:
        return 'Medium (250px)';
      case PadSize.large:
        return 'Large (400px)';
      case PadSize.extraLarge:
        return 'Extra Large (600px)';
      case PadSize.custom:
        return 'Custom';
    }
  }
}

/// Pad touch state (for real-time control)
class PadTouchState {
  final Map<int, TouchPoint> touches; // Pointer ID → touch point
  final Offset center; // Average of all touches
  final double spread; // Distance between touches (for pinch/spread)
  final DateTime timestamp;

  PadTouchState({
    required this.touches,
    required this.center,
    required this.spread,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create empty state
  factory PadTouchState.empty() {
    return PadTouchState(
      touches: {},
      center: Offset.zero,
      spread: 0.0,
    );
  }

  /// Get normalized values (0.0 to 1.0)
  Map<String, double> getNormalizedValues(Size padSize) {
    return {
      'x': center.dx / padSize.width,
      'y': center.dy / padSize.height,
      'spread': spread,
    };
  }
}

/// Individual touch point
class TouchPoint {
  final int id;
  final Offset position;
  final DateTime timestamp;

  TouchPoint({
    required this.id,
    required this.position,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Pad preset (saved mappings)
class PadPreset {
  final String id;
  final String name;
  final String description;
  final List<PadConfig> pads;
  final DateTime createdAt;

  PadPreset({
    required this.id,
    required this.name,
    this.description = '',
    required this.pads,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pads': pads.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Deserialize from JSON
  factory PadPreset.fromJson(Map<String, dynamic> json) {
    return PadPreset(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Untitled',
      description: json['description'] ?? '',
      pads: (json['pads'] as List? ?? [])
          .map((p) => PadConfig.fromJson(p))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
