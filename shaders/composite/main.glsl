# Composite Pass Shaders
# Verdant — Unbound Lite
# Post-processing and lighting composition

# Vertex Shader - Composite
# composite.vsh

#version 330 core

#include "includes/common.glsl"

in vec2 position;
in vec2 texcoord;

out vec2 fragTexcoord;

void main() {
    fragTexcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}

# Fragment Shader - Composite (Lighting and Shadows)
# composite.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D colortex0_in;  # Albedo from gbuffers
uniform sampler2D colortex1_in;  # Normal + Lightmap
uniform sampler2D colortex2_in;  # Material
uniform sampler2D shadowcolor0;  # Shadow map
uniform sampler2D skyTexture;    # Sky texture
uniform sampler2D waterTexture;  # Water texture

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

// Efficient lighting composition for 940MX
vec3 calculateDeferredLighting(vec3 albedo, vec3 normal, vec3 viewPos, float shadow) {
    // Simplified deferred lighting
    vec3 lightDir = normalize(vec3(0.5, 0.7, 0.5));  // Sun direction
    vec3 moonlightDir = normalize(vec3(-0.5, 0.7, 0.5));  // Moon direction
    
    // Sunlight
    float sunDot = max(dot(normal, lightDir), 0.0);
    vec3 sunLighting = sunlightColor * sunDot * lightIntensity * shadow;
    
    // Moonlight
    vec3 moonLighting = vec3(0.0);
    if (moonlight) {
        float moonDot = max(dot(normal, moonlightDir), 0.0);
        moonLighting = moonlightColor * moonDot * lightIntensity * 0.5;
    }
    
    // Ambient lighting
    vec3 ambient = ambientColor;
    if (ambientOcclusion) {
        // Simplified ambient occlusion approximation
        ambient *= 0.8;
    }
    
    // Combined lighting
    vec3 lighting = sunLighting + moonLighting + ambient;
    
    // Material shading
    vec3 material = colortex2_in.rgb;
    vec3 finalColor = albedo * lighting * material;
    
    return finalColor;
}

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(colortex0_in, fragTexcoord);
        return;
    }
    
    // Read G-Buffer data
    vec4 albedoData = texture2D(colortex0_in, fragTexcoord);
    vec4 normalData = texture2D(colortex1_in, fragTexcoord);
    vec4 materialData = texture2D(colortex2_in, fragTexcoord);
    
    vec3 albedo = albedoData.rgb;
    vec3 normal = normalize(normalData.rgb);
    vec3 material = materialData.rgb;
    
    // Read shadow data
    float shadow = texture2D(shadowcolor0, fragTexcoord).r;
    
    // Calculate lighting
    vec3 lighting = calculateDeferredLighting(albedo, normal, vec3(0.0), shadow);
    
    // Color grading
    if (colorGrading) {
        lighting = applyColorGrading(lighting, 1.0, 1.0);
    }
    
    colortex0 = vec4(lighting, albedoData.a);
}

# Vertex Shader - Composite 1 (Fog and Atmosphere)
# composite1.vsh

#version 330 core

#include "includes/common.glsl"

in vec2 position;
in vec2 texcoord;

out vec2 fragTexcoord;

void main() {
    fragTexcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}

# Fragment Shader - Composite 1 (Fog and Atmosphere)
# composite1.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;

inout vec4 colortex0;  # Input/Output from previous pass

uniform sampler2D skyTexture;
uniform float time;
uniform float weather;
uniform bool fog;
uniform bool skyEffects;
uniform bool masterToggle;

void main() {
    if (!masterToggle || !fog) {
        return;
    }
    
    // Atmospheric fog approximation
    vec3 skyColor = calculateSkyColor(time, weather);
    float fogDensity = 0.1;
    float fogDistance = length(fragTexcoord - vec2(0.5));
    
    vec3 fogColor = mix(colortex0.rgb, skyColor, fogDensity * fogDistance);
    colortex0.rgb = fogColor;
}

# Vertex Shader - Composite 2 (Water and Reflections)
# composite2.vsh

#version 330 core

#include "includes/common.glsl"

in vec2 position;
in vec2 texcoord;

out vec2 fragTexcoord;

void main() {
    fragTexcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}

# Fragment Shader - Composite 2 (Water and Reflections)
# composite2.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;

inout vec4 colortex0;

uniform sampler2D colortex3_in;  # Water normal and mask
uniform sampler2D colortex4_in;  # Translucent layer
uniform float time;
uniform bool waterQuality;
uniform bool reflections;
uniform bool waterAnimation;
uniform bool underwaterEffects;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        return;
    }
    
    // Water processing (efficient approximation for 940MX)
    vec4 waterData = texture2D(colortex3_in, fragTexcoord);
    vec4 translucentData = texture2D(colortex4_in, fragTexcoord);
    
    if (waterData.a > 0.1) {  // Water mask
        // Water animation
        vec2 animatedCoord = fragTexcoord;
        if (waterAnimation) {
            animatedCoord = animateWaterSurface(fragTexcoord, time);
        }
        
        // Water reflections (simplified screen-space approximation)
        vec3 reflectionColor = vec3(0.0);
        if (reflections) {
            reflectionColor = colortex0.rgb * 0.1;  // Simplified reflection
        }
        
        // Water quality adjustment
        float qualityFactor = waterQuality ? 1.0 : 0.5;
        
        // Combine water effects
        vec3 waterColor = colortex0.rgb * 0.8 + reflectionColor * qualityFactor;
        
        // Underwater effects
        if (underwaterEffects) {
            waterColor *= vec3(0.8, 0.9, 1.0);  // Blue tint
        }
        
        colortex0.rgb = mix(colortex0.rgb, waterColor, waterData.a);
    }
}

# Vertex Shader - Final Pass
# final.vsh

#version 330 core

#include "includes/common.glsl"

in vec2 position;
in vec2 texcoord;

out vec2 fragTexcoord;

void main() {
    fragTexcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}

# Fragment Shader - Final Pass (Post-processing)
# final.fsh

#version 330 core

#include "includes/common.glsl"

in vec2 fragTexcoord;

out vec4 finalColor;

uniform sampler2D colortex0_in;  # Input from previous pass
uniform float exposure;
uniform float contrast;
uniform float saturation;
uniform bool bloom;
uniform bool tonemapping;
uniform bool vignette;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        finalColor = texture2D(colortex0_in, fragTexcoord);
        return;
    }
    
    vec4 colorData = texture2D(colortex0_in, fragTexcoord);
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
        color = applyBloom(color, 0.8, 0.3);
    }
    
    // Tonemapping
    if (tonemapping) {
        color = applyTonemapping(color);
    }
    
    // Vignette (simplified)
    if (vignette) {
        float distance = length(fragTexcoord - vec2(0.5));
        float vignetteFactor = max(1.0 - distance * 2.0, 0.5);
        color *= vignetteFactor;
    }
    
    finalColor = vec4(color, colorData.a);
}
