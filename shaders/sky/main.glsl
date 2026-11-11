# Sky System Shaders
# Verdant — Unbound Lite
# Realistic sun, moon, stars, atmospheric effects, 3D aurora, godrays, round sun/moon (Complementary Unbound style)

# Sky Basic Vertex Shader
# shaders/sky/skybasic.vsh

#version 330 core

#include "../includes/common.glsl"

in vec3 position;
in vec2 texcoord;

out vec2 fragTexcoord;
out vec3 fragPosition;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    fragTexcoord = texcoord;
    fragPosition = (view * model * vec4(position, 1.0)).xyz;
    gl_Position = projection * view * model * vec4(position, 1.0);
}

# Sky Basic Fragment Shader
# shaders/sky/skybasic.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragPosition;

out vec4 colortex0;

uniform float time;
uniform float weather;
uniform bool skyEffects;
uniform bool auroraEffect;  // New aurora toggle
uniform bool godrays;       // New godray toggle
uniform bool masterToggle;

// 3D Animated Aurora Effect (Lightweight)
vec3 applyAuroraEffect(vec3 position, vec3 skyColor, float time, float weather) {
    // Lightweight 3D aurora approximation for 940MX
    // No expensive volumetric ray marching
    vec3 aurora = calculateAurora(position, time, weather);
    
    // Blend with sky color
    float blendFactor = min(aurora.r + aurora.g + aurora.b, 0.5);  // Limit intensity
    return mix(skyColor, aurora, blendFactor * float(auroraEffect));
}

// Godray Effect (Lightweight)
vec3 applyGodrays(vec3 skyColor, vec2 coord, float time, float weather, vec3 lightDir) {
    // Lightweight godray approximation
    vec3 godrays = calculateGodrays(lightDir, coord, time, weather);
    return skyColor + godrays * float(godrays);
}

void main() {
    if (!masterToggle) {
        colortex0 = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    
    // Atmospheric horizon and sky coloring
    vec3 skyColor = calculateSkyColor(time, weather);
    
    // Horizon gradient (simplified)
    float horizon = fragTexcoord.y;
    vec3 horizonColor = mix(skyColor, vec3(0.8, 0.9, 1.0), horizon);
    
    // Apply 3D Aurora Effect (Lightweight)
    if (auroraEffect && weather < 0.5) {  // Aurora visible in clear weather
        horizonColor = applyAuroraEffect(fragPosition, horizonColor, time, weather);
    }
    
    // Apply Godrays (Lightweight)
    vec3 lightDir = normalize(vec3(0.5, 0.7, 0.5));  // Sun direction
    if (godrays) {
        horizonColor = applyGodrays(horizonColor, fragTexcoord, time, weather, lightDir);
    }
    
    colortex0 = vec4(horizonColor, 1.0);
}

# Sky Textured Vertex Shader (Sun/Moon - Round Shape)
# shaders/sky/skytextured.vsh

#version 330 core

#include "../includes/common.glsl"

in vec3 position;
in vec2 texcoord;

out vec2 fragTexcoord;
out vec3 fragPosition;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    fragTexcoord = texcoord;
    fragPosition = (view * model * vec4(position, 1.0)).xyz;
    gl_Position = projection * view * model * vec4(position, 1.0);
}

# Sky Textured Fragment Shader (Sun/Moon - Round Shape, Complementary Unbound Style)
# shaders/sky/skytextured.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragPosition;

out vec4 colortex0;

uniform sampler2D sunTexture;
uniform sampler2D moonTexture;
uniform float time;
uniform bool masterToggle;

// Round Sun/Moon rendering (Complementary Unbound style)
vec4 renderRoundCelestial(sampler2D texture, vec2 center, float radius, float intensity, float time) {
    // Calculate distance from center for round shape
    float distance = length(fragTexcoord - center);
    
    // Circular mask (Complementary Unbound style)
    float mask = smoothstep(radius + 0.02, radius - 0.02, distance);
    
    // Texture sampling within circle
    vec2 localCoord = (fragTexcoord - center) / radius + vec2(0.5);
    localCoord = clamp(localCoord, 0.0, 1.0);
    
    vec4 color = texture2D(texture, localCoord);
    
    // Apply circular mask
    color.a *= mask;
    color.rgb *= mask * intensity;
    
    // Glow effect (lightweight)
    float glow = exp(-distance * 20.0) * intensity * 0.3;
    color.rgb += vec3(glow);
    
    return color;
}

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(sunTexture, fragTexcoord);
        return;
    }
    
    // Round Sun/Moon position calculation (Complementary Unbound style)
    vec2 sunPos = calculateRoundCelestialPosition(time, true);
    vec2 moonPos = calculateRoundCelestialPosition(time, false);
    
    // Sun rendering (daytime) - Round shape
    float sunIntensity = max(sin(time * 2.0 * 3.14159), 0.0);
    vec4 sunColor = renderRoundCelestial(sunTexture, sunPos, 0.05, sunIntensity, time);
    
    // Moon rendering (nighttime) - Round shape
    float moonIntensity = max(sin(time * 2.0 * 3.14159 + 3.14159), 0.0);
    vec4 moonColor = renderRoundCelestial(moonTexture, moonPos, 0.04, moonIntensity, time);
    
    // Combine sun and moon (Complementary Unbound style)
    vec4 combinedColor = sunColor + moonColor;
    
    colortex0 = combinedColor;
}

# Stars Vertex Shader
# shaders/sky/stars.vsh

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

# Stars Fragment Shader
# shaders/sky/stars.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D starsTexture;
uniform float time;
uniform bool stars;
uniform bool masterToggle;

void main() {
    if (!masterToggle || !stars) {
        colortex0 = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }
    
    // Stars rendering (efficient approximation)
    vec4 starColor = texture2D(starsTexture, fragTexcoord);
    
    // Star animation (simplified)
    float starAnimation = sin(time * 0.5) * 0.1 + 0.9;
    starColor.rgb *= starAnimation;
    
    colortex0 = starColor;
}
