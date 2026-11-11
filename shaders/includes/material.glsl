# Material System Shaders
# Verdant — Unbound Lite
# Improved visual appearance of stone, dirt, grass, sand, wood, logs, leaves, glass, ice, metal, ores, water, lava, nether, end

# Material Vertex Shader
# shaders/material/material.vsh

#version 330 core

#include "../../includes/common.glsl"

in vec3 position;
in vec2 texcoord;
in vec3 normal;
in vec4 color;

out vec2 fragTexcoord;
out vec3 fragNormal;
out vec4 fragColor;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    fragTexcoord = texcoord;
    fragNormal = normalize(mat3(view * model) * normal);
    fragColor = color;
    gl_Position = projection * view * model * vec4(position, 1.0);
}

# Material Fragment Shader
# shaders/material/material.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragNormal;
in vec4 fragColor;

out vec4 colortex0;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform vec3 sunlightColor;
uniform vec3 ambientColor;
uniform float lightIntensity;
uniform bool masterToggle;

// Material-specific highlights and roughness approximations
vec3 calculateMaterialHighlight(vec3 normal, vec3 lightDir, vec3 color, float materialType) {
    // Simplified material highlights for 940MX
    // materialType: 0=stone, 1=dirt, 2=grass, 3=sand, 4=wood, 5=logs, 6=leaves, 7=glass, 8=ice, 9=metal, 10=ores, 11=water, 12=lava, 13=nether, 14=end
    
    float dotProduct = max(dot(normal, lightDir), 0.0);
    vec3 highlight = vec3(0.0);
    
    // Material-specific adjustments
    if (materialType == 0.0) {  // Stone
        highlight = color * dotProduct * 0.8;
    } else if (materialType == 1.0) {  // Dirt
        highlight = color * dotProduct * 0.6;
    } else if (materialType == 2.0) {  // Grass
        highlight = color * dotProduct * 0.7;
    } else if (materialType == 3.0) {  // Sand
        highlight = color * dotProduct * 0.9;
    } else if (materialType == 4.0 || materialType == 5.0) {  // Wood/Logs
        highlight = color * dotProduct * 0.7;
    } else if (materialType == 6.0) {  // Leaves
        highlight = color * dotProduct * 0.6;
    } else if (materialType == 7.0) {  // Glass
        highlight = color * dotProduct * 1.0;  // High reflectivity
    } else if (materialType == 8.0) {  // Ice
        highlight = color * dotProduct * 0.9;
    } else if (materialType == 9.0) {  // Metal
        highlight = color * dotProduct * 1.2;  // High reflectivity
    } else if (materialType == 10.0) {  // Ores
        highlight = color * dotProduct * 1.1;
    } else if (materialType == 11.0) {  // Water
        highlight = color * dotProduct * 0.8;
    } else if (materialType == 12.0) {  // Lava
        highlight = color * dotProduct * 1.3;  // Emissive
    } else if (materialType == 13.0) {  // Nether
        highlight = color * dotProduct * 0.9;
    } else if (materialType == 14.0) {  // End
        highlight = color * dotProduct * 0.8;
    } else {
        highlight = color * dotProduct * 0.8;  // Default
    }
    
    return highlight;
}

// Improved material contrast and transparency
vec3 improveMaterialContrast(vec3 color, float materialType) {
    // Simplified contrast adjustment
    float contrast = 1.0;
    
    if (materialType == 7.0) {  // Glass
        contrast = 0.8;  // Lower contrast for transparency
    } else if (materialType == 8.0) {  // Ice
        contrast = 0.9;
    } else if (materialType == 9.0) {  // Metal
        contrast = 1.2;
    } else if (materialType == 12.0) {  // Lava
        contrast = 1.3;
    }
    
    return (color - 0.5) * contrast + 0.5;
}

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(texture, fragTexcoord);
        return;
    }
    
    // Read texture and lightmap
    vec4 albedoData = texture2D(texture, fragTexcoord);
    vec4 lightmapData = texture2D(lightmap, fragTexcoord);
    vec3 albedo = albedoData.rgb;
    vec3 normal = normalize(fragNormal);
    
    // Determine material type (simplified approximation based on texture)
    // In practice, this would be determined by block ID or texture properties
    float materialType = 0.0;  // Default to stone
    
    // Directional lighting
    vec3 lightDir = normalize(vec3(0.5, 0.7, 0.5));
    vec3 materialHighlight = calculateMaterialHighlight(normal, lightDir, albedo, materialType);
    
    // Ambient lighting
    vec3 ambient = ambientColor * 0.8;
    
    // Combined lighting
    vec3 lighting = materialHighlight + ambient;
    
    // Improved material contrast
    vec3 contrastedColor = improveMaterialContrast(albedo, materialType);
    
    // Final material shading
    vec3 finalColor = contrastedColor * lighting;
    
    // Material-specific effects
    if (materialType == 7.0) {  // Glass transparency
        finalColor = mix(finalColor, vec3(1.0), 0.3);
    } else if (materialType == 8.0) {  // Ice transparency
        finalColor = mix(finalColor, vec3(0.9, 1.0, 1.0), 0.2);
    } else if (materialType == 12.0) {  // Lava emissive
        finalColor += vec3(0.5, 0.2, 0.0);
    }
    
    colortex0 = vec4(finalColor, albedoData.a);
}

# Material Properties Vertex Shader
# shaders/material/material_properties.vsh

#version 330 core

#include "../../includes/common.glsl"

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

# Material Properties Fragment Shader
# shaders/material/material_properties.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D texture;
uniform float materialType;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(texture, fragTexcoord);
        return;
    }
    
    // Material property adjustments (simplified for 940MX)
    vec4 color = texture2D(texture, fragTexcoord);
    vec3 materialColor = color.rgb;
    
    // Material-specific adjustments
    if (materialType == 7.0) {  // Glass transparency
        color.a *= 0.7;
    } else if (materialType == 8.0) {  // Ice transparency
        color.a *= 0.8;
    } else if (materialType == 12.0) {  // Lava emissive
        materialColor += vec3(0.3, 0.1, 0.0);
    }
    
    colortex0 = vec4(materialColor, color.a);
}
