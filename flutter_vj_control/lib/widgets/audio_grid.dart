import 'package:flutter/material.dart';
import '../models/visualizer_state.dart';

/// Audio Reactivity Grid Widget
/// 3x3 grid for sensitivity × visual mode selection
class AudioGrid extends StatelessWidget {
  final AudioSensitivity currentSensitivity;
  final Set<AudioVisualMode> activeModes;
  final Function(AudioSensitivity, AudioVisualMode) onCellToggle;

  const AudioGrid({
    Key? key,
    required this.currentSensitivity,
    required this.activeModes,
    required this.onCellToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with visual mode labels
        Padding(
          padding: const EdgeInsets.only(left: 80, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: AudioVisualMode.values.map((mode) {
              return Expanded(
                child: Center(
                  child: Text(
                    mode.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Grid rows
        ...AudioSensitivity.values.map((sensitivity) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Sensitivity label
                SizedBox(
                  width: 70,
                  child: Text(
                    sensitivity.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Mode cells
                ...AudioVisualMode.values.map((mode) {
                  final isActive = currentSensitivity == sensitivity &&
                      activeModes.contains(mode);
                  return Expanded(
                    child: AudioGridCell(
                      isActive: isActive,
                      sensitivity: sensitivity,
                      mode: mode,
                      onTap: () => onCellToggle(sensitivity, mode),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

/// Individual cell in the audio reactivity grid
class AudioGridCell extends StatelessWidget {
  final bool isActive;
  final AudioSensitivity sensitivity;
  final AudioVisualMode mode;
  final VoidCallback onTap;

  const AudioGridCell({
    Key? key,
    required this.isActive,
    required this.sensitivity,
    required this.mode,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColorForMode(mode);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        height: 50,
        decoration: BoxDecoration(
          color: isActive
              ? color.withOpacity(0.3)
              : theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: isActive
              ? Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                )
              : Icon(
                  Icons.circle_outlined,
                  color: color.withOpacity(0.5),
                  size: 20,
                ),
        ),
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
}
