# Shadow Pass Shaders
# Verdant — Unbound Lite
# Efficient shadow mapping for NVIDIA GeForce 940MX
# Super good but lightweight shadows (8-sample PCF)

# Vertex Shader - Shadow
# shadow.vsh

#version 330 core

#include "../includes/common.glsl"

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

#include "../includes/common.glsl"

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

#include "../includes/common.glsl"

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

#include "../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 shadowcolor0;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform float shadowDistance;
uniform float shadowQuality;
uniform bool softShadows;
uniform bool masterToggle;

// Super Good Lightweight Shadow Filtering (8-sample PCF)
float calculateSuperGoodShadow(sampler2D shadowMap, vec2 coord, float quality) {
    // Improved 8-tap PCF for "super good" but lightweight filtering
    // Optimized for 940MX memory constraints
    float shadow = 0.0;
    float offset = SHADOW_SOFTNESS * quality;
    
    // Lightweight 8-sample PCF approximation (Super Good but Lightweight)
    // Better than previous 4-sample, but still optimized for 940MX
    for (int i = 0; i < SHADOW_SAMPLES; i++) {
        float dx = (float((i % 3) - 1)) * offset;
        float dy = (float((i / 3) - 1)) * offset;
        shadow += texture2D(shadowMap, coord + vec2(dx, dy)).r;
    }
    shadow /= float(SHADOW_SAMPLES);
    
    return shadow;
}

void main() {
    if (!masterToggle) {
        shadowcolor0 = vec4(1.0);
        return;
    }
    
    // Super Good Lightweight shadow calculation
    float shadow = calculateSuperGoodShadow(shadowtex0, fragTexcoord, shadowQuality);
    
    // Distance-based optimization
    float distanceFactor = min(fragTexcoord.x, fragTexcoord.y) / shadowDistance;
    shadow *= distanceFactor;
    
    shadowcolor0 = vec4(shadow, shadow, shadow, 1.0);
}
