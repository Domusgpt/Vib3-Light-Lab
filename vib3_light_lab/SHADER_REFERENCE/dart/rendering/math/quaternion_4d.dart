/// VIB3 Light Lab - 4D Quaternion Mathematics
///
/// Complete 4D rotation system using quaternions.
/// Handles 6-plane rotations: XY, XZ, XW, YZ, YW, ZW
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

/// Vector4 - 4D Vector
class Vector4 {
  double x, y, z, w;

  Vector4(this.x, this.y, this.z, this.w);

  Vector4.zero()
      : x = 0.0,
        y = 0.0,
        z = 0.0,
        w = 0.0;

  Vector4.copy(Vector4 other)
      : x = other.x,
        y = other.y,
        z = other.z,
        w = other.w;

  /// Length of vector
  double get length => math.sqrt(x * x + y * y + z * z + w * w);

  /// Normalize vector
  Vector4 normalize() {
    final len = length;
    if (len == 0) return Vector4.zero();
    return Vector4(x / len, y / len, z / len, w / len);
  }

  /// Dot product
  double dot(Vector4 other) {
    return x * other.x + y * other.y + z * other.z + w * other.w;
  }

  /// Add vectors
  Vector4 operator +(Vector4 other) {
    return Vector4(x + other.x, y + other.y, z + other.z, w + other.w);
  }

  /// Subtract vectors
  Vector4 operator -(Vector4 other) {
    return Vector4(x - other.x, y - other.y, z - other.z, w - other.w);
  }

  /// Multiply by scalar
  Vector4 operator *(double scalar) {
    return Vector4(x * scalar, y * scalar, z * scalar, w * scalar);
  }

  @override
  String toString() => 'Vector4($x, $y, $z, $w)';
}

/// Matrix4D - 4x4 matrix for 4D transformations
class Matrix4D {
  final Float32List _storage = Float32List(16);

  Matrix4D();

  /// Identity matrix
  Matrix4D.identity() {
    _storage[0] = 1.0;
    _storage[5] = 1.0;
    _storage[10] = 1.0;
    _storage[15] = 1.0;
  }

  /// Access storage
  Float32List get storage => _storage;

  /// Set value at row, col
  void setEntry(int row, int col, double value) {
    _storage[col * 4 + row] = value;
  }

  /// Get value at row, col
  double entry(int row, int col) {
    return _storage[col * 4 + row];
  }

  /// Multiply vector by matrix
  Vector4 transform(Vector4 v) {
    return Vector4(
      _storage[0] * v.x +
          _storage[4] * v.y +
          _storage[8] * v.z +
          _storage[12] * v.w,
      _storage[1] * v.x +
          _storage[5] * v.y +
          _storage[9] * v.z +
          _storage[13] * v.w,
      _storage[2] * v.x +
          _storage[6] * v.y +
          _storage[10] * v.z +
          _storage[14] * v.w,
      _storage[3] * v.x +
          _storage[7] * v.y +
          _storage[11] * v.z +
          _storage[15] * v.w,
    );
  }

  /// Multiply matrices
  Matrix4D operator *(Matrix4D other) {
    final result = Matrix4D();
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        double sum = 0.0;
        for (int k = 0; k < 4; k++) {
          sum += entry(i, k) * other.entry(k, j);
        }
        result.setEntry(i, j, sum);
      }
    }
    return result;
  }
}

/// Rotation4D - 4D rotation utilities
class Rotation4D {
  /// Rotation in XY plane
  static Matrix4D rotateXY(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    final mat = Matrix4D.identity();
    mat.setEntry(0, 0, c);
    mat.setEntry(0, 1, -s);
    mat.setEntry(1, 0, s);
    mat.setEntry(1, 1, c);
    return mat;
  }

  /// Rotation in XZ plane
  static Matrix4D rotateXZ(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    final mat = Matrix4D.identity();
    mat.setEntry(0, 0, c);
    mat.setEntry(0, 2, -s);
    mat.setEntry(2, 0, s);
    mat.setEntry(2, 2, c);
    return mat;
  }

  /// Rotation in XW plane
  static Matrix4D rotateXW(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    final mat = Matrix4D.identity();
    mat.setEntry(0, 0, c);
    mat.setEntry(0, 3, -s);
    mat.setEntry(3, 0, s);
    mat.setEntry(3, 3, c);
    return mat;
  }

  /// Rotation in YZ plane
  static Matrix4D rotateYZ(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    final mat = Matrix4D.identity();
    mat.setEntry(1, 1, c);
    mat.setEntry(1, 2, -s);
    mat.setEntry(2, 1, s);
    mat.setEntry(2, 2, c);
    return mat;
  }

  /// Rotation in YW plane
  static Matrix4D rotateYW(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    final mat = Matrix4D.identity();
    mat.setEntry(1, 1, c);
    mat.setEntry(1, 3, -s);
    mat.setEntry(3, 1, s);
    mat.setEntry(3, 3, c);
    return mat;
  }

  /// Rotation in ZW plane
  static Matrix4D rotateZW(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    final mat = Matrix4D.identity();
    mat.setEntry(2, 2, c);
    mat.setEntry(2, 3, -s);
    mat.setEntry(3, 2, s);
    mat.setEntry(3, 3, c);
    return mat;
  }

  /// Combined rotation (XW, YW, ZW planes)
  static Matrix4D rotate4D(double angleXW, double angleYW, double angleZW) {
    return rotateZW(angleZW) * rotateYW(angleYW) * rotateXW(angleXW);
  }

  /// Project 4D point to 3D (perspective projection)
  static Vector3 project4Dto3D(Vector4 point, {double distance = 2.0}) {
    final w = 1.0 / (distance - point.w);
    return Vector3(
      point.x * w,
      point.y * w,
      point.z * w,
    );
  }

  /// Stereographic projection 4D to 3D
  static Vector3 stereographicProject(Vector4 point) {
    final denominator = 1.0 - point.w;
    if (denominator.abs() < 0.0001) {
      return Vector3(point.x, point.y, point.z) * 1000.0;
    }
    return Vector3(
      point.x / denominator,
      point.y / denominator,
      point.z / denominator,
    );
  }
}

/// 4D Polytope Vertices Generator
class PolytopeVertices {
  /// Generate 4D hypercube (tesseract) vertices
  static List<Vector4> hypercube() {
    final vertices = <Vector4>[];
    for (int i = 0; i < 16; i++) {
      vertices.add(Vector4(
        (i & 1) == 0 ? -1.0 : 1.0,
        (i & 2) == 0 ? -1.0 : 1.0,
        (i & 4) == 0 ? -1.0 : 1.0,
        (i & 8) == 0 ? -1.0 : 1.0,
      ));
    }
    return vertices;
  }

  /// Generate 4D hypertetrahedron (5-cell) vertices
  static List<Vector4> hypertetrahedron() {
    final sqrt5 = math.sqrt(5.0);
    return [
      Vector4(1.0, 1.0, 1.0, -1.0 / sqrt5),
      Vector4(1.0, -1.0, -1.0, -1.0 / sqrt5),
      Vector4(-1.0, 1.0, -1.0, -1.0 / sqrt5),
      Vector4(-1.0, -1.0, 1.0, -1.0 / sqrt5),
      Vector4(0.0, 0.0, 0.0, sqrt5 - 1.0 / sqrt5),
    ];
  }

  /// Generate 4D hypersphere points (subdivided)
  static List<Vector4> hypersphere(int subdivisions) {
    final vertices = <Vector4>[];
    final goldenRatio = (1.0 + math.sqrt(5.0)) / 2.0;

    // 120-cell vertices (600 vertices total)
    // Simplified: use spherical distribution
    for (int i = 0; i < subdivisions; i++) {
      for (int j = 0; j < subdivisions; j++) {
        final theta = (i / subdivisions) * 2 * math.pi;
        final phi = (j / subdivisions) * math.pi;
        final psi = goldenRatio * theta;

        vertices.add(Vector4(
          math.cos(theta) * math.sin(phi),
          math.sin(theta) * math.sin(phi),
          math.cos(phi),
          math.sin(psi),
        ).normalize());
      }
    }

    return vertices;
  }
}
