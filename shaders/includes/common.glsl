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
const int SHADOW_SAMPLES = 8;  # Improved to 8 samples for "super good" but lightweight filtering
const float SHADOW_SOFTNESS = 0.005;  # Lightweight softness

# Water Constants
const float WATER_REFRACTION = 0.02;
const float WATER_REFLECTION = 0.2;  # Increased for better reflection
const float WATER_ANIMATION_SPEED = 0.5;

# Sky and Cloud Constants
const vec3 SKY_COLOR_DAY = vec3(0.5, 0.7, 1.0);
const vec3 SKY_COLOR_SUNSET = vec3(1.0, 0.6, 0.4);
const vec3 SKY_COLOR_NIGHT = vec3(0.1, 0.1, 0.2);
const float CLOUD_SPEED = 0.1;

# Aurora Constants (3D Animated)
const float AURORA_SPEED = 0.3;
const float AURORA_INTENSITY = 0.4;
const vec3 AURORA_COLOR_1 = vec3(0.2, 0.8, 0.6);  # Green
const vec3 AURORA_COLOR_2 = vec3(0.4, 0.3, 0.9);  # Purple
const float AURORA_HEIGHT = 100.0;

# Vegetation Constants
const float VEGETATION_WIND_SPEED = 0.5;
const float VEGETATION_WIND_INTENSITY = 0.1;

# Post-processing Constants
const float BLOOM_THRESHOLD = 0.8;
const float BLOOM_INTENSITY = 0.3;
const float EXPOSURE = 1.0;
const float CONTRAST = 1.0;
const float SATURATION = 1.0;

# Godray Constants (Lightweight)
const float GODRAY_STEPS = 6;  # Lightweight 6 steps
const float GODRAY_INTENSITY = 0.15;
const float GODRAY_DENSITY = 0.8;

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

# Efficient shadow calculation (Super Good Lightweight)
float calculateShadow(sampler2D shadowMap, vec2 coord, float bias, float quality) {
    // Improved 8-tap PCF for "super good" but lightweight filtering
    // Optimized for 940MX memory constraints
    float shadow = 0.0;
    float offset = SHADOW_SOFTNESS * quality;
    
    // Lightweight 8-sample PCF approximation
    for (int i = 0; i < SHADOW_SAMPLES; i++) {
        float dx = (float((i % 3) - 1)) * offset;
        float dy = (float((i / 3) - 1)) * offset;
        shadow += texture2D(shadowMap, coord + vec2(dx, dy)).r;
    }
    shadow /= float(SHADOW_SAMPLES);
    
    return shadow > bias ? 1.0 : 0.0;
}

# Water surface animation
vec2 animateWaterSurface(vec2 coord, float time) {
    // Efficient water animation using sine waves
    float wave1 = sin(coord.x * 10.0 + time * WATER_ANIMATION_SPEED) * 0.01;
    float wave2 = cos(coord.y * 10.0 + time * WATER_ANIMATION_SPEED) * 0.01;
    return coord + vec2(wave1, wave2);
}

# Water reflection calculation (Lightweight)
vec3 calculateWaterReflection(sampler2D reflectionMap, vec2 coord, float quality) {
    // Simplified screen-space reflection for 940MX
    // Lightweight approximation with limited samples (5-sample blend)
    vec2 reflectionCoord = coord + vec2(0.01, 0.01) * quality;
    vec4 reflectionColor = texture2D(rmap, reflectionCoord);
    
    // 5-sample screen-space blend approximation
    vec4 neighbor1 = texture2D(rmap, reflectionCoord + vec2(0.005, 0.0));
    vec4 neighbor2 = texture2D(rmap, reflectionCoord - vec2(0.005, 0.0));
    vec4 neighbor3 = texture2D(rmap, reflectionCoord + vec2(0.0, 0.005));
    vec4 neighbor4 = texture2D(rmap, reflectionCoord - vec2(0.0, 0.005));
    
    vec3 blended = (reflectionColor.rgb + neighbor1.rgb + neighbor2.rgb + neighbor3.rgb + neighbor4.rgb) / 5.0;
    return blended * WATER_REFLECTION;
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

# 3D Animated Aurora Effect (Lightweight)
vec3 calculateAurora(vec3 position, float time, float weather) {
    // Lightweight 3D aurora approximation for 940MX
    // Uses sine/cosine waves for animation without expensive ray marching
    float heightFactor = position.y / AURORA_HEIGHT;
    float horizontalFactor = sin(position.x * 0.1 + time * AURORA_SPEED) * cos(position.z * 0.1);
    
    // Aurora animation
    float auroraWave1 = sin(time * AURORA_SPEED + position.x * 0.05) * 0.5 + 0.5;
    float auroraWave2 = cos(time * AURORA_SPEED * 0.8 + position.z * 0.05) * 0.5 + 0.5;
    
    // Combine waves with height factor
    float auroraIntensity = (auroraWave1 * auroraWave2) * heightFactor * AURORA_INTENSITY;
    
    // Weather adjustment (aurora visible in clear weather)
    float weatherFactor = max(1.0 - weather * 0.8, 0.0);
    auroraIntensity *= weatherFactor;
    
    // Color blending (Green and Purple)
    vec3 auroraColor = mix(AURORA_COLOR_1, AURORA_COLOR_2, horizontalFactor);
    
    return auroraColor * auroraIntensity;
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

# Godray calculation (Lightweight)
vec3 calculateGodrays(vec3 lightDir, vec2 coord, float time, float weather) {
    // Lightweight godray approximation for 940MX
    // No expensive volumetric ray marching
    float godrayIntensity = 0.0;
    
    // Simplified godray calculation using screen-space approximation
    vec2 center = vec2(0.5, 0.5);
    vec2 direction = normalize(coord - center);
    
    // Limited steps for performance
    for (float i = 0.0; i < GODRAY_STEPS; i++) {
        float t = i / GODRAY_STEPS;
        vec2 samplePos = center + direction * t * 0.5;
        float sample = max(dot(direction, lightDir), 0.0);
        godrayIntensity += sample * GODRAY_INTENSITY * exp(-t * GODRAY_DENSITY);
    }
    
    // Weather adjustment
    float weatherFactor = max(1.0 - weather * 0.5, 0.0);
    godrayIntensity *= weatherFactor;
    
    // Time-based animation
    godrayIntensity *= (sin(time * 2.0) * 0.1 + 1.0);
    
    return vec3(godrayIntensity);
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

# Round Sun/Moon Calculation (Complementary Unbound Style)
vec2 calculateRoundCelestialPosition(float time, bool isSun) {
    // Circular path calculation for round sun/moon
    float angle = time * 2.0 * 3.14159;
    if (!isSun) {
        angle += 3.14159;  // Moon opposite sun
    }
    
    // Circular orbit approximation
    float radius = 0.5;
    float x = 0.5 + cos(angle) * radius;
    float y = 0.5 + sin(angle) * radius;
    
    return vec2(x, y);
}

# NVIDIA GeForce 940MX specific optimizations
# Memory-efficient buffer handling
# Reduced texture fetches
# Simplified branching
