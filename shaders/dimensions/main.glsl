# Dimension Support Shaders
# Verdant — Unbound Lite
# Overworld, Nether, End dimension support

# Dimension Vertex Shader
# shaders/dimensions/dimension.vsh

#version 330 core

#include "../../includes/common.glsl"

in vec3 position;
in vec2 texcoord;
in vec3 normal;

out vec2 fragTexcoord;
out vec3 fragNormal;
out vec3 viewPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform int dimension;  // 0 = Overworld, 1 = Nether, 2 = End

void main() {
    fragTexcoord = texcoord;
    fragNormal = normalize(mat3(view * model) * normal);
    viewPos = (view * model * vec4(position, 1.0)).xyz;
    
    // Dimension-specific adjustments (simplified)
    vec3 dimensionPosition = position;
    if (dimension == 1) {  // Nether
        dimensionPosition.y -= 10.0;  // Nether height adjustment
    } else if (dimension == 2) {  // End
        dimensionPosition.y += 10.0;  // End height adjustment
    }
    
    gl_Position = projection * view * model * vec4(dimensionPosition, 1.0);
}

# Dimension Fragment Shader
# shaders/dimensions/dimension.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragNormal;
in vec3 viewPos;

out vec4 colortex0;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform int dimension;  // 0 = Overworld, 1 = Nether, 2 = End
uniform float time;
uniform float weather;
uniform bool masterToggle;

// Dimension-specific lighting and atmosphere
vec3 calculateDimensionLighting(int dimension, vec3 baseColor, float time, float weather) {
    // Overworld (0)
    if (dimension == 0) {
        return calculateSkyColor(time, weather) * baseColor;
    }
    // Nether (1)
    else if (dimension == 1) {
        // Nether fog and atmospheric coloring
        vec3 netherColor = vec3(1.2, 0.6, 0.4);  // Reddish tint
        float netherFog = 0.8;
        return baseColor * netherColor * netherFog;
    }
    // End (2)
    else if (dimension == 2) {
        // End sky and purple atmospheric appearance
        vec3 endColor = vec3(0.8, 0.6, 1.2);  // Purplish tint
        float endFog = 0.9;
        return baseColor * endColor * endFog;
    }
    
    return baseColor;
}

// Dimension-specific material adjustments
vec3 adjustDimensionMaterial(vec3 materialColor, int dimension) {
    if (dimension == 1) {  // Nether
        // Nether-specific material adjustments
        materialColor *= vec3(1.1, 0.8, 0.7);
    } else if (dimension == 2) {  // End
        // End-specific material adjustments
        materialColor *= vec3(0.8, 0.7, 1.1);
    }
    
    return materialColor;
}

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(texture, fragTexcoord);
        return;
    }
    
    // Read base color and lightmap
    vec4 baseColorData = texture2D(texture, fragTexcoord);
    vec4 lightmapData = texture2D(lightmap, fragTexcoord);
    vec3 baseColor = baseColorData.rgb;
    vec3 normal = normalize(fragNormal);
    
    // Dimension-specific lighting
    vec3 dimensionLighting = calculateDimensionLighting(dimension, baseColor, time, weather);
    
    // Dimension-specific material adjustments
    vec3 adjustedMaterial = adjustDimensionMaterial(baseColor, dimension);
    
    // Combine dimension effects
    vec3 finalColor = dimensionLighting * adjustedMaterial;
    
    // Dimension-specific fog and atmosphere
    if (dimension == 1) {  // Nether
        // Nether fog (reddish)
        finalColor = mix(finalColor, vec3(1.0, 0.5, 0.3), 0.2);
    } else if (dimension == 2) {  // End
        // End fog (purplish)
        finalColor = mix(finalColor, vec3(0.7, 0.5, 1.0), 0.2);
    }
    
    colortex0 = vec4(finalColor, baseColorData.a);
}

# Dimension Transition Vertex Shader
# shaders/dimensions/dimension_transition.vsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 position;
in vec2 texcoord;

out vec2 fragTexcoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    fragTexcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}

# Dimension Transition Fragment Shader
# shaders/dimensions/dimension_transition.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;

inout vec4 colortex0;

uniform int dimension;  // 0 = Overworld, 1 = Nether, 2 = End
uniform float transitionProgress;  // 0.0 to 1.0
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        return;
    }
    
    // Dimension transition effects (simplified approximation)
    vec3 transitionColor = vec3(0.0);
    
    if (dimension == 1) {  // Overworld to Nether
        transitionColor = vec3(1.0, 0.5, 0.3) * transitionProgress;
    } else if (dimension == 2) {  // Overworld to End
        transitionColor = vec3(0.7, 0.5, 1.0) * transitionProgress;
    } else if (dimension == 0) {  // Return to Overworld
        transitionColor = vec3(0.5, 0.8, 1.0) * (1.0 - transitionProgress);
    }
    
    // Apply transition effect
    colortex0.rgb = mix(colortex0.rgb, transitionColor, transitionProgress * 0.3);
}
