import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/panel_config.dart';
import '../models/workspace.dart';
import '../models/pad_config.dart';
import 'parameter_bank.dart';
import 'effect_library.dart';

/// Central workspace manager - handles all UI state and layout
class WorkspaceManager extends ChangeNotifier {
  static final WorkspaceManager _instance = WorkspaceManager._internal();
  factory WorkspaceManager() => _instance;
  WorkspaceManager._internal() {
    _initializeDefaultWorkspaces();
  }

  // Current state
  Workspace? _currentWorkspace;
  final Map<String, Workspace> _savedWorkspaces = {};
  WorkspaceMode _mode = WorkspaceMode.performance;
  Size _screenSize = const Size(1920, 1080);

  // Parameter state
  final Map<String, double> _parameterValues = {};

  // Effect chains per system
  final Map<String, EffectChain> _systemEffectChains = {
    'faceted': EffectChain(id: 'faceted_chain', name: 'Faceted FX'),
    'quantum': EffectChain(id: 'quantum_chain', name: 'Quantum FX'),
    'holographic': EffectChain(id: 'holographic_chain', name: 'Holographic FX'),
    'polychora': EffectChain(id: 'polychora_chain', name: 'Polychora FX'),
  };

  String _activeSystem = 'faceted';

  // Getters
  Workspace? get currentWorkspace => _currentWorkspace;
  Map<String, Workspace> get savedWorkspaces => _savedWorkspaces;
  WorkspaceMode get mode => _mode;
  Size get screenSize => _screenSize;
  Map<String, double> get parameterValues => _parameterValues;
  String get activeSystem => _activeSystem;

  /// Initialize default workspaces
  void _initializeDefaultWorkspaces() {
    _savedWorkspaces['performance'] = Workspace.createPerformanceWorkspace(_screenSize);
    _savedWorkspaces['setup'] = Workspace.createSetupWorkspace(_screenSize);
    _savedWorkspaces['minimal'] = Workspace.createMinimalWorkspace(_screenSize);
    _savedWorkspaces['dj'] = Workspace.createDJWorkspace(_screenSize);

    // Load performance workspace by default
    _currentWorkspace = _savedWorkspaces['performance'];

    // Initialize parameter values with defaults
    final paramBank = ParameterBank();
    for (var param in paramBank.getAllParameters()) {
      _parameterValues[param.id] = param.defaultValue;
    }
  }

  /// Update screen size (for responsive layout)
  void updateScreenSize(Size newSize) {
    if (_screenSize != newSize) {
      _screenSize = newSize;
      notifyListeners();
    }
  }

  /// Switch to a different workspace
  void switchWorkspace(String workspaceId) {
    final workspace = _savedWorkspaces[workspaceId];
    if (workspace != null) {
      _currentWorkspace = workspace;
      _mode = workspace.mode;
      notifyListeners();
    }
  }

  /// Create a new custom workspace
  Workspace createCustomWorkspace(String name) {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final workspace = Workspace(
      id: id,
      name: name,
      panels: [],
      gridSettings: GridSettings(),
      mode: WorkspaceMode.performance,
    );
    _savedWorkspaces[id] = workspace;
    notifyListeners();
    return workspace;
  }

  /// Save current workspace state
  void saveCurrentWorkspace() {
    if (_currentWorkspace != null) {
      _savedWorkspaces[_currentWorkspace!.id] = _currentWorkspace!;
      notifyListeners();
    }
  }

  /// Delete a workspace
  void deleteWorkspace(String workspaceId) {
    // Don't delete default workspaces
    if (!['performance', 'setup', 'minimal', 'dj'].contains(workspaceId)) {
      _savedWorkspaces.remove(workspaceId);
      if (_currentWorkspace?.id == workspaceId) {
        _currentWorkspace = _savedWorkspaces['performance'];
      }
      notifyListeners();
    }
  }

  /// Toggle workspace mode
  void toggleMode() {
    _mode = _mode == WorkspaceMode.performance
        ? WorkspaceMode.setup
        : WorkspaceMode.performance;
    notifyListeners();
  }

  /// Set workspace mode
  void setMode(WorkspaceMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  /// Get panel by ID
  PanelConfig? getPanel(String panelId) {
    return _currentWorkspace?.panels.firstWhere(
      (p) => p.id == panelId,
      orElse: () => throw Exception('Panel not found'),
    );
  }

  /// Update panel configuration
  void updatePanel(String panelId, PanelConfig updatedPanel) {
    if (_currentWorkspace != null) {
      final index = _currentWorkspace!.panels.indexWhere((p) => p.id == panelId);
      if (index != -1) {
        _currentWorkspace!.panels[index] = updatedPanel;
        notifyListeners();
      }
    }
  }

  /// Toggle panel visibility
  void togglePanelVisibility(String panelId) {
    final panel = getPanel(panelId);
    if (panel != null) {
      panel.toggleVisibility();
      notifyListeners();
    }
  }

  /// Toggle panel collapsed state
  void togglePanelCollapsed(String panelId) {
    final panel = getPanel(panelId);
    if (panel != null) {
      panel.toggleCollapsed();
      notifyListeners();
    }
  }

  /// Update panel bounds (position/size)
  void updatePanelBounds(String panelId, Rect newBounds) {
    final panel = getPanel(panelId);
    if (panel != null) {
      panel.updateBounds(newBounds);
      notifyListeners();
    }
  }

  /// Bring panel to front
  void bringPanelToFront(String panelId) {
    if (_currentWorkspace != null) {
      final maxZ = _currentWorkspace!.panels.fold<int>(
        0,
        (max, p) => p.zIndex > max ? p.zIndex : max,
      );
      final panel = getPanel(panelId);
      if (panel != null) {
        panel.bringToFront(maxZ);
        notifyListeners();
      }
    }
  }

  /// Update parameter value
  void updateParameter(String parameterId, double value) {
    _parameterValues[parameterId] = value;
    notifyListeners();
  }

  /// Get parameter value
  double getParameterValue(String parameterId) {
    return _parameterValues[parameterId] ?? 0.0;
  }

  /// Randomize all parameters
  void randomizeAllParameters() {
    final paramBank = ParameterBank();
    for (var param in paramBank.getAllParameters()) {
      final random = (param.max - param.min) * (0.2 + (0.6 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000));
      _parameterValues[param.id] = param.min + random;
    }
    notifyListeners();
  }

  /// Reset all parameters to defaults
  void resetAllParameters() {
    final paramBank = ParameterBank();
    for (var param in paramBank.getAllParameters()) {
      _parameterValues[param.id] = param.defaultValue;
    }
    notifyListeners();
  }

  /// Randomize parameters by category
  void randomizeCategory(ParameterCategory category) {
    final paramBank = ParameterBank();
    for (var param in paramBank.getByCategory(category)) {
      final random = (param.max - param.min) * (0.2 + (0.6 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000));
      _parameterValues[param.id] = param.min + random;
    }
    notifyListeners();
  }

  /// Switch active visualizer system
  void switchSystem(String systemId) {
    if (['faceted', 'quantum', 'holographic', 'polychora'].contains(systemId)) {
      _activeSystem = systemId;
      notifyListeners();
    }
  }

  /// Get effect chain for current system
  EffectChain getActiveEffectChain() {
    return _systemEffectChains[_activeSystem]!;
  }

  /// Get effect chain for specific system
  EffectChain getEffectChain(String systemId) {
    return _systemEffectChains[systemId]!;
  }

  /// Add effect to current system's chain
  void addEffectToChain(String effectId) {
    final chain = getActiveEffectChain();
    final instance = EffectInstance(
      id: 'effect_${DateTime.now().millisecondsSinceEpoch}',
      effectId: effectId,
    );
    chain.addEffect(instance);
    notifyListeners();
  }

  /// Remove effect from chain
  void removeEffectFromChain(String effectInstanceId) {
    final chain = getActiveEffectChain();
    chain.removeEffect(effectInstanceId);
    notifyListeners();
  }

  /// Reorder effects in chain
  void reorderEffectsInChain(int oldIndex, int newIndex) {
    final chain = getActiveEffectChain();
    chain.reorderEffect(oldIndex, newIndex);
    notifyListeners();
  }

  /// Toggle effect enabled state
  void toggleEffectEnabled(String effectInstanceId) {
    final chain = getActiveEffectChain();
    final effect = chain.getEffect(effectInstanceId);
    if (effect != null) {
      effect.enabled = !effect.enabled;
      notifyListeners();
    }
  }

  /// Export workspace to JSON
  String exportWorkspace() {
    if (_currentWorkspace == null) return '{}';

    final data = {
      'workspace': _currentWorkspace!.toJson(),
      'parameters': _parameterValues,
      'effectChains': _systemEffectChains.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'activeSystem': _activeSystem,
    };

    return jsonEncode(data);
  }

  /// Import workspace from JSON
  void importWorkspace(String jsonString) {
    try {
      final data = jsonDecode(jsonString);

      // Import workspace
      if (data['workspace'] != null) {
        final workspace = Workspace.fromJson(data['workspace']);
        _savedWorkspaces[workspace.id] = workspace;
        _currentWorkspace = workspace;
      }

      // Import parameters
      if (data['parameters'] != null) {
        _parameterValues.clear();
        (data['parameters'] as Map<String, dynamic>).forEach((key, value) {
          _parameterValues[key] = value.toDouble();
        });
      }

      // Import effect chains
      if (data['effectChains'] != null) {
        (data['effectChains'] as Map<String, dynamic>).forEach((key, value) {
          _systemEffectChains[key] = EffectChain.fromJson(value);
        });
      }

      // Import active system
      if (data['activeSystem'] != null) {
        _activeSystem = data['activeSystem'];
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing workspace: $e');
    }
  }

  /// Save pad configuration
  void savePadConfig(String padId, PadConfig config) {
    // Store in panel state
    final padMatrixPanel = _currentWorkspace?.panels.firstWhere(
      (p) => p.type == PanelType.padMatrix,
      orElse: () => throw Exception('Pad matrix panel not found'),
    );

    if (padMatrixPanel != null) {
      padMatrixPanel.state['pads'] ??= <String, dynamic>{};
      padMatrixPanel.state['pads'][padId] = config.toJson();
      notifyListeners();
    }
  }

  /// Get pad configuration
  PadConfig? getPadConfig(String padId) {
    final padMatrixPanel = _currentWorkspace?.panels.firstWhere(
      (p) => p.type == PanelType.padMatrix,
      orElse: () => throw Exception('Pad matrix panel not found'),
    );

    if (padMatrixPanel != null) {
      final padsData = padMatrixPanel.state['pads'] as Map<String, dynamic>?;
      if (padsData != null && padsData.containsKey(padId)) {
        return PadConfig.fromJson(padsData[padId]);
      }
    }
    return null;
  }

  /// Create snapshot of current state (for undo/redo)
  Map<String, dynamic> createSnapshot() {
    return {
      'workspace': _currentWorkspace?.toJson(),
      'parameters': Map<String, double>.from(_parameterValues),
      'effectChains': _systemEffectChains.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'activeSystem': _activeSystem,
      'mode': _mode.toString(),
    };
  }

  /// Restore from snapshot
  void restoreSnapshot(Map<String, dynamic> snapshot) {
    if (snapshot['workspace'] != null) {
      _currentWorkspace = Workspace.fromJson(snapshot['workspace']);
    }

    if (snapshot['parameters'] != null) {
      _parameterValues.clear();
      (snapshot['parameters'] as Map<String, dynamic>).forEach((key, value) {
        _parameterValues[key] = value.toDouble();
      });
    }

    if (snapshot['effectChains'] != null) {
      (snapshot['effectChains'] as Map<String, dynamic>).forEach((key, value) {
        _systemEffectChains[key] = EffectChain.fromJson(value);
      });
    }

    if (snapshot['activeSystem'] != null) {
      _activeSystem = snapshot['activeSystem'];
    }

    if (snapshot['mode'] != null) {
      _mode = WorkspaceMode.values.firstWhere(
        (m) => m.toString() == snapshot['mode'],
      );
    }

    notifyListeners();
  }
}
