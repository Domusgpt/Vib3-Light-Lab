import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/workspace_manager.dart';
import 'widgets/resizable_panel.dart';
import 'panels/visualizer_panel.dart';
import 'panels/pad_matrix_panel.dart';
import 'panels/parameter_inspector_panel.dart';
import 'panels/layer_mixer_panel.dart';
import 'models/panel_config.dart';

void main() {
  runApp(const VIB34DVJControlApp());
}

class VIB34DVJControlApp extends StatelessWidget {
  const VIB34DVJControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkspaceManager(),
      child: MaterialApp(
        title: 'VIB34D VJ Control Suite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Inter',
        ),
        home: const VJControlHome(),
      ),
    );
  }
}

class VJControlHome extends StatefulWidget {
  const VJControlHome({super.key});

  @override
  State<VJControlHome> createState() => _VJControlHomeState();
}

class _VJControlHomeState extends State<VJControlHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WorkspaceManager>(
        builder: (context, workspaceManager, child) {
          final workspace = workspaceManager.currentWorkspace;

          if (workspace == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Update workspace manager with screen size
              WidgetsBinding.instance.addPostFrameCallback((_) {
                workspaceManager.updateScreenSize(
                  Size(constraints.maxWidth, constraints.maxHeight),
                );
              });

              return Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.purple.withOpacity(0.1),
                          Colors.black,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),

                  // Top menu bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildMenuBar(workspaceManager),
                  ),

                  // Panels
                  ...workspace.panels.map((panelConfig) {
                    return ResizablePanel(
                      key: ValueKey(panelConfig.id),
                      config: panelConfig,
                      child: _buildPanelContent(panelConfig.type),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Build menu bar
  Widget _buildMenuBar(WorkspaceManager workspaceManager) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.blue.withOpacity(0.2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Logo
          const Text(
            'VIB34D',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'VJ CONTROL SUITE',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),

          // Workspace selector
          _buildWorkspaceMenu(workspaceManager),
          const SizedBox(width: 16),

          // Mode toggle
          _buildModeToggle(workspaceManager),
          const SizedBox(width: 16),

          // Panel visibility toggles
          _buildPanelToggles(workspaceManager),
          const SizedBox(width: 16),

          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings dialog
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// Build workspace dropdown menu
  Widget _buildWorkspaceMenu(WorkspaceManager workspaceManager) {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              workspaceManager.currentWorkspace?.name ?? 'Workspace',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) {
        return workspaceManager.savedWorkspaces.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Text(entry.value.name),
          );
        }).toList();
      },
      onSelected: (workspaceId) {
        workspaceManager.switchWorkspace(workspaceId);
      },
    );
  }

  /// Build mode toggle
  Widget _buildModeToggle(WorkspaceManager workspaceManager) {
    final isPerformance = workspaceManager.mode == WorkspaceMode.performance;

    return InkWell(
      onTap: () {
        workspaceManager.toggleMode();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPerformance
              ? Colors.purple.withOpacity(0.6)
              : Colors.blue.withOpacity(0.6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              isPerformance ? Icons.play_arrow : Icons.settings,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isPerformance ? 'Performance' : 'Setup',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build panel visibility toggles
  Widget _buildPanelToggles(WorkspaceManager workspaceManager) {
    return Row(
      children: [
        _buildPanelToggle(
          workspaceManager,
          PanelType.visualizer,
          Icons.visibility,
          'Visualizer',
        ),
        const SizedBox(width: 4),
        _buildPanelToggle(
          workspaceManager,
          PanelType.padMatrix,
          Icons.apps,
          'Pads',
        ),
        const SizedBox(width: 4),
        _buildPanelToggle(
          workspaceManager,
          PanelType.parameterInspector,
          Icons.tune,
          'Parameters',
        ),
        const SizedBox(width: 4),
        _buildPanelToggle(
          workspaceManager,
          PanelType.layerMixer,
          Icons.layers,
          'Mixer',
        ),
      ],
    );
  }

  /// Build individual panel toggle
  Widget _buildPanelToggle(
    WorkspaceManager workspaceManager,
    PanelType type,
    IconData icon,
    String tooltip,
  ) {
    final panel = workspaceManager.currentWorkspace?.panels.firstWhere(
      (p) => p.type == type,
      orElse: () => throw Exception('Panel not found'),
    );

    final isVisible = panel?.isVisible ?? false;

    return IconButton(
      icon: Icon(
        icon,
        color: isVisible ? Colors.white : Colors.white30,
      ),
      onPressed: () {
        if (panel != null) {
          workspaceManager.togglePanelVisibility(panel.id);
        }
      },
      tooltip: tooltip,
    );
  }

  /// Build panel content based on type
  Widget _buildPanelContent(PanelType type) {
    switch (type) {
      case PanelType.visualizer:
        return const VisualizerPanel();
      case PanelType.padMatrix:
        return const PadMatrixPanel();
      case PanelType.parameterInspector:
        return const ParameterInspectorPanel();
      case PanelType.layerMixer:
        return const LayerMixerPanel();
      case PanelType.effectBank:
        return const Center(child: Text('Effect Bank Panel'));
      case PanelType.timeline:
        return const Center(child: Text('Timeline Panel'));
      case PanelType.mediaBrowser:
        return const Center(child: Text('Media Browser Panel'));
      case PanelType.audioAnalyzer:
        return const Center(child: Text('Audio Analyzer Panel'));
      case PanelType.hardwareBridge:
        return const Center(child: Text('Hardware Bridge Panel'));
      case PanelType.telemetry:
        return const Center(child: Text('Telemetry Panel'));
    }
  }
}
