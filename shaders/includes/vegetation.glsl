# Vegetation System Shaders
# Verdant — Unbound Lite
# Animated leaves, grass, flowers, crops, natural wind movement

# Vegetation Vertex Shader
# shaders/vegetation/vegetation.vsh

#version 330 core

#include "../../includes/common.glsl"

in vec3 position;
in vec2 texcoord;
in vec3 normal;
in vec4 color;

out vec2 fragTexcoord;
out vec3 fragNormal;
out vec4 fragColor;
out vec3 viewPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 cameraPos;
uniform float time;
uniform bool vegetationMovement;
uniform float windIntensity;

void main() {
    fragTexcoord = texcoord;
    fragNormal = normalize(mat3(view * model) * normal);
    fragColor = color;
    viewPos = (view * model * vec4(position, 1.0)).xyz;
    
    // Vegetation wind animation (efficient approximation for 940MX)
    vec3 animatedPosition = position;
    if (vegetationMovement) {
        animatedPosition = animateVegetation(position, time, windIntensity);
    }
    
    gl_Position = projection * view * model * vec4(animatedPosition, 1.0);
}

# Vegetation Fragment Shader
# shaders/vegetation/vegetation.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragNormal;
in vec4 fragColor;
in vec3 viewPos;

out vec4 colortex0;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform vec3 sunlightColor;
uniform vec3 ambientColor;
uniform float lightIntensity;
uniform float time;
uniform bool masterToggle;

// Biome-dependent vegetation colors
vec3 getBiomeVegetationColor(vec2 coord) {
    // Simplified biome detection
    float biomeFactor = sin(coord.x * 10.0) * cos(coord.y * 10.0);
    vec3 baseColor = vec3(0.3, 0.8, 0.3);  // Default green
    
    if (biomeFactor > 0.5) {
        baseColor = vec3(0.4, 0.9, 0.4);  // Forest
    } else if (biomeFactor < -0.5) {
        baseColor = vec3(0.7, 0.6, 0.3);  // Desert/Dry
    } else {
        baseColor = vec3(0.2, 0.7, 0.4);  // Ocean/Wet
    }
    
    return baseColor;
}

// Subtle foliage lighting
vec3 calculateFoliageLighting(vec3 normal, vec3 lightDir, vec3 color) {
    // Simplified foliage lighting for performance
    float dotProduct = max(dot(normal, lightDir), 0.0);
    return color * dotProduct * 0.8;  // Reduced intensity for foliage
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
    
    // Biome-dependent vegetation color
    vec3 biomeColor = getBiomeVegetationColor(fragTexcoord);
    albedo *= biomeColor;
    
    // Directional lighting
    vec3 lightDir = normalize(vec3(0.5, 0.7, 0.5));
    vec3 foliageLighting = calculateFoliageLighting(normal, lightDir, albedo);
    
    // Ambient lighting
    vec3 ambient = ambientColor * 0.8;
    
    // Combined lighting
    vec3 lighting = foliageLighting + ambient;
    
    // Material shading (simplified for vegetation)
    vec3 material = vec3(1.0);
    vec3 finalColor = albedo * lighting * material;
    
    // Subtle wind movement effect (visual approximation)
    if (fragColor.a > 0.5) {
        float windEffect = sin(fragTexcoord.x * 10.0 + time * 0.5) * 0.05;
        finalColor += vec3(windEffect);
    }
    
    colortex0 = vec4(finalColor, albedoData.a);
}

# Vegetation Wind Vertex Shader (Optimized for 940MX)
# shaders/vegetation/vegetation_wind.vsh

#version 330 core

#include "../../includes/common.glsl"

in vec3 position;
in vec2 texcoord;

out vec2 fragTexcoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform float time;
uniform bool vegetationMovement;
uniform float windIntensity;

void main() {
    fragTexcoord = texcoord;
    
    // Efficient wind animation (vertex-based for performance)
    vec3 animatedPosition = position;
    if (vegetationMovement) {
        animatedPosition = animateVegetation(position, time, windIntensity);
    }
    
    gl_Position = projection * view * model * vec4(animatedPosition, 1.0);
}

# Vegetation Wind Fragment Shader
# shaders/vegetation/vegetation_wind.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D texture;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(texture, fragTexcoord);
        return;
    }
    
    // Simple vegetation rendering (optimized for performance)
    vec4 color = texture2D(texture, fragTexcoord);
    colortex0 = color;
}
