// VIB34D Faceted System - Vertex Shader
// 4D to 3D projection with rotation
// © 2025 Paul Phillips - Clear Seas Solutions LLC

attribute vec4 a_position;  // 4D vertex position
attribute vec3 a_color;     // Vertex color

uniform mat4 u_rotation4D;  // 4D rotation matrix
uniform mat4 u_projection;  // 3D projection matrix
uniform mat4 u_view;        // 3D view matrix
uniform float u_time;       // Animation time

varying vec3 v_color;
varying float v_depth;

// 4D to 3D perspective projection
vec3 project4Dto3D(vec4 point4D) {
    float distance = 2.0;
    float w = 1.0 / (distance - point4D.w);
    return vec3(point4D.xyz) * w;
}

void main() {
    // Apply 4D rotation
    vec4 rotated4D = u_rotation4D * a_position;

    // Project to 3D
    vec3 position3D = project4Dto3D(rotated4D);

    // Apply 3D transformations
    vec4 viewPos = u_view * vec4(position3D, 1.0);
    gl_Position = u_projection * viewPos;

    // Pass color and depth to fragment shader
    v_color = a_color;
    v_depth = rotated4D.w;

    // Point size for GL_POINTS rendering
    gl_PointSize = 2.0;
}
