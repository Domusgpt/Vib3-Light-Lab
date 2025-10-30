/// VIB3 Light Lab - System Switcher Widget
///
/// Switches between 4 visualization systems: Faceted, Quantum, Holographic, Polychora.
/// Holographic design with active state indicators.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../providers/engine_provider.dart';

/// System Switcher Layout
enum SystemSwitcherLayout {
  horizontal,
  vertical,
  grid,
}

/// System Switcher - Switch between visualization systems
class SystemSwitcher extends ConsumerWidget {
  /// Layout style
  final SystemSwitcherLayout layout;

  /// Show system names
  final bool showNames;

  /// Show system icons
  final bool showIcons;

  /// Enable glow effect on active system
  final bool enableGlow;

  /// Compact mode (smaller buttons)
  final bool compact;

  const SystemSwitcher({
    super.key,
    this.layout = SystemSwitcherLayout.horizontal,
    this.showNames = true,
    this.showIcons = true,
    this.enableGlow = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSystem = ref.watch(currentSystemProvider);
    final isLoading = ref.watch(loadingProvider);

    final buttons = VIB3Systems.all.map((system) {
      return _SystemButton(
        system: system,
        isActive: currentSystem == system,
        isLoading: isLoading && currentSystem != system,
        showName: showNames,
        showIcon: showIcons,
        enableGlow: enableGlow,
        compact: compact,
        onTap: () => _switchSystem(ref, system),
      );
    }).toList();

    return Container(
      decoration: VIB3Theme.glassContainer(),
      padding: EdgeInsets.all(compact ? 8 : VIB3Layout.paddingMedium),
      child: switch (layout) {
        SystemSwitcherLayout.horizontal => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons
                .map((btn) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: btn,
                      ),
                    ))
                .toList(),
          ),
        SystemSwitcherLayout.vertical => Column(
            children: buttons
                .map((btn) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(width: double.infinity, child: btn),
                    ))
                .toList(),
          ),
        SystemSwitcherLayout.grid => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: buttons,
          ),
      },
    );
  }

  /// Switch system
  void _switchSystem(WidgetRef ref, String system) {
    ref.read(engineProvider.notifier).switchSystem(system);
  }
}

/// System Button - Individual system button
class _SystemButton extends StatelessWidget {
  final String system;
  final bool isActive;
  final bool isLoading;
  final bool showName;
  final bool showIcon;
  final bool enableGlow;
  final bool compact;
  final VoidCallback onTap;

  const _SystemButton({
    required this.system,
    required this.isActive,
    required this.isLoading,
    required this.showName,
    required this.showIcon,
    required this.enableGlow,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final systemInfo = _getSystemInfo(system);
    final accentColor = systemInfo.color;

    return AnimatedContainer(
      duration: VIB3Animations.fast,
      curve: VIB3Animations.defaultCurve,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  accentColor.withOpacity(0.3),
                  accentColor.withOpacity(0.15),
                ]
              : [
                  VIB3Colors.glassBackground,
                  const Color(0x1100FFFF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          compact ? 8 : VIB3Layout.borderRadiusSmall,
        ),
        border: Border.all(
          color: isActive ? accentColor : VIB3Colors.glassBorder,
          width: isActive ? 2 : 1,
        ),
        boxShadow: enableGlow && isActive
            ? VIB3Theme.glowEffect(color: accentColor)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(
            compact ? 8 : VIB3Layout.borderRadiusSmall,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : VIB3Layout.paddingMedium,
              vertical: compact ? 8 : VIB3Layout.paddingSmall,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                if (showIcon)
                  Icon(
                    systemInfo.icon,
                    color: isActive ? accentColor : VIB3Colors.textSecondary,
                    size: compact ? 24 : 32,
                  ),

                // Loading Indicator
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(accentColor),
                    ),
                  ),

                // Name
                if (showName && !isLoading) ...[
                  if (showIcon) const SizedBox(height: 4),
                  Text(
                    systemInfo.name,
                    style: (compact
                            ? VIB3TextStyles.label
                            : VIB3TextStyles.systemButton)
                        .copyWith(
                      color: isActive
                          ? VIB3Colors.textPrimary
                          : VIB3Colors.textSecondary,
                      fontSize: compact ? 10 : null,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Active Indicator
                if (isActive && !compact)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 24,
                    height: 2,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get system information
  _SystemInfo _getSystemInfo(String system) {
    return switch (system) {
      VIB3Systems.faceted => _SystemInfo(
          name: VIB3Systems.names[system]!,
          icon: Icons.grid_4x4,
          color: VIB3Colors.cyan,
        ),
      VIB3Systems.quantum => _SystemInfo(
          name: VIB3Systems.names[system]!,
          icon: Icons.bubble_chart,
          color: VIB3Colors.magenta,
        ),
      VIB3Systems.holographic => _SystemInfo(
          name: VIB3Systems.names[system]!,
          icon: Icons.auto_awesome,
          color: VIB3Colors.pink,
        ),
      VIB3Systems.polychora => _SystemInfo(
          name: VIB3Systems.names[system]!,
          icon: Icons.view_in_ar,
          color: VIB3Colors.purple,
        ),
      _ => _SystemInfo(
          name: system,
          icon: Icons.extension,
          color: VIB3Colors.cyan,
        ),
    };
  }
}

/// System Info - Internal data class
class _SystemInfo {
  final String name;
  final IconData icon;
  final Color color;

  const _SystemInfo({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Compact System Switcher - Minimal version
class CompactSystemSwitcher extends StatelessWidget {
  const CompactSystemSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return const SystemSwitcher(
      layout: SystemSwitcherLayout.horizontal,
      showNames: false,
      showIcons: true,
      enableGlow: false,
      compact: true,
    );
  }
}

/// Vertical System Switcher - For side panels
class VerticalSystemSwitcher extends StatelessWidget {
  const VerticalSystemSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return const SystemSwitcher(
      layout: SystemSwitcherLayout.vertical,
      showNames: true,
      showIcons: true,
      enableGlow: true,
    );
  }
}
