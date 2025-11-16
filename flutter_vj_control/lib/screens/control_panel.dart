import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/visualizer_state.dart';
import '../models/preset_model.dart';
import '../models/parameter_model.dart';
import '../widgets/collapsible_panel.dart';
import '../widgets/parameter_slider.dart';

/// Control Panel Screen
/// Main VJ controls with parameters, system selector, and geometry
class ControlPanel extends StatelessWidget {
  const ControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<VisualizerState>(
      builder: (context, state, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // System Selector
              _SystemSelector(
                currentSystem: state.currentSystem,
                onSystemChanged: state.switchSystem,
              ),
              const SizedBox(height: 12),

              // Quick Actions
              _QuickActions(state: state),
              const SizedBox(height: 12),

              // Geometry Selector
              if (state.currentSystem != VisualizerSystem.holographic)
                CollapsiblePanel(
                  title: 'Geometry',
                  icon: Icons.category,
                  child: _GeometryGrid(
                    selectedGeometry: state.parameters.geometry,
                    onGeometrySelected: (index) {
                      state.parameters.geometry = index;
                      state.setParameters(state.parameters);
                    },
                  ),
                ),

              // 4D Rotation Controls
              CollapsiblePanel(
                title: '4D Rotation',
                icon: Icons.threed_rotation,
                child: Column(
                  children: [
                    ParameterSlider(
                      paramName: 'rot4dXW',
                      value: state.parameters.rot4dXW,
                      onChanged: (v) => state.updateParameter('rot4dXW', v),
                    ),
                    const SizedBox(height: 8),
                    ParameterSlider(
                      paramName: 'rot4dYW',
                      value: state.parameters.rot4dYW,
                      onChanged: (v) => state.updateParameter('rot4dYW', v),
                    ),
                    const SizedBox(height: 8),
                    ParameterSlider(
                      paramName: 'rot4dZW',
                      value: state.parameters.rot4dZW,
                      onChanged: (v) => state.updateParameter('rot4dZW', v),
                    ),
                  ],
                ),
              ),

              // Structure Controls
              CollapsiblePanel(
                title: 'Structure',
                icon: Icons.grid_on,
                child: Column(
                  children: [
                    ParameterSlider(
                      paramName: 'gridDensity',
                      value: state.parameters.gridDensity,
                      onChanged: (v) => state.updateParameter('gridDensity', v),
                    ),
                    const SizedBox(height: 8),
                    ParameterSlider(
                      paramName: 'morphFactor',
                      value: state.parameters.morphFactor,
                      onChanged: (v) => state.updateParameter('morphFactor', v),
                    ),
                    const SizedBox(height: 8),
                    ParameterSlider(
                      paramName: 'chaos',
                      value: state.parameters.chaos,
                      onChanged: (v) => state.updateParameter('chaos', v),
                    ),
                  ],
                ),
              ),

              // Dynamics Controls
              CollapsiblePanel(
                title: 'Dynamics',
                icon: Icons.speed,
                child: ParameterSlider(
                  paramName: 'speed',
                  value: state.parameters.speed,
                  onChanged: (v) => state.updateParameter('speed', v),
                ),
              ),

              // Color Controls
              CollapsiblePanel(
                title: 'Color',
                icon: Icons.palette,
                child: Column(
                  children: [
                    ParameterSlider(
                      paramName: 'hue',
                      value: state.parameters.hue,
                      onChanged: (v) => state.updateParameter('hue', v),
                    ),
                    const SizedBox(height: 8),
                    ParameterSlider(
                      paramName: 'intensity',
                      value: state.parameters.intensity,
                      onChanged: (v) => state.updateParameter('intensity', v),
                    ),
                    const SizedBox(height: 8),
                    ParameterSlider(
                      paramName: 'saturation',
                      value: state.parameters.saturation,
                      onChanged: (v) => state.updateParameter('saturation', v),
                    ),
                  ],
                ),
              ),

              // Interactivity Toggles
              CollapsiblePanel(
                title: 'Interactivity',
                icon: Icons.touch_app,
                initiallyExpanded: false,
                child: _InteractivityToggles(state: state),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// System Selector Widget
class _SystemSelector extends StatelessWidget {
  final VisualizerSystem currentSystem;
  final ValueChanged<VisualizerSystem> onSystemChanged;

  const _SystemSelector({
    required this.currentSystem,
    required this.onSystemChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: VisualizerSystem.values.map((system) {
          final isActive = system == currentSystem;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSystemChanged(system),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      system.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      system.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Quick Actions Widget
class _QuickActions extends StatelessWidget {
  final VisualizerState state;

  const _QuickActions({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => state.randomizeParameters(includeGeometry: false),
            icon: const Icon(Icons.shuffle, size: 18),
            label: const Text('Randomize'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => state.randomizeParameters(
              includeGeometry: true,
              includeHue: true,
            ),
            icon: const Icon(Icons.casino, size: 18),
            label: const Text('All Random'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.tertiary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.resetParameters,
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Geometry Grid Widget
class _GeometryGrid extends StatelessWidget {
  final int selectedGeometry;
  final ValueChanged<int> onGeometrySelected;

  const _GeometryGrid({
    required this.selectedGeometry,
    required this.onGeometrySelected,
  });

  static const geometryNames = [
    'Tetrahedron',
    'Hypercube',
    'Sphere',
    'Torus',
    'Klein Bottle',
    'Fractal',
    'Wave',
    'Crystal',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: geometryNames.length,
      itemBuilder: (context, index) {
        final isSelected = index == selectedGeometry;
        return GestureDetector(
          onTap: () => onGeometrySelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : theme.colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                geometryNames[index],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Interactivity Toggles Widget
class _InteractivityToggles extends StatelessWidget {
  final VisualizerState state;

  const _InteractivityToggles({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ToggleRow(
          label: 'Mouse Reactive',
          icon: Icons.mouse,
          value: state.mouseReactive,
          onChanged: (_) => state.toggleMouseReactive(),
        ),
        _ToggleRow(
          label: 'Device Tilt',
          icon: Icons.screen_rotation,
          value: state.deviceTilt,
          onChanged: (_) => state.toggleDeviceTilt(),
        ),
        _ToggleRow(
          label: 'Audio Reactive',
          icon: Icons.music_note,
          value: state.audioReactive,
          onChanged: (_) => state.toggleAudioReactive(),
        ),
        _ToggleRow(
          label: 'Enhanced FX',
          icon: Icons.auto_awesome,
          value: state.enhancedFX,
          onChanged: (_) => state.toggleEnhancedFX(),
        ),
        _ToggleRow(
          label: 'Accent Twin',
          icon: Icons.layers,
          value: state.accentTwin,
          onChanged: (_) => state.toggleAccentTwin(),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
