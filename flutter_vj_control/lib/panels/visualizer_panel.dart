import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/workspace_manager.dart';

/// Visualizer panel - main output display with WebView integration
class VisualizerPanel extends StatefulWidget {
  const VisualizerPanel({super.key});

  @override
  State<VisualizerPanel> createState() => _VisualizerPanelState();
}

class _VisualizerPanelState extends State<VisualizerPanel> {
  final WorkspaceManager _workspaceManager = WorkspaceManager();
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _setupJavaScriptBridge();
          },
        ),
      )
      ..loadRequest(Uri.parse('http://localhost:8080/index-clean.html'));
  }

  /// Setup JavaScript bridge for parameter control
  void _setupJavaScriptBridge() {
    // Add JavaScript channel for parameter updates
    _webViewController.addJavaScriptChannel(
      'FlutterBridge',
      onMessageReceived: (JavaScriptMessage message) {
        debugPrint('Message from JS: ${message.message}');
      },
    );

    // Listen to workspace manager changes and update visualizer
    _workspaceManager.addListener(_syncParametersToVisualizer);
  }

  /// Sync parameters from Flutter to JavaScript visualizer
  void _syncParametersToVisualizer() {
    final params = _workspaceManager.parameterValues;
    final activeSystem = _workspaceManager.activeSystem;

    // Convert parameters to JavaScript call
    final jsCode = '''
      if (typeof switchSystem === 'function') {
        switchSystem('$activeSystem');
      }
      ${params.entries.map((e) => '''
        if (typeof updateParameter === 'function') {
          updateParameter('${e.key}', ${e.value});
        }
      ''').join('\n')}
    ''';

    _webViewController.runJavaScript(jsCode);
  }

  @override
  void dispose() {
    _workspaceManager.removeListener(_syncParametersToVisualizer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _webViewController),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            ),

          // System switcher overlay
          Positioned(
            top: 10,
            left: 10,
            child: _buildSystemSwitcher(),
          ),

          // Transport controls
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: _buildTransportControls(),
          ),
        ],
      ),
    );
  }

  /// Build system switcher buttons
  Widget _buildSystemSwitcher() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSystemButton('faceted', '🔷', 'Faceted'),
          const SizedBox(width: 8),
          _buildSystemButton('quantum', '🌌', 'Quantum'),
          const SizedBox(width: 8),
          _buildSystemButton('holographic', '✨', 'Holographic'),
          const SizedBox(width: 8),
          _buildSystemButton('polychora', '🔮', 'Polychora'),
        ],
      ),
    );
  }

  /// Build individual system button
  Widget _buildSystemButton(String systemId, String emoji, String label) {
    final isActive = _workspaceManager.activeSystem == systemId;

    return InkWell(
      onTap: () {
        _workspaceManager.switchSystem(systemId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.purple.withOpacity(0.8)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: isActive
              ? Border.all(color: Colors.purple, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build transport controls
  Widget _buildTransportControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            onPressed: () {
              // Previous preset
            },
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.white),
            onPressed: () {
              _workspaceManager.randomizeAllParameters();
            },
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _workspaceManager.resetAllParameters();
            },
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: () {
              // Next preset
            },
          ),
        ],
      ),
    );
  }
}
