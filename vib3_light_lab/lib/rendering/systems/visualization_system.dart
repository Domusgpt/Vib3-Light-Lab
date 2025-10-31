/// VIB3 Light Lab - Visualization System Interface
///
/// Base interface for all VIB34D visualization systems.
/// Defines common methods for initialization, rendering, and parameter updates.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'package:flutter/foundation.dart';

/// Visualization System - Base interface
abstract class VisualizationSystem {
  /// System name
  String get name;

  /// Initialize system with OpenGL context
  Future<void> initialize(dynamic gl);

  /// Render frame
  void render(double deltaTime);

  /// Update parameter
  void updateParameter(String name, double value);

  /// Select geometry (0-7)
  void selectGeometry(int index);

  /// Resize viewport
  void resize(int width, int height);

  /// Set interactivity enabled
  void setInteractivityEnabled(bool enabled);

  /// Dispose resources
  void dispose();
}

/// System State - Current rendering state
class SystemState {
  final Map<String, double> parameters;
  final int currentGeometry;
  final double time;
  final bool interactivityEnabled;

  const SystemState({
    required this.parameters,
    required this.currentGeometry,
    required this.time,
    this.interactivityEnabled = true,
  });

  SystemState copyWith({
    Map<String, double>? parameters,
    int? currentGeometry,
    double? time,
    bool? interactivityEnabled,
  }) {
    return SystemState(
      parameters: parameters ?? Map.from(this.parameters),
      currentGeometry: currentGeometry ?? this.currentGeometry,
      time: time ?? this.time,
      interactivityEnabled: interactivityEnabled ?? this.interactivityEnabled,
    );
  }
}
