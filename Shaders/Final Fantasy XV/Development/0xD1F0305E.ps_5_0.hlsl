// ---- Created with 3Dmigoto v1.4.1 on Thu Feb  5 12:35:15 2026

cbuffer _Globals : register(b0)
{
  float4 graph_color : packoffset(c0);
  float3 copy_srcColorFactor : packoffset(c1);
  float3 copy_srcColorFactorArray[11] : packoffset(c2);
  float3 highpass_gamma : packoffset(c13);
  float2 highpass_pixelOffset : packoffset(c14);
  float3 highpass_threshold : packoffset(c15);
  float2 gauss_minUV : packoffset(c16);
  float2 gauss_maxUV : packoffset(c16.z);
  float3 gauss_mix : packoffset(c17);
  float4 gauss_weights[65] : packoffset(c18);
  float2 gauss_offsets[65] : packoffset(c83);
  float3 compo_sparkBlend : packoffset(c148);
  float3 compo_oneMinusSparkBlend : packoffset(c149);
  float3 compo_glareGamma : packoffset(c150);
  float4 compo_glareWeights[11] : packoffset(c151);
  float4 compo_glareWeightsSumInv : packoffset(c162);
  float compo_glareBaseBlurMip : packoffset(c163);
  float3 compo_glareSoftAmount : packoffset(c163.y);
  float3 compo_glareSoftExpand : packoffset(c164);
  float3 compo_glareFoggyAmount : packoffset(c165);
  float3 compo_glareFoggyExpand : packoffset(c166);
  float4 compo_vignetteParam0 : packoffset(c167);
  float4 compo_vignetteParam1 : packoffset(c168);
  float4 compo_vignetteParam2 : packoffset(c169);
}

SamplerState srcSampler_s : register(s0);
Texture2D<float4> srcSamplerTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float2 v2 : TEXCOORD1,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = max(gauss_minUV.xyxy, v1.xyzw);
  r0.xyzw = min(gauss_maxUV.xyxy, r0.xyzw);
  r1.xyz = srcSamplerTexture.SampleLevel(srcSampler_s, r0.zw, 0).xyz;
  r0.xyz = srcSamplerTexture.SampleLevel(srcSampler_s, r0.xy, 0).xyz;
  r1.xyz = gauss_weights[1].xyz * r1.xyz;
  r0.xyz = r0.xyz * gauss_weights[0].xyz + r1.xyz;
  r1.xy = max(gauss_minUV.xy, v2.xy);
  r1.xy = min(gauss_maxUV.xy, r1.xy);
  r1.xyz = srcSamplerTexture.SampleLevel(srcSampler_s, r1.xy, 0).xyz;
  r0.xyz = r1.xyz * gauss_weights[2].xyz + r0.xyz;
  o0.xyz = gauss_mix.xyz * r0.xyz;
  o0.w = 0;
  return;
}