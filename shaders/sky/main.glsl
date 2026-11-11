# Sky System Shaders
# Verdant — Unbound Lite
# Realistic sun, moon, stars, and atmospheric effects

# Sky Basic Vertex Shader
# shaders/sky/skybasic.vsh

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

# Sky Basic Fragment Shader
# shaders/sky/skybasic.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform float time;
uniform float weather;
uniform bool skyEffects;
uniform bool masterToggle;

void main() {
    if (!masterToggle || !skyEffects) {
        colortex0 = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    
    // Atmospheric horizon and sky coloring
    vec3 skyColor = calculateSkyColor(time, weather);
    
    // Horizon gradient (simplified)
    float horizon = fragTexcoord.y;
    vec3 horizonColor = mix(skyColor, vec3(0.8, 0.9, 1.0), horizon);
    
    colortex0 = vec4(horizonColor, 1.0);
}

# Sky Textured Vertex Shader (Sun/Moon)
# shaders/sky/skytextured.vsh

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

# Sky Textured Fragment Shader (Sun/Moon)
# shaders/sky/skytextured.fsh

#version 330 core

#include "../includes/common.glsl"

in vec2 fragTexcoord;

out vec4 colortex0;

uniform sampler2D sunTexture;
uniform sampler2D moonTexture;
uniform float time;
uniform bool masterToggle;

void main() {
    if (!masterToggle) {
        colortex0 = texture2D(sunTexture, fragTexcoord);
        return;
    }
    
    // Sun/Moon position calculation (simplified)
    float sunPosition = time * 2.0 * 3.14159;
    float moonPosition = sunPosition + 3.14159;
    
    // Sun rendering (daytime)
    vec4 sunColor = texture2D(sunTexture, fragTexcoord);
    float sunIntensity = max(sin(sunPosition), 0.0);
    
    // Moon rendering (nighttime)
    vec4 moonColor = texture2D(moonTexture, fragTexcoord);
    float moonIntensity = max(sin(moonPosition), 0.0);
    
    // Combine sun and moon
    vec4 combinedColor = sunColor * sunIntensity + moonColor * moonIntensity;
    
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
