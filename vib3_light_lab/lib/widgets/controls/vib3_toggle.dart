/// VIB3 Light Lab - Toggle Switch Widget
///
/// Glassmorphic toggle switches for audio, interactivity, and other features.
/// Holographic design with glow effects.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../providers/engine_provider.dart';

/// VIB3 Toggle Type
enum VIB3ToggleType {
  audio,
  interactivity,
  deviceTilt,
  beatSync,
}

/// VIB3 Toggle - Feature toggle switch
class VIB3Toggle extends ConsumerWidget {
  /// Toggle type
  final VIB3ToggleType type;

  /// Custom label
  final String? label;

  /// Custom icon
  final IconData? icon;

  /// Show label
  final bool showLabel;

  /// Enable glow effect
  final bool enableGlow;

  const VIB3Toggle({
    super.key,
    required this.type,
    this.label,
    this.icon,
    this.showLabel = true,
    this.enableGlow = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);

    final isEnabled = switch (type) {
      VIB3ToggleType.audio => engineState.audioEnabled,
      VIB3ToggleType.interactivity => engineState.interactivityEnabled,
      VIB3ToggleType.deviceTilt => engineState.deviceTiltEnabled,
      VIB3ToggleType.beatSync => engineState.beatSyncEnabled,
    };

    final displayLabel = label ?? _getDefaultLabel();
    final displayIcon = icon ?? _getDefaultIcon();
    final accentColor = _getAccentColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VIB3Layout.paddingMedium,
        vertical: VIB3Layout.paddingSmall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEnabled
              ? [
                  accentColor.withOpacity(0.2),
                  accentColor.withOpacity(0.1),
                ]
              : [
                  VIB3Colors.glassBackground,
                  const Color(0x1100FFFF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(VIB3Layout.borderRadiusSmall),
        border: Border.all(
          color: isEnabled ? accentColor.withOpacity(0.5) : VIB3Colors.glassBorder,
          width: 2,
        ),
        boxShadow: enableGlow && isEnabled
            ? VIB3Theme.glowEffect(color: accentColor, blurRadius: 16)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and Label
          Row(
            children: [
              Icon(
                displayIcon,
                color: isEnabled ? accentColor : VIB3Colors.textDisabled,
                size: 20,
              ),
              if (showLabel) ...[
                const SizedBox(width: 12),
                Text(
                  displayLabel,
                  style: VIB3TextStyles.body1.copyWith(
                    color: isEnabled ? VIB3Colors.textPrimary : VIB3Colors.textSecondary,
                    fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),

          // Switch
          Switch(
            value: isEnabled,
            onChanged: (value) => _onToggled(ref, value),
            activeColor: VIB3Colors.cyan,
            activeTrackColor: accentColor.withOpacity(0.5),
            inactiveThumbColor: VIB3Colors.textDisabled,
            inactiveTrackColor: VIB3Colors.glassBorder,
          ),
        ],
      ),
    );
  }

  /// Handle toggle change
  void _onToggled(WidgetRef ref, bool enabled) {
    final notifier = ref.read(engineProvider.notifier);

    switch (type) {
      case VIB3ToggleType.audio:
        notifier.toggleAudio(enabled);
        break;
      case VIB3ToggleType.interactivity:
        notifier.toggleInteractivity(enabled);
        break;
      case VIB3ToggleType.deviceTilt:
        notifier.toggleDeviceTilt(enabled);
        break;
      case VIB3ToggleType.beatSync:
        // TODO: Implement beat sync toggle
        debugPrint('Beat sync toggle not yet implemented');
        break;
    }
  }

  /// Get default label for toggle type
  String _getDefaultLabel() {
    return switch (type) {
      VIB3ToggleType.audio => 'Audio Reactivity',
      VIB3ToggleType.interactivity => 'Mouse/Touch Control',
      VIB3ToggleType.deviceTilt => 'Device Tilt',
      VIB3ToggleType.beatSync => 'Beat Sync',
    };
  }

  /// Get default icon for toggle type
  IconData _getDefaultIcon() {
    return switch (type) {
      VIB3ToggleType.audio => Icons.graphic_eq,
      VIB3ToggleType.interactivity => Icons.touch_app,
      VIB3ToggleType.deviceTilt => Icons.screen_rotation,
      VIB3ToggleType.beatSync => Icons.sync,
    };
  }

  /// Get accent color for toggle type
  Color _getAccentColor() {
    return switch (type) {
      VIB3ToggleType.audio => VIB3Colors.magenta,
      VIB3ToggleType.interactivity => VIB3Colors.cyan,
      VIB3ToggleType.deviceTilt => VIB3Colors.purple,
      VIB3ToggleType.beatSync => VIB3Colors.pink,
    };
  }
}

/// Compact VIB3 Toggle - Icon-only version
class CompactVIB3Toggle extends StatelessWidget {
  final VIB3ToggleType type;
  final String? tooltip;

  const CompactVIB3Toggle({
    super.key,
    required this.type,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: VIB3Toggle(
        type: type,
        showLabel: false,
        enableGlow: false,
      ),
    );
  }
}

/// Toggle Group - Multiple toggles in a group
class VIB3ToggleGroup extends StatelessWidget {
  final List<VIB3ToggleType> toggles;
  final String? title;

  const VIB3ToggleGroup({
    super.key,
    required this.toggles,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: VIB3Theme.glassContainer(
        borderColor: VIB3Colors.glassBorder,
      ),
      padding: const EdgeInsets.all(VIB3Layout.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: VIB3TextStyles.h3,
            ),
            const SizedBox(height: 12),
          ],
          ...toggles.map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: VIB3Toggle(type: type),
              )),
        ],
      ),
    );
  }
}
