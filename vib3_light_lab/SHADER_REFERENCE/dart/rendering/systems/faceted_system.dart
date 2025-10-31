/// VIB3 Light Lab - Faceted Visualization System
///
/// First VIB34D system implementation using native OpenGL ES.
/// Reference implementation showing complete rendering pipeline.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_math/vector_math.dart' hide Vector4;

import 'visualization_system.dart';
import '../shaders/shader_manager.dart';
import '../geometry/polytope_generator.dart';
import '../math/quaternion_4d.dart';
import '../../config/constants.dart';

/// Faceted System - 2D geometric patterns with 4D rotation
class FacetedSystem implements VisualizationSystem {
  dynamic _gl;
  ShaderManager? _shaderManager;
  ShaderProgram? _program;

  // Geometry buffers
  int? _vertexBuffer;
  int? _colorBuffer;
  int? _indexBuffer;

  // Current state
  final SystemState _state = SystemState(
    parameters: {},
    currentGeometry: 0,
    time: 0.0,
  );

  // Current geometry
  PolytopeGeometry? _currentGeometry;
  int _indexCount = 0;

  // View matrices
  final Matrix4 _projectionMatrix = Matrix4.identity();
  final Matrix4 _viewMatrix = Matrix4.identity();
  Matrix4D _rotation4D = Matrix4D.identity();

  @override
  String get name => 'faceted';

  @override
  Future<void> initialize(dynamic gl) async {
    _gl = gl;
    _shaderManager = ShaderManager(gl);

    try {
      // Load shaders
      final vertexSource =
          await rootBundle.loadString('assets/shaders/faceted_vertex.glsl');
      final fragmentSource =
          await rootBundle.loadString('assets/shaders/faceted_fragment.glsl');

      // Create shader program
      _program = await _shaderManager!.createProgram(
        name: 'faceted',
        vertexSource: vertexSource,
        fragmentSource: fragmentSource,
        uniforms: [
          'u_rotation4D',
          'u_projection',
          'u_view',
          'u_time',
          'u_hue',
          'u_saturation',
          'u_intensity',
        ],
        attributes: [
          'a_position',
          'a_color',
        ],
      );

      if (_program == null) {
        throw Exception('Failed to create shader program');
      }

      // Initialize geometry
      await _initializeGeometry(0);

      // Setup view matrices
      _setupMatrices();

      debugPrint('[FacetedSystem] Initialized successfully');
    } catch (e) {
      debugPrint('[FacetedSystem] Initialization error: $e');
      rethrow;
    }
  }

  /// Initialize geometry buffers
  Future<void> _initializeGeometry(int geometryIndex) async {
    // Generate geometry
    _currentGeometry = PolytopeGenerator.generate(geometryIndex);
    _indexCount = _currentGeometry!.indices.length;

    // Create vertex buffer
    _vertexBuffer = _gl.createBuffer();
    _gl.bindBuffer(_gl.ARRAY_BUFFER, _vertexBuffer);
    _gl.bufferData(_gl.ARRAY_BUFFER, _currentGeometry!.vertices.lengthInBytes,
        _currentGeometry!.vertices, _gl.STATIC_DRAW);

    // Create color buffer
    _colorBuffer = _gl.createBuffer();
    _gl.bindBuffer(_gl.ARRAY_BUFFER, _colorBuffer);
    _gl.bufferData(_gl.ARRAY_BUFFER, _currentGeometry!.colors.lengthInBytes,
        _currentGeometry!.colors, _gl.STATIC_DRAW);

    // Create index buffer
    _indexBuffer = _gl.createBuffer();
    _gl.bindBuffer(_gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    _gl.bufferData(_gl.ELEMENT_ARRAY_BUFFER,
        _currentGeometry!.indices.lengthInBytes,
        _currentGeometry!.indices, _gl.STATIC_DRAW);

    debugPrint(
        '[FacetedSystem] Loaded geometry $geometryIndex: ${_currentGeometry!.vertexCount} vertices');
  }

  /// Setup projection and view matrices
  void _setupMatrices() {
    // Perspective projection
    _projectionMatrix.setPerspectiveFov(
      1.2, // FOV
      1.0, // Aspect (will be updated on resize)
      0.1, // Near
      100.0, // Far
    );

    // View matrix (camera at z=3, looking at origin)
    _viewMatrix.setIdentity();
    _viewMatrix.translate(0.0, 0.0, -3.0);
  }

  @override
  void render(double deltaTime) {
    if (_program == null || _currentGeometry == null) return;

    // Use shader program
    _shaderManager!.useProgram('faceted');

    // Update 4D rotation matrix from parameters
    final rot4dXW =
        _state.parameters[VIB3Parameters.rot4dXW] ?? 0.0;
    final rot4dYW =
        _state.parameters[VIB3Parameters.rot4dYW] ?? 0.0;
    final rot4dZW =
        _state.parameters[VIB3Parameters.rot4dZW] ?? 0.0;

    _rotation4D = Rotation4D.rotate4D(rot4dXW, rot4dYW, rot4dZW);

    // Set uniforms
    _shaderManager!.setUniformMatrix4fv(
        'faceted', 'u_rotation4D', _rotation4D.storage);
    _shaderManager!.setUniformMatrix4fv(
        'faceted', 'u_projection', _projectionMatrix.storage);
    _shaderManager!.setUniformMatrix4fv(
        'faceted', 'u_view', _viewMatrix.storage);
    _shaderManager!.setUniform1f(
        'faceted', 'u_time', _state.time);

    // Color parameters
    final hue = _state.parameters[VIB3Parameters.hue] ?? 240.0;
    final saturation =
        _state.parameters[VIB3Parameters.saturation] ?? 0.8;
    final intensity =
        _state.parameters[VIB3Parameters.intensity] ?? 1.0;

    _shaderManager!.setUniform1f('faceted', 'u_hue', hue);
    _shaderManager!.setUniform1f('faceted', 'u_saturation', saturation);
    _shaderManager!.setUniform1f('faceted', 'u_intensity', intensity);

    // Bind vertex buffer
    _gl.bindBuffer(_gl.ARRAY_BUFFER, _vertexBuffer);
    final positionLoc = _program!.getAttributeLocation('a_position');
    if (positionLoc != null) {
      _gl.enableVertexAttribArray(positionLoc);
      _gl.vertexAttribPointer(positionLoc, 4, _gl.FLOAT, false, 0, 0);
    }

    // Bind color buffer
    _gl.bindBuffer(_gl.ARRAY_BUFFER, _colorBuffer);
    final colorLoc = _program!.getAttributeLocation('a_color');
    if (colorLoc != null) {
      _gl.enableVertexAttribArray(colorLoc);
      _gl.vertexAttribPointer(colorLoc, 3, _gl.FLOAT, false, 0, 0);
    }

    // Bind index buffer
    _gl.bindBuffer(_gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);

    // Draw
    _gl.drawElements(_gl.LINES, _indexCount, _gl.UNSIGNED_SHORT, 0);

    // Cleanup
    if (positionLoc != null) {
      _gl.disableVertexAttribArray(positionLoc);
    }
    if (colorLoc != null) {
      _gl.disableVertexAttribArray(colorLoc);
    }
  }

  @override
  void updateParameter(String name, double value) {
    _state.parameters[name] = value;

    // Special handling for time-based parameters
    if (name == VIB3Parameters.speed) {
      // Speed affects time progression
    }
  }

  @override
  void selectGeometry(int index) {
    if (index >= 0 && index <= 7) {
      _initializeGeometry(index);
    }
  }

  @override
  void resize(int width, int height) {
    final aspect = width / height;
    _projectionMatrix.setPerspectiveFov(1.2, aspect, 0.1, 100.0);
  }

  @override
  void setInteractivityEnabled(bool enabled) {
    // TODO: Implement mouse/touch interaction
  }

  @override
  void dispose() {
    // Delete buffers
    if (_vertexBuffer != null) {
      _gl.deleteBuffer(_vertexBuffer);
    }
    if (_colorBuffer != null) {
      _gl.deleteBuffer(_colorBuffer);
    }
    if (_indexBuffer != null) {
      _gl.deleteBuffer(_indexBuffer);
    }

    // Delete shader program
    _shaderManager?.deleteProgram('faceted');
    _shaderManager?.dispose();

    debugPrint('[FacetedSystem] Disposed');
  }
}
