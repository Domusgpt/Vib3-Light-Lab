/// VIB3 Light Lab - Engine State Model
///
/// Immutable state model for VIB3 visualization engine.
/// Manages current system, parameters, and toggle states.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import '../config/constants.dart';

/// Engine State - Complete visualization engine state
class EngineState {
  /// Current active system
  final String currentSystem;

  /// All parameter values
  final Map<String, double> parameters;

  /// Audio reactivity enabled
  final bool audioEnabled;

  /// Interactivity (mouse/touch) enabled
  final bool interactivityEnabled;

  /// Device tilt enabled (mobile)
  final bool deviceTiltEnabled;

  /// Beat sync enabled
  final bool beatSyncEnabled;

  /// Last parameter update timestamp
  final DateTime lastUpdate;

  /// System initialization status
  final bool isInitialized;

  /// Loading status
  final bool isLoading;

  /// Error message (if any)
  final String? errorMessage;

  const EngineState({
    required this.currentSystem,
    required this.parameters,
    this.audioEnabled = false,
    this.interactivityEnabled = true,
    this.deviceTiltEnabled = false,
    this.beatSyncEnabled = false,
    required this.lastUpdate,
    this.isInitialized = false,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Default initial state
  factory EngineState.initial() {
    return EngineState(
      currentSystem: VIB3Systems.faceted,
      parameters: _getDefaultParameters(),
      lastUpdate: DateTime.now(),
    );
  }

  /// Get default parameter values
  static Map<String, double> _getDefaultParameters() {
    return {
      for (var param in VIB3Parameters.all)
        param: VIB3Parameters.ranges[param]!.defaultValue,
    };
  }

  /// Copy with modifications (immutable update)
  EngineState copyWith({
    String? currentSystem,
    Map<String, double>? parameters,
    bool? audioEnabled,
    bool? interactivityEnabled,
    bool? deviceTiltEnabled,
    bool? beatSyncEnabled,
    DateTime? lastUpdate,
    bool? isInitialized,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EngineState(
      currentSystem: currentSystem ?? this.currentSystem,
      parameters: parameters ?? Map.from(this.parameters),
      audioEnabled: audioEnabled ?? this.audioEnabled,
      interactivityEnabled: interactivityEnabled ?? this.interactivityEnabled,
      deviceTiltEnabled: deviceTiltEnabled ?? this.deviceTiltEnabled,
      beatSyncEnabled: beatSyncEnabled ?? this.beatSyncEnabled,
      lastUpdate: lastUpdate ?? DateTime.now(),
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Update a single parameter
  EngineState updateParameter(String name, double value) {
    final newParams = Map<String, double>.from(parameters);
    newParams[name] = value;
    return copyWith(
      parameters: newParams,
      lastUpdate: DateTime.now(),
    );
  }

  /// Update multiple parameters at once
  EngineState updateParameters(Map<String, double> updates) {
    final newParams = Map<String, double>.from(parameters);
    newParams.addAll(updates);
    return copyWith(
      parameters: newParams,
      lastUpdate: DateTime.now(),
    );
  }

  /// Reset all parameters to defaults
  EngineState resetParameters() {
    return copyWith(
      parameters: _getDefaultParameters(),
      lastUpdate: DateTime.now(),
    );
  }

  /// Randomize all parameters
  EngineState randomizeParameters() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final newParams = <String, double>{};

    for (var param in VIB3Parameters.all) {
      final range = VIB3Parameters.ranges[param]!;
      // Simple pseudo-random based on timestamp + param hash
      final seed = (random + param.hashCode) % 1000;
      final normalized = seed / 1000.0;
      newParams[param] = range.denormalize(normalized);
    }

    return copyWith(
      parameters: newParams,
      lastUpdate: DateTime.now(),
    );
  }

  /// Get parameter value safely
  double getParameter(String name) {
    return parameters[name] ?? VIB3Parameters.ranges[name]?.defaultValue ?? 0.0;
  }

  /// Check if parameter is in valid range
  bool isParameterValid(String name, double value) {
    final range = VIB3Parameters.ranges[name];
    if (range == null) return false;
    return value >= range.min && value <= range.max;
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentSystem': currentSystem,
      'parameters': parameters,
      'audioEnabled': audioEnabled,
      'interactivityEnabled': interactivityEnabled,
      'deviceTiltEnabled': deviceTiltEnabled,
      'beatSyncEnabled': beatSyncEnabled,
      'lastUpdate': lastUpdate.toIso8601String(),
      'isInitialized': isInitialized,
    };
  }

  /// Deserialize from JSON
  factory EngineState.fromJson(Map<String, dynamic> json) {
    return EngineState(
      currentSystem: json['currentSystem'] as String? ?? VIB3Systems.faceted,
      parameters: (json['parameters'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          _getDefaultParameters(),
      audioEnabled: json['audioEnabled'] as bool? ?? false,
      interactivityEnabled: json['interactivityEnabled'] as bool? ?? true,
      deviceTiltEnabled: json['deviceTiltEnabled'] as bool? ?? false,
      beatSyncEnabled: json['beatSyncEnabled'] as bool? ?? false,
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.parse(json['lastUpdate'] as String)
          : DateTime.now(),
      isInitialized: json['isInitialized'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EngineState &&
        other.currentSystem == currentSystem &&
        _mapsEqual(other.parameters, parameters) &&
        other.audioEnabled == audioEnabled &&
        other.interactivityEnabled == interactivityEnabled &&
        other.deviceTiltEnabled == deviceTiltEnabled &&
        other.beatSyncEnabled == beatSyncEnabled;
  }

  static bool _mapsEqual(Map<String, double> a, Map<String, double> b) {
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentSystem,
      parameters.hashCode,
      audioEnabled,
      interactivityEnabled,
      deviceTiltEnabled,
      beatSyncEnabled,
    );
  }

  @override
  String toString() {
    return 'EngineState('
        'system: $currentSystem, '
        'params: ${parameters.length}, '
        'audio: $audioEnabled, '
        'interactive: $interactivityEnabled'
        ')';
  }
}

/// Preset - Saved engine state configuration
class Preset {
  final String id;
  final String name;
  final String? description;
  final EngineState state;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final List<String> tags;

  const Preset({
    required this.id,
    required this.name,
    this.description,
    required this.state,
    required this.createdAt,
    this.modifiedAt,
    this.tags = const [],
  });

  /// Create preset from engine state
  factory Preset.fromEngineState({
    required String id,
    required String name,
    String? description,
    required EngineState state,
    List<String> tags = const [],
  }) {
    return Preset(
      id: id,
      name: name,
      description: description,
      state: state,
      createdAt: DateTime.now(),
      tags: tags,
    );
  }

  /// Copy with modifications
  Preset copyWith({
    String? name,
    String? description,
    EngineState? state,
    List<String>? tags,
  }) {
    return Preset(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      state: state ?? this.state,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
      tags: tags ?? this.tags,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'state': state.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
      'tags': tags,
    };
  }

  /// Deserialize from JSON
  factory Preset.fromJson(Map<String, dynamic> json) {
    return Preset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      state: EngineState.fromJson(json['state'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
