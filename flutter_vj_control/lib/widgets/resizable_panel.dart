import 'package:flutter/material.dart';
import '../models/panel_config.dart';
import '../core/workspace_manager.dart';

/// Resizable, draggable, collapsible panel container
/// Core widget for adaptive workspace system
class ResizablePanel extends StatefulWidget {
  final PanelConfig config;
  final Widget child;
  final VoidCallback? onTap;

  const ResizablePanel({
    super.key,
    required this.config,
    required this.child,
    this.onTap,
  });

  @override
  State<ResizablePanel> createState() => _ResizablePanelState();
}

class _ResizablePanelState extends State<ResizablePanel> {
  final WorkspaceManager _workspaceManager = WorkspaceManager();

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  bool _isResizing = false;
  ResizeHandle? _activeHandle;

  // Resize handles (8 points around panel)
  static const double _handleSize = 12.0;
  static const double _headerHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    if (!widget.config.isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: widget.config.bounds.left,
      top: widget.config.bounds.top,
      width: widget.config.bounds.width,
      height: widget.config.bounds.height,
      child: GestureDetector(
        onTap: () {
          _workspaceManager.bringPanelToFront(widget.config.id);
          widget.onTap?.call();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: [
                _buildHeader(),
                if (!widget.config.isCollapsed)
                  Expanded(
                    child: widget.child,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build panel header with title and controls
  Widget _buildHeader() {
    return GestureDetector(
      onPanStart: _onHeaderDragStart,
      onPanUpdate: _onHeaderDragUpdate,
      onPanEnd: _onHeaderDragEnd,
      child: Container(
        height: _headerHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.3),
              Colors.blue.withOpacity(0.2),
            ],
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              widget.config.type.icon,
              size: 20,
              color: Colors.white70,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.config.type.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Collapse button
            IconButton(
              icon: Icon(
                widget.config.isCollapsed
                    ? Icons.expand_more
                    : Icons.expand_less,
                size: 20,
              ),
              onPressed: () {
                _workspaceManager.togglePanelCollapsed(widget.config.id);
              },
              tooltip: widget.config.isCollapsed ? 'Expand' : 'Collapse',
            ),
            // Close button
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                _workspaceManager.togglePanelVisibility(widget.config.id);
              },
              tooltip: 'Close',
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  /// Handle header drag start
  void _onHeaderDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = details.localPosition;
    });
    _workspaceManager.bringPanelToFront(widget.config.id);
  }

  /// Handle header drag update
  void _onHeaderDragUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      final newLeft = widget.config.bounds.left + details.delta.dx;
      final newTop = widget.config.bounds.top + details.delta.dy;

      final newBounds = Rect.fromLTWH(
        newLeft,
        newTop,
        widget.config.bounds.width,
        widget.config.bounds.height,
      );

      _workspaceManager.updatePanelBounds(widget.config.id, newBounds);
    }
  }

  /// Handle header drag end
  void _onHeaderDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    _snapToGrid();
  }

  /// Snap panel to grid if enabled
  void _snapToGrid() {
    final workspace = _workspaceManager.currentWorkspace;
    if (workspace != null && workspace.gridSettings.snapToGrid) {
      final gridSize = workspace.gridSettings.gridSize;
      final snappedLeft = (widget.config.bounds.left / gridSize).round() * gridSize.toDouble();
      final snappedTop = (widget.config.bounds.top / gridSize).round() * gridSize.toDouble();

      final snappedBounds = Rect.fromLTWH(
        snappedLeft,
        snappedTop,
        widget.config.bounds.width,
        widget.config.bounds.height,
      );

      _workspaceManager.updatePanelBounds(widget.config.id, snappedBounds);
    }
  }

  /// Build resize handles (8 points around panel)
  List<Widget> _buildResizeHandles() {
    if (widget.config.isCollapsed) return [];

    return [
      // Top-left
      _buildResizeHandle(
        ResizeHandle.topLeft,
        Alignment.topLeft,
        SystemMouseCursors.resizeUpLeft,
      ),
      // Top
      _buildResizeHandle(
        ResizeHandle.top,
        Alignment.topCenter,
        SystemMouseCursors.resizeUp,
      ),
      // Top-right
      _buildResizeHandle(
        ResizeHandle.topRight,
        Alignment.topRight,
        SystemMouseCursors.resizeUpRight,
      ),
      // Right
      _buildResizeHandle(
        ResizeHandle.right,
        Alignment.centerRight,
        SystemMouseCursors.resizeRight,
      ),
      // Bottom-right
      _buildResizeHandle(
        ResizeHandle.bottomRight,
        Alignment.bottomRight,
        SystemMouseCursors.resizeDownRight,
      ),
      // Bottom
      _buildResizeHandle(
        ResizeHandle.bottom,
        Alignment.bottomCenter,
        SystemMouseCursors.resizeDown,
      ),
      // Bottom-left
      _buildResizeHandle(
        ResizeHandle.bottomLeft,
        Alignment.bottomLeft,
        SystemMouseCursors.resizeDownLeft,
      ),
      // Left
      _buildResizeHandle(
        ResizeHandle.left,
        Alignment.centerLeft,
        SystemMouseCursors.resizeLeft,
      ),
    ];
  }

  /// Build individual resize handle
  Widget _buildResizeHandle(
    ResizeHandle handle,
    Alignment alignment,
    MouseCursor cursor,
  ) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: MouseRegion(
          cursor: cursor,
          child: GestureDetector(
            onPanStart: (details) => _onResizeStart(handle, details),
            onPanUpdate: (details) => _onResizeUpdate(handle, details),
            onPanEnd: (details) => _onResizeEnd(handle, details),
            child: Container(
              width: _handleSize,
              height: _handleSize,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.8),
                borderRadius: BorderRadius.circular(_handleSize / 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle resize start
  void _onResizeStart(ResizeHandle handle, DragStartDetails details) {
    setState(() {
      _isResizing = true;
      _activeHandle = handle;
    });
    _workspaceManager.bringPanelToFront(widget.config.id);
  }

  /// Handle resize update
  void _onResizeUpdate(ResizeHandle handle, DragUpdateDetails details) {
    if (!_isResizing || _activeHandle == null) return;

    var newBounds = widget.config.bounds;
    final delta = details.delta;

    switch (handle) {
      case ResizeHandle.topLeft:
        newBounds = Rect.fromLTRB(
          newBounds.left + delta.dx,
          newBounds.top + delta.dy,
          newBounds.right,
          newBounds.bottom,
        );
        break;
      case ResizeHandle.top:
        newBounds = Rect.fromLTRB(
          newBounds.left,
          newBounds.top + delta.dy,
          newBounds.right,
          newBounds.bottom,
        );
        break;
      case ResizeHandle.topRight:
        newBounds = Rect.fromLTRB(
          newBounds.left,
          newBounds.top + delta.dy,
          newBounds.right + delta.dx,
          newBounds.bottom,
        );
        break;
      case ResizeHandle.right:
        newBounds = Rect.fromLTRB(
          newBounds.left,
          newBounds.top,
          newBounds.right + delta.dx,
          newBounds.bottom,
        );
        break;
      case ResizeHandle.bottomRight:
        newBounds = Rect.fromLTRB(
          newBounds.left,
          newBounds.top,
          newBounds.right + delta.dx,
          newBounds.bottom + delta.dy,
        );
        break;
      case ResizeHandle.bottom:
        newBounds = Rect.fromLTRB(
          newBounds.left,
          newBounds.top,
          newBounds.right,
          newBounds.bottom + delta.dy,
        );
        break;
      case ResizeHandle.bottomLeft:
        newBounds = Rect.fromLTRB(
          newBounds.left + delta.dx,
          newBounds.top,
          newBounds.right,
          newBounds.bottom + delta.dy,
        );
        break;
      case ResizeHandle.left:
        newBounds = Rect.fromLTRB(
          newBounds.left + delta.dx,
          newBounds.top,
          newBounds.right,
          newBounds.bottom,
        );
        break;
    }

    // Enforce minimum size
    const minWidth = 200.0;
    const minHeight = 150.0;

    if (newBounds.width >= minWidth && newBounds.height >= minHeight) {
      _workspaceManager.updatePanelBounds(widget.config.id, newBounds);
    }
  }

  /// Handle resize end
  void _onResizeEnd(ResizeHandle handle, DragEndDetails details) {
    setState(() {
      _isResizing = false;
      _activeHandle = null;
    });
    _snapToGrid();
  }
}

/// Resize handle positions
enum ResizeHandle {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

extension PanelTypeExtension on PanelType {
  String get displayName {
    switch (this) {
      case PanelType.visualizer:
        return 'Visualizer';
      case PanelType.padMatrix:
        return 'Control Pads';
      case PanelType.effectBank:
        return 'Effect Bank';
      case PanelType.parameterInspector:
        return 'Parameters';
      case PanelType.layerMixer:
        return 'Layer Mixer';
      case PanelType.timeline:
        return 'Timeline';
      case PanelType.mediaBrowser:
        return 'Media Browser';
      case PanelType.audioAnalyzer:
        return 'Audio Analyzer';
      case PanelType.hardwareBridge:
        return 'Hardware';
      case PanelType.telemetry:
        return 'Telemetry';
    }
  }

  IconData get icon {
    switch (this) {
      case PanelType.visualizer:
        return Icons.visibility;
      case PanelType.padMatrix:
        return Icons.apps;
      case PanelType.effectBank:
        return Icons.auto_awesome;
      case PanelType.parameterInspector:
        return Icons.tune;
      case PanelType.layerMixer:
        return Icons.layers;
      case PanelType.timeline:
        return Icons.timeline;
      case PanelType.mediaBrowser:
        return Icons.photo_library;
      case PanelType.audioAnalyzer:
        return Icons.graphic_eq;
      case PanelType.hardwareBridge:
        return Icons.settings_input_component;
      case PanelType.telemetry:
        return Icons.monitor_heart;
    }
  }
}
