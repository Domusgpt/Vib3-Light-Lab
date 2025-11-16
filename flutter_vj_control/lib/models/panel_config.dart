import 'package:flutter/material.dart';

/// Panel type enumeration
enum PanelType {
  visualizer,
  padMatrix,
  effectBank,
  parameterInspector,
  layerMixer,
  timeline,
  mediaBrowser,
  audioAnalyzer,
  hardwareBridge,
  telemetry,
}

extension PanelTypeExtension on PanelType {
  String get displayName {
    switch (this) {
      case PanelType.visualizer:
        return 'Visualizer';
      case PanelType.padMatrix:
        return 'Control Pads';
      case PanelType.effectBank:
        return 'Effect Bank';
      case PanelType.parameterInspector:
        return 'Parameters';
      case PanelType.layerMixer:
        return 'Layer Mixer';
      case PanelType.timeline:
        return 'Timeline';
      case PanelType.mediaBrowser:
        return 'Media Browser';
      case PanelType.audioAnalyzer:
        return 'Audio Analyzer';
      case PanelType.hardwareBridge:
        return 'Hardware';
      case PanelType.telemetry:
        return 'Telemetry';
    }
  }

  IconData get icon {
    switch (this) {
      case PanelType.visualizer:
        return Icons.visibility;
      case PanelType.padMatrix:
        return Icons.grid_on;
      case PanelType.effectBank:
        return Icons.auto_awesome;
      case PanelType.parameterInspector:
        return Icons.tune;
      case PanelType.layerMixer:
        return Icons.layers;
      case PanelType.timeline:
        return Icons.timeline;
      case PanelType.mediaBrowser:
        return Icons.photo_library;
      case PanelType.audioAnalyzer:
        return Icons.graphic_eq;
      case PanelType.hardwareBridge:
        return Icons.settings_input_component;
      case PanelType.telemetry:
        return Icons.analytics;
    }
  }

  /// Priority for auto-layout (higher = more important)
  int get priority {
    switch (this) {
      case PanelType.visualizer:
        return 100;
      case PanelType.padMatrix:
        return 90;
      case PanelType.layerMixer:
        return 80;
      case PanelType.audioAnalyzer:
        return 70;
      case PanelType.parameterInspector:
        return 60;
      case PanelType.effectBank:
        return 50;
      case PanelType.mediaBrowser:
        return 40;
      case PanelType.timeline:
        return 30;
      case PanelType.hardwareBridge:
        return 20;
      case PanelType.telemetry:
        return 10;
    }
  }
}

/// Panel configuration model
class PanelConfig {
  final String id;
  final PanelType type;
  Rect bounds; // Position and size
  bool isVisible;
  bool isCollapsed;
  bool isFloating; // Pop-out window
  int zIndex;
  Map<String, dynamic> state; // Panel-specific state

  PanelConfig({
    required this.id,
    required this.type,
    required this.bounds,
    this.isVisible = true,
    this.isCollapsed = false,
    this.isFloating = false,
    this.zIndex = 0,
    this.state = const {},
  });

  /// Create default panel config
  factory PanelConfig.createDefault(PanelType type, Size screenSize) {
    final id = '${type.name}_${DateTime.now().millisecondsSinceEpoch}';

    // Default sizes and positions based on panel type
    late Rect bounds;

    switch (type) {
      case PanelType.visualizer:
        // Large, top-left
        bounds = Rect.fromLTWH(
          0,
          0,
          screenSize.width * 0.7,
          screenSize.height * 0.6,
        );
        break;

      case PanelType.padMatrix:
        // Medium, bottom-left
        bounds = Rect.fromLTWH(
          0,
          screenSize.height * 0.6,
          screenSize.width * 0.4,
          screenSize.height * 0.4,
        );
        break;

      case PanelType.layerMixer:
        // Horizontal strip, top-right
        bounds = Rect.fromLTWH(
          screenSize.width * 0.7,
          0,
          screenSize.width * 0.3,
          screenSize.height * 0.15,
        );
        break;

      case PanelType.audioAnalyzer:
        // Medium, bottom-right
        bounds = Rect.fromLTWH(
          screenSize.width * 0.7,
          screenSize.height * 0.15,
          screenSize.width * 0.3,
          screenSize.height * 0.25,
        );
        break;

      case PanelType.parameterInspector:
        // Tall, right side
        bounds = Rect.fromLTWH(
          screenSize.width * 0.7,
          screenSize.height * 0.4,
          screenSize.width * 0.3,
          screenSize.height * 0.6,
        );
        break;

      default:
        // Default medium size, centered
        bounds = Rect.fromLTWH(
          screenSize.width * 0.25,
          screenSize.height * 0.25,
          screenSize.width * 0.5,
          screenSize.height * 0.5,
        );
    }

    return PanelConfig(
      id: id,
      type: type,
      bounds: bounds,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'bounds': {
        'left': bounds.left,
        'top': bounds.top,
        'width': bounds.width,
        'height': bounds.height,
      },
      'isVisible': isVisible,
      'isCollapsed': isCollapsed,
      'isFloating': isFloating,
      'zIndex': zIndex,
      'state': state,
    };
  }

  /// Deserialize from JSON
  factory PanelConfig.fromJson(Map<String, dynamic> json) {
    return PanelConfig(
      id: json['id'] ?? '',
      type: PanelType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PanelType.visualizer,
      ),
      bounds: Rect.fromLTWH(
        (json['bounds']?['left'] ?? 0).toDouble(),
        (json['bounds']?['top'] ?? 0).toDouble(),
        (json['bounds']?['width'] ?? 400).toDouble(),
        (json['bounds']?['height'] ?? 300).toDouble(),
      ),
      isVisible: json['isVisible'] ?? true,
      isCollapsed: json['isCollapsed'] ?? false,
      isFloating: json['isFloating'] ?? false,
      zIndex: json['zIndex'] ?? 0,
      state: Map<String, dynamic>.from(json['state'] ?? {}),
    );
  }

  /// Copy with modifications
  PanelConfig copyWith({
    String? id,
    PanelType? type,
    Rect? bounds,
    bool? isVisible,
    bool? isCollapsed,
    bool? isFloating,
    int? zIndex,
    Map<String, dynamic>? state,
  }) {
    return PanelConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      bounds: bounds ?? this.bounds,
      isVisible: isVisible ?? this.isVisible,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      isFloating: isFloating ?? this.isFloating,
      zIndex: zIndex ?? this.zIndex,
      state: state ?? this.state,
    );
  }

  /// Update bounds
  void updateBounds(Rect newBounds) {
    bounds = newBounds;
  }

  /// Toggle visibility
  void toggleVisibility() {
    isVisible = !isVisible;
  }

  /// Toggle collapsed state
  void toggleCollapsed() {
    isCollapsed = !isCollapsed;
  }

  /// Bring to front
  void bringToFront(int maxZ) {
    zIndex = maxZ + 1;
  }
}

/// Dock position for panel snapping
enum DockPosition {
  none,
  left,
  right,
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

/// Grid snapping settings
class GridSettings {
  final bool enabled;
  final double gridSize;
  final bool snapToEdges;
  final bool snapToPanels;

  const GridSettings({
    this.enabled = true,
    this.gridSize = 20.0,
    this.snapToEdges = true,
    this.snapToPanels = true,
  });

  GridSettings copyWith({
    bool? enabled,
    double? gridSize,
    bool? snapToEdges,
    bool? snapToPanels,
  }) {
    return GridSettings(
      enabled: enabled ?? this.enabled,
      gridSize: gridSize ?? this.gridSize,
      snapToEdges: snapToEdges ?? this.snapToEdges,
      snapToPanels: snapToPanels ?? this.snapToPanels,
    );
  }
}
