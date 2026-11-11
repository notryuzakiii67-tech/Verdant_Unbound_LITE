# Weather System Shaders
# Verdant — Unbound Lite
# Rain atmosphere, rain-dependent fog, rain streak appearance, cloud darkening, thunderstorm lighting, lightning flashes, snow atmosphere

# Weather Vertex Shader
# shaders/weather/weather.vsh

#version 330 core

#include "../../includes/common.glsl"

in vec3 position;
in vec2 texcoord;
in vec3 normal;

out vec2 fragTexcoord;
out vec3 fragNormal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    fragTexcoord = texcoord;
    fragNormal = normalize(mat3(view * model) * normal);
    gl_Position = projection * view * model * vec4(position, 1.0);
}

# Weather Fragment Shader
# shaders/weather/weather.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;
in vec3 fragNormal;

out vec4 colortex0;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform float time;
uniform float weather;  // 0 = clear, 1 = rain, 2 = snow, 3 = thunderstorm
uniform bool rainEffects;
uniform bool snowEffects;
uniform bool weatherLighting;
uniform bool masterToggle;

// Rain streak appearance (efficient approximation)
vec3 calculateRainStreaks(vec2 coord, float time, float weatherFactor) {
    // Simplified rain streaks for 940MX
    float streak = sin(coord.x * 50.0 + time * 10.0) * cos(coord.y * 50.0) * weatherFactor;
    return vec3(streak * 0.3);
}

// Cloud darkening (weather-dependent)
float calculateCloudDarkening(float weatherFactor) {
    // Simplified cloud darkening
    return max(1.0 - weatherFactor * 0.5, 0.5);
}

// Thunderstorm lighting and lightning flashes
vec3 calculateThunderstormLighting(float time, float weatherFactor) {
    // Simplified lightning flash approximation
    float flash = sin(time * 20.0) * 0.5 + 0.5;
    float lightningIntensity = flash * weatherFactor * 0.3;
    return vec3(lightningIntensity, lightningIntensity * 0.8, lightningIntensity * 1.0);
}

// Snow atmosphere
vec3 calculateSnowAtmosphere(float weatherFactor) {
    // Simplified snow atmosphere
    return vec3(0.9, 0.9, 1.0) * weatherFactor * 0.2;
}

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(texture, fragTexcoord);
        return;
    }
    
    // Read base color
    vec4 baseColorData = texture2D(texture, fragTexcoord);
    vec3 baseColor = baseColorData.rgb;
    vec3 normal = normalize(fragNormal);
    
    // Weather factor (0 = clear, 1 = rain, 2 = snow, 3 = thunderstorm)
    float weatherFactor = weather / 3.0;
    
    // Rain effects
    vec3 rainColor = vec3(0.0);
    if (rainEffects && weather >= 1.0) {
        rainColor = calculateRainStreaks(fragTexcoord, time, weatherFactor);
    }
    
    // Snow effects
    vec3 snowColor = vec3(0.0);
    if (snowEffects && weather >= 2.0) {
        snowColor = calculateSnowAtmosphere(weatherFactor);
    }
    
    // Weather lighting (thunderstorm)
    vec3 weatherLightingColor = vec3(0.0);
    if (weatherLighting && weather >= 3.0) {
        weatherLightingColor = calculateThunderstormLighting(time, weatherFactor);
    }
    
    // Cloud darkening
    float cloudDarkening = calculateCloudDarkening(weatherFactor);
    
    // Rain-dependent fog (simplified approximation)
    float fogFactor = 1.0;
    if (weather >= 1.0) {
        fogFactor = max(1.0 - weatherFactor * 0.3, 0.7);
    }
    
    // Combine weather effects
    vec3 finalColor = baseColor * cloudDarkening * fogFactor;
    finalColor += rainColor + snowColor + weatherLightingColor;
    
    // Weather-dependent color grading
    if (weather >= 1.0) {
        finalColor = mix(finalColor, vec3(0.8, 0.8, 0.9), weatherFactor * 0.3);  // Rain tint
    } else if (weather >= 2.0) {
        finalColor = mix(finalColor, vec3(0.9, 0.9, 1.0), weatherFactor * 0.4);  // Snow tint
    } else if (weather >= 3.0) {
        finalColor = mix(finalColor, vec3(0.6, 0.7, 1.0), weatherFactor * 0.5);  // Thunderstorm tint
    }
    
    colortex0 = vec4(finalColor, baseColorData.a);
}

# Weather Atmosphere Vertex Shader
# shaders/weather/weather_atmosphere.vsh

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

# Weather Atmosphere Fragment Shader
# shaders/weather/weather_atmosphere.fsh

#version 330 core

#include "../../includes/common.glsl"

in vec2 fragTexcoord;

inout vec4 colortex0;

uniform float time;
uniform float weather;
uniform bool rainEffects;
uniform bool snowEffects;
uniform bool weatherLighting;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        return;
    }
    
    // Weather-dependent atmosphere adjustments
    float weatherFactor = weather / 3.0;
    
    // Rain atmosphere (fog and darkening)
    if (rainEffects && weather >= 1.0) {
        vec3 rainAtmosphere = vec3(0.8, 0.8, 0.9) * weatherFactor * 0.2;
        colortex0.rgb += rainAtmosphere;
    }
    
    // Snow atmosphere
    if (snowEffects && weather >= 2.0) {
        vec3 snowAtmosphere = calculateSnowAtmosphere(weatherFactor);
        colortex0.rgb += snowAtmosphere;
    }
    
    // Thunderstorm atmosphere
    if (weatherLighting && weather >= 3.0) {
        vec3 thunderstormAtmosphere = calculateThunderstormLighting(time, weatherFactor);
        colortex0.rgb += thunderstormAtmosphere;
    }
    
    // Smooth weather transitions
    float transitionFactor = sin(time * 0.5) * 0.5 + 0.5;
    colortex0.rgb = mix(colortex0.rgb, colortex0.rgb * (1.0 - weatherFactor * 0.2), transitionFactor);
}
