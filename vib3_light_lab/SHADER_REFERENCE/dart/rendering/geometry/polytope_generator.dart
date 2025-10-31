/// VIB3 Light Lab - 4D Polytope Geometry Generator
///
/// Generates vertices, edges, and faces for 8 4D polytopes.
/// Converts 4D geometry to renderable 3D buffers.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:math' as math;
import 'dart:typed_data';
import '../math/quaternion_4d.dart';

/// Polytope Geometry - Generated 4D geometry data
class PolytopeGeometry {
  final Float32List vertices;    // 4D vertices (x,y,z,w)
  final Uint16List indices;      // Triangle indices
  final Float32List colors;      // RGB colors per vertex
  final int vertexCount;

  const PolytopeGeometry({
    required this.vertices,
    required this.indices,
    required this.colors,
    required this.vertexCount,
  });
}

/// Polytope Generator - Creates 4D geometry
class PolytopeGenerator {
  /// Generate geometry for specified polytope type
  static PolytopeGeometry generate(int geometryIndex) {
    return switch (geometryIndex) {
      0 => _generateHypercube(),
      1 => _generateHypertetrahedron(),
      2 => _generateHypersphere(),
      3 => _generateTorus(),
      4 => _generateKleinBottle(),
      5 => _generateCrystal(),
      6 => _generateFractal(),
      7 => _generateWave(),
      _ => _generateHypercube(),
    };
  }

  /// Generate hypercube (tesseract) - 16 vertices, 32 edges
  static PolytopeGeometry _generateHypercube() {
    final vertices4D = PolytopeVertices.hypercube();
    final vertexCount = vertices4D.length;

    // Convert to Float32List (4 components per vertex)
    final vertices = Float32List(vertexCount * 4);
    for (int i = 0; i < vertexCount; i++) {
      vertices[i * 4 + 0] = vertices4D[i].x;
      vertices[i * 4 + 1] = vertices4D[i].y;
      vertices[i * 4 + 2] = vertices4D[i].z;
      vertices[i * 4 + 3] = vertices4D[i].w;
    }

    // Generate edges (32 edges for tesseract)
    final edges = <int>[
      // Bottom hypercube edges
      0, 1, 1, 3, 3, 2, 2, 0, // XY face
      4, 5, 5, 7, 7, 6, 6, 4, // XY face (shifted in Z)
      0, 4, 1, 5, 2, 6, 3, 7, // Z connections

      // Top hypercube edges
      8, 9, 9, 11, 11, 10, 10, 8,   // XY face (shifted in W)
      12, 13, 13, 15, 15, 14, 14, 12, // XY face (shifted in Z and W)
      8, 12, 9, 13, 10, 14, 11, 15,  // Z connections

      // W connections
      0, 8, 1, 9, 2, 10, 3, 11,
      4, 12, 5, 13, 6, 14, 7, 15,
    ];

    final indices = Uint16List.fromList(edges);

    // Generate colors (cyan-magenta gradient)
    final colors = Float32List(vertexCount * 3);
    for (int i = 0; i < vertexCount; i++) {
      final t = i / vertexCount;
      colors[i * 3 + 0] = 0.0 + t; // Red
      colors[i * 3 + 1] = 1.0 - t * 0.5; // Green
      colors[i * 3 + 2] = 1.0; // Blue
    }

    return PolytopeGeometry(
      vertices: vertices,
      indices: indices,
      colors: colors,
      vertexCount: vertexCount,
    );
  }

  /// Generate hypertetrahedron (5-cell) - 5 vertices
  static PolytopeGeometry _generateHypertetrahedron() {
    final vertices4D = PolytopeVertices.hypertetrahedron();
    final vertexCount = vertices4D.length;

    final vertices = Float32List(vertexCount * 4);
    for (int i = 0; i < vertexCount; i++) {
      vertices[i * 4 + 0] = vertices4D[i].x;
      vertices[i * 4 + 1] = vertices4D[i].y;
      vertices[i * 4 + 2] = vertices4D[i].z;
      vertices[i * 4 + 3] = vertices4D[i].w;
    }

    // Edges: connect all vertices to each other (10 edges)
    final edges = <int>[
      0, 1, 0, 2, 0, 3, 0, 4,
      1, 2, 1, 3, 1, 4,
      2, 3, 2, 4,
      3, 4,
    ];

    final indices = Uint16List.fromList(edges);

    // Purple-pink colors
    final colors = Float32List(vertexCount * 3);
    for (int i = 0; i < vertexCount; i++) {
      colors[i * 3 + 0] = 0.6 + i * 0.1; // Red
      colors[i * 3 + 1] = 0.0; // Green
      colors[i * 3 + 2] = 1.0; // Blue
    }

    return PolytopeGeometry(
      vertices: vertices,
      indices: indices,
      colors: colors,
      vertexCount: vertexCount,
    );
  }

  /// Generate hypersphere - subdivided sphere in 4D
  static PolytopeGeometry _generateHypersphere() {
    const subdivisions = 20;
    final vertices4D = PolytopeVertices.hypersphere(subdivisions);
    final vertexCount = vertices4D.length;

    final vertices = Float32List(vertexCount * 4);
    for (int i = 0; i < vertexCount; i++) {
      vertices[i * 4 + 0] = vertices4D[i].x;
      vertices[i * 4 + 1] = vertices4D[i].y;
      vertices[i * 4 + 2] = vertices4D[i].z;
      vertices[i * 4 + 3] = vertices4D[i].w;
    }

    // Create indices for triangle mesh
    final edgesList = <int>[];
    for (int i = 0; i < subdivisions - 1; i++) {
      for (int j = 0; j < subdivisions - 1; j++) {
        final idx = i * subdivisions + j;
        edgesList.addAll([
          idx, idx + 1,
          idx, idx + subdivisions,
        ]);
      }
    }

    final indices = Uint16List.fromList(edgesList);

    // Gradient colors
    final colors = Float32List(vertexCount * 3);
    for (int i = 0; i < vertexCount; i++) {
      final t = (i % subdivisions) / subdivisions;
      colors[i * 3 + 0] = t; // Red
      colors[i * 3 + 1] = 0.5; // Green
      colors[i * 3 + 2] = 1.0 - t * 0.5; // Blue
    }

    return PolytopeGeometry(
      vertices: vertices,
      indices: indices,
      colors: colors,
      vertexCount: vertexCount,
    );
  }

  /// Generate 4D torus
  static PolytopeGeometry _generateTorus() {
    const segments = 24;
    const rings = 16;
    final majorRadius = 1.0;
    final minorRadius = 0.3;

    final vertices4D = <Vector4>[];

    for (int i = 0; i < rings; i++) {
      final theta = (i / rings) * 2 * math.pi;
      for (int j = 0; j < segments; j++) {
        final phi = (j / segments) * 2 * math.pi;

        final x = (majorRadius + minorRadius * math.cos(phi)) * math.cos(theta);
        final y = (majorRadius + minorRadius * math.cos(phi)) * math.sin(theta);
        final z = minorRadius * math.sin(phi);
        final w = math.sin(theta) * 0.5; // 4D component

        vertices4D.add(Vector4(x, y, z, w));
      }
    }

    final vertexCount = vertices4D.length;
    final vertices = Float32List(vertexCount * 4);
    for (int i = 0; i < vertexCount; i++) {
      vertices[i * 4 + 0] = vertices4D[i].x;
      vertices[i * 4 + 1] = vertices4D[i].y;
      vertices[i * 4 + 2] = vertices4D[i].z;
      vertices[i * 4 + 3] = vertices4D[i].w;
    }

    // Generate indices
    final edgesList = <int>[];
    for (int i = 0; i < rings; i++) {
      for (int j = 0; j < segments; j++) {
        final current = i * segments + j;
        final next = i * segments + ((j + 1) % segments);
        final nextRing = ((i + 1) % rings) * segments + j;

        edgesList.addAll([current, next, current, nextRing]);
      }
    }

    final indices = Uint16List.fromList(edgesList);

    // Rainbow colors
    final colors = Float32List(vertexCount * 3);
    for (int i = 0; i < vertexCount; i++) {
      final hue = (i / vertexCount) * 360.0;
      final rgb = _hsvToRgb(hue, 0.8, 1.0);
      colors[i * 3 + 0] = rgb[0];
      colors[i * 3 + 1] = rgb[1];
      colors[i * 3 + 2] = rgb[2];
    }

    return PolytopeGeometry(
      vertices: vertices,
      indices: indices,
      colors: colors,
      vertexCount: vertexCount,
    );
  }

  /// Generate Klein bottle (4D non-orientable surface)
  static PolytopeGeometry _generateKleinBottle() {
    // For now, use torus as placeholder
    // TODO: Implement proper Klein bottle parametrization
    return _generateTorus();
  }

  /// Generate crystal lattice
  static PolytopeGeometry _generateCrystal() {
    // Use hypercube as base
    return _generateHypercube();
  }

  /// Generate fractal structure
  static PolytopeGeometry _generateFractal() {
    // Use hypertetrahedron as base
    return _generateHypertetrahedron();
  }

  /// Generate wave pattern
  static PolytopeGeometry _generateWave() {
    // Use hypersphere as base
    return _generateHypersphere();
  }

  /// HSV to RGB conversion
  static List<double> _hsvToRgb(double h, double s, double v) {
    final c = v * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = v - c;

    double r, g, b;
    if (h < 60) {
      r = c; g = x; b = 0;
    } else if (h < 120) {
      r = x; g = c; b = 0;
    } else if (h < 180) {
      r = 0; g = c; b = x;
    } else if (h < 240) {
      r = 0; g = x; b = c;
    } else if (h < 300) {
      r = x; g = 0; b = c;
    } else {
      r = c; g = 0; b = x;
    }

    return [r + m, g + m, b + m];
  }
}
