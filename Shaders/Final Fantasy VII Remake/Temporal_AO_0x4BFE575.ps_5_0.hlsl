#include "Includes/Common.hlsl"

// ------------------------------------------------------------------------------------------------
// Luma Constant Buffers
// ------------------------------------------------------------------------------------------------
// Assumes Common.hlsl defines LumaData and LumaSettings cbuffers.

// ------------------------------------------------------------------------------------------------
// Game Constant Buffers
// ------------------------------------------------------------------------------------------------
cbuffer cb1 : register(b1) { float4 cb1[140]; }
cbuffer cb0 : register(b0) { float4 cb0[21]; }

// ------------------------------------------------------------------------------------------------
// XeGTAO Configuration
// ------------------------------------------------------------------------------------------------
#define XE_GTAO_ENABLE_DENOISE 1 
#define XE_GTAO_USE_HALF_FLOAT_PRECISION 0
// FIX: Disable default constants so XeGTAO uses the values we set in GTAO_Impl
#define XE_GTAO_USE_DEFAULT_CONSTANTS 0 
#include "Includes/XeGTAO.hlsl"

// ------------------------------------------------------------------------------------------------
// Resources
// ------------------------------------------------------------------------------------------------
Texture3D<float4> t0 : register(t0); 
Texture2D<float4> t1 : register(t1); // G-Buffer Normals
Texture2D<float>  t2 : register(t2); // Depth Buffer
Texture2D<float4> t3 : register(t3); // Previous Frame Output
Texture2D<float4> t4 : register(t4); // Motion Vectors
Texture2D<float4> t5 : register(t5); // Original AO Source (Unused in GTAO path)

SamplerState s0_s : register(s0);

// 3Dmigoto declarations
#define cmp -

// ------------------------------------------------------------------------------------------------
// Helper: Calculate Linear Depth (Exact Assembly Logic)
// ------------------------------------------------------------------------------------------------
float GetLinearDepth(float2 uv)
{
    float rawDepth = t2.SampleLevel(s0_s, uv, 0).x;
    
    // Assembly:
    // r2.z = r0.z * cb1[57].x + cb1[57].y;
    // r2.w = r0.z * cb1[57].z + -cb1[57].w;
    // r2.w = rcp(r2.w);
    // r3.z = r2.z + r2.w;
    
    float term1 = rawDepth * cb1[57].x + cb1[57].y;
    float term2 = 1.0f / (rawDepth * cb1[57].z - cb1[57].w);
    
    return term1 + term2;
}

// ------------------------------------------------------------------------------------------------
// Original Shader Logic (Legacy Path)
// ------------------------------------------------------------------------------------------------
float4 Original_Impl(float4 v1)
{
    return float4(1,1,0,1); 
}

// ------------------------------------------------------------------------------------------------
// Temporal Implementation (Exact Decompiled Logic)
// ------------------------------------------------------------------------------------------------
float4 Temporal_Impl(float4 v1, float gtaoVisibility)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  
  // --- SETUP (Lines 39-54) ---
  r0.xy = (int2)v1.xy;
  r1.xy = trunc(v1.xy);
  r1.xy = float2(0.5,0.5) + r1.xy;
  r1.xy = -cb1[121].xy + r1.xy;
  r1.xy = cb1[122].zw * r1.xy;
  r1.xy = r1.xy * float2(2,2) + float2(-1,-1);
  r1.zw = float2(1,-1) * r1.xy;
  r0.z = asuint(cb1[139].w) << 1;
  r2.xyz = (int3)r0.xyz & int3(63,63,63);
  r2.w = 0;
  r2.xy = t0.Load(r2.xyzw).yz;
  r0.w = 0;
  
  // Calculate Linear Depth for Alpha (Matches GetLinearDepth)
  r0.z = t2.Load(r0.xyw).x;
  r2.z = r0.z * cb1[57].x + cb1[57].y;
  r2.w = r0.z * cb1[57].z + -cb1[57].w;
  r2.w = rcp(r2.w);
  r3.z = r2.z + r2.w;
  
  // --- INJECT GTAO VISIBILITY ---
  r2.w = gtaoVisibility;

  // --- TEMPORAL LOGIC (Lines 270-317) ---
  r3.xyw = cb1[115].xyw * r1.www;
  r3.xyw = r1.zzz * cb1[114].xyw + r3.xyw;
  r3.xyw = r0.zzz * cb1[116].xyw + r3.xyw;
  r3.xyw = cb1[117].xyw + r3.xyw;
  r3.xy = r3.xy / r3.ww;
  r3.xy = r1.xy * float2(1,-1) + -r3.xy;
  r0.xy = t4.Load(r0.xyw).xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.z = cmp(0 < r0.z);
  r0.xy = float2(-0.499992371,-0.499992371) + r0.xy;
  r0.xy = float2(4.00801611,4.00801611) * r0.xy;
  r0.xy = r0.zz ? r0.xy : r3.xy;
  r0.xy = r1.xy * float2(1,-1) + -r0.xy;
  r1.xy = cb1[125].xy * r0.xy;
  r1.xy = r1.zw * cb1[122].xy + -r1.xy;
  r0.w = dot(r1.xy, r1.xy);
  r0.w = sqrt(r0.w);
  r0.w = 0.0125000002 * r0.w;
  r2.y = min(1, r0.w);
  r0.w = max(abs(r0.x), abs(r0.y));
  r0.w = cmp(r0.w < 1);
  if (r0.w != 0) {
    r0.xy = r0.xy * cb1[123].xy + cb1[123].wz;
    r0.xy = cb1[126].xy * r0.xy;
    r1.xy = float2(0.5,0.5) + cb1[124].xy;
    r1.zw = cb1[125].xy + cb1[124].xy;
    r1.zw = float2(-0.5,-0.5) + r1.zw;
    r0.xy = max(r1.xy, r0.xy);
    r0.xy = min(r0.xy, r1.zw);
    r0.xy = cb0[1].zw * r0.xy;
    r0.xyw = t3.SampleLevel(s0_s, r0.xy, 0).xyz;
    r1.x = cmp(r0.y != 0.000000);
    r0.y = r0.w * 0.800000012 + r2.y;
    r0.w = ~(int)r0.z;
    r0.w = r1.x ? r0.w : 0;
    r2.x = 1;
    r2.xy = r0.ww ? r2.wx : r0.xy;
  } else {
    r2.xy = r2.wy;
  }
  r2.z = r0.z ? -r3.z : r3.z;
  
  return r2.wxyz;
}

// ------------------------------------------------------------------------------------------------
// GTAO Implementation
// ------------------------------------------------------------------------------------------------
void GTAO_Impl(float4 WPos, out float4 o0)
{
    GTAOConstants consts;
    
    // 1. Viewport & Depth Setup
    consts.ViewportSize = (uint2)LumaData.GameData.RenderResolution.xy;
    consts.ViewportPixelSize = LumaData.GameData.RenderResolution.zw;
    
    consts.ScaledViewportMax = consts.ViewportSize - 1; 
    consts.ScaledViewportPixelSize = consts.ViewportPixelSize; 
    consts.RenderResolutionScale = float2(1.0f, 1.0f);         
    consts.SampleUVClamp = float2(1.0f, 1.0f);
    consts.SampleScaledUVClamp = float2(1.0f, 1.0f);
    consts.MinVisibility = 0.0f;

    // FIX: Set Radius Scaling parameters to match Prey (scaled to cm for FF7R).
    // Prey: 8m -> 1000m, Mult 55.0
    // FF7R (cm): 800.0 -> 100000.0
    consts.RadiusScalingMinDepth = 8.0f; 
    consts.RadiusScalingMaxDepth = 1000.0f;
    consts.RadiusScalingMultiplier = 55.0f;
    consts.DepthFar = 0.0f; // Unused in FF7R path

    // Note: DepthUnpackConsts removed from struct in XeGTAO.hlsl
    // consts.DepthUnpackConsts.x = cb1[57].z;
    // consts.DepthUnpackConsts.y = -cb1[57].w;
    
    // 2. FOV & Projection Setup
    float vertFOV = (LumaData.GameData.GTAO.FOV); 
    // Safety check for FOV to prevent division by zero/infinity
    if (vertFOV <= 0.001f) vertFOV = radians(60.0f);

    float aspectRatio = (float)consts.ViewportSize.x / (float)consts.ViewportSize.y;
    float tanHalfFOVY = tan(vertFOV * 0.5f);
    float tanHalfFOVX = tanHalfFOVY * aspectRatio;
    consts.CameraTanHalfFOV = float2(tanHalfFOVX, tanHalfFOVY);
    
    consts.NDCToViewMul = float2(consts.CameraTanHalfFOV.x * 2.0f, consts.CameraTanHalfFOV.y * -2.0f);
    consts.NDCToViewAdd = float2(-consts.CameraTanHalfFOV.x, consts.CameraTanHalfFOV.y);
    consts.NDCToViewMul_x_PixelSize = float2(consts.NDCToViewMul.x, -consts.NDCToViewMul.y) * consts.ViewportPixelSize;

    // 3. Quality Settings
    // FIX: Increased Radius to 300.0 (3 meters) to capture more detail
    consts.EffectRadius = 2.f; // Original: cb0[18].w * 5.0f;
    consts.EffectFalloffRange = 0.2f; // Original: 0.615f;
    consts.RadiusMultiplier = 1.457f;
    consts.SampleDistributionPower = XE_GTAO_DEFAULT_SAMPLE_DISTRIBUTION_POWER;
    consts.ThinOccluderCompensation = LumaSettings.DevSetting02;
    consts.FinalValuePower = 2.2f; 
    consts.DepthMIPSamplingOffset = 0;
    consts.NoiseIndex = LumaSettings.FrameIndex % 64; 
    consts.DenoiseBlurBeta = 1.2f;

    // 4. Inputs
    float2 pos = WPos.xy; 
    float2 localNoise = SpatioTemporalNoise((uint2)pos, consts.NoiseIndex);
    
    // 5. Normal Decoding
    float3 normalWorld = t1.Load(int3((int2)pos, 0)).xyz * 2.0 - 1.0;
    
    float3x3 viewRotationMatrix;
    viewRotationMatrix[0] = cb1[8].xyz;
    viewRotationMatrix[1] = cb1[9].xyz;
    viewRotationMatrix[2] = cb1[10].xyz;
    
    float3 normalView = mul(normalWorld, viewRotationMatrix);
    normalView = normalize(normalView);
    
    // 6. Execute GTAO
    float edges;
    
    // Pass raw depth (t2). XeGTAO.hlsl is patched to decode it using cb1.
    float4 gtao = XeGTAO_MainPass(pos, 7, 3, localNoise, normalView, consts, t2, t2, s0_s, edges);
    
    // FIX: XeGTAO returns Obscurance (0=Visible, 1=Occluded).
    // We need Visibility (1=Visible, 0=Occluded).
    float currentVisibility = 1.0f - gtao.w;
    
    // 7. Pass to Temporal Implementation
    o0 = Temporal_Impl(WPos, currentVisibility);
    
}

// ------------------------------------------------------------------------------------------------
// Entry Point
// ------------------------------------------------------------------------------------------------
void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  out float4 o0 : SV_Target0
)
{
    bool useGTAO = true; 

    if (useGTAO)
    {
        GTAO_Impl(v1, o0);
    }
    else
    {
        o0 = Original_Impl(v1);
    }
}