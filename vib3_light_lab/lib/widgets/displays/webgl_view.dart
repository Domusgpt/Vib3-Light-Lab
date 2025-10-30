/// VIB3 Light Lab - WebGL View Widget
///
/// Displays VIB34D visualization in WebView with bridge initialization.
/// Critical component for Flutter ↔ WebGL communication.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../config/theme.dart';
import '../../providers/webgl_bridge_provider.dart';
import '../../providers/engine_provider.dart';

/// WebGL View Widget - Displays VIB34D visualization
class WebGLView extends ConsumerStatefulWidget {
  /// URL to load VIB34D HTML file
  final String webglUrl;

  /// Show loading indicator
  final bool showLoading;

  /// Error callback
  final void Function(String error)? onError;

  const WebGLView({
    super.key,
    required this.webglUrl,
    this.showLoading = true,
    this.onError,
  });

  @override
  ConsumerState<WebGLView> createState() => _WebGLViewState();
}

class _WebGLViewState extends ConsumerState<WebGLView> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final bridgeReady = ref.watch(bridgeReadyProvider);

    return Stack(
      children: [
        // WebView
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.webglUrl)),
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            javaScriptEnabled: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            useOnLoadResource: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            verticalScrollBarEnabled: false,
            horizontalScrollBarEnabled: false,
            disableVerticalScroll: true,
            disableHorizontalScroll: true,
            supportZoom: false,
          ),
          onWebViewCreated: _onWebViewCreated,
          onLoadStart: _onLoadStart,
          onLoadStop: _onLoadStop,
          onLoadError: _onLoadError,
          onProgressChanged: _onProgressChanged,
          onConsoleMessage: _onConsoleMessage,
        ),

        // Loading Indicator
        if (_isLoading && widget.showLoading)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: VIB3Colors.backgroundGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: VIB3Colors.cyan,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading VIB34D Engine...',
                    style: VIB3TextStyles.body1,
                  ),
                ],
              ),
            ),
          ),

        // Error Display
        if (_errorMessage != null)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: VIB3Colors.backgroundGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: VIB3Colors.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'WebGL Initialization Error',
                      style: VIB3TextStyles.h2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: VIB3TextStyles.body1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Bridge Ready Indicator (dev mode)
        if (bridgeReady && !_isLoading)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: VIB3Colors.success.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: VIB3Colors.success),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Bridge Ready',
                    style: VIB3TextStyles.label.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// WebView created callback
  void _onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    debugPrint('[WebGLView] WebView created');
  }

  /// Load start callback
  void _onLoadStart(InAppWebViewController controller, WebUri? url) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    debugPrint('[WebGLView] Load started: $url');
  }

  /// Load stop callback - Initialize bridge
  Future<void> _onLoadStop(
    InAppWebViewController controller,
    WebUri? url,
  ) async {
    debugPrint('[WebGLView] Load stopped: $url');

    try {
      // Initialize WebGL bridge
      final bridge = ref.read(webglBridgeProvider);
      await bridge.initialize(controller);

      // Mark bridge as initialized
      ref.read(bridgeInitializedProvider.notifier).state = true;

      // Sync initial state
      await ref.read(engineProvider.notifier).syncState();

      setState(() {
        _isLoading = false;
      });

      debugPrint('[WebGLView] Bridge initialized successfully');
    } catch (e) {
      final errorMsg = 'Failed to initialize WebGL bridge: $e';
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });

      widget.onError?.call(errorMsg);
      debugPrint('[WebGLView] $errorMsg');
    }
  }

  /// Load error callback
  void _onLoadError(
    InAppWebViewController controller,
    WebUri? url,
    int code,
    String message,
  ) {
    final errorMsg = 'WebView load error ($code): $message';
    setState(() {
      _isLoading = false;
      _errorMessage = errorMsg;
    });

    widget.onError?.call(errorMsg);
    debugPrint('[WebGLView] $errorMsg');
  }

  /// Progress changed callback
  void _onProgressChanged(InAppWebViewController controller, int progress) {
    debugPrint('[WebGLView] Loading progress: $progress%');
  }

  /// Console message callback - Forward WebGL console to Flutter debug
  void _onConsoleMessage(
    InAppWebViewController controller,
    ConsoleMessage consoleMessage,
  ) {
    debugPrint(
      '[WebGL Console] [${consoleMessage.messageLevel.name}] ${consoleMessage.message}',
    );
  }

  /// Retry loading
  void _retry() {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    _webViewController?.reload();
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}

/// WebGL View with Auto URL Provider
///
/// Automatically uses the configured WebGL server URL.
class AutoWebGLView extends ConsumerWidget {
  final bool showLoading;
  final void Function(String error)? onError;

  const AutoWebGLView({
    super.key,
    this.showLoading = true,
    this.onError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(webglBridgeConfigProvider);

    return WebGLView(
      webglUrl: config.serverUrl,
      showLoading: showLoading,
      onError: onError,
    );
  }
}
