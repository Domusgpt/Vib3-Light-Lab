import 'parameter_model.dart';

/// Preset Model
/// Stores complete visualizer configuration including parameters and system type
class PresetModel {
  final String id;
  final String name;
  final String description;
  final VisualizerSystem system;
  final ParameterModel parameters;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final List<String> tags;
  final String? thumbnailPath;

  PresetModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.system,
    required this.parameters,
    DateTime? createdAt,
    this.modifiedAt,
    this.tags = const [],
    this.thumbnailPath,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'system': system.name,
      'parameters': parameters.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
      'tags': tags,
      'thumbnailPath': thumbnailPath,
    };
  }

  /// Deserialize from JSON
  factory PresetModel.fromJson(Map<String, dynamic> json) {
    return PresetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Untitled',
      description: json['description'] ?? '',
      system: VisualizerSystem.values.firstWhere(
        (s) => s.name == json['system'],
        orElse: () => VisualizerSystem.faceted,
      ),
      parameters: ParameterModel.fromJson(json['parameters'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      thumbnailPath: json['thumbnailPath'],
    );
  }

  /// Create copy with modifications
  PresetModel copyWith({
    String? id,
    String? name,
    String? description,
    VisualizerSystem? system,
    ParameterModel? parameters,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? thumbnailPath,
  }) {
    return PresetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      system: system ?? this.system,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}

/// Visualizer system types
enum VisualizerSystem {
  faceted,
  quantum,
  holographic,
  polychora,
}

extension VisualizerSystemExtension on VisualizerSystem {
  String get displayName {
    switch (this) {
      case VisualizerSystem.faceted:
        return 'Faceted';
      case VisualizerSystem.quantum:
        return 'Quantum';
      case VisualizerSystem.holographic:
        return 'Holographic';
      case VisualizerSystem.polychora:
        return 'Polychora';
    }
  }

  String get icon {
    switch (this) {
      case VisualizerSystem.faceted:
        return '🔷';
      case VisualizerSystem.quantum:
        return '🌌';
      case VisualizerSystem.holographic:
        return '✨';
      case VisualizerSystem.polychora:
        return '🔮';
    }
  }

  String get description {
    switch (this) {
      case VisualizerSystem.faceted:
        return 'Simple 2D patterns with 4D rotations';
      case VisualizerSystem.quantum:
        return 'Complex 3D lattice effects';
      case VisualizerSystem.holographic:
        return 'Audio-reactive holographic visualization';
      case VisualizerSystem.polychora:
        return '4D polytope mathematics';
    }
  }
}
