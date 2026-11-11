# Water System Shaders
# Verdant — Unbound Lite
# Transparent water, animated surface, efficient reflections

# Water Vertex Shader
# shaders/water/water.vsh

#version 330 core

#include "../includes/common.glsl"

in vec3 position;
in vec2 texcoord;
in vec3 normal;

out vec2 fragTexcoord;
out vec3 fragNormal;
out vec3 viewPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 cameraPos;

void main() {
    fragTexcoord = texcoord;
    fragNormal = normalize(mat3(view * model) * normal);
    viewPos = (view * model * vec4(position, 1.0)).xyz;
    
    gl_Position = projection * view * model * vec4(position, 1.0);
}

# Water Fragment Shader
# shaders/water/water.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragNormal;
in vec3 viewPos;

out vec4 colortex0;

uniform sampler2D waterTexture;
uniform sampler2D reflectionTexture;
uniform float time;
uniform float waterQuality;
uniform bool reflections;
uniform bool waterAnimation;
uniform bool underwaterEffects;
uniform bool masterToggle;

// Efficient water reflection approximation
vec3 calculateWaterReflection(sampler2D reflectionMap, vec2 coord, float quality) {
    // Simplified screen-space reflection for 940MX
    vec2 reflectionCoord = coord + vec2(0.01, 0.01) * quality;
    return texture2D(rmap, reflectionCoord).rgb;
}

// Water refraction approximation
vec3 calculateWaterRefraction(sampler2D texture, vec2 coord, float quality) {
    // Simplified refraction for performance
    vec2 refractionCoord = coord - vec2(0.01, 0.01) * quality;
    return texture2D(texture, refractionCoord).rgb;
}

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(waterTexture, fragTexcoord);
        return;
    }
    
    // Water normal and animation
    vec2 animatedCoord = fragTexcoord;
    if (waterAnimation) {
        animatedCoord = animateWaterSurface(fragTexcoord, time);
    }
    
    vec4 waterColor = texture2D(waterTexture, animatedCoord);
    vec3 normal = normalize(fragNormal);
    
    // Water quality adjustment
    float qualityFactor = waterQuality ? 1.0 : 0.5;
    
    // Reflections (efficient approximation)
    vec3 reflectionColor = vec3(0.0);
    if (reflections) {
        reflectionColor = calculateWaterReflection(reflectionTexture, animatedCoord, qualityFactor);
    }
    
    // Refraction (simplified)
    vec3 refractionColor = calculateWaterRefraction(waterTexture, animatedCoord, qualityFactor);
    
    // Combine water effects
    vec3 finalColor = mix(reflectionColor, refractionColor, 0.5) * waterColor.rgb;
    
    // Underwater effects
    if (underwaterEffects) {
        finalColor *= vec3(0.8, 0.9, 1.0);  // Blue tint
    }
    
    // Transparency
    float transparency = waterColor.a * qualityFactor;
    
    colortex0 = vec4(finalColor, transparency);
}

# Water Normal Vertex Shader
# shaders/water/water_normal.vsh

#version 330 core

#include "../includes/common.glsl"

in vec3 position;
in vec2 texcoord;

out vec2 fragTexcoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    fragTexcoord = texcoord;
    gl_Position = projection * view * model * vec4(position, 1.0);
}

# Water Normal Fragment Shader
# shaders/water/water_normal.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D normalMap;
uniform float time;
uniform bool waterAnimation;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(normalMap, fragTexcoord);
        return;
    }
    
    // Animated normal map (efficient approximation)
    vec2 animatedCoord = fragTexcoord;
    if (waterAnimation) {
        animatedCoord = animateWaterSurface(fragTexcoord, time);
    }
    
    vec4 normalColor = texture2D(normalMap, animatedCoord);
    
    // Normalize normal
    vec3 normal = normalize(normalColor.rgb * 2.0 - 1.0);
    
    colortex0 = vec4(normal, normalColor.a);
}
