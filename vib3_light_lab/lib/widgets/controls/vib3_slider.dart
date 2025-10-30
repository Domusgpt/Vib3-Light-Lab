/// VIB3 Light Lab - Parameter Slider Widget
///
/// Glassmorphic slider with live value display and throttling.
/// Optimized for 60 FPS performance during parameter updates.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../providers/engine_provider.dart';

/// VIB3 Slider - Parameter control slider
class VIB3Slider extends ConsumerStatefulWidget {
  /// Parameter name
  final String parameter;

  /// Display label (defaults to parameter name)
  final String? label;

  /// Show current value
  final bool showValue;

  /// Value decimal places
  final int decimalPlaces;

  /// Enable haptic feedback
  final bool enableHaptics;

  /// Custom color
  final Color? color;

  const VIB3Slider({
    super.key,
    required this.parameter,
    this.label,
    this.showValue = true,
    this.decimalPlaces = 2,
    this.enableHaptics = true,
    this.color,
  });

  @override
  ConsumerState<VIB3Slider> createState() => _VIB3SliderState();
}

class _VIB3SliderState extends ConsumerState<VIB3Slider> {
  Timer? _throttleTimer;
  double? _localValue;

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(parameterProvider(widget.parameter));
    final range = VIB3Parameters.ranges[widget.parameter];

    if (range == null) {
      return const SizedBox.shrink();
    }

    final displayValue = _localValue ?? value;
    final sliderColor = widget.color ?? VIB3Colors.magenta;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VIB3Layout.paddingMedium,
        vertical: VIB3Layout.paddingSmall,
      ),
      decoration: VIB3Theme.glassContainer(
        borderColor: sliderColor.withOpacity(0.3),
        borderWidth: 1,
        borderRadius: VIB3Layout.borderRadiusSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label and Value Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label
              Text(
                widget.label ?? _formatParameterName(widget.parameter),
                style: VIB3TextStyles.label,
              ),

              // Current Value
              if (widget.showValue)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: sliderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: sliderColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    displayValue.toStringAsFixed(widget.decimalPlaces),
                    style: VIB3TextStyles.parameterValue.copyWith(
                      fontSize: 12,
                      color: sliderColor,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 4),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: sliderColor,
              inactiveTrackColor: sliderColor.withOpacity(0.2),
              thumbColor: VIB3Colors.cyan,
              overlayColor: VIB3Colors.cyan.withOpacity(0.3),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
                elevation: 4,
                pressedElevation: 6,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: displayValue,
              min: range.min,
              max: range.max,
              onChanged: _onSliderChanged,
              onChangeEnd: _onSliderChangeEnd,
            ),
          ),

          // Range indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  range.min.toStringAsFixed(widget.decimalPlaces),
                  style: VIB3TextStyles.label.copyWith(
                    fontSize: 8,
                    color: VIB3Colors.textDisabled,
                  ),
                ),
                Text(
                  range.max.toStringAsFixed(widget.decimalPlaces),
                  style: VIB3TextStyles.label.copyWith(
                    fontSize: 8,
                    color: VIB3Colors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle slider value change with throttling
  void _onSliderChanged(double value) {
    setState(() {
      _localValue = value;
    });

    // Throttle updates to 16ms (60 FPS)
    _throttleTimer?.cancel();
    _throttleTimer = Timer(const Duration(milliseconds: 16), () {
      _updateParameter(value);
    });
  }

  /// Handle slider change end - immediate update
  void _onSliderChangeEnd(double value) {
    _throttleTimer?.cancel();
    _updateParameter(value);
    setState(() {
      _localValue = null;
    });
  }

  /// Update parameter value
  void _updateParameter(double value) {
    ref.read(engineProvider.notifier).updateParameter(
          widget.parameter,
          value,
        );
  }

  /// Format parameter name for display
  String _formatParameterName(String name) {
    // Convert camelCase to Title Case
    final words = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );

    return words
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ')
        .trim();
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }
}

/// Compact VIB3 Slider - Smaller version for dense layouts
class CompactVIB3Slider extends StatelessWidget {
  final String parameter;
  final String? label;
  final Color? color;

  const CompactVIB3Slider({
    super.key,
    required this.parameter,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return VIB3Slider(
      parameter: parameter,
      label: label,
      showValue: true,
      decimalPlaces: 1,
      enableHaptics: false,
      color: color,
    );
  }
}

/// 4D Rotation Slider Group - Three rot4d sliders together
class Rotation4DSliderGroup extends StatelessWidget {
  const Rotation4DSliderGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: VIB3Theme.glassContainer(
        borderColor: VIB3Colors.purple.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(VIB3Layout.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4D ROTATION',
            style: VIB3TextStyles.h3.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          const VIB3Slider(
            parameter: VIB3Parameters.rot4dXW,
            label: 'X-W Plane',
            color: VIB3Colors.cyan,
          ),
          const SizedBox(height: 4),
          const VIB3Slider(
            parameter: VIB3Parameters.rot4dYW,
            label: 'Y-W Plane',
            color: VIB3Colors.magenta,
          ),
          const SizedBox(height: 4),
          const VIB3Slider(
            parameter: VIB3Parameters.rot4dZW,
            label: 'Z-W Plane',
            color: VIB3Colors.purple,
          ),
        ],
      ),
    );
  }
}
