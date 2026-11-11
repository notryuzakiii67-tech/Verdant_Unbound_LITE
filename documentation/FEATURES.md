# VERDANT — UNBOUND LITE
## Features Documentation

### 1. Lighting System
- **Directional sunlight**: Implemented with efficient calculation
- **Directional moonlight**: Optional, configurable
- **Smooth day/night lighting transitions**: Time-dependent color temperature
- **Natural ambient lighting**: Biome-dependent lighting colors
- **Approximate ambient occlusion**: Simplified for 940MX performance
- **Improved block lighting**: Material-specific adjustments
- **Natural light attenuation**: Distance-based optimization
- **Biome-dependent lighting colors**: Coordinate-based detection
- **Time-dependent color temperature**: Sunrise/sunset/night transitions
- **Sunrise lighting**: Warm color temperature
- **Sunset lighting**: Warm color temperature
- **Nighttime blue lighting**: Cool color temperature
- **Cave darkness**: Reduced ambient lighting
- **Natural-looking light contrast**: Material-specific contrast
- **Improved underwater lighting**: Water-specific adjustments
- **Weather-dependent ambient lighting**: Rain/snow/thunderstorm effects

### 2. Shadow System (Super Good Lightweight)
- **Directional shadows**: Efficient shadow mapping
- **Moving tree shadows**: Dynamic shadow updates
- **Building shadows**: Static shadow mapping
- **Player and entity shadows**: Supported where available
- **Super good lightweight shadow filtering**: Improved 8-sample PCF approximation (better than previous but still optimized for 940MX)
- **Configurable shadow distance**: Adjustable 4-16 blocks
- **Adjustable shadow quality**: Low/Medium/High options
- **Distance-based shadow optimization**: Performance optimization
- **Contact-shadow approximation**: Simplified contact shadows
- **Weather-dependent shadow behavior**: Rain/snow effects
- **Sun and moon shadow direction**: Dynamic direction

### 3. Water System (Lightweight Reflection)
- **Transparent water**: Configurable transparency
- **Animated water surface**: Efficient sine wave animation
- **Efficient animated normal maps**: Simplified normal animation
- **Fresnel reflections**: Approximate screen-space reflections
- **Lightweight water reflection**: Simplified screen-space approximation with limited samples (Complementary Unbound style)
- **Sunlight reflections**: Dynamic reflection calculation
- **Water depth coloring**: Depth-based color variation
- **Underwater fog**: Dimension-specific fog
- **Underwater color distortion**: Blue tint approximation
- **Subtle underwater caustic effects**: Simplified caustics
- **River appearance**: Flow-based animation
- **Ocean appearance**: Large-scale animation
- **Lake appearance**: Small-scale animation
- **Rain-dependent wet appearance**: Weather-based effects
- **Improved ice shading**: Material-specific adjustments

### 4. Sky System (3D Aurora, Godrays, Round Sun/Moon)
- **Realistic sun (Round shape)**: Complementary Unbound style circular rendering
- **Realistic moon (Round shape)**: Complementary Unbound style circular rendering
- **Stars**: Configurable star rendering
- **Atmospheric horizon**: Gradient-based horizon
- **Sunrise gradients**: Time-dependent gradients
- **Sunset gradients**: Time-dependent gradients
- **Daytime sky coloring**: Blue sky approximation
- **Nighttime sky coloring**: Dark sky approximation
- **Biome-dependent atmospheric colors**: Coordinate-based colors
- **Weather-dependent sky appearance**: Rain/snow/thunderstorm effects
- **Sun glow**: Simplified glow approximation
- **Subtle atmospheric scattering approximation**: Lightweight scattering
- **Smooth day/night transitions**: Time-based transitions
- **3D Animated Aurora Effect**: Lightweight 3D approximation (no expensive volumetric ray marching)
- **Godrays (Lightweight)**: Simplified screen-space approximation (6 steps)

### 5. Cloud System
- **Animated clouds**: 2D/2.5D animation approximation
- **Soft cloud edges**: Distance-based edge calculation
- **Natural cloud shading**: Simplified shading
- **Multiple cloud layers**: Limited to 2-3 layers for performance
- **Cloud color variation**: Time/weather-dependent colors
- **Sunset cloud colors**: Time-dependent colors
- **Nighttime clouds**: Darkened appearance
- **Weather-dependent clouds**: Rain/snow effects
- **Approximate cloud shadows**: Simplified shadow calculation

### 6. Vegetation System
- **Animated leaves**: Vertex-based animation
- **Animated grass**: Vertex-based animation
- **Animated flowers**: Vertex-based animation
- **Animated crops**: Vertex-based animation
- **Natural wind movement**: Sine wave approximation
- **Wind intensity variation**: Configurable intensity
- **Biome-dependent movement**: Coordinate-based variation
- **Subtle foliage lighting**: Simplified lighting
- **Improved leaf shading**: Material-specific adjustments

### 7. Weather System
- **Rain atmosphere**: Weather-dependent fog
- **Rain-dependent fog**: Simplified fog approximation
- **Rain streak appearance**: Sine wave approximation
- **Cloud darkening**: Weather-based darkening
- **Thunderstorm lighting**: Lightning flash approximation
- **Lightning flashes**: Time-based flashes
- **Snow atmosphere**: Weather-dependent atmosphere
- **Weather-dependent color grading**: Weather-based tinting
- **Smooth weather transitions**: Time-based transitions

### 8. Material System
- **Stone**: Material-specific highlights
- **Dirt**: Material-specific highlights
- **Grass blocks**: Material-specific highlights
- **Sand**: Material-specific highlights
- **Wood**: Material-specific highlights
- **Logs**: Material-specific highlights
- **Leaves**: Material-specific highlights
- **Glass**: Transparency and reflectivity
- **Ice**: Transparency and reflectivity
- **Metal blocks**: High reflectivity
- **Ores**: Enhanced highlights
- **Water**: Reflection and refraction
- **Lava**: Emissive effects
- **Nether blocks**: Dimension-specific adjustments
- **End blocks**: Dimension-specific adjustments

### 9. Bloom and Post-Processing
- **Subtle bloom**: Lightweight approximation
- **Controlled exposure**: Adjustable exposure
- **Tonemapping**: Efficient tonemapping
- **Color grading**: Saturation and contrast adjustment
- **Contrast adjustment**: Configurable contrast
- **Saturation adjustment**: Configurable saturation
- **Subtle light adaptation**: Time-based adaptation
- **Optional vignette**: Distance-based vignette
- **Optional lens effects**: Simplified lens approximation

### 10. Emissive Effects
- **Torches**: Emissive glow approximation
- **Lanterns**: Emissive glow approximation
- **Glowstone**: Emissive glow approximation
- **Sea lanterns**: Emissive glow approximation
- **Glowing ores**: Emissive glow approximation
- **Lava**: Emissive glow approximation
- **Fire**: Emissive glow approximation
- **Nether portals**: Emissive glow approximation
- **Other emissive blocks**: General emissive support

### 11. Dimension Support
- **Overworld**: Full system support
- **Nether**: Dimension-specific lighting and atmosphere
- **End**: Dimension-specific lighting and atmosphere

### 12. Performance Presets
- **Potato**: Extremely low-end optimization
- **Lite**: Maximum practical performance
- **Balanced Ultra-Lite**: Default recommended (ASUS X405UQ)
- **Quality**: Better visuals with low-end awareness

### 13. Configuration Menu
- **Main settings**: Quality preset, master toggle, performance mode
- **Lighting**: Sunlight, moonlight, ambient occlusion, intensity, color grading
- **Shadows**: Quality, distance, soft shadows, entity shadows
- **Water**: Quality, reflections, animation, underwater effects
- **Clouds and sky**: Quality, animation, shadows, sky effects, stars
- **Environment**: Fog, vegetation movement, rain, snow, weather lighting
- **Post-processing**: Bloom, tonemapping, exposure, vignette, saturation, contrast
- **Performance**: Advanced mode, reduced resolution, shadow optimization, effect toggles

### 14. NVIDIA GeForce 940MX Optimizations
- No ray tracing or path tracing
- No expensive global illumination
- Efficient shadow maps (low resolution)
- Minimal framebuffer allocation
- Reduced render passes
- Limited texture sampling
- No expensive per-pixel iterative loops
- Simplified procedural noise
- Lightweight post-processing
- Minimal volumetric ray marching
- Limited temporal accumulation
- Reduced GPU memory consumption
- CPU-friendly animation calculations
- Minimal shader recompilation
- Consistent frame times
- GPU-friendly GLSL operations
- Predictable rendering workloads
