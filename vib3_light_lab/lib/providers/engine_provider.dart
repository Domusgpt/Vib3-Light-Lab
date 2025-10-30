/// VIB3 Light Lab - Engine State Provider
///
/// Main state management for VIB3 visualization engine.
/// Integrates WebGL bridge with immutable state management.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/engine_state.dart';
import '../config/constants.dart';
import 'webgl_bridge_provider.dart';

/// Engine State Notifier - Main state management
class EngineStateNotifier extends StateNotifier<EngineState> {
  final Ref _ref;
  StreamSubscription? _stateSubscription;

  EngineStateNotifier(this._ref) : super(EngineState.initial()) {
    _initializeStateListener();
  }

  /// Initialize listener for WebGL state changes
  void _initializeStateListener() {
    final bridge = _ref.read(webglBridgeProvider);

    // Subscribe to bridge state stream
    _stateSubscription = bridge.stateStream.listen(
      (engineState) {
        state = engineState;
      },
      onError: (error) {
        debugPrint('[EngineProvider] Stream error: $error');
        state = state.copyWith(
          errorMessage: error.toString(),
          isLoading: false,
        );
      },
    );
  }

  /// Switch visualization system
  Future<void> switchSystem(String system) async {
    if (!VIB3Systems.all.contains(system)) {
      debugPrint('[EngineProvider] Invalid system: $system');
      return;
    }

    if (state.currentSystem == system) {
      debugPrint('[EngineProvider] Already on system: $system');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final bridge = _ref.read(webglBridgeProvider);
      await bridge.switchSystem(system);

      state = state.copyWith(
        currentSystem: system,
        isLoading: false,
      );

      debugPrint('[EngineProvider] Switched to system: $system');
    } catch (e) {
      debugPrint('[EngineProvider] Error switching system: $e');
      state = state.copyWith(
        errorMessage: 'Failed to switch system: $e',
        isLoading: false,
      );
    }
  }

  /// Update single parameter
  Future<void> updateParameter(String name, double value) async {
    if (!VIB3Parameters.all.contains(name)) {
      debugPrint('[EngineProvider] Invalid parameter: $name');
      return;
    }

    // Validate range
    final range = VIB3Parameters.ranges[name];
    if (range == null || !range.isValid(value)) {
      debugPrint('[EngineProvider] Invalid value for $name: $value');
      return;
    }

    try {
      final bridge = _ref.read(webglBridgeProvider);
      await bridge.updateParameter(name, value);

      // Update local state immediately for responsive UI
      state = state.updateParameter(name, value);
    } catch (e) {
      debugPrint('[EngineProvider] Error updating parameter: $e');
      state = state.copyWith(errorMessage: 'Failed to update parameter: $e');
    }
  }

  /// Update multiple parameters (batched for performance)
  Future<void> updateParameters(Map<String, double> parameters) async {
    if (parameters.isEmpty) return;

    try {
      final bridge = _ref.read(webglBridgeProvider);
      await bridge.updateParameters(parameters);

      // Update local state
      state = state.updateParameters(parameters);

      debugPrint('[EngineProvider] Updated ${parameters.length} parameters');
    } catch (e) {
      debugPrint('[EngineProvider] Error updating parameters: $e');
      state = state.copyWith(errorMessage: 'Failed to update parameters: $e');
    }
  }

  /// Select geometry (0-7)
  Future<void> selectGeometry(int index) async {
    if (index < 0 || index > 7) {
      debugPrint('[EngineProvider] Invalid geometry index: $index');
      return;
    }

    try {
      final bridge = _ref.read(webglBridgeProvider);
      await bridge.selectGeometry(index);

      // Update geometry parameter
      state = state.updateParameter(VIB3Parameters.geometry, index.toDouble());
    } catch (e) {
      debugPrint('[EngineProvider] Error selecting geometry: $e');
      state = state.copyWith(errorMessage: 'Failed to select geometry: $e');
    }
  }

  /// Toggle audio reactivity
  Future<void> toggleAudio(bool enabled) async {
    try {
      final bridge = _ref.read(webglBridgeProvider);
      await bridge.toggleAudio(enabled);

      state = state.copyWith(audioEnabled: enabled);

      debugPrint('[EngineProvider] Audio ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('[EngineProvider] Error toggling audio: $e');
      state = state.copyWith(errorMessage: 'Failed to toggle audio: $e');
    }
  }

  /// Toggle interactivity
  Future<void> toggleInteractivity(bool enabled) async {
    try {
      final bridge = _ref.read(webglBridgeProvider);
      await bridge.toggleInteractivity(enabled);

      state = state.copyWith(interactivityEnabled: enabled);
    } catch (e) {
      debugPrint('[EngineProvider] Error toggling interactivity: $e');
      state =
          state.copyWith(errorMessage: 'Failed to toggle interactivity: $e');
    }
  }

  /// Toggle device tilt (mobile)
  Future<void> toggleDeviceTilt(bool enabled) async {
    try {
      final bridge = _ref.read(webglBridgeProvider);
      await bridge.toggleDeviceTilt(enabled);

      state = state.copyWith(deviceTiltEnabled: enabled);
    } catch (e) {
      debugPrint('[EngineProvider] Error toggling device tilt: $e');
      state =
          state.copyWith(errorMessage: 'Failed to toggle device tilt: $e');
    }
  }

  /// Randomize all parameters
  Future<void> randomizeAll() async {
    state = state.copyWith(isLoading: true);

    try {
      final bridge = _ref.read(webglBridgeProvider);
      await bridge.randomizeAll();

      // Generate random state locally
      state = state.randomizeParameters().copyWith(isLoading: false);

      debugPrint('[EngineProvider] Randomized all parameters');
    } catch (e) {
      debugPrint('[EngineProvider] Error randomizing: $e');
      state = state.copyWith(
        errorMessage: 'Failed to randomize: $e',
        isLoading: false,
      );
    }
  }

  /// Reset all parameters to defaults
  Future<void> resetAll() async {
    state = state.copyWith(isLoading: true);

    try {
      final bridge = _ref.read(webglBridgeProvider);
      await bridge.resetAll();

      state = state.resetParameters().copyWith(isLoading: false);

      debugPrint('[EngineProvider] Reset all parameters');
    } catch (e) {
      debugPrint('[EngineProvider] Error resetting: $e');
      state = state.copyWith(
        errorMessage: 'Failed to reset: $e',
        isLoading: false,
      );
    }
  }

  /// Get current state from WebGL (sync local state)
  Future<void> syncState() async {
    try {
      final bridge = _ref.read(webglBridgeProvider);
      final webglState = await bridge.getCurrentState();

      if (webglState != null) {
        state = webglState;
        debugPrint('[EngineProvider] State synced from WebGL');
      }
    } catch (e) {
      debugPrint('[EngineProvider] Error syncing state: $e');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }
}

/// Engine State Provider - Main provider for engine state
///
/// Usage:
/// ```dart
/// // Watch state
/// final engine = ref.watch(engineProvider);
///
/// // Read notifier
/// final notifier = ref.read(engineProvider.notifier);
/// await notifier.switchSystem('quantum');
/// await notifier.updateParameter('hue', 240);
/// ```
final engineProvider =
    StateNotifierProvider<EngineStateNotifier, EngineState>((ref) {
  return EngineStateNotifier(ref);
});

/// Current System Provider - Convenience provider for current system
final currentSystemProvider = Provider<String>((ref) {
  return ref.watch(engineProvider).currentSystem;
});

/// Current Parameters Provider - Convenience provider for parameters
final currentParametersProvider = Provider<Map<String, double>>((ref) {
  return ref.watch(engineProvider).parameters;
});

/// Single Parameter Provider Family - Watch individual parameters
///
/// Usage:
/// ```dart
/// final hueValue = ref.watch(parameterProvider('hue'));
/// ```
final parameterProvider = Provider.family<double, String>((ref, paramName) {
  return ref.watch(engineProvider).getParameter(paramName);
});

/// Audio Enabled Provider - Convenience provider for audio state
final audioEnabledProvider = Provider<bool>((ref) {
  return ref.watch(engineProvider).audioEnabled;
});

/// Loading State Provider - Convenience provider for loading state
final loadingProvider = Provider<bool>((ref) {
  return ref.watch(engineProvider).isLoading;
});

/// Error Message Provider - Convenience provider for error messages
final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(engineProvider).errorMessage;
});
