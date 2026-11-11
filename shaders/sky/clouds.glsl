# Cloud System Shaders
# Verdant — Unbound Lite
# Animated clouds, soft edges, natural shading

# Cloud Vertex Shader
# shaders/clouds/clouds.vsh

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

# Cloud Fragment Shader
# shaders/clouds/clouds.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D cloudTexture;
uniform float time;
uniform float weather;
uniform bool cloudQuality;
uniform bool cloudAnimation;
uniform bool cloudShadows;
uniform bool masterToggle;

// Efficient cloud animation (2D approximation)
vec2 animateCloud(vec2 coord, float time, float quality) {
    // Simplified cloud movement
    float speed = CLOUD_SPEED * (quality ? 1.0 : 0.5);
    vec2 offset = vec2(time * speed, 0.0);
    return coord + offset;
}

// Soft cloud edges approximation
float calculateCloudEdge(vec2 coord) {
    // Simplified edge calculation
    float distance = length(coord - vec2(0.5));
    return max(1.0 - distance * 2.0, 0.0);
}

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(cloudTexture, fragTexcoord);
        return;
    }
    
    // Cloud animation
    vec2 animatedCoord = fragTexcoord;
    if (cloudAnimation) {
        animatedCoord = animateCloud(fragTexcoord, time, float(cloudQuality));
    }
    
    // Cloud color and shading
    vec4 cloudColor = texture2D(cloudTexture, animatedCoord);
    vec3 shadedColor = calculateCloudShading(vec3(0.0, 1.0, 0.0), vec3(0.5, 0.7, 0.5), cloudColor.a);
    
    // Soft edges
    float edgeFactor = calculateCloudEdge(animatedCoord);
    shadedColor *= edgeFactor;
    
    // Weather-dependent cloud appearance
    float weatherFactor = 1.0 - weather * 0.3;
    shadedColor *= weatherFactor;
    
    // Cloud shadows (simplified approximation)
    if (cloudShadows) {
        shadedColor *= 0.9;
    }
    
    // Sunset/Nighttime cloud colors
    vec3 timeColor = calculateSkyColor(time, weather);
    shadedColor *= timeColor;
    
    colortex0 = vec4(shadedColor, cloudColor.a * edgeFactor);
}

# Cloud Layer Vertex Shader (Multiple layers)
# shaders/clouds/cloud_layer.vsh

#version 330 core

#include "../includes/common.glsl"

in vec3 position;
in vec2 texcoord;

out vec2 fragTexcoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform float layerHeight;

void main() {
    // Adjust position for cloud layer height
    vec3 layerPosition = position + vec3(0.0, layerHeight, 0.0);
    fragTexcoord = texcoord;
    gl_Position = projection * view * model * vec4(layerPosition, 1.0);
}

# Cloud Layer Fragment Shader
# shaders/clouds/cloud_layer.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D cloudTexture;
uniform float time;
uniform float layerIndex;
uniform bool cloudQuality;
uniform bool cloudAnimation;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(cloudTexture, fragTexcoord);
        return;
    }
    
    // Multiple cloud layers (efficient approximation for 940MX)
    // Limit to 2-3 layers for performance
    float layerOffset = layerIndex * 0.1;
    vec2 layerCoord = fragTexcoord + vec2(layerOffset, 0.0);
    
    // Layer-specific animation
    float layerSpeed = CLOUD_SPEED * (1.0 - layerIndex * 0.3);
    vec2 animatedCoord = layerCoord + vec2(time * layerSpeed, 0.0);
    
    vec4 cloudColor = texture2D(cloudTexture, animatedCoord);
    
    // Layer-specific quality
    float qualityFactor = cloudQuality ? 1.0 : 0.5;
    
    // Cloud shading
    vec3 shadedColor = calculateCloudShading(vec3(0.0, 1.0, 0.0), vec3(0.5, 0.7, 0.5), cloudColor.a * qualityFactor);
    
    colortex0 = vec4(shadedColor, cloudColor.a * qualityFactor);
}
