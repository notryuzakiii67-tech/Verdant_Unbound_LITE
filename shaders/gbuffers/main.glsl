# G-Buffers - Geometry Pass Shaders
# Verdant — Unbound Lite
# Minecraft 1.21.11 | Iris | Fabulously Optimized

# Vertex Shader - Terrain
# gbuffers_terrain.vsh

#version 330 core

# Iris compatibility macros
#include "includes/common.glsl"

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

void main() {
    fragTexcoord = texcoord;
    fragNormal = normalize(mat3(view * model) * normal);
    fragColor = color;
    viewPos = (view * model * vec4(position, 1.0)).xyz;
    
    gl_Position = projection * view * model * vec4(position, 1.0);
}

# Fragment Shader - Terrain
# gbuffers_terrain.fsh

#version 330 core

# Iris compatibility macros
#include "includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragNormal;
in vec4 fragColor;
in vec3 viewPos;

out vec4 colortex0;  # Albedo
out vec4 colortex1;  # Normal + Lightmap
out vec4 colortex2;  # Material

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform vec3 sunlightColor;
uniform vec3 ambientColor;
uniform float lightIntensity;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(texture, fragTexcoord);
        colortex1 = vec4(fragNormal, 0.0);
        colortex2 = vec4(1.0);
        return;
    }
    
    // Albedo
    vec4 albedo = texture2D(texture, fragTexcoord);
    colortex0 = albedo;
    
    // Normal and lightmap
    vec3 normal = normalize(fragNormal);
    vec4 lightmapColor = texture2D(lightmap, fragTexcoord);
    colortex1 = vec4(normal, lightmapColor.r);
    
    // Material properties (simplified for 940MX)
    vec3 material = vec3(1.0);
    colortex2 = vec4(material, 1.0);
    
    // Basic lighting calculation (deferred)
    vec3 lightDir = normalize(vec3(0.5, 0.7, 0.5));  // Simplified sun direction
    float lighting = max(dot(normal, lightDir), 0.0) * lightIntensity;
    
    // Store lighting information for composite pass
    colortex0.rgb *= (sunlightColor * lighting + ambientColor);
}

# Vertex Shader - Entities
# gbuffers_entities.vsh

#version 330 core

#include "includes/common.glsl"

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

# Fragment Shader - Entities
# gbuffers_entities.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragNormal;
in vec4 fragColor;

out vec4 colortex0;
out vec4 colortex1;
out vec4 colortex2;

uniform sampler2D texture;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(texture, fragTexcoord);
        colortex1 = vec4(fragNormal, 0.0);
        colortex2 = vec4(1.0);
        return;
    }
    
    vec4 albedo = texture2D(texture, fragTexcoord);
    colortex0 = albedo;
    colortex1 = vec4(normalize(fragNormal), 0.0);
    colortex2 = vec4(1.0);
}

# Vertex Shader - Water
# gbuffers_water.vsh

#version 330 core

#include "includes/common.glsl"

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

# Fragment Shader - Water
# gbuffers_water.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragNormal;
in vec3 viewPos;

out vec4 colortex3;  # Water normal and mask
out vec4 colortex4;  # Translucent layer

uniform sampler2D texture;
uniform float time;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex3 = vec4(fragNormal, 1.0);
        colortex4 = texture2D(texture, fragTexcoord);
        return;
    }
    
    // Water normal animation (efficient approximation)
    vec2 animatedCoord = animateWaterSurface(fragTexcoord, time);
    vec4 waterNormal = texture2D(texture, animatedCoord);
    
    // Water mask (transparency)
    float waterMask = waterNormal.a;
    
    colortex3 = vec4(normalize(fragNormal), waterMask);
    colortex4 = texture2D(texture, animatedCoord);
}

# Vertex Shader - Sky
# gbuffers_sky.vsh

#version 330 core

#include "includes/common.glsl"

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

# Fragment Shader - Sky
# gbuffers_sky.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D skyTexture;
uniform float time;
uniform float weather;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(skyTexture, fragTexcoord);
        return;
    }
    
    // Sky color calculation (efficient approximation)
    vec3 skyColor = calculateSkyColor(time, weather);
    
    // 3D Animated Aurora Effect (Lightweight)
    vec3 auroraColor = calculateAurora(vec3(fragTexcoord.x, 50.0, fragTexcoord.y), time, weather);
    skyColor += auroraColor;
    
    // Lightweight Godrays
    vec3 godrays = calculateGodrays(normalize(vec3(0.5, 0.7, 0.5)), fragTexcoord, time, weather);
    skyColor += godrays;
    
    // Round Sun/Moon (Complementary Unbound Style)
    vec2 sunPos = calculateRoundCelestialPosition(time, true);
    vec2 moonPos = calculateRoundCelestialPosition(time, false);
    
    // Simple circular rendering for sun/moon
    float sunDist = length(fragTexcoord - sunPos);
    float moonDist = length(fragTexcoord - moonPos);
    
    if (sunDist < 0.05) {
        skyColor = mix(skyColor, SUNLIGHT_COLOR, 1.0 - sunDist * 20.0);
    }
    if (moonDist < 0.05) {
        skyColor = mix(skyColor, MOONLIGHT_COLOR, 1.0 - moonDist * 20.0);
    }
    
    colortex0 = vec4(skyColor, 1.0);
}

# Vertex Shader - Clouds
# gbuffers_clouds.vsh

#version 330 core

#include "includes/common.glsl"

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

# Fragment Shader - Clouds
# gbuffers_clouds.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D cloudTexture;
uniform float time;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(cloudTexture, fragTexcoord);
        return;
    }
    
    // Cloud animation (efficient 2D approximation)
    vec2 animatedCoord = fragTexcoord + vec2(time * CLOUD_SPEED, 0.0);
    vec4 cloudColor = texture2D(cloudTexture, animatedCoord);
    
    // Cloud shading (simplified)
    vec3 shadedColor = calculateCloudShading(vec3(0.0, 1.0, 0.0), vec3(0.5, 0.7, 0.5), cloudColor.a);
    
    colortex0 = vec4(shadedColor, cloudColor.a);
}

# Vertex Shader - Weather
# gbuffers_weather.vsh

#version 330 core

#include "includes/common.glsl"

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

# Fragment Shader - Weather
# gbuffers_weather.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D weatherTexture;
uniform float time;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(weatherTexture, fragTexcoord);
        return;
    }
    
    // Weather effects (rain/snow approximation)
    vec4 weatherColor = texture2D(weatherTexture, fragTexcoord);
    colortex0 = weatherColor;
}
