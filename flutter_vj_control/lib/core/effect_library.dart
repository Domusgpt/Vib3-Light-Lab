import 'package:flutter/material.dart';

/// Central effect library - organizes all VIB34D visual effects
class EffectLibrary {
  static final EffectLibrary _instance = EffectLibrary._internal();
  factory EffectLibrary() => _instance;
  EffectLibrary._internal();

  /// All effects organized by category
  final Map<EffectCategory, List<EffectDef>> _effects = {
    EffectCategory.color: [
      EffectDef(
        id: 'hueShift',
        name: 'Hue Shift',
        description: 'Shift the color spectrum dynamically',
        category: EffectCategory.color,
        icon: Icons.colorize,
        parameters: ['hue', 'saturation', 'intensity'],
        tags: ['color', 'performance', 'audio'],
      ),
      EffectDef(
        id: 'saturationBoost',
        name: 'Saturation Boost',
        description: 'Enhance color vibrancy',
        category: EffectCategory.color,
        icon: Icons.brightness_high,
        parameters: ['saturation', 'intensity'],
        tags: ['color', 'enhancement'],
      ),
      EffectDef(
        id: 'colorCycle',
        name: 'Color Cycle',
        description: 'Smooth color palette cycling',
        category: EffectCategory.color,
        icon: Icons.palette,
        parameters: ['hue', 'speed'],
        tags: ['color', 'animation', 'auto'],
      ),
    ],
    EffectCategory.distortion: [
      EffectDef(
        id: 'kaleidoscope',
        name: 'Kaleidoscope',
        description: 'Mirror and repeat patterns',
        category: EffectCategory.distortion,
        icon: Icons.crop_rotate,
        parameters: ['gridDensity', 'chaos'],
        tags: ['distortion', 'geometric', 'psychedelic'],
      ),
      EffectDef(
        id: 'twist',
        name: 'Twist',
        description: 'Spiral distortion effect',
        category: EffectCategory.distortion,
        icon: Icons.rotate_right,
        parameters: ['chaos', 'speed'],
        tags: ['distortion', 'motion'],
      ),
      EffectDef(
        id: 'mirror',
        name: 'Mirror',
        description: 'Symmetrical reflection',
        category: EffectCategory.distortion,
        icon: Icons.flip,
        parameters: ['chaos'],
        tags: ['distortion', 'symmetry'],
      ),
    ],
    EffectCategory.time: [
      EffectDef(
        id: 'delay',
        name: 'Delay',
        description: 'Time-based echo effect',
        category: EffectCategory.time,
        icon: Icons.replay,
        parameters: ['speed'],
        tags: ['time', 'echo', 'feedback'],
      ),
      EffectDef(
        id: 'stutter',
        name: 'Stutter',
        description: 'Rhythmic freeze frames',
        category: EffectCategory.time,
        icon: Icons.pause_circle,
        parameters: ['speed'],
        tags: ['time', 'glitch', 'rhythmic'],
      ),
    ],
    EffectCategory.spatial: [
      EffectDef(
        id: 'rotate4D',
        name: '4D Rotation',
        description: 'Hyperspace rotation effect',
        category: EffectCategory.spatial,
        icon: Icons.threed_rotation,
        parameters: ['rot4dXW', 'rot4dYW', 'rot4dZW', 'speed'],
        tags: ['4d', 'rotation', 'performance'],
      ),
      EffectDef(
        id: 'morph',
        name: 'Morph',
        description: 'Shape transformation',
        category: EffectCategory.spatial,
        icon: Icons.transform,
        parameters: ['morphFactor', 'chaos'],
        tags: ['structure', 'morph', 'transformation'],
      ),
      EffectDef(
        id: 'scale',
        name: 'Scale',
        description: 'Dynamic size changes',
        category: EffectCategory.spatial,
        icon: Icons.zoom_in,
        parameters: ['gridDensity'],
        tags: ['spatial', 'zoom'],
      ),
    ],
    EffectCategory.generate: [
      EffectDef(
        id: 'noise',
        name: 'Noise',
        description: 'Procedural noise generation',
        category: EffectCategory.generate,
        icon: Icons.grain,
        parameters: ['chaos', 'speed'],
        tags: ['generative', 'texture'],
      ),
      EffectDef(
        id: 'particles',
        name: 'Particles',
        description: 'Particle system overlay',
        category: EffectCategory.generate,
        icon: Icons.blur_on,
        parameters: ['gridDensity', 'speed', 'chaos'],
        tags: ['generative', 'particles'],
      ),
      EffectDef(
        id: 'fractal',
        name: 'Fractal',
        description: 'Fractal pattern generation',
        category: EffectCategory.generate,
        icon: Icons.scatter_plot,
        parameters: ['chaos', 'gridDensity', 'morphFactor'],
        tags: ['generative', 'fractal', 'complex'],
      ),
    ],
    EffectCategory.composite: [
      EffectDef(
        id: 'blend',
        name: 'Blend',
        description: 'Layer blending modes',
        category: EffectCategory.composite,
        icon: Icons.layers,
        parameters: ['intensity'],
        tags: ['composite', 'blend'],
        blendModes: ['normal', 'add', 'multiply', 'screen', 'overlay'],
      ),
      EffectDef(
        id: 'alpha',
        name: 'Alpha',
        description: 'Transparency control',
        category: EffectCategory.composite,
        icon: Icons.opacity,
        parameters: ['intensity'],
        tags: ['composite', 'transparency'],
      ),
    ],
  };

  /// Get all effects
  List<EffectDef> getAllEffects() {
    return _effects.values.expand((list) => list).toList();
  }

  /// Get effects by category
  List<EffectDef> getByCategory(EffectCategory category) {
    return _effects[category] ?? [];
  }

  /// Get effect by ID
  EffectDef? getById(String id) {
    for (var list in _effects.values) {
      try {
        return list.firstWhere((e) => e.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Get effects by tags
  List<EffectDef> getByTags(List<String> tags) {
    return getAllEffects()
        .where((e) => tags.any((tag) => e.tags.contains(tag)))
        .toList();
  }

  /// Search effects by name or description
  List<EffectDef> search(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllEffects()
        .where((e) =>
            e.name.toLowerCase().contains(lowerQuery) ||
            e.description.toLowerCase().contains(lowerQuery) ||
            e.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  /// Get all categories
  List<EffectCategory> getCategories() {
    return EffectCategory.values;
  }
}

/// Effect definition
class EffectDef {
  final String id;
  final String name;
  final String description;
  final EffectCategory category;
  final IconData icon;
  final List<String> parameters; // Parameter IDs this effect uses
  final List<String> tags;
  final List<String>? blendModes; // For composite effects

  const EffectDef({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    this.parameters = const [],
    this.tags = const [],
    this.blendModes,
  });
}

/// Effect categories matching professional VJ software
enum EffectCategory {
  color, // Hue, saturation, contrast
  distortion, // Kaleidoscope, mirror, twist
  time, // Delay, echo, stutter
  spatial, // Translate, scale, rotate
  generate, // Noise, fractals, particles
  composite, // Blend, alpha, masks
}

extension EffectCategoryExtension on EffectCategory {
  String get displayName {
    switch (this) {
      case EffectCategory.color:
        return 'Color';
      case EffectCategory.distortion:
        return 'Distortion';
      case EffectCategory.time:
        return 'Time';
      case EffectCategory.spatial:
        return 'Spatial';
      case EffectCategory.generate:
        return 'Generate';
      case EffectCategory.composite:
        return 'Composite';
    }
  }

  String get emoji {
    switch (this) {
      case EffectCategory.color:
        return '🎨';
      case EffectCategory.distortion:
        return '🌀';
      case EffectCategory.time:
        return '⏱️';
      case EffectCategory.spatial:
        return '📐';
      case EffectCategory.generate:
        return '✨';
      case EffectCategory.composite:
        return '🎭';
    }
  }

  IconData get icon {
    switch (this) {
      case EffectCategory.color:
        return Icons.palette;
      case EffectCategory.distortion:
        return Icons.crop_rotate;
      case EffectCategory.time:
        return Icons.access_time;
      case EffectCategory.spatial:
        return Icons.threed_rotation;
      case EffectCategory.generate:
        return Icons.auto_awesome;
      case EffectCategory.composite:
        return Icons.layers;
    }
  }
}

/// Effect chain - ordered list of effects applied to a layer
class EffectChain {
  final String id;
  String name;
  final List<EffectInstance> effects;

  EffectChain({
    required this.id,
    this.name = 'Untitled Chain',
    this.effects = const [],
  });

  /// Add effect to chain
  void addEffect(EffectInstance effect) {
    effects.add(effect);
  }

  /// Remove effect from chain
  void removeEffect(String effectInstanceId) {
    effects.removeWhere((e) => e.id == effectInstanceId);
  }

  /// Reorder effects in chain
  void reorderEffect(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final effect = effects.removeAt(oldIndex);
    effects.insert(newIndex, effect);
  }

  /// Get effect instance by ID
  EffectInstance? getEffect(String id) {
    try {
      return effects.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'effects': effects.map((e) => e.toJson()).toList(),
    };
  }

  /// Deserialize from JSON
  factory EffectChain.fromJson(Map<String, dynamic> json) {
    return EffectChain(
      id: json['id'],
      name: json['name'] ?? 'Untitled Chain',
      effects: (json['effects'] as List)
          .map((e) => EffectInstance.fromJson(e))
          .toList(),
    );
  }
}

/// Instance of an effect with its parameter values
class EffectInstance {
  final String id;
  final String effectId; // References EffectDef.id
  bool enabled;
  Map<String, dynamic> parameterValues; // Parameter overrides

  EffectInstance({
    required this.id,
    required this.effectId,
    this.enabled = true,
    this.parameterValues = const {},
  });

  /// Get effect definition
  EffectDef? getDefinition() {
    return EffectLibrary().getById(effectId);
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'effectId': effectId,
      'enabled': enabled,
      'parameterValues': parameterValues,
    };
  }

  /// Deserialize from JSON
  factory EffectInstance.fromJson(Map<String, dynamic> json) {
    return EffectInstance(
      id: json['id'],
      effectId: json['effectId'],
      enabled: json['enabled'] ?? true,
      parameterValues: Map<String, dynamic>.from(json['parameterValues'] ?? {}),
    );
  }
}
