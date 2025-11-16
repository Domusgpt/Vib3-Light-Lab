import 'package:flutter/material.dart';
import '../core/parameter_bank.dart';
import '../core/workspace_manager.dart';

/// Smart parameter slider with automation and visual feedback
class ParameterSlider extends StatefulWidget {
  final ParameterDef parameter;
  final double value;
  final Function(double)? onChanged;
  final bool showLabel;
  final bool showValue;
  final bool compact;

  const ParameterSlider({
    super.key,
    required this.parameter,
    required this.value,
    this.onChanged,
    this.showLabel = true,
    this.showValue = true,
    this.compact = false,
  });

  @override
  State<ParameterSlider> createState() => _ParameterSliderState();
}

class _ParameterSliderState extends State<ParameterSlider> {
  final WorkspaceManager _workspaceManager = WorkspaceManager();
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactSlider();
    }
    return _buildFullSlider();
  }

  /// Build full slider with label and value
  Widget _buildFullSlider() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.purple.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label and value row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.showLabel)
                  Text(
                    widget.parameter.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (widget.showValue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.value.toStringAsFixed(2)}${widget.parameter.unit}',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Slider with custom track
            SizedBox(
              height: 30,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                  activeTrackColor: Colors.purple,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbColor: Colors.white,
                  overlayColor: Colors.purple.withOpacity(0.3),
                ),
                child: Slider(
                  value: widget.value,
                  min: widget.parameter.min,
                  max: widget.parameter.max,
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    _workspaceManager.updateParameter(widget.parameter.id, value);
                  },
                ),
              ),
            ),
            // Quick actions
            if (_isHovered) _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  /// Build compact slider (minimal version)
  Widget _buildCompactSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          if (widget.showLabel)
            SizedBox(
              width: 100,
              child: Text(
                widget.parameter.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 12,
                ),
                activeTrackColor: Colors.purple,
                inactiveTrackColor: Colors.white.withOpacity(0.2),
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: widget.value,
                min: widget.parameter.min,
                max: widget.parameter.max,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  _workspaceManager.updateParameter(widget.parameter.id, value);
                },
              ),
            ),
          ),
          if (widget.showValue)
            SizedBox(
              width: 60,
              child: Text(
                '${widget.value.toStringAsFixed(1)}${widget.parameter.unit}',
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  /// Build quick action buttons
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.refresh,
            label: 'Reset',
            onPressed: () {
              widget.onChanged?.call(widget.parameter.defaultValue);
              _workspaceManager.updateParameter(
                widget.parameter.id,
                widget.parameter.defaultValue,
              );
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.shuffle,
            label: 'Random',
            onPressed: () {
              final random = widget.parameter.min +
                  (widget.parameter.max - widget.parameter.min) *
                      (DateTime.now().millisecondsSinceEpoch % 1000) /
                      1000;
              widget.onChanged?.call(random);
              _workspaceManager.updateParameter(widget.parameter.id, random);
            },
          ),
        ],
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
