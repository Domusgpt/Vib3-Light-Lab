/// VIB3 Light Lab - OpenGL View Widget
///
/// Native OpenGL ES rendering widget using flutter_gl.
/// Displays VIB34D visualizations with direct GPU access.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gl/flutter_gl.dart';

import '../../config/theme.dart';
import '../../providers/opengl_bridge_provider.dart';
import '../../providers/engine_provider.dart';

/// OpenGL View Widget - Native OpenGL ES rendering
class OpenGLView extends ConsumerStatefulWidget {
  /// Show loading indicator
  final bool showLoading;

  /// Error callback
  final void Function(String error)? onError;

  const OpenGLView({
    super.key,
    this.showLoading = true,
    this.onError,
  });

  @override
  ConsumerState<OpenGLView> createState() => _OpenGLViewState();
}

class _OpenGLViewState extends ConsumerState<OpenGLView>
    with SingleTickerProviderStateMixin {
  FlutterGlPlugin? _glPlugin;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation
  late Ticker _ticker;
  Duration _lastFrameTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeOpenGL();

    // Start render loop
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  /// Initialize OpenGL context
  Future<void> _initializeOpenGL() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create flutter_gl plugin
      _glPlugin = FlutterGlPlugin();

      // Initialize OpenGL bridge
      final bridge = ref.read(openglBridgeProvider);
      await bridge.initialize(_glPlugin!);

      // Mark bridge as initialized
      ref.read(bridgeInitializedProvider.notifier).state = true;

      // Load initial system (faceted)
      await bridge.switchSystem('faceted');

      // Sync initial state
      await ref.read(engineProvider.notifier).syncState();

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      debugPrint('[OpenGLView] Initialized successfully');
    } catch (e) {
      final errorMsg = 'Failed to initialize OpenGL: $e';
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });

      widget.onError?.call(errorMsg);
      debugPrint('[OpenGLView] $errorMsg');
    }
  }

  /// Render loop tick
  void _onTick(Duration elapsed) {
    if (!_isInitialized || _glPlugin == null) return;

    // Calculate delta time
    final deltaTime = elapsed - _lastFrameTime;
    _lastFrameTime = elapsed;

    // Render frame
    final bridge = ref.read(openglBridgeProvider);
    bridge.render(deltaTime.inMilliseconds / 1000.0);

    // Update texture
    setState(() {
      _glPlugin!.updateTexture();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bridgeReady = ref.watch(bridgeReadyProvider);

    return Stack(
      children: [
        // OpenGL Texture
        if (_isInitialized && _glPlugin != null)
          LayoutBuilder(
            builder: (context, constraints) {
              // Update viewport size
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final bridge = ref.read(openglBridgeProvider);
                bridge.resize(
                  constraints.maxWidth.toInt(),
                  constraints.maxHeight.toInt(),
                );
              });

              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Texture(textureId: _glPlugin!.textureId!),
              );
            },
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
                    'Initializing OpenGL Engine...',
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
                      'OpenGL Initialization Error',
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
                      onPressed: _initializeOpenGL,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Ready Indicator (dev mode)
        if (bridgeReady && _isInitialized && !_isLoading)
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
                    'OpenGL Ready',
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

  @override
  void dispose() {
    _ticker.dispose();
    _glPlugin?.dispose();
    super.dispose();
  }
}

/// Auto OpenGL View - Automatically configured
class AutoOpenGLView extends StatelessWidget {
  final bool showLoading;
  final void Function(String error)? onError;

  const AutoOpenGLView({
    super.key,
    this.showLoading = true,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return OpenGLView(
      showLoading: showLoading,
      onError: onError,
    );
  }
}
