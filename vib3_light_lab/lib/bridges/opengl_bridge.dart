/// VIB3 Light Lab - OpenGL Bridge
///
/// Direct OpenGL ES rendering bridge using flutter_gl.
/// Replaces WebGL/JavaScript bridge with native GPU rendering.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_gl/flutter_gl.dart';

import '../models/engine_state.dart';
import '../config/constants.dart';
import '../rendering/systems/visualization_system.dart';
import '../rendering/systems/faceted_system.dart';

/// OpenGL Bridge - Native OpenGL ES rendering
class OpenGLBridge {
  FlutterGlPlugin? _flutterGl;
  dynamic _gl;

  /// State stream controller
  final _stateController = StreamController<EngineState>.broadcast();

  /// Event stream controller
  final _eventController = StreamController<OpenGLEvent>.broadcast();

  /// Initialization completer
  final _initCompleter = Completer<void>();

  /// Current engine state cache
  EngineState? _cachedState;

  /// Bridge ready status
  bool _isReady = false;

  /// Current visualization system
  VisualizationSystem? _currentSystem;

  /// Constructor
  OpenGLBridge();

  /// State stream
  Stream<EngineState> get stateStream => _stateController.stream;

  /// Event stream
  Stream<OpenGLEvent> get eventStream => _eventController.stream;

  /// Bridge ready status
  bool get isReady => _isReady;

  /// Initialization future
  Future<void> get initialized => _initCompleter.future;

  /// OpenGL context
  dynamic get gl => _gl;

  /// Initialize bridge with flutter_gl plugin
  Future<void> initialize(FlutterGlPlugin flutterGl) async {
    _flutterGl = flutterGl;

    try {
      // Initialize OpenGL context
      await _flutterGl!.initialize(
        options: {
          'width': 800,
          'height': 600,
          'antialias': true,
          'alpha': false,
        },
      );

      _gl = _flutterGl!.gl;

      // Set initial OpenGL state
      _setupOpenGLState();

      _isReady = true;
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }

      debugPrint('[OpenGLBridge] Initialized successfully');
    } catch (e) {
      debugPrint('[OpenGLBridge] Initialization error: $e');
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
  }

  /// Setup initial OpenGL state
  void _setupOpenGLState() {
    // Enable depth testing
    _gl.enable(_gl.DEPTH_TEST);
    _gl.depthFunc(_gl.LEQUAL);

    // Enable blending for transparency
    _gl.enable(_gl.BLEND);
    _gl.blendFunc(_gl.SRC_ALPHA, _gl.ONE_MINUS_SRC_ALPHA);

    // Set clear color (dark background)
    _gl.clearColor(0.04, 0.05, 0.15, 1.0); // VIB3 dark navy

    debugPrint('[OpenGLBridge] OpenGL state configured');
  }

  /// Switch visualization system
  Future<void> switchSystem(String systemName) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    if (!VIB3Systems.all.contains(systemName)) {
      throw ArgumentError('Invalid system: $systemName');
    }

    try {
      // Dispose old system
      _currentSystem?.dispose();

      // Create new system based on name
      _currentSystem = _createSystem(systemName);

      // Initialize new system
      await _currentSystem!.initialize(_gl);

      // Update cached state
      if (_cachedState != null) {
        _cachedState = _cachedState!.copyWith(currentSystem: systemName);
        _stateController.add(_cachedState!);
      }

      _eventController.add(OpenGLEvent(
        type: 'systemSwitched',
        data: {'system': systemName},
        timestamp: DateTime.now(),
      ));

      debugPrint('[OpenGLBridge] Switched to system: $systemName');
    } catch (e) {
      debugPrint('[OpenGLBridge] Error switching system: $e');
      rethrow;
    }
  }

  /// Create visualization system instance
  VisualizationSystem _createSystem(String systemName) {
    switch (systemName) {
      case 'faceted':
        return FacetedSystem();
      case 'quantum':
        // TODO: Implement quantum system
        throw UnimplementedError('Quantum system not yet implemented');
      case 'holographic':
        // TODO: Implement holographic system
        throw UnimplementedError('Holographic system not yet implemented');
      case 'polychora':
        // TODO: Implement polychora system
        throw UnimplementedError('Polychora system not yet implemented');
      default:
        debugPrint('[OpenGLBridge] Unknown system: $systemName, using faceted');
        return FacetedSystem();
    }
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

    // Update current system
    _currentSystem?.updateParameter(name, clampedValue);

    // Update cache
    if (_cachedState != null) {
      _cachedState = _cachedState!.updateParameter(name, clampedValue);
    }
  }

  /// Update multiple parameters (batched)
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

    // Update current system
    for (var entry in validParams.entries) {
      _currentSystem?.updateParameter(entry.key, entry.value);
    }

    // Update cache
    if (_cachedState != null) {
      _cachedState = _cachedState!.updateParameters(validParams);
    }
  }

  /// Render frame
  void render(double deltaTime) {
    if (!_isReady || _currentSystem == null) return;

    // Clear buffers
    _gl.clear(_gl.COLOR_BUFFER_BIT | _gl.DEPTH_BUFFER_BIT);

    // Render current system
    _currentSystem!.render(deltaTime);
  }

  /// Resize viewport
  void resize(int width, int height) {
    if (!_isReady) return;

    _gl.viewport(0, 0, width, height);
    _currentSystem?.resize(width, height);
  }

  /// Get current engine state
  Future<EngineState?> getCurrentState() async {
    return _cachedState;
  }

  /// Select geometry
  Future<void> selectGeometry(int index) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    if (index < 0 || index > 7) {
      throw ArgumentError('Geometry index must be 0-7');
    }

    _currentSystem?.selectGeometry(index);

    // Update cache
    if (_cachedState != null) {
      _cachedState =
          _cachedState!.updateParameter(VIB3Parameters.geometry, index.toDouble());
    }
  }

  /// Toggle audio reactivity
  Future<void> toggleAudio(bool enabled) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    // TODO: Implement audio reactivity
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

    _currentSystem?.setInteractivityEnabled(enabled);

    if (_cachedState != null) {
      _cachedState = _cachedState!.copyWith(interactivityEnabled: enabled);
      _stateController.add(_cachedState!);
    }
  }

  /// Toggle device tilt
  Future<void> toggleDeviceTilt(bool enabled) async {
    if (!_isReady) {
      throw Exception('Bridge not initialized');
    }

    // TODO: Implement device tilt
    if (_cachedState != null) {
      _cachedState = _cachedState!.copyWith(deviceTiltEnabled: enabled);
      _stateController.add(_cachedState!);
    }
  }

  /// Randomize all parameters
  Future<void> randomizeAll() async {
    // Generate random state
    final randomState = EngineState.initial().randomizeParameters();

    // Update system with random parameters
    await updateParameters(randomState.parameters);
  }

  /// Reset all parameters
  Future<void> resetAll() async {
    // Reset to defaults
    final defaultState = EngineState.initial();

    // Update system with default parameters
    await updateParameters(defaultState.parameters);
  }

  /// Dispose resources
  void dispose() {
    _currentSystem?.dispose();
    _currentSystem = null;

    _stateController.close();
    _eventController.close();

    _flutterGl?.dispose();
    _flutterGl = null;
    _gl = null;

    _isReady = false;
    debugPrint('[OpenGLBridge] Disposed');
  }
}

/// OpenGL Event
class OpenGLEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const OpenGLEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'OpenGLEvent(type: $type, timestamp: $timestamp)';
  }
}
