/// VIB3 Light Lab - WebGL Bridge Provider
///
/// Provides singleton WebGL bridge instance with lifecycle management.
/// Ensures proper initialization and disposal of WebGL communication.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../bridges/webgl_bridge.dart';

/// WebGL Bridge Provider - Singleton instance
///
/// Usage:
/// ```dart
/// final bridge = ref.read(webglBridgeProvider);
/// await bridge.switchSystem('quantum');
/// ```
final webglBridgeProvider = Provider<WebGLBridge>((ref) {
  final bridge = WebGLBridge();

  // Dispose on provider cleanup
  ref.onDispose(() {
    bridge.dispose();
  });

  return bridge;
});

/// WebGL Bridge Initialization State Provider
///
/// Tracks whether the bridge has been initialized with a WebView controller.
/// Use this to show loading states in the UI.
final bridgeInitializedProvider = StateProvider<bool>((ref) {
  return false;
});

/// WebGL Bridge State Stream Provider
///
/// Streams engine state changes from the WebGL bridge.
/// Automatically subscribes/unsubscribes based on widget lifecycle.
///
/// Usage:
/// ```dart
/// final stateAsync = ref.watch(bridgeStateStreamProvider);
/// stateAsync.when(
///   data: (state) => Text('System: ${state.currentSystem}'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
final bridgeStateStreamProvider = StreamProvider.autoDispose((ref) {
  final bridge = ref.watch(webglBridgeProvider);
  return bridge.stateStream;
});

/// WebGL Event Stream Provider
///
/// Streams WebGL events (parameter changes, system switches, errors).
/// Use for logging, telemetry, or reactive UI updates.
final bridgeEventStreamProvider = StreamProvider.autoDispose((ref) {
  final bridge = ref.watch(webglBridgeProvider);
  return bridge.eventStream;
});

/// Bridge Ready State Provider
///
/// Computed provider that combines initialization state with bridge ready status.
final bridgeReadyProvider = Provider<bool>((ref) {
  final initialized = ref.watch(bridgeInitializedProvider);
  final bridge = ref.watch(webglBridgeProvider);
  return initialized && bridge.isReady;
});

/// WebGL Bridge Configuration Provider
///
/// Provides configuration for the WebGL bridge.
/// Override this provider to customize bridge settings.
final webglBridgeConfigProvider = Provider<WebGLBridgeConfig>((ref) {
  return const WebGLBridgeConfig();
});
