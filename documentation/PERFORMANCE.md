# VERDANT — UNBOUND LITE
## Performance Documentation

### Target Hardware
- **GPU**: NVIDIA GeForce 940MX (ASUS X405UQ)
- **CPU**: Intel Core i5 7th generation
- **RAM**: 8 GB
- **Storage**: 1 TB HDD
- **Target Resolution**: 1280×720 (720p) and 1600×900 (900p)

### Performance Engineering Principles

1. **Baseline Establishment**
   - Vanilla with Sodium: Baseline performance
   - Measurement: FPS, 1% low FPS, frame-time consistency

2. **Lighting System Optimization**
   - Simplified lighting calculations
   - Reduced texture fetches
   - Efficient shadow mapping
   - Minimal framebuffer allocation

3. **Shadow System Optimization**
   - Low-resolution shadow maps
   - Limited shadow samples (4 samples)
   - Distance-based optimization
   - Simplified PCF filtering

4. **Water System Optimization**
   - Efficient normal animation
   - Simplified screen-space reflections
   - Reduced water quality options
   - Minimal refraction calculations

5. **Sky and Cloud Optimization**
   - 2D/2.5D cloud rendering
   - Limited cloud layers (2-3)
   - Simplified atmospheric scattering
   - Efficient sun/moon calculations

6. **Vegetation Optimization**
   - Vertex-based animation
   - Simplified wind calculations
   - Limited foliage lighting
   - Reduced texture sampling

7. **Weather Optimization**
   - Simplified rain streaks
   - Minimal cloud darkening
   - Efficient lightning flashes
   - Reduced snow atmosphere

8. **Material Optimization**
   - Simplified material highlights
   - Reduced contrast adjustments
   - Efficient transparency handling
   - Minimal emissive calculations

9. **Post-Processing Optimization**
   - Lightweight bloom approximation
   - Efficient tonemapping
   - Simplified color grading
   - Minimal vignette calculations

### Benchmark Results (Estimated - Pending Physical Testing)

| Preset | Target FPS (720p) | Target FPS (900p) | 1% Low FPS (720p) | Frame-Time Consistency |
|--------|-------------------|-------------------|-------------------|------------------------|
| Vanilla + Sodium | 60+ | 50+ | 55+ | Excellent |
| Potato | 45+ | 35+ | 40+ | Excellent |
| Lite | 35+ | 28+ | 30+ | Good |
| Balanced Ultra-Lite | 30+ | 24+ | 25+ | Good |
| Quality | 25+ | 20+ | 20+ | Fair |

### Performance Targets for ASUS X405UQ
- **720p Resolution**: Primary optimization target
- **900p Resolution**: Secondary optimization target
- **1080p Resolution**: Not recommended (may drop below 20 FPS)
- **GPU Utilization**: Target < 80% for consistent frame times
- **VRAM Usage**: Target < 2 GB
- **RAM Usage**: Target < 4 GB

### Optimization Techniques Used

1. **Texture Fetch Minimization**
   - Reduced texture sampling in shaders
   - Efficient texture coordinate calculations
   - Limited texture lookups per fragment

2. **Framebuffer Optimization**
   - Minimal framebuffer attachments
   - Reduced intermediate buffers
   - Efficient buffer clearing

3. **Branching Optimization**
   - Compile-time options for disabled effects
   - Minimal dynamic branching
   - Efficient conditional calculations

4. **Resolution Optimization**
   - Reduced-resolution effects option
   - Efficient scaling calculations
   - Limited high-resolution passes

5. **Memory Optimization**
   - Minimal GPU memory consumption
   - Efficient buffer management
   - Reduced texture memory usage

6. **CPU Optimization**
   - CPU-friendly animation calculations
   - Minimal shader recompilation
   - Efficient uniform updates

### Known Bottlenecks
1. **Shadow Mapping**: Primary bottleneck on 940MX
2. **Water Reflections**: Secondary bottleneck
3. **Post-Processing**: Tertiary bottleneck
4. **Vegetation Animation**: Vertex processing cost

### Testing Status
- **Static Validation**: Completed
- **Shader Compilation**: Validated
- **Physical GPU Testing**: Pending (ASUS X405UQ / NVIDIA GeForce 940MX)
- **Benchmark Results**: Estimated (pending physical testing)

### Recommendations for ASUS X405UQ
1. **Default Preset**: Balanced Ultra-Lite
2. **Resolution**: 1280×720 (720p)
3. **Shadow Distance**: 8 blocks
4. **Shadow Quality**: Medium
5. **Water Quality**: Medium
6. **Cloud Quality**: Medium
7. **Post-Processing**: Enable bloom and tonemapping, disable vignette
8. **Performance Mode**: Enable advanced mode for better FPS

### Future Optimizations
1. Further shadow optimization
2. Improved water reflection efficiency
3. Enhanced vegetation animation performance
4. Better post-processing optimization
5. Reduced memory consumption
