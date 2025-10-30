/// VIB3 Light Lab - WebGL Bridge
///
/// Critical bridge between Flutter UI and WebGL2 visualization engines.
/// Provides bidirectional communication for parameter control and state sync.
///
/// Architecture:
/// Flutter UI <-> WebGL Bridge <-> WebView <-> JavaScript <-> WebGL Engines
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/engine_state.dart';
import '../config/constants.dart';

/// WebGL Bridge - Manages communication with WebGL visualization engines
class WebGLBridge {
  /// WebView controller for JavaScript communication
  InAppWebViewController? _controller;

  /// State stream controller
  final _stateController = StreamController<EngineState>.broadcast();

  /// Event stream controller
  final _eventController = StreamController<WebGLEvent>.broadcast();

  /// Initialization completer
  final _initCompleter = Completer<void>();

  /// Current engine state cache
  EngineState? _cachedState;

  /// Bridge ready status
  bool _isReady = false;

  /// JavaScript channel name
  static const String _channelName = 'FlutterBridge';

  /// Constructor
  WebGLBridge();

  /// State stream - broadcasts engine state changes
  Stream<EngineState> get stateStream => _stateController.stream;

  /// Event stream - broadcasts WebGL events
  Stream<WebGLEvent> get eventStream => _eventController.stream;

  /// Bridge ready status
  bool get isReady => _isReady;

  /// Initialization future
  Future<void> get initialized => _initCompleter.future;

  /// Initialize bridge with WebView controller
  Future<void> initialize(InAppWebViewController controller) async {
    _controller = controller;

    // Add JavaScript handler for bidirectional communication
    await controller.addJavaScriptHandler(
      handlerName: _channelName,
      callback: _handleJavaScriptMessage,
    );

    // Wait for WebGL engines to be ready
    await _waitForEnginesReady();

    _isReady = true;
    if (!_initCompleter.isCompleted) {
      _initCompleter.complete();
    }

    debugPrint('[WebGLBridge] Initialized successfully');
  }

  /// Wait for WebGL engines to be ready
  Future<void> _waitForEnginesReady() async {
    var retries = 0;
    const maxRetries = 50; // 5 seconds with 100ms intervals
    const retryDelay = Duration(milliseconds: 100);

    while (retries < maxRetries) {
      try {
        final result = await _evaluateJavaScript('typeof window.switchSystem');
        if (result == 'function') {
          debugPrint('[WebGLBridge] WebGL engines ready');
          return;
        }
      } catch (e) {
        // Engine not ready yet, continue waiting
      }

      await Future.delayed(retryDelay);
      retries++;
    }

    throw Exception(
      'WebGL engines failed to initialize after ${maxRetries * 100}ms',
    );
  }

  /// Handle messages from JavaScript
  dynamic _handleJavaScriptMessage(List<dynamic> args) {
    if (args.isEmpty) return;

    try {
      final message = args[0];
      if (message is Map) {
        _processEvent(Map<String, dynamic>.from(message));
      }
    } catch (e) {
      debugPrint('[WebGLBridge] Error processing message: $e');
    }
  }

  /// Process event from WebGL
  void _processEvent(Map<String, dynamic> eventData) {
    final type = eventData['type'] as String?;

    switch (type) {
      case 'parameterChanged':
        _handleParameterChanged(eventData);
        break;
      case 'systemSwitched':
        _handleSystemSwitched(eventData);
        break;
      case 'engineInitialized':
        _handleEngineInitialized(eventData);
        break;
      case 'error':
        _handleError(eventData);
        break;
      default:
        // Broadcast unknown events
        _eventController.add(WebGLEvent.fromJson(eventData));
    }
  }

  /// Handle parameter change from WebGL
  void _handleParameterChanged(Map<String, dynamic> data) {
    if (_cachedState == null) return;

    final paramName = data['name'] as String;
    final value = (data['value'] as num).toDouble();

    _cachedState = _cachedState!.updateParameter(paramName, value);
    _stateController.add(_cachedState!);
  }

  /// Handle system switch from WebGL
  void _handleSystemSwitched(Map<String, dynamic> data) {
    if (_cachedState == null) return;

    final system = data['system'] as String;
    _cachedState = _cachedState!.copyWith(currentSystem: system);
    _stateController.add(_cachedState!);
  }

  /// Handle engine initialization
  void _handleEngineInitialized(Map<String, dynamic> data) {
    if (_cachedState == null) return;

    _cachedState = _cachedState!.copyWith(isInitialized: true);
    _stateController.add(_cachedState!);

    debugPrint('[WebGLBridge] Engine initialized: ${data['system']}');
  }

  /// Handle error from WebGL
  void _handleError(Map<String, dynamic> data) {
    final error = data['message'] as String?;
    debugPrint('[WebGLBridge] WebGL Error: $error');

    if (_cachedState != null) {
      _cachedState = _cachedState!.copyWith(errorMessage: error);
      _stateController.add(_cachedState!);
    }
  }

  /// Switch visualization system
  Future<void> switchSystem(String system) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    if (!VIB3Systems.all.contains(system)) {
      throw ArgumentError('Invalid system: $system');
    }

    await _evaluateJavaScript('window.switchSystem("$system")');

    debugPrint('[WebGLBridge] Switched to system: $system');
  }

  /// Update single parameter
  Future<void> updateParameter(String name, double value) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    if (!VIB3Parameters.all.contains(name)) {
      throw ArgumentError('Invalid parameter: $name');
    }

    // Validate range
    final range = VIB3Parameters.ranges[name]!;
    final clampedValue = range.clamp(value);

    await _evaluateJavaScript(
      'window.updateParameter("$name", $clampedValue)',
    );

    // Update cache
    if (_cachedState != null) {
      _cachedState = _cachedState!.updateParameter(name, clampedValue);
    }
  }

  /// Update multiple parameters at once (batched for performance)
  Future<void> updateParameters(Map<String, double> parameters) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    // Validate and clamp all parameters
    final validParams = <String, double>{};
    for (var entry in parameters.entries) {
      if (VIB3Parameters.all.contains(entry.key)) {
        final range = VIB3Parameters.ranges[entry.key]!;
        validParams[entry.key] = range.clamp(entry.value);
      }
    }

    // Send as batch
    final jsonParams = jsonEncode(validParams);
    await _evaluateJavaScript('window.updateParametersBatch($jsonParams)');

    // Update cache
    if (_cachedState != null) {
      _cachedState = _cachedState!.updateParameters(validParams);
    }
  }

  /// Toggle audio reactivity
  Future<void> toggleAudio(bool enabled) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    await _evaluateJavaScript('window.toggleAudio($enabled)');

    if (_cachedState != null) {
      _cachedState = _cachedState!.copyWith(audioEnabled: enabled);
      _stateController.add(_cachedState!);
    }
  }

  /// Toggle interactivity
  Future<void> toggleInteractivity(bool enabled) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    await _evaluateJavaScript('window.toggleInteractivity($enabled)');

    if (_cachedState != null) {
      _cachedState = _cachedState!.copyWith(interactivityEnabled: enabled);
      _stateController.add(_cachedState!);
    }
  }

  /// Toggle device tilt (mobile)
  Future<void> toggleDeviceTilt(bool enabled) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    await _evaluateJavaScript('window.toggleDeviceTilt($enabled)');

    if (_cachedState != null) {
      _cachedState = _cachedState!.copyWith(deviceTiltEnabled: enabled);
      _stateController.add(_cachedState!);
    }
  }

  /// Randomize all parameters
  Future<void> randomizeAll() async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    await _evaluateJavaScript('window.randomizeAll()');
  }

  /// Reset all parameters to defaults
  Future<void> resetAll() async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    await _evaluateJavaScript('window.resetAll()');
  }

  /// Select geometry (0-7)
  Future<void> selectGeometry(int index) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    if (index < 0 || index > 7) {
      throw ArgumentError('Geometry index must be 0-7');
    }

    await _evaluateJavaScript('window.selectGeometry($index)');
  }

  /// Get current engine state from WebGL
  Future<EngineState?> getCurrentState() async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    try {
      final result = await _evaluateJavaScript('window.getCurrentState()');
      if (result != null && result is Map) {
        return EngineState.fromJson(Map<String, dynamic>.from(result));
      }
    } catch (e) {
      debugPrint('[WebGLBridge] Error getting current state: $e');
    }

    return null;
  }

  /// Capture screenshot from WebGL canvas
  Future<String?> captureScreenshot() async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    try {
      final result = await _evaluateJavaScript('window.captureScreenshot()');
      return result as String?;
    } catch (e) {
      debugPrint('[WebGLBridge] Error capturing screenshot: $e');
      return null;
    }
  }

  /// Evaluate JavaScript code
  Future<dynamic> _evaluateJavaScript(String code) async {
    if (_controller == null) {
      throw Exception('WebView controller not initialized');
    }

    try {
      final result = await _controller!.evaluateJavascript(source: code);
      return result;
    } catch (e) {
      debugPrint('[WebGLBridge] JavaScript evaluation error: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _stateController.close();
    _eventController.close();
    _controller = null;
    _isReady = false;
    debugPrint('[WebGLBridge] Disposed');
  }
}

/// WebGL Event - Events from WebGL engines
class WebGLEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const WebGLEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  factory WebGLEvent.fromJson(Map<String, dynamic> json) {
    return WebGLEvent(
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json),
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'WebGLEvent(type: $type, timestamp: $timestamp)';
  }
}

/// WebGL Bridge Configuration
class WebGLBridgeConfig {
  /// WebGL server URL
  final String serverUrl;

  /// Enable debug logging
  final bool debugLogging;

  /// Timeout for JavaScript evaluation
  final Duration evaluationTimeout;

  /// Maximum retry attempts for initialization
  final int maxRetries;

  const WebGLBridgeConfig({
    this.serverUrl = VIB3API.defaultWebGLServerUrl,
    this.debugLogging = kDebugMode,
    this.evaluationTimeout = const Duration(seconds: 5),
    this.maxRetries = 50,
  });
}
