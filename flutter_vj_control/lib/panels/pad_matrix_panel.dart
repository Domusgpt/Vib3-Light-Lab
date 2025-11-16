import 'package:flutter/material.dart';
import '../widgets/xy_pad.dart';
import '../models/pad_config.dart';
import '../core/workspace_manager.dart';

/// Pad Matrix Panel - grid of resizable XY pads for performance control
class PadMatrixPanel extends StatefulWidget {
  const PadMatrixPanel({super.key});

  @override
  State<PadMatrixPanel> createState() => _PadMatrixPanelState();
}

class _PadMatrixPanelState extends State<PadMatrixPanel> {
  final WorkspaceManager _workspaceManager = WorkspaceManager();

  // Default pad configurations
  final List<PadConfig> _pads = [
    PadConfig(
      id: 'pad1',
      label: '4D Rotation',
      size: PadSize.medium,
      xAxis: AxisMapping(parameter: 'rot4dXW'),
      yAxis: AxisMapping(parameter: 'rot4dYW'),
      spreadAxis: AxisMapping(parameter: 'rot4dZW'),
    ),
    PadConfig(
      id: 'pad2',
      label: 'Color Control',
      size: PadSize.medium,
      xAxis: AxisMapping(parameter: 'hue'),
      yAxis: AxisMapping(parameter: 'saturation'),
      spreadAxis: AxisMapping(parameter: 'intensity'),
    ),
    PadConfig(
      id: 'pad3',
      label: 'Structure',
      size: PadSize.medium,
      xAxis: AxisMapping(parameter: 'gridDensity'),
      yAxis: AxisMapping(parameter: 'morphFactor'),
      spreadAxis: AxisMapping(parameter: 'chaos'),
    ),
    PadConfig(
      id: 'pad4',
      label: 'Dynamics',
      size: PadSize.medium,
      xAxis: AxisMapping(parameter: 'speed'),
      yAxis: AxisMapping(parameter: 'intensity'),
      spreadAxis: AxisMapping(parameter: 'chaos'),
    ),
  ];

  GridLayoutMode _layoutMode = GridLayoutMode.grid2x2;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Header with layout selector
          _buildHeader(),
          // Pad grid
          Expanded(
            child: _buildPadGrid(),
          ),
        ],
      ),
    );
  }

  /// Build header with controls
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.2),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Control Pads',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Layout mode selector
          _buildLayoutButton(GridLayoutMode.single, '1×1'),
          const SizedBox(width: 4),
          _buildLayoutButton(GridLayoutMode.grid2x1, '2×1'),
          const SizedBox(width: 4),
          _buildLayoutButton(GridLayoutMode.grid2x2, '2×2'),
          const SizedBox(width: 4),
          _buildLayoutButton(GridLayoutMode.grid3x2, '3×2'),
        ],
      ),
    );
  }

  /// Build layout button
  Widget _buildLayoutButton(GridLayoutMode mode, String label) {
    final isActive = _layoutMode == mode;

    return InkWell(
      onTap: () {
        setState(() {
          _layoutMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.purple.withOpacity(0.6)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Build pad grid based on layout mode
  Widget _buildPadGrid() {
    switch (_layoutMode) {
      case GridLayoutMode.single:
        return _buildSinglePad();
      case GridLayoutMode.grid2x1:
        return _build2x1Grid();
      case GridLayoutMode.grid2x2:
        return _build2x2Grid();
      case GridLayoutMode.grid3x2:
        return _build3x2Grid();
    }
  }

  /// Build single pad layout (full screen)
  Widget _buildSinglePad() {
    return Center(
      child: XYPad(config: _pads[0]),
    );
  }

  /// Build 2×1 grid
  Widget _build2x1Grid() {
    return Row(
      children: [
        Expanded(
          child: Center(child: XYPad(config: _pads[0])),
        ),
        Expanded(
          child: Center(child: XYPad(config: _pads[1])),
        ),
      ],
    );
  }

  /// Build 2×2 grid
  Widget _build2x2Grid() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Center(child: XYPad(config: _pads[0])),
              ),
              Expanded(
                child: Center(child: XYPad(config: _pads[1])),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Center(child: XYPad(config: _pads[2])),
              ),
              Expanded(
                child: Center(child: XYPad(config: _pads[3])),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build 3×2 grid
  Widget _build3x2Grid() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: Center(child: XYPad(config: _pads[0]))),
              Expanded(child: Center(child: XYPad(config: _pads[1]))),
              Expanded(child: Center(child: XYPad(config: _pads[2]))),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Center(child: XYPad(config: _pads[3]))),
              Expanded(child: Center(child: XYPad(config: _pads[0]))),
              Expanded(child: Center(child: XYPad(config: _pads[1]))),
            ],
          ),
        ),
      ],
    );
  }
}

/// Grid layout modes
enum GridLayoutMode {
  single, // 1×1
  grid2x1, // 2×1
  grid2x2, // 2×2
  grid3x2, // 3×2
}
