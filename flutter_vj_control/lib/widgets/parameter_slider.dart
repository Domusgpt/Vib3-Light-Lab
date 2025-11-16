import 'package:flutter/material.dart';
import '../models/parameter_model.dart';

/// Parameter Slider Widget
/// Professional VJ-style parameter control with real-time feedback
class ParameterSlider extends StatelessWidget {
  final String paramName;
  final double value;
  final ValueChanged<double> onChanged;
  final bool showValue;
  final Color? activeColor;

  const ParameterSlider({
    Key? key,
    required this.paramName,
    required this.value,
    required this.onChanged,
    this.showValue = true,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final def = ParameterModel.definitions[paramName];

    if (def == null) {
      return const SizedBox.shrink();
    }

    final displayValue = _formatValue(value, def);
    final normalizedValue = (value - def.min) / (def.max - def.min);
    final sliderColor = activeColor ?? _getColorForGroup(def.group, theme);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: sliderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                def.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showValue)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: sliderColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayValue,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: sliderColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: sliderColor,
              inactiveTrackColor: sliderColor.withOpacity(0.2),
              thumbColor: sliderColor,
              overlayColor: sliderColor.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: def.min,
              max: def.max,
              onChanged: onChanged,
            ),
          ),
          // Progress bar indicator
          SizedBox(
            height: 2,
            child: LinearProgressIndicator(
              value: normalizedValue,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(sliderColor.withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double value, ParameterDefinition def) {
    final formatted = value.toStringAsFixed(
      def.unit == '°' ? 0 : (value.abs() < 10 ? 2 : 1),
    );
    return '${formatted}${def.unit}';
  }

  Color _getColorForGroup(ParameterGroup group, ThemeData theme) {
    switch (group) {
      case ParameterGroup.rotation:
        return Colors.cyan;
      case ParameterGroup.structure:
        return Colors.purple;
      case ParameterGroup.dynamics:
        return Colors.orange;
      case ParameterGroup.color:
        return Colors.pink;
    }
  }
}

/// Compact Parameter Slider for grid layouts
class CompactParameterSlider extends StatelessWidget {
  final String paramName;
  final double value;
  final ValueChanged<double> onChanged;
  final Color? activeColor;

  const CompactParameterSlider({
    Key? key,
    required this.paramName,
    required this.value,
    required this.onChanged,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final def = ParameterModel.definitions[paramName];

    if (def == null) {
      return const SizedBox.shrink();
    }

    final displayValue = _formatValue(value, def);
    final sliderColor = activeColor ?? Colors.cyan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              def.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
            Text(
              displayValue,
              style: theme.textTheme.bodySmall?.copyWith(
                color: sliderColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: sliderColor,
            inactiveTrackColor: sliderColor.withOpacity(0.2),
            thumbColor: sliderColor,
            overlayColor: sliderColor.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: def.min,
            max: def.max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _formatValue(double value, ParameterDefinition def) {
    final formatted = value.toStringAsFixed(
      def.unit == '°' ? 0 : (value.abs() < 10 ? 1 : 0),
    );
    return '${formatted}${def.unit}';
  }
}
