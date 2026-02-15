// ---- Created with 3Dmigoto v1.4.1 on Thu Feb  5 12:35:15 2026

cbuffer cbDof : register(b0)
{
  float4 unprojectParam : packoffset(c0);
  float4 CoCParam0 : packoffset(c1);
  float4 CoCParam1 : packoffset(c2);
  float4 CoCParam2 : packoffset(c3);
  float4 CoCParam3 : packoffset(c4);
  float4 fullscreenDims : packoffset(c5);
  float4 vignetteBlurParam0 : packoffset(c6);
  float4 vignetteBlurParam1 : packoffset(c7);
  float4 uvJitterOffset : packoffset(c8);
  float4x4 motionMatrix : packoffset(c9);
  float blendBokeh_param0 : packoffset(c13);
  float blendBokeh_param1 : packoffset(c13.y);
  float gamePaused : packoffset(c13.z);
  float spare : packoffset(c14);
}

SamplerState linearSampler_s : register(s0);
Texture2D<float4> srcCoCTex : register(t0);
Texture2D<float4> blurredCoCTex : register(t1);
Texture2D<float4> srcBlurredTex : register(t2);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = blurredCoCTex.SampleLevel(linearSampler_s, v1.xy, 0).x;
  r0.x = CoCParam2.x * r0.x;
  r0.x = min(CoCParam3.x, r0.x);
  r0.y = srcCoCTex.SampleLevel(linearSampler_s, v1.xy, 0).y;
  r0.y = CoCParam2.y * r0.y;
  r0.y = min(CoCParam3.y, r0.y);
  r0.x = max(r0.x, r0.y);
  r0.y = r0.x * CoCParam0.w + -1.5;
  r0.x = r0.x * CoCParam0.w + -blendBokeh_param0;
  r0.x = max(0, r0.x);
  r0.x = blendBokeh_param1 * r0.x;
  o0.w = min(1, r0.x);
  r0.x = cmp(r0.y < 0);
  if (r0.x != 0) discard;
  r0.xyz = srcBlurredTex.SampleLevel(linearSampler_s, v1.xy, 0).xyz;
  o0.xyz = r0.xyz;
  return;
}