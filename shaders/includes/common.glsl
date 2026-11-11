# Includes - Shared GLSL Functions and Constants
# Verdant — Unbound Lite

# Version Declaration
# GLSL 330 for compatibility with Iris and NVIDIA GeForce 940MX
# Minecraft 1.21.11 compatibility

# Common Constants
# NVIDIA GeForce 940MX optimization constants
# Memory-efficient texture sampling and calculations

# Lighting Constants
const vec3 SUNLIGHT_COLOR = vec3(1.0, 0.95, 0.85);
const vec3 MOONLIGHT_COLOR = vec3(0.8, 0.85, 1.0);
const vec3 AMBIENT_COLOR = vec3(0.2, 0.3, 0.4);
const vec3 CAVE_DARKNESS = vec3(0.05, 0.05, 0.1);

# Shadow Constants
const float SHADOW_BIAS = 0.001;
const float SHADOW_OFFSET = 0.002;
const int SHADOW_SAMPLES = 4;  # Optimized for 940MX

# Water Constants
const float WATER_REFRACTION = 0.02;
const float WATER_REFLECTION = 0.1;
const float WATER_ANIMATION_SPEED = 0.5;

# Sky and Cloud Constants
const vec3 SKY_COLOR_DAY = vec3(0.5, 0.7, 1.0);
const vec3 SKY_COLOR_SUNSET = vec3(1.0, 0.6, 0.4);
const vec3 SKY_COLOR_NIGHT = vec3(0.1, 0.1, 0.2);
const float CLOUD_SPEED = 0.1;

# Vegetation Constants
const float VEGETATION_WIND_SPEED = 0.5;
const float VEGETATION_WIND_INTENSITY = 0.1;

# Post-processing Constants
const float BLOOM_THRESHOLD = 0.8;
const float BLOOM_INTENSITY = 0.3;
const float EXPOSURE = 1.0;
const float CONTRAST = 1.0;
const float SATURATION = 1.0;

# Performance Optimization Functions
# NVIDIA GeForce 940MX specific optimizations

# Efficient texture sampling
vec4 efficientTextureSample(sampler2D texture, vec2 coord) {
    // Optimized sampling for 940MX
    return texture2D(texture, coord);
}

# Lightweight lighting calculation
vec3 calculateLighting(vec3 normal, vec3 lightDir, vec3 color, float intensity) {
    // Simplified lighting calculation for performance
    float dotProduct = max(dot(normal, lightDir), 0.0);
    return color * dotProduct * intensity;
}

# Efficient shadow calculation
float calculateShadow(sampler2D shadowMap, vec2 coord, float bias) {
    // Optimized shadow calculation for 940MX
    float shadow = texture2D(shadowMap, coord).r;
    return shadow > bias ? 1.0 : 0.0;
}

# Water surface animation
vec2 animateWaterSurface(vec2 coord, float time) {
    // Efficient water animation using sine waves
    float wave1 = sin(coord.x * 10.0 + time * WATER_ANIMATION_SPEED) * 0.01;
    float wave2 = cos(coord.y * 10.0 + time * WATER_ANIMATION_SPEED) * 0.01;
    return coord + vec2(wave1, wave2);
}

# Vegetation wind animation
vec3 animateVegetation(vec3 position, float time, float windIntensity) {
    // Efficient vegetation animation for 940MX
    float wind = sin(position.x * 5.0 + time * VEGETATION_WIND_SPEED) * windIntensity;
    return position + vec3(wind, 0.0, wind);
}

# Sky color calculation
vec3 calculateSkyColor(float time, float weather) {
    // Simplified atmospheric scattering approximation
    vec3 color;
    if (time < 0.25 || time > 0.75) {
        color = SKY_COLOR_NIGHT;  // Night
    } else if (time < 0.5) {
        color = mix(SKY_COLOR_NIGHT, SKY_COLOR_DAY, (time - 0.25) * 4.0);  // Sunrise
    } else {
        color = mix(SKY_COLOR_DAY, SKY_COLOR_SUNSET, (time - 0.5) * 4.0);  // Sunset
    }
    
    // Weather adjustment
    color = mix(color, vec3(0.5, 0.5, 0.5), weather * 0.5);
    
    return color;
}

# Cloud shading
vec3 calculateCloudShading(vec3 normal, vec3 lightDir, float density) {
    // Efficient cloud shading approximation
    float dotProduct = max(dot(normal, lightDir), 0.0);
    return vec3(0.8, 0.8, 0.9) * dotProduct * density;
}

# Material shading
vec3 calculateMaterialShading(vec3 albedo, vec3 normal, vec3 lightDir, float roughness) {
    // Simplified material shading for performance
    float dotProduct = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = albedo * dotProduct;
    vec3 specular = vec3(0.1) * pow(max(dotProduct, 0.0), roughness * 10.0);
    return diffuse + specular;
}

# Post-processing functions
vec3 applyBloom(vec3 color, float threshold, float intensity) {
    // Lightweight bloom approximation
    float brightness = max(max(color.r, color.g), color.b);
    float bloomFactor = max(brightness - threshold, 0.0) * intensity;
    return color + vec3(bloomFactor);
}

vec3 applyTonemapping(vec3 color) {
    // Simple tonemapping for performance
    return color / (1.0 + color);
}

vec3 applyColorGrading(vec3 color, float saturation, float contrast) {
    // Efficient color grading
    vec3 gray = vec3(0.299, 0.587, 0.114) * dot(color, vec3(1.0));
    vec3 graded = mix(gray, color, saturation);
    return (graded - 0.5) * contrast + 0.5;
}

# Dimension-specific functions
vec3 calculateDimensionLighting(int dimension, vec3 baseColor) {
    // Simplified dimension lighting
    if (dimension == 1) {  // Nether
        return baseColor * vec3(1.2, 0.8, 0.6);  // Reddish tint
    } else if (dimension == 2) {  // End
        return baseColor * vec3(0.8, 0.6, 1.2);  // Purplish tint
    }
    return baseColor;  // Overworld
}

# NVIDIA GeForce 940MX specific optimizations
# Memory-efficient buffer handling
# Reduced texture fetches
# Simplified branching
