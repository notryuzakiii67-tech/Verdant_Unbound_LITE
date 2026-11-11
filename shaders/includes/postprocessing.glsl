# Bloom and Post-Processing Shaders
# Verdant — Unbound Lite
# Subtle bloom, controlled exposure, tonemapping, color grading, contrast, saturation, vignette, lens effects

# Post-Processing Vertex Shader
# shaders/postprocessing/postprocessing.vsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 position;
in vec2 texcoord;

out vec2 fragTexcoord;

void main() {
    fragTexcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}

# Post-Processing Fragment Shader
# shaders/postprocessing/postprocessing.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 finalColor;

uniform sampler2D inputTexture;

uniform float exposure;
uniform float contrast;
uniform float saturation;
uniform bool bloom;
uniform bool tonemapping;
uniform bool vignette;
uniform bool colorGrading;
uniform bool masterToggle;

// Lightweight bloom approximation (optimized for 940MX)
vec3 calculateBloom(sampler2D texture, vec2 coord, float threshold, float intensity) {
    // Simplified bloom (no expensive blur passes)
    vec4 colorData = texture2D(texture, coord);
    vec3 color = colorData.rgb;
    
    float brightness = max(max(color.r, color.g), color.b);
    float bloomFactor = max(brightness - threshold, 0.0) * intensity;
    
    // Simple bloom approximation (no expensive blur)
    vec3 bloomColor = vec3(bloomFactor);
    
    return bloomColor;
}

// Efficient tonemapping
vec3 efficientTonemapping(vec3 color) {
    // Simplified tonemapping for performance
    return color / (1.0 + color);
}

// Lightweight vignette
float calculateVignette(vec2 coord) {
    // Simplified vignette calculation
    float distance = length(coord - vec2(0.5));
    return max(1.0 - distance * 2.0, 0.5);
}

void main() {
    if (!masterToggle) {
        finalColor = texture2D(inputTexture, fragTexcoord);
        return;
    }
    
    vec4 colorData = texture2D(inputTexture, fragTexcoord);
    vec3 color = colorData.rgb;
    
    // Exposure adjustment
    color *= exposure;
    
    // Contrast adjustment
    color = (color - 0.5) * contrast + 0.5;
    
    // Saturation adjustment
    vec3 gray = vec3(0.299, 0.587, 0.114) * dot(color, vec3(1.0));
    color = mix(gray, color, saturation);
    
    // Bloom (lightweight approximation)
    if (bloom) {
        vec3 bloomColor = calculateBloom(inputTexture, fragTexcoord, 0.8, 0.3);
        color += bloomColor;
    }
    
    // Tonemapping
    if (tonemapping) {
        color = efficientTonemapping(color);
    }
    
    // Color grading
    if (colorGrading) {
        color = applyColorGrading(color, saturation, contrast);
    }
    
    // Vignette
    if (vignette) {
        float vignetteFactor = calculateVignette(fragTexcoord);
        color *= vignetteFactor;
    }
    
    // Lens effects (simplified approximation)
    float lensEffect = sin(fragTexcoord.x * 10.0) * cos(fragTexcoord.y * 10.0) * 0.05;
    color += vec3(lensEffect);
    
    finalColor = vec4(color, colorData.a);
}

# Bloom Pass Vertex Shader (Optimized for 940MX)
# shaders/postprocessing/bloom.vsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 position;
in vec2 texcoord;

out vec2 fragTexcoord;

void main() {
    fragTexcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}

# Bloom Pass Fragment Shader (Optimized for 940MX)
# shaders/postprocessing/bloom.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 bloomColor;

uniform sampler2D inputTexture;
uniform float bloomThreshold;
uniform float bloomIntensity;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        bloomColor = vec4(0.0);
        return;
    }
    
    // Simplified bloom extraction (no expensive blur)
    vec4 colorData = texture2D(inputTexture, fragTexcoord);
    vec3 color = colorData.rgb;
    
    float brightness = max(max(color.r, color.g), color.b);
    float bloomFactor = max(brightness - bloomThreshold, 0.0) * bloomIntensity;
    
    bloomColor = vec4(bloomFactor, bloomFactor, bloomFactor, 1.0);
}
