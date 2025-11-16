import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/visualizer_state.dart';
import '../widgets/collapsible_panel.dart';
import '../widgets/audio_grid.dart';

/// Audio Panel Screen
/// Audio reactivity controls with 3x3 sensitivity × mode grid
class AudioPanel extends StatelessWidget {
  const AudioPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VisualizerState>(
      builder: (context, state, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Audio Status
              _AudioStatus(isActive: state.audioReactive),
              const SizedBox(height: 12),

              // Sensitivity & Mode Grid
              CollapsiblePanel(
                title: 'Audio Reactivity Matrix',
                icon: Icons.graphic_eq,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select sensitivity level and visual modes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 16),
                    AudioGrid(
                      currentSensitivity: state.audioSensitivity,
                      activeModes: state.activeAudioModes,
                      onCellToggle: (sensitivity, mode) {
                        state.setAudioSensitivity(sensitivity);
                        state.toggleAudioMode(mode);
                      },
                    ),
                  ],
                ),
              ),

              // Sensitivity Info
              CollapsiblePanel(
                title: 'Sensitivity Levels',
                icon: Icons.tune,
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AudioSensitivity.values.map((sensitivity) {
                    return _SensitivityInfo(
                      sensitivity: sensitivity,
                      isActive: state.audioSensitivity == sensitivity,
                    );
                  }).toList(),
                ),
              ),

              // Visual Mode Info
              CollapsiblePanel(
                title: 'Visual Modes',
                icon: Icons.visibility,
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AudioVisualMode.values.map((mode) {
                    return _VisualModeInfo(
                      mode: mode,
                      isActive: state.activeAudioModes.contains(mode),
                    );
                  }).toList(),
                ),
              ),

              // Quick Presets
              CollapsiblePanel(
                title: 'Quick Audio Presets',
                icon: Icons.music_note,
                initiallyExpanded: false,
                child: _AudioPresets(state: state),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Audio Status Widget
class _AudioStatus extends StatelessWidget {
  final bool isActive;

  const _AudioStatus({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  theme.colorScheme.primary.withOpacity(0.3),
                  theme.colorScheme.secondary.withOpacity(0.3),
                ]
              : [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface,
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.music_note : Icons.music_off,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.5),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'Audio Reactive' : 'Audio Disabled',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive
                      ? 'Visualizer responding to audio input'
                      : 'Enable in Control Panel to activate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sensitivity Info Widget
class _SensitivityInfo extends StatelessWidget {
  final AudioSensitivity sensitivity;
  final bool isActive;

  const _SensitivityInfo({
    required this.sensitivity,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${(sensitivity.multiplier * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sensitivity.displayName} Sensitivity',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${sensitivity.multiplier}x multiplier',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual Mode Info Widget
class _VisualModeInfo extends StatelessWidget {
  final AudioVisualMode mode;
  final bool isActive;

  const _VisualModeInfo({
    required this.mode,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColorForMode(mode);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? color.withOpacity(0.1)
            : theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForMode(mode),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                mode.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? color : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: mode.affectedParameters.map((param) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  param,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getColorForMode(AudioVisualMode mode) {
    switch (mode) {
      case AudioVisualMode.color:
        return Colors.pink;
      case AudioVisualMode.geometry:
        return Colors.purple;
      case AudioVisualMode.movement:
        return Colors.orange;
    }
  }

  IconData _getIconForMode(AudioVisualMode mode) {
    switch (mode) {
      case AudioVisualMode.color:
        return Icons.palette;
      case AudioVisualMode.geometry:
        return Icons.category;
      case AudioVisualMode.movement:
        return Icons.directions_run;
    }
  }
}

/// Audio Presets Widget
class _AudioPresets extends StatelessWidget {
  final VisualizerState state;

  const _AudioPresets({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PresetButton(
          label: 'Subtle Color Pulse',
          icon: Icons.blur_circular,
          onTap: () {
            state.setAudioSensitivity(AudioSensitivity.low);
            state.setAudioModes({AudioVisualMode.color});
          },
        ),
        const SizedBox(height: 8),
        _PresetButton(
          label: 'Dynamic Geometry',
          icon: Icons.grain,
          onTap: () {
            state.setAudioSensitivity(AudioSensitivity.medium);
            state.setAudioModes({AudioVisualMode.geometry});
          },
        ),
        const SizedBox(height: 8),
        _PresetButton(
          label: 'Intense Movement',
          icon: Icons.waves,
          onTap: () {
            state.setAudioSensitivity(AudioSensitivity.high);
            state.setAudioModes({AudioVisualMode.movement});
          },
        ),
        const SizedBox(height: 8),
        _PresetButton(
          label: 'Full Spectrum',
          icon: Icons.auto_awesome,
          onTap: () {
            state.setAudioSensitivity(AudioSensitivity.medium);
            state.setAudioModes(AudioVisualMode.values.toSet());
          },
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
