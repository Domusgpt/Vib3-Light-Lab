/// VIB3 Light Lab - OpenGL Bridge Provider
///
/// Provides singleton OpenGL bridge instance with lifecycle management.
/// Native OpenGL ES rendering instead of WebView-based WebGL.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bridges/opengl_bridge.dart';

/// OpenGL Bridge Provider - Singleton instance
///
/// Usage:
/// ```dart
/// final bridge = ref.read(openglBridgeProvider);
/// await bridge.switchSystem('quantum');
/// ```
final openglBridgeProvider = Provider<OpenGLBridge>((ref) {
  final bridge = OpenGLBridge();

  // Dispose on provider cleanup
  ref.onDispose(() {
    bridge.dispose();
  });

  return bridge;
});

/// OpenGL Bridge Initialization State Provider
///
/// Tracks whether the bridge has been initialized with OpenGL context.
final bridgeInitializedProvider = StateProvider<bool>((ref) {
  return false;
});

/// OpenGL Bridge State Stream Provider
///
/// Streams engine state changes from the OpenGL bridge.
final bridgeStateStreamProvider = StreamProvider.autoDispose((ref) {
  final bridge = ref.watch(openglBridgeProvider);
  return bridge.stateStream;
});

/// OpenGL Event Stream Provider
///
/// Streams OpenGL events (parameter changes, system switches, errors).
final bridgeEventStreamProvider = StreamProvider.autoDispose((ref) {
  final bridge = ref.watch(openglBridgeProvider);
  return bridge.eventStream;
});

/// Bridge Ready State Provider
///
/// Computed provider that combines initialization state with bridge ready status.
final bridgeReadyProvider = Provider<bool>((ref) {
  final initialized = ref.watch(bridgeInitializedProvider);
  final bridge = ref.watch(openglBridgeProvider);
  return initialized && bridge.isReady;
});
