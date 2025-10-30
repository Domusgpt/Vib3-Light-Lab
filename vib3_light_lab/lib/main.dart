/// VIB3 Light Lab - Main Application
///
/// Flutter-based live VJ performance controller for VIB34D visualizations.
/// Professional-grade interface for controlling 4D WebGL shaders in real-time.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme.dart';
import 'config/constants.dart';
import 'widgets/displays/webgl_view.dart';
import 'widgets/controls/system_switcher.dart';
import 'widgets/controls/vib3_slider.dart';
import 'widgets/controls/vib3_toggle.dart';
import 'widgets/controls/geometry_selector.dart';
import 'providers/engine_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations and system UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: VIB3Colors.darkNavy,
    ),
  );

  runApp(
    const ProviderScope(
      child: VIB3LightLabApp(),
    ),
  );
}

/// Main Application Widget
class VIB3LightLabApp extends StatelessWidget {
  const VIB3LightLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIB3 Light Lab',
      debugShowCheckedModeBanner: false,
      theme: VIB3Theme.darkTheme,
      home: const MainScreen(),
    );
  }
}

/// Main Screen - Primary application interface
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: VIB3Colors.darkNavy,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: VIB3Colors.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isDesktop
              ? _buildDesktopLayout()
              : isTablet
                  ? _buildTabletLayout()
                  : _buildMobileLayout(),
        ),
      ),
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              backgroundColor: VIB3Colors.magenta,
              child: Icon(
                _showControls ? Icons.close : Icons.tune,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  /// Desktop Layout - Side panels with main view
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Control Panel
        SizedBox(
          width: VIB3Layout.panelWidth,
          child: _buildLeftPanel(),
        ),

        // Main Visualization View
        Expanded(
          child: _buildMainView(),
        ),

        // Right Control Panel
        SizedBox(
          width: VIB3Layout.panelWidth,
          child: _buildRightPanel(),
        ),
      ],
    );
  }

  /// Tablet Layout - Bottom sheet controls
  Widget _buildTabletLayout() {
    return Stack(
      children: [
        _buildMainView(),
        if (_showControls)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    VIB3Colors.darkPurple.withOpacity(0.95),
                    VIB3Colors.deepPurple.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: const Border(
                  top: BorderSide(color: VIB3Colors.magenta, width: 2),
                ),
              ),
              child: _buildCompactControls(),
            ),
          ),
      ],
    );
  }

  /// Mobile Layout - Full screen with drawer
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        _buildMainView(),
        if (_showControls)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 350),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    VIB3Colors.darkPurple.withOpacity(0.98),
                    VIB3Colors.deepPurple.withOpacity(0.98),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: const Border(
                  top: BorderSide(color: VIB3Colors.cyan, width: 2),
                ),
              ),
              child: _buildMobileControls(),
            ),
          ),
      ],
    );
  }

  /// Main Visualization View
  Widget _buildMainView() {
    return Column(
      children: [
        // Header with System Switcher
        Container(
          padding: const EdgeInsets.all(VIB3Layout.paddingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                VIB3Colors.darkPurple.withOpacity(0.8),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Title
              VIB3Theme.holographicText(
                child: const Text(
                  'VIB3 LIGHT LAB',
                  style: VIB3TextStyles.h1,
                ),
              ),
              const SizedBox(height: 12),
              // System Switcher
              const SystemSwitcher(
                layout: SystemSwitcherLayout.horizontal,
              ),
            ],
          ),
        ),

        // WebGL View
        const Expanded(
          child: AutoWebGLView(),
        ),
      ],
    );
  }

  /// Left Panel - 4D Rotations and Geometry
  Widget _buildLeftPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            VIB3Colors.darkPurple.withOpacity(0.8),
            VIB3Colors.darkNavy.withOpacity(0.8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: const Border(
          right: BorderSide(color: VIB3Colors.glassBorder),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(VIB3Layout.paddingMedium),
        children: [
          // 4D Rotation Controls
          const Rotation4DSliderGroup(),
          const SizedBox(height: 16),

          // Geometry Selector
          const GeometrySelector(),
          const SizedBox(height: 16),

          // Grid Density
          const VIB3Slider(
            parameter: VIB3Parameters.gridDensity,
            label: 'Grid Density',
            color: VIB3Colors.cyan,
          ),
        ],
      ),
    );
  }

  /// Right Panel - Visual Parameters and Toggles
  Widget _buildRightPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            VIB3Colors.darkPurple.withOpacity(0.8),
            VIB3Colors.darkNavy.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: const Border(
          left: BorderSide(color: VIB3Colors.glassBorder),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(VIB3Layout.paddingMedium),
        children: [
          // Visual Parameters
          const VIB3Slider(
            parameter: VIB3Parameters.hue,
            label: 'Color Hue',
            color: VIB3Colors.magenta,
          ),
          const SizedBox(height: 12),
          const VIB3Slider(
            parameter: VIB3Parameters.saturation,
            label: 'Saturation',
            color: VIB3Colors.pink,
          ),
          const SizedBox(height: 12),
          const VIB3Slider(
            parameter: VIB3Parameters.intensity,
            label: 'Intensity',
            color: VIB3Colors.cyan,
          ),
          const SizedBox(height: 12),
          const VIB3Slider(
            parameter: VIB3Parameters.speed,
            label: 'Animation Speed',
            color: VIB3Colors.purple,
          ),
          const SizedBox(height: 12),
          const VIB3Slider(
            parameter: VIB3Parameters.morphFactor,
            label: 'Morph Factor',
            color: VIB3Colors.magenta,
          ),
          const SizedBox(height: 12),
          const VIB3Slider(
            parameter: VIB3Parameters.chaos,
            label: 'Chaos',
            color: VIB3Colors.pink,
          ),

          const SizedBox(height: 24),

          // Feature Toggles
          const VIB3ToggleGroup(
            title: 'FEATURES',
            toggles: [
              VIB3ToggleType.audio,
              VIB3ToggleType.interactivity,
              VIB3ToggleType.deviceTilt,
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Compact Controls - For tablet
  Widget _buildCompactControls() {
    return ListView(
      padding: const EdgeInsets.all(VIB3Layout.paddingMedium),
      children: [
        // Drag Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: VIB3Colors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Key Parameters
        const VIB3Slider(parameter: VIB3Parameters.hue),
        const SizedBox(height: 8),
        const VIB3Slider(parameter: VIB3Parameters.intensity),
        const SizedBox(height: 8),
        const VIB3Slider(parameter: VIB3Parameters.speed),

        const SizedBox(height: 16),

        // Geometry Selector
        const CompactGeometrySelector(),

        const SizedBox(height: 16),

        // Toggles
        Row(
          children: [
            Expanded(
              child: CompactVIB3Toggle(
                type: VIB3ToggleType.audio,
                tooltip: 'Audio Reactivity',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CompactVIB3Toggle(
                type: VIB3ToggleType.interactivity,
                tooltip: 'Mouse Control',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Mobile Controls - For mobile phones
  Widget _buildMobileControls() {
    return ListView(
      padding: const EdgeInsets.all(VIB3Layout.paddingSmall),
      children: [
        // Drag Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: VIB3Colors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Compact Geometry
        const CompactGeometrySelector(),

        const SizedBox(height: 12),

        // Essential Sliders
        CompactVIB3Slider(parameter: VIB3Parameters.hue),
        const SizedBox(height: 6),
        CompactVIB3Slider(parameter: VIB3Parameters.speed),

        const SizedBox(height: 12),

        // Quick Actions
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.shuffle,
                label: 'Randomize',
                color: VIB3Colors.magenta,
                onTap: () =>
                    ref.read(engineProvider.notifier).randomizeAll(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.restart_alt,
                label: 'Reset',
                color: VIB3Colors.cyan,
                onTap: () => ref.read(engineProvider.notifier).resetAll(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Action Buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.shuffle,
          label: 'Randomize All',
          color: VIB3Colors.magenta,
          onTap: () => ref.read(engineProvider.notifier).randomizeAll(),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          icon: Icons.restart_alt,
          label: 'Reset All',
          color: VIB3Colors.cyan,
          onTap: () => ref.read(engineProvider.notifier).resetAll(),
        ),
      ],
    );
  }

  /// Build Action Button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: VIB3Theme.glassContainer(borderColor: color),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(VIB3Layout.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(VIB3Layout.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: VIB3TextStyles.systemButton.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build Quick Action Button (compact)
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: VIB3Theme.glassContainer(
        borderColor: color,
        borderRadius: 8,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: VIB3TextStyles.label.copyWith(
                    color: color,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
