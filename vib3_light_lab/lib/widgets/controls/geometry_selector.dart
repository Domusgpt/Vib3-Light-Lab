/// VIB3 Light Lab - Geometry Selector Widget
///
/// Visual selector for 8 4D geometries.
/// Grid layout with visual icons and holographic effects.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../providers/engine_provider.dart';

/// Geometry Selector - Select from 8 4D geometries
class GeometrySelector extends ConsumerWidget {
  /// Grid columns
  final int columns;

  /// Show geometry names
  final bool showNames;

  /// Compact mode
  final bool compact;

  const GeometrySelector({
    super.key,
    this.columns = 4,
    this.showNames = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGeometry = ref.watch(parameterProvider(VIB3Parameters.geometry)).round();

    return Container(
      decoration: VIB3Theme.glassContainer(),
      padding: EdgeInsets.all(compact ? 8 : VIB3Layout.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GEOMETRY',
                  style: VIB3TextStyles.h3.copyWith(fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: VIB3Colors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: VIB3Colors.cyan.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    VIB3Geometries.names[currentGeometry] ?? 'Unknown',
                    style: VIB3TextStyles.label.copyWith(
                      color: VIB3Colors.cyan,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: compact ? 4 : 8,
            crossAxisSpacing: compact ? 4 : 8,
            childAspectRatio: compact ? 1.2 : 1.0,
            children: List.generate(
              8,
              (index) => _GeometryButton(
                index: index,
                isSelected: currentGeometry == index,
                showName: showNames,
                compact: compact,
                onTap: () => _selectGeometry(ref, index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Select geometry
  void _selectGeometry(WidgetRef ref, int index) {
    ref.read(engineProvider.notifier).selectGeometry(index);
  }
}

/// Geometry Button - Individual geometry button
class _GeometryButton extends StatelessWidget {
  final int index;
  final bool isSelected;
  final bool showName;
  final bool compact;
  final VoidCallback onTap;

  const _GeometryButton({
    required this.index,
    required this.isSelected,
    required this.showName,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final geometryInfo = _getGeometryInfo(index);
    final accentColor = geometryInfo.color;

    return AnimatedContainer(
      duration: VIB3Animations.fast,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
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
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(
          color: isSelected ? accentColor : VIB3Colors.glassBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: compact ? 8 : 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 6 : 8),
          child: Padding(
            padding: EdgeInsets.all(compact ? 4 : 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  geometryInfo.icon,
                  color: isSelected ? accentColor : VIB3Colors.textSecondary,
                  size: compact ? 20 : 28,
                ),
                if (showName) ...[
                  SizedBox(height: compact ? 2 : 4),
                  Text(
                    geometryInfo.name,
                    style: VIB3TextStyles.label.copyWith(
                      fontSize: compact ? 8 : 9,
                      color: isSelected
                          ? VIB3Colors.textPrimary
                          : VIB3Colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get geometry information
  _GeometryInfo _getGeometryInfo(int index) {
    final name = VIB3Geometries.names[index] ?? 'Unknown';

    return switch (index) {
      0 => _GeometryInfo(
          // Hypercube
          name: name,
          icon: Icons.view_in_ar,
          color: VIB3Colors.cyan,
        ),
      1 => _GeometryInfo(
          // Hypertetrahedron
          name: name,
          icon: Icons.change_history,
          color: VIB3Colors.magenta,
        ),
      2 => _GeometryInfo(
          // Hypersphere
          name: name,
          icon: Icons.circle_outlined,
          color: VIB3Colors.purple,
        ),
      3 => _GeometryInfo(
          // Torus
          name: name,
          icon: Icons.donut_large,
          color: VIB3Colors.pink,
        ),
      4 => _GeometryInfo(
          // Klein Bottle
          name: name,
          icon: Icons.all_inclusive,
          color: VIB3Colors.electricBlue,
        ),
      5 => _GeometryInfo(
          // Crystal
          name: name,
          icon: Icons.diamond_outlined,
          color: VIB3Colors.cyan,
        ),
      6 => _GeometryInfo(
          // Fractal
          name: name,
          icon: Icons.auto_awesome,
          color: VIB3Colors.magenta,
        ),
      7 => _GeometryInfo(
          // Wave
          name: name,
          icon: Icons.waves,
          color: VIB3Colors.purple,
        ),
      _ => _GeometryInfo(
          name: name,
          icon: Icons.help_outline,
          color: VIB3Colors.cyan,
        ),
    };
  }
}

/// Geometry Info - Internal data class
class _GeometryInfo {
  final String name;
  final IconData icon;
  final Color color;

  const _GeometryInfo({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Compact Geometry Selector - Minimal version
class CompactGeometrySelector extends StatelessWidget {
  const CompactGeometrySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeometrySelector(
      columns: 4,
      showNames: false,
      compact: true,
    );
  }
}
