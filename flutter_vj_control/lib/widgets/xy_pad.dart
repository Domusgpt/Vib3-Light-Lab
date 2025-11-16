import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/pad_config.dart';
import '../core/workspace_manager.dart';
import '../core/parameter_bank.dart';

/// Multi-touch XY pad controller
/// Professional Kaoss Pad-style controller with visual feedback
class XYPad extends StatefulWidget {
  final PadConfig config;
  final Function(String parameterId, double value)? onParameterChange;

  const XYPad({
    super.key,
    required this.config,
    this.onParameterChange,
  });

  @override
  State<XYPad> createState() => _XYPadState();
}

class _XYPadState extends State<XYPad> with SingleTickerProviderStateMixin {
  final WorkspaceManager _workspaceManager = WorkspaceManager();
  final ParameterBank _parameterBank = ParameterBank();

  // Touch state
  final Map<int, TouchPoint> _touches = {};
  Offset _center = Offset.zero;
  double _spread = 0.0;

  // Visual feedback
  late AnimationController _pulseController;
  final List<TouchTrail> _trails = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.config.size.toSize();

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.05),
            Colors.black,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: _touches.isEmpty
              ? Colors.white.withOpacity(0.2)
              : Colors.purple.withOpacity(0.8),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Grid background
            _buildGrid(),
            // Touch area
            Positioned.fill(
              child: GestureDetector(
                onPanStart: _onTouchStart,
                onPanUpdate: _onTouchUpdate,
                onPanEnd: _onTouchEnd,
                onPanCancel: _onTouchCancel,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Touch trails
            ..._buildTouchTrails(),
            // Touch points
            ..._buildTouchPoints(),
            // Center indicator
            if (_touches.length > 1) _buildCenterIndicator(),
            // Spread lines
            if (_touches.length > 1) _buildSpreadLines(),
            // Value overlays
            ..._buildValueOverlays(),
            // Label
            _buildLabel(),
          ],
        ),
      ),
    );
  }

  /// Build grid background
  Widget _buildGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(),
    );
  }

  /// Build touch trails (motion blur effect)
  List<Widget> _buildTouchTrails() {
    return _trails.map((trail) {
      return Positioned(
        left: trail.position.dx - 15,
        top: trail.position.dy - 15,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: trail.color.withOpacity(trail.opacity * 0.3),
          ),
        ),
      );
    }).toList();
  }

  /// Build touch points
  List<Widget> _buildTouchPoints() {
    return _touches.entries.map((entry) {
      final index = entry.key;
      final touch = entry.value;

      // Color-coded by finger index
      final color = _getTouchColor(index);

      return Positioned(
        left: touch.position.dx - 25,
        top: touch.position.dy - 25,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = (math.sin(_pulseController.value * 2 * math.pi) + 1) / 2;
            return Container(
              width: 50 + (pulse * 10),
              height: 50 + (pulse * 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.3),
                    color.withOpacity(0.0),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.8),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  /// Build center indicator (average of all touches)
  Widget _buildCenterIndicator() {
    return Positioned(
      left: _center.dx - 10,
      top: _center.dy - 10,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.8),
          border: Border.all(color: Colors.purple, width: 2),
        ),
      ),
    );
  }

  /// Build spread lines (connecting touches)
  Widget _buildSpreadLines() {
    return CustomPaint(
      size: Size.infinite,
      painter: SpreadLinesPainter(_touches.values.toList(), _center),
    );
  }

  /// Build value overlays
  List<Widget> _buildValueOverlays() {
    final overlays = <Widget>[];

    // X-axis value
    if (widget.config.xAxis.parameter.isNotEmpty) {
      final xValue = _calculateNormalizedX(_center);
      final xParam = _parameterBank.getById(widget.config.xAxis.parameter);
      if (xParam != null) {
        final denormalized = xParam.denormalize(xValue);
        overlays.add(
          Positioned(
            bottom: 10,
            right: 10,
            child: _buildValueChip('X: ${denormalized.toStringAsFixed(2)}${xParam.unit}'),
          ),
        );
      }
    }

    // Y-axis value
    if (widget.config.yAxis.parameter.isNotEmpty) {
      final yValue = _calculateNormalizedY(_center);
      final yParam = _parameterBank.getById(widget.config.yAxis.parameter);
      if (yParam != null) {
        final denormalized = yParam.denormalize(yValue);
        overlays.add(
          Positioned(
            bottom: 40,
            right: 10,
            child: _buildValueChip('Y: ${denormalized.toStringAsFixed(2)}${yParam.unit}'),
          ),
        );
      }
    }

    // Spread value
    if (widget.config.spreadAxis.parameter.isNotEmpty && _touches.length > 1) {
      final spreadParam = _parameterBank.getById(widget.config.spreadAxis.parameter);
      if (spreadParam != null) {
        final denormalized = spreadParam.denormalize(_spread);
        overlays.add(
          Positioned(
            bottom: 70,
            right: 10,
            child: _buildValueChip('Spread: ${denormalized.toStringAsFixed(2)}${spreadParam.unit}'),
          ),
        );
      }
    }

    return overlays;
  }

  /// Build value chip widget
  Widget _buildValueChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build pad label
  Widget _buildLabel() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.config.label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Handle touch start
  void _onTouchStart(DragStartDetails details) {
    _updateTouch(0, details.localPosition);
  }

  /// Handle touch update
  void _onTouchUpdate(DragUpdateDetails details) {
    _updateTouch(0, details.localPosition);
  }

  /// Handle touch end
  void _onTouchEnd(DragEndDetails details) {
    _removeTouch(0);
  }

  /// Handle touch cancel
  void _onTouchCancel() {
    _removeTouch(0);
  }

  /// Update touch position
  void _updateTouch(int pointerId, Offset position) {
    setState(() {
      // Add touch trail
      if (_touches.containsKey(pointerId)) {
        final oldPos = _touches[pointerId]!.position;
        _trails.add(TouchTrail(
          position: oldPos,
          color: _getTouchColor(pointerId),
          opacity: 1.0,
        ));
        // Keep only recent trails
        if (_trails.length > 20) {
          _trails.removeAt(0);
        }
      }

      _touches[pointerId] = TouchPoint(position: position);
      _updateCenter();
      _updateSpread();
      _sendParameterUpdates();
    });

    // Fade out trails
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        for (var trail in _trails) {
          trail.opacity *= 0.9;
        }
        _trails.removeWhere((trail) => trail.opacity < 0.1);
      });
    });
  }

  /// Remove touch
  void _removeTouch(int pointerId) {
    setState(() {
      _touches.remove(pointerId);
      _updateCenter();
      _updateSpread();
    });
  }

  /// Update center point (average of all touches)
  void _updateCenter() {
    if (_touches.isEmpty) {
      _center = Offset.zero;
      return;
    }

    double sumX = 0;
    double sumY = 0;
    for (var touch in _touches.values) {
      sumX += touch.position.dx;
      sumY += touch.position.dy;
    }

    _center = Offset(
      sumX / _touches.length,
      sumY / _touches.length,
    );
  }

  /// Update spread (distance between touches)
  void _updateSpread() {
    if (_touches.length < 2) {
      _spread = 0.0;
      return;
    }

    // Calculate average distance from center
    double totalDistance = 0;
    for (var touch in _touches.values) {
      final distance = (touch.position - _center).distance;
      totalDistance += distance;
    }

    // Normalize spread to 0-1 based on pad size
    final size = widget.config.size.toSize();
    final maxDistance = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    _spread = (totalDistance / _touches.length) / maxDistance;
    _spread = _spread.clamp(0.0, 1.0);
  }

  /// Send parameter updates to workspace manager
  void _sendParameterUpdates() {
    final size = widget.config.size.toSize();
    final renderBox = context.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      // X-axis
      if (widget.config.xAxis.parameter.isNotEmpty) {
        var normalizedX = _calculateNormalizedX(_center);
        if (widget.config.xAxis.invert) normalizedX = 1.0 - normalizedX;

        final xParam = _parameterBank.getById(widget.config.xAxis.parameter);
        if (xParam != null) {
          final value = xParam.denormalize(normalizedX);
          _workspaceManager.updateParameter(widget.config.xAxis.parameter, value);
          widget.onParameterChange?.call(widget.config.xAxis.parameter, value);
        }
      }

      // Y-axis
      if (widget.config.yAxis.parameter.isNotEmpty) {
        var normalizedY = _calculateNormalizedY(_center);
        if (widget.config.yAxis.invert) normalizedY = 1.0 - normalizedY;

        final yParam = _parameterBank.getById(widget.config.yAxis.parameter);
        if (yParam != null) {
          final value = yParam.denormalize(normalizedY);
          _workspaceManager.updateParameter(widget.config.yAxis.parameter, value);
          widget.onParameterChange?.call(widget.config.yAxis.parameter, value);
        }
      }

      // Spread axis
      if (widget.config.spreadAxis.parameter.isNotEmpty && _touches.length > 1) {
        var normalizedSpread = _spread;
        if (widget.config.spreadAxis.invert) normalizedSpread = 1.0 - normalizedSpread;

        final spreadParam = _parameterBank.getById(widget.config.spreadAxis.parameter);
        if (spreadParam != null) {
          final value = spreadParam.denormalize(normalizedSpread);
          _workspaceManager.updateParameter(widget.config.spreadAxis.parameter, value);
          widget.onParameterChange?.call(widget.config.spreadAxis.parameter, value);
        }
      }
    }
  }

  /// Calculate normalized X value (0-1)
  double _calculateNormalizedX(Offset position) {
    final size = widget.config.size.toSize();
    return (position.dx / size.width).clamp(0.0, 1.0);
  }

  /// Calculate normalized Y value (0-1)
  double _calculateNormalizedY(Offset position) {
    final size = widget.config.size.toSize();
    // Invert Y so top = 1, bottom = 0 (standard for VJ controls)
    return (1.0 - (position.dy / size.height)).clamp(0.0, 1.0);
  }

  /// Get color for touch point based on index
  Color _getTouchColor(int index) {
    const colors = [
      Colors.cyan,
      Colors.magenta,
      Colors.yellow,
    ];
    return colors[index % colors.length];
  }
}

/// Touch point data
class TouchPoint {
  final Offset position;

  TouchPoint({required this.position});
}

/// Touch trail for motion blur effect
class TouchTrail {
  final Offset position;
  final Color color;
  double opacity;

  TouchTrail({
    required this.position,
    required this.color,
    required this.opacity,
  });
}

/// Grid painter for XY pad background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    const gridCount = 8;

    // Vertical lines
    for (int i = 0; i <= gridCount; i++) {
      final x = (size.width / gridCount) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 0; i <= gridCount; i++) {
      final y = (size.height / gridCount) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Center crosshair
    paint.color = Colors.white.withOpacity(0.3);
    paint.strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Spread lines painter (connecting touches)
class SpreadLinesPainter extends CustomPainter {
  final List<TouchPoint> touches;
  final Offset center;

  SpreadLinesPainter(this.touches, this.center);

  @override
  void paint(Canvas canvas, Size size) {
    if (touches.length < 2) return;

    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw lines from each touch to center
    for (var touch in touches) {
      canvas.drawLine(touch.position, center, paint);
    }

    // Draw circle showing spread radius
    final avgDistance = touches.fold<double>(
      0.0,
      (sum, touch) => sum + (touch.position - center).distance,
    ) / touches.length;

    paint.style = PaintingStyle.stroke;
    paint.color = Colors.purple.withOpacity(0.3);
    canvas.drawCircle(center, avgDistance, paint);
  }

  @override
  bool shouldRepaint(covariant SpreadLinesPainter oldDelegate) => true;
}

extension PadSizeExtension on PadSize {
  Size toSize() {
    switch (this) {
      case PadSize.small:
        return const Size(150, 150);
      case PadSize.medium:
        return const Size(250, 250);
      case PadSize.large:
        return const Size(400, 400);
      case PadSize.extraLarge:
        return const Size(600, 600);
      case PadSize.custom:
        return const Size(300, 300); // Default for custom
    }
  }
}
