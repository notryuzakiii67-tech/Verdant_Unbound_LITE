# Shadow Pass Shaders
# Verdant — Unbound Lite
# Efficient shadow mapping for NVIDIA GeForce 940MX

# Vertex Shader - Shadow
# shadow.vsh

#version 330 core

#include "includes/common.glsl"

in vec3 position;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    gl_Position = projection * view * model * vec4(position, 1.0);
}

# Fragment Shader - Shadow
# shadow.fsh

#version 330 core

#include "includes/common.glsl"

out float shadowtex0;

uniform float shadowBias;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        shadowtex0 = 1.0;
        return;
    }
    
    // Simplified shadow depth calculation
    // Optimized for 940MX memory constraints
    float depth = gl_FragCoord.z / gl_FragCoord.w;
    shadowtex0 = depth + shadowBias;
}

# Vertex Shader - Shadow Composite
# shadowcomp.vsh

#version 330 core

#include "includes/common.glsl"

in vec2 position;
in vec2 texcoord;

out vec2 fragTexcoord;

void main() {
    fragTexcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}

# Fragment Shader - Shadow Composite
# shadowcomp.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;

out vec4 shadowcolor0;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform float shadowDistance;
uniform float shadowQuality;
uniform bool softShadows;
uniform bool masterToggle;

// Efficient shadow filtering for 940MX
float calculateShadowFiltering(sampler2D shadowMap, vec2 coord, float quality) {
    // Simplified PCF (Percentage Closer Filtering)
    // Reduced sample count for performance
    float shadow = texture2D(shadowMap, coord).r;
    
    if (softShadows) {
        // Lightweight soft shadow approximation
        float offset = 0.001 * quality;
        float sample1 = texture2D(shadowMap, coord + vec2(offset, 0.0)).r;
        float sample2 = texture2D(shadowMap, coord - vec2(offset, 0.0)).r;
        float sample3 = texture2D(shadowMap, coord + vec2(0.0, offset)).r;
        float sample4 = texture2D(shadowMap, coord - vec2(0.0, offset)).r;
        shadow = (shadow + sample1 + sample2 + sample3 + sample4) / 5.0;
    }
    
    return shadow;
}

void main() {
    if (!masterToggle) {
        shadowcolor0 = vec4(1.0);
        return;
    }
    
    // Efficient shadow calculation
    float shadow = calculateShadowFiltering(shadowtex0, fragTexcoord, shadowQuality);
    
    // Distance-based optimization
    float distanceFactor = min(fragTexcoord.x, fragTexcoord.y) / shadowDistance;
    shadow *= distanceFactor;
    
    shadowcolor0 = vec4(shadow, shadow, shadow, 1.0);
}
