// VIB34D Faceted System - Fragment Shader
// Vaporwave holographic coloring
// © 2025 Paul Phillips - Clear Seas Solutions LLC

#ifdef GL_ES
precision mediump float;
#endif

varying vec3 v_color;
varying float v_depth;

uniform float u_hue;           // 0-360
uniform float u_saturation;    // 0-1
uniform float u_intensity;     // 0-1
uniform float u_time;

// HSV to RGB conversion
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    // Convert hue to 0-1 range
    float hueNormalized = u_hue / 360.0;

    // Add depth-based hue shift
    float depthShift = v_depth * 0.1;
    float finalHue = mod(hueNormalized + depthShift, 1.0);

    // Create holographic color
    vec3 color = hsv2rgb(vec3(finalHue, u_saturation, u_intensity));

    // Apply vertex color modulation
    color *= v_color;

    // Add depth fade
    float alpha = 1.0 - abs(v_depth) * 0.3;
    alpha = clamp(alpha, 0.5, 1.0);

    gl_FragColor = vec4(color, alpha);
}
