# Lighting System Shaders
# Verdant — Unbound Lite
# Directional sunlight, moonlight, ambient lighting, biome-dependent colors

# Lighting Vertex Shader
# shaders/lighting/lighting.vsh

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

# Lighting Fragment Shader
# shaders/lighting/lighting.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragNormal;
in vec3 viewPos;

out vec4 colortex0;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D shadowcolor0;

uniform vec3 sunlightColor;
uniform vec3 moonlightColor;
uniform vec3 ambientColor;
uniform float lightIntensity;
uniform float time;
uniform float weather;
uniform bool sunlightQuality;
uniform bool moonlight;
uniform bool ambientOcclusion;
uniform bool colorGrading;
uniform bool masterToggle;

// Biome-dependent lighting colors (simplified)
vec3 getBiomeLightingColor(vec2 coord) {
    // Simplified biome detection based on coordinates
    float biomeFactor = sin(coord.x * 10.0) * cos(coord.y * 10.0);
    vec3 baseColor = vec3(1.0, 1.0, 1.0);
    
    if (biomeFactor > 0.5) {
        baseColor = vec3(0.9, 1.0, 0.9);  // Forest/Plains
    } else if (biomeFactor < -0.5) {
        baseColor = vec3(1.0, 0.9, 0.8);  // Desert
    } else {
        baseColor = vec3(0.8, 0.9, 1.0);  // Ocean/Water
    }
    
    return baseColor;
}

// Time-dependent color temperature
vec3 getTimeDependentColorTemperature(float time) {
    // Simplified color temperature based on time
    if (time < 0.25 || time > 0.75) {
        return vec3(0.8, 0.8, 1.0);  // Night (cool)
    } else if (time < 0.5) {
        return vec3(1.0, 0.9, 0.8);  // Sunrise (warm)
    } else {
        return vec3(1.0, 0.9, 0.7);  // Sunset (warm)
    }
}

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(texture, fragTexcoord);
        return;
    }
    
    // Read G-Buffer data
    vec4 albedoData = texture2D(texture, fragTexcoord);
    vec4 normalData = texture2D(lightmap, fragTexcoord);
    vec3 albedo = albedoData.rgb;
    vec3 normal = normalize(normalData.rgb);
    
    // Read shadow data
    float shadow = texture2D(shadowcolor0, fragTexcoord).r;
    
    // Directional sunlight
    vec3 lightDir = normalize(vec3(0.5, 0.7, 0.5));
    float sunDot = max(dot(normal, lightDir), 0.0);
    vec3 sunLighting = sunlightColor * sunDot * lightIntensity * shadow;
    
    // Directional moonlight
    vec3 moonLighting = vec3(0.0);
    if (moonlight) {
        vec3 moonlightDir = normalize(vec3(-0.5, 0.7, 0.5));
        float moonDot = max(dot(normal, moonlightDir), 0.0);
        moonLighting = moonlightColor * moonDot * lightIntensity * 0.5 * shadow;
    }
    
    // Ambient lighting
    vec3 ambient = ambientColor;
    if (ambientOcclusion) {
        // Simplified ambient occlusion approximation
        ambient *= 0.8;
    }
    
    // Biome-dependent lighting
    vec3 biomeColor = getBiomeLightingColor(fragTexcoord);
    
    // Time-dependent color temperature
    vec3 temperatureColor = getTimeDependentColorTemperature(time);
    
    // Weather-dependent ambient lighting
    float weatherFactor = 1.0 - weather * 0.5;
    ambient *= weatherFactor;
    
    // Combined lighting
    vec3 lighting = (sunLighting + moonLighting + ambient) * biomeColor * temperatureColor;
    
    // Material shading
    vec3 material = vec3(1.0);
    vec3 finalColor = albedo * lighting * material;
    
    // Color grading
    if (colorGrading) {
        finalColor = applyColorGrading(finalColor, 1.0, 1.0);
    }
    
    colortex0 = vec4(finalColor, albedoData.a);
}

# Lighting Composite Vertex Shader
# shaders/lighting/lighting_composite.vsh

#version 330 core

#include "../includes/common.glsl"

in vec2 position;
in vec2 texcoord;

out vec2 fragTexcoord;

void main() {
    fragTexcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}

# Lighting Composite Fragment Shader
# shaders/lighting/lighting_composite.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;

inout vec4 colortex0;

uniform float time;
uniform float weather;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        return;
    }
    
    // Lighting transitions and adjustments
    vec3 skyColor = calculateSkyColor(time, weather);
    
    // Smooth day/night transitions
    float transitionFactor = sin(time * 3.14159) * 0.5 + 0.5;
    vec3 transitionColor = mix(vec3(0.1, 0.1, 0.2), skyColor, transitionFactor);
    
    // Apply lighting adjustments
    colortex0.rgb *= transitionColor;
}
