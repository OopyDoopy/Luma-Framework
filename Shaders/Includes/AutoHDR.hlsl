#ifndef SRC_AUTOHDR_HLSL
#define SRC_AUTOHDR_HLSL

// AutoHDR with bloom-based spatial analysis
// Samples surrounding pixels to determine highlight regions and applies
// HDR enhancement selectively based on local brightness extremes.

#include "Common.hlsl"

// ============================================================================
// Configuration
// ============================================================================
struct AutoHDRBloomConfig
{
    // HDR parameters
    float MaxPeakWhiteNits;
    float PaperWhiteNits;
    float ShoulderPow;
    
    // Spatial sampling
    int   NumRings;
    int   AnglesPerRing;
    float UVRadius;
    float MidGrey;
    
    // Film grain
    bool  EnableFilmGrain;
    float GrainIntensity;
    uint  FrameIndex;
    
    // Resolution info for grain scaling
    float2 SourceResolution;  // Source texture resolution (e.g., 1080p video)
    float2 OutputResolution;  // Output/display resolution (e.g., 4K)
};

AutoHDRBloomConfig CreateDefaultAutoHDRBloomConfig()
{
    AutoHDRBloomConfig config;
    
    config.MaxPeakWhiteNits = 600.0f;
    config.PaperWhiteNits   = GamePaperWhiteNits;
    config.ShoulderPow      = 2.75f;
    
    config.NumRings      = 14;
    config.AnglesPerRing = 14;
    config.UVRadius      = 1.0f / 80.0f;
    config.MidGrey       = 0.5f;
    
    config.EnableFilmGrain = false;
    config.GrainIntensity  = 1.0f;
    config.FrameIndex      = 0;
    
    config.SourceResolution = float2(1920.0f, 1080.0f);
    config.OutputResolution = float2(1920.0f, 1080.0f);
    
    return config;
}

// ============================================================================
// Helpers
// ============================================================================

float AutoHDR_Hash13(float3 p)
{
    float3 p3 = frac(p * 0.1031f);
    p3 += dot(p3, p3.yzx + 33.33f);
    return frac((p3.x + p3.y) * p3.z);
}

// Returns 0 at mid grey, 1 towards black or white
float AutoHDR_RingExtremeness(float ringY, float midGrey)
{
    float d = ringY - midGrey;
    return saturate(4.0f * d * d);
}

// Additive film grain (apply in gamma space)
float AutoHDR_GetFilmGrain(float linearLuminance, float2 uv, float2 outputRes, uint frameIndex)
{
    // Grain at 1080p reference, scales with output resolution
    float grainPixels = outputRes.y / 1080.0f;
    
    float2 pixelPos  = uv * outputRes;
    float2 grainCell = floor(pixelPos / grainPixels);
    
    float grain = AutoHDR_Hash13(float3(grainCell, (float)frameIndex));
    grain = grain * 2.0f - 1.0f;
    
    float gammaLum = pow(max(linearLuminance, 0.0f), 1.0f / 2.2f);
    float shadowWeight = smoothstep(0.667f, 1.0f, 1.0f - gammaLum) * 0.1f;
    float highlightWeight = smoothstep(0.333f, 1.0f, gammaLum) + max(gammaLum - 1.0f, 0.0f);
    
    return grain * max(shadowWeight + highlightWeight, 0.125f) * 0.0333f;
}

// ============================================================================
// Main Function
// ============================================================================

// Applies AutoHDR with bloom-based spatial analysis
// Parameters:
//   inputColor  - Pre-sampled center pixel color in linear space
//   sourceTex   - Source texture for ring sampling (e.g., video)
//   sourceSamp  - Sampler
//   texCoord    - UV coordinates in source texture space
//   config      - Configuration
// Returns: HDR-enhanced color in linear space
float3 ApplyAutoHDRWithBloom(
    float3 inputColor,
    Texture2D<float4> sourceTex,
    SamplerState sourceSamp,
    float2 texCoord,
    AutoHDRBloomConfig config)
{
    float aspectRatio = config.SourceResolution.x / config.SourceResolution.y;
    
    // Center pixel luminance (already linear)
    float centerY = GetLuminance(inputColor);
    
    // Ring sampling for spatial brightness analysis
    float ringYSum = 0.0f;
    int sampleCount = 1;
    
    [unroll]
    for (int r = 0; r < config.NumRings; ++r)
    {
        float ringRadius = config.UVRadius * (float)(r + 1) / (float)config.NumRings;
        
        [unroll]
        for (int a = 0; a < config.AnglesPerRing; ++a)
        {
            float angle = (float)a / (float)config.AnglesPerRing * 6.28318530f;
            float2 offset;
            sincos(angle, offset.y, offset.x);
            offset.x *= ringRadius / aspectRatio;
            offset.y *= ringRadius;
            
            // Sample and linearize ring pixel
            float3 ringSample = linear_to_sRGB_gamma(sourceTex.SampleLevel(sourceSamp, saturate(texCoord + offset), 0).rgb);
            ringYSum += GetLuminance(ringSample);
            sampleCount++;
        }
    }
    
    float averageY = (ringYSum + centerY) / (float)sampleCount;
    float ringWeight = AutoHDR_RingExtremeness(averageY, config.MidGrey);
    float factor = centerY * ringWeight;
    
    // Apply AutoHDR with spatial blending
    float3 linearColor = gamma_sRGB_to_linear(inputColor);
    float3 hdrColor = PumboAutoHDR(linearColor, config.MaxPeakWhiteNits, config.PaperWhiteNits, config.ShoulderPow);
    float3 outputColor = lerp(linearColor, hdrColor, factor);
    
    // Film grain (applied at output resolution)
    if (config.EnableFilmGrain)
    {
        float lum = GetLuminance(outputColor);
        float2 outputUV = texCoord;
        
        outputColor = pow(abs(outputColor), 1.0f / 2.2f) * sign(outputColor);
        outputColor += AutoHDR_GetFilmGrain(lum, outputUV, config.OutputResolution, config.FrameIndex) * config.GrainIntensity;
        outputColor = pow(abs(outputColor), 2.2f) * sign(outputColor);
    }
    
    return outputColor;
}

#endif // SRC_AUTOHDR_HLSL
