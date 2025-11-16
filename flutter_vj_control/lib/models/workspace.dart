import 'panel_config.dart';

/// Complete workspace configuration
class Workspace {
  final String id;
  final String name;
  final String description;
  final List<PanelConfig> panels;
  final GridSettings gridSettings;
  final WorkspaceMode mode;
  final DateTime createdAt;
  DateTime modifiedAt;
  final Map<String, dynamic> metadata;

  Workspace({
    required this.id,
    required this.name,
    this.description = '',
    required this.panels,
    this.gridSettings = const GridSettings(),
    this.mode = WorkspaceMode.performance,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.metadata = const {},
  })  : createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  /// Create default workspaces
  static List<Workspace> createDefaults(Size screenSize) {
    return [
      createPerformanceWorkspace(screenSize),
      createSetupWorkspace(screenSize),
      createMinimalWorkspace(screenSize),
      createDJWorkspace(screenSize),
    ];
  }

  /// Performance layout (live show)
  static Workspace createPerformanceWorkspace(Size screenSize) {
    return Workspace(
      id: 'performance',
      name: 'Performance',
      description: 'Optimized for live shows with essential controls',
      mode: WorkspaceMode.performance,
      panels: [
        PanelConfig(
          id: 'visualizer_main',
          type: PanelType.visualizer,
          bounds: Rect.fromLTWH(0, 0, screenSize.width * 0.65, screenSize.height * 0.7),
        ),
        PanelConfig(
          id: 'pads_main',
          type: PanelType.padMatrix,
          bounds: Rect.fromLTWH(0, screenSize.height * 0.7, screenSize.width * 0.45, screenSize.height * 0.3),
        ),
        PanelConfig(
          id: 'mixer_main',
          type: PanelType.layerMixer,
          bounds: Rect.fromLTWH(screenSize.width * 0.65, 0, screenSize.width * 0.35, screenSize.height * 0.25),
        ),
        PanelConfig(
          id: 'audio_main',
          type: PanelType.audioAnalyzer,
          bounds: Rect.fromLTWH(screenSize.width * 0.45, screenSize.height * 0.7, screenSize.width * 0.55, screenSize.height * 0.3),
        ),
        // Hidden panels
        PanelConfig(
          id: 'params_hidden',
          type: PanelType.parameterInspector,
          bounds: Rect.fromLTWH(screenSize.width * 0.65, screenSize.height * 0.25, screenSize.width * 0.35, screenSize.height * 0.45),
          isVisible: false,
        ),
      ],
    );
  }

  /// Setup layout (mapping & configuration)
  static Workspace createSetupWorkspace(Size screenSize) {
    return Workspace(
      id: 'setup',
      name: 'Setup',
      description: 'Full panel access for mapping and configuration',
      mode: WorkspaceMode.setup,
      panels: [
        PanelConfig(
          id: 'visualizer_setup',
          type: PanelType.visualizer,
          bounds: Rect.fromLTWH(screenSize.width * 0.2, 0, screenSize.width * 0.5, screenSize.height * 0.5),
        ),
        PanelConfig(
          id: 'effects_setup',
          type: PanelType.effectBank,
          bounds: Rect.fromLTWH(0, 0, screenSize.width * 0.2, screenSize.height * 0.5),
        ),
        PanelConfig(
          id: 'params_setup',
          type: PanelType.parameterInspector,
          bounds: Rect.fromLTWH(screenSize.width * 0.7, 0, screenSize.width * 0.3, screenSize.height * 0.4),
        ),
        PanelConfig(
          id: 'hardware_setup',
          type: PanelType.hardwareBridge,
          bounds: Rect.fromLTWH(screenSize.width * 0.7, screenSize.height * 0.4, screenSize.width * 0.3, screenSize.height * 0.3),
        ),
        PanelConfig(
          id: 'pads_setup',
          type: PanelType.padMatrix,
          bounds: Rect.fromLTWH(0, screenSize.height * 0.5, screenSize.width * 0.7, screenSize.height * 0.5),
        ),
        PanelConfig(
          id: 'telemetry_setup',
          type: PanelType.telemetry,
          bounds: Rect.fromLTWH(screenSize.width * 0.7, screenSize.height * 0.7, screenSize.width * 0.3, screenSize.height * 0.3),
        ),
      ],
    );
  }

  /// Minimal layout (fullscreen focus)
  static Workspace createMinimalWorkspace(Size screenSize) {
    return Workspace(
      id: 'minimal',
      name: 'Minimal',
      description: 'Fullscreen visualizer with minimal controls',
      mode: WorkspaceMode.performance,
      panels: [
        PanelConfig(
          id: 'visualizer_minimal',
          type: PanelType.visualizer,
          bounds: Rect.fromLTWH(0, 0, screenSize.width, screenSize.height),
        ),
        // All other panels hidden
      ],
    );
  }

  /// DJ layout (crossfader focus)
  static Workspace createDJWorkspace(Size screenSize) {
    return Workspace(
      id: 'dj',
      name: 'DJ Mode',
      description: 'Crossfader-focused layout for mixing',
      mode: WorkspaceMode.performance,
      panels: [
        PanelConfig(
          id: 'visualizer_dj',
          type: PanelType.visualizer,
          bounds: Rect.fromLTWH(0, 0, screenSize.width, screenSize.height * 0.6),
        ),
        PanelConfig(
          id: 'mixer_dj',
          type: PanelType.layerMixer,
          bounds: Rect.fromLTWH(0, screenSize.height * 0.6, screenSize.width, screenSize.height * 0.15),
        ),
        PanelConfig(
          id: 'pads_dj',
          type: PanelType.padMatrix,
          bounds: Rect.fromLTWH(0, screenSize.height * 0.75, screenSize.width * 0.5, screenSize.height * 0.25),
        ),
        PanelConfig(
          id: 'audio_dj',
          type: PanelType.audioAnalyzer,
          bounds: Rect.fromLTWH(screenSize.width * 0.5, screenSize.height * 0.75, screenSize.width * 0.5, screenSize.height * 0.25),
        ),
      ],
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'panels': panels.map((p) => p.toJson()).toList(),
      'gridSettings': {
        'enabled': gridSettings.enabled,
        'gridSize': gridSettings.gridSize,
        'snapToEdges': gridSettings.snapToEdges,
        'snapToPanels': gridSettings.snapToPanels,
      },
      'mode': mode.name,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Deserialize from JSON
  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Untitled',
      description: json['description'] ?? '',
      panels: (json['panels'] as List? ?? [])
          .map((p) => PanelConfig.fromJson(p))
          .toList(),
      gridSettings: GridSettings(
        enabled: json['gridSettings']?['enabled'] ?? true,
        gridSize: (json['gridSettings']?['gridSize'] ?? 20.0).toDouble(),
        snapToEdges: json['gridSettings']?['snapToEdges'] ?? true,
        snapToPanels: json['gridSettings']?['snapToPanels'] ?? true,
      ),
      mode: WorkspaceMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => WorkspaceMode.performance,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'])
          : DateTime.now(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Copy with modifications
  Workspace copyWith({
    String? id,
    String? name,
    String? description,
    List<PanelConfig>? panels,
    GridSettings? gridSettings,
    WorkspaceMode? mode,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      panels: panels ?? this.panels,
      gridSettings: gridSettings ?? this.gridSettings,
      mode: mode ?? this.mode,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get panel by ID
  PanelConfig? getPanelById(String panelId) {
    try {
      return panels.firstWhere((p) => p.id == panelId);
    } catch (e) {
      return null;
    }
  }

  /// Get panels by type
  List<PanelConfig> getPanelsByType(PanelType type) {
    return panels.where((p) => p.type == type).toList();
  }

  /// Get visible panels
  List<PanelConfig> get visiblePanels {
    return panels.where((p) => p.isVisible).toList();
  }

  /// Add panel
  void addPanel(PanelConfig panel) {
    panels.add(panel);
    modifiedAt = DateTime.now();
  }

  /// Remove panel
  void removePanel(String panelId) {
    panels.removeWhere((p) => p.id == panelId);
    modifiedAt = DateTime.now();
  }

  /// Update panel
  void updatePanel(String panelId, PanelConfig updatedPanel) {
    final index = panels.indexWhere((p) => p.id == panelId);
    if (index != -1) {
      panels[index] = updatedPanel;
      modifiedAt = DateTime.now();
    }
  }
}

/// Workspace mode (affects which panels are shown)
enum WorkspaceMode {
  performance, // Live show mode
  setup, // Configuration mode
  minimal, // Fullscreen mode
}

extension WorkspaceModeExtension on WorkspaceMode {
  String get displayName {
    switch (this) {
      case WorkspaceMode.performance:
        return 'Performance';
      case WorkspaceMode.setup:
        return 'Setup';
      case WorkspaceMode.minimal:
        return 'Minimal';
    }
  }

  IconData get icon {
    switch (this) {
      case WorkspaceMode.performance:
        return Icons.play_circle;
      case WorkspaceMode.setup:
        return Icons.settings;
      case WorkspaceMode.minimal:
        return Icons.fullscreen;
    }
  }
}
