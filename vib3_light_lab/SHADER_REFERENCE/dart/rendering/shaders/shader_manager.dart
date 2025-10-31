/// VIB3 Light Lab - Shader Management System
///
/// Manages GLSL shader compilation, linking, and uniform updates.
/// Handles all shader programs for VIB34D visualization systems.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_gl/flutter_gl.dart';

/// Shader Program - Compiled vertex + fragment shader
class ShaderProgram {
  final int programId;
  final Map<String, int> uniformLocations = {};
  final Map<String, int> attributeLocations = {};

  ShaderProgram(this.programId);

  /// Cache uniform location
  void cacheUniformLocation(dynamic gl, String name) {
    final location = gl.getUniformLocation(programId, name);
    if (location != null && location >= 0) {
      uniformLocations[name] = location;
    }
  }

  /// Cache attribute location
  void cacheAttributeLocation(dynamic gl, String name) {
    final location = gl.getAttribLocation(programId, name);
    if (location >= 0) {
      attributeLocations[name] = location;
    }
  }

  /// Get uniform location
  int? getUniformLocation(String name) => uniformLocations[name];

  /// Get attribute location
  int? getAttributeLocation(String name) => attributeLocations[name];
}

/// Shader Manager - Manages all shader programs
class ShaderManager {
  final dynamic gl;
  final Map<String, ShaderProgram> _programs = {};

  ShaderManager(this.gl);

  /// Create shader program from source
  Future<ShaderProgram?> createProgram({
    required String name,
    required String vertexSource,
    required String fragmentSource,
    List<String>? uniforms,
    List<String>? attributes,
  }) async {
    try {
      // Compile vertex shader
      final vertexShader = _compileShader(
        gl.VERTEX_SHADER,
        vertexSource,
      );
      if (vertexShader == null) {
        debugPrint('[ShaderManager] Failed to compile vertex shader: $name');
        return null;
      }

      // Compile fragment shader
      final fragmentShader = _compileShader(
        gl.FRAGMENT_SHADER,
        fragmentSource,
      );
      if (fragmentShader == null) {
        debugPrint('[ShaderManager] Failed to compile fragment shader: $name');
        gl.deleteShader(vertexShader);
        return null;
      }

      // Link program
      final program = gl.createProgram();
      gl.attachShader(program, vertexShader);
      gl.attachShader(program, fragmentShader);
      gl.linkProgram(program);

      // Check link status
      final linkStatus = gl.getProgramParameter(program, gl.LINK_STATUS);
      if (linkStatus == 0 || linkStatus == false) {
        final info = gl.getProgramInfoLog(program);
        debugPrint('[ShaderManager] Failed to link program $name: $info');
        gl.deleteProgram(program);
        gl.deleteShader(vertexShader);
        gl.deleteShader(fragmentShader);
        return null;
      }

      // Cleanup shaders (no longer needed after linking)
      gl.deleteShader(vertexShader);
      gl.deleteShader(fragmentShader);

      final shaderProgram = ShaderProgram(program);

      // Cache uniform locations
      if (uniforms != null) {
        for (final uniform in uniforms) {
          shaderProgram.cacheUniformLocation(gl, uniform);
        }
      }

      // Cache attribute locations
      if (attributes != null) {
        for (final attribute in attributes) {
          shaderProgram.cacheAttributeLocation(gl, attribute);
        }
      }

      _programs[name] = shaderProgram;
      debugPrint('[ShaderManager] Created shader program: $name');

      return shaderProgram;
    } catch (e) {
      debugPrint('[ShaderManager] Error creating program $name: $e');
      return null;
    }
  }

  /// Compile shader
  int? _compileShader(int type, String source) {
    final shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);

    final compileStatus = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (compileStatus == 0 || compileStatus == false) {
      final info = gl.getShaderInfoLog(shader);
      debugPrint('[ShaderManager] Shader compile error: $info');
      gl.deleteShader(shader);
      return null;
    }

    return shader;
  }

  /// Get program by name
  ShaderProgram? getProgram(String name) => _programs[name];

  /// Use program
  void useProgram(String name) {
    final program = _programs[name];
    if (program != null) {
      gl.useProgram(program.programId);
    }
  }

  /// Set uniform float
  void setUniform1f(String programName, String uniformName, double value) {
    final program = _programs[programName];
    final location = program?.getUniformLocation(uniformName);
    if (location != null) {
      gl.uniform1f(location, value);
    }
  }

  /// Set uniform vec2
  void setUniform2f(
      String programName, String uniformName, double x, double y) {
    final program = _programs[programName];
    final location = program?.getUniformLocation(uniformName);
    if (location != null) {
      gl.uniform2f(location, x, y);
    }
  }

  /// Set uniform vec3
  void setUniform3f(
      String programName, String uniformName, double x, double y, double z) {
    final program = _programs[programName];
    final location = program?.getUniformLocation(uniformName);
    if (location != null) {
      gl.uniform3f(location, x, y, z);
    }
  }

  /// Set uniform vec4
  void setUniform4f(String programName, String uniformName, double x, double y,
      double z, double w) {
    final program = _programs[programName];
    final location = program?.getUniformLocation(uniformName);
    if (location != null) {
      gl.uniform4f(location, x, y, z, w);
    }
  }

  /// Set uniform matrix4
  void setUniformMatrix4fv(
      String programName, String uniformName, Float32List matrix) {
    final program = _programs[programName];
    final location = program?.getUniformLocation(uniformName);
    if (location != null) {
      gl.uniformMatrix4fv(location, false, matrix);
    }
  }

  /// Set uniform int
  void setUniform1i(String programName, String uniformName, int value) {
    final program = _programs[programName];
    final location = program?.getUniformLocation(uniformName);
    if (location != null) {
      gl.uniform1i(location, value);
    }
  }

  /// Delete program
  void deleteProgram(String name) {
    final program = _programs[name];
    if (program != null) {
      gl.deleteProgram(program.programId);
      _programs.remove(name);
    }
  }

  /// Delete all programs
  void dispose() {
    for (final program in _programs.values) {
      gl.deleteProgram(program.programId);
    }
    _programs.clear();
  }
}
