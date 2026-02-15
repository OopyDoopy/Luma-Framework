// ---- Created with 3Dmigoto v1.4.1 on Thu Feb  5 12:35:16 2026

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

SamplerState pointSampler_s : register(s0);
Texture2D<float4> srcDepthTex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  linear sample float2 v1 : TEXCOORD0,
  linear sample float2 w1 : TEXCOORD3,
  out float4 o0 : SV_TARGET0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(w1.xy, w1.xy);
  r0.x = sqrt(r0.x);
  r0.x = -vignetteBlurParam1.x + r0.x;
  r0.x = saturate(vignetteBlurParam1.y * r0.x);
  r0.x = vignetteBlurParam1.z * r0.x;
  r0.x = max(9.99999975e-06, r0.x);
  r0.x = log2(r0.x);
  r0.x = vignetteBlurParam1.w * r0.x;
  r0.x = exp2(r0.x);
  r0.y = srcDepthTex.SampleLevel(pointSampler_s, v1.xy, 0).x;
  r0.y = r0.y * unprojectParam.x + unprojectParam.y;
  r0.y = 1 / r0.y;
  r0.z = CoCParam2.z + r0.y;
  r0.z = min(CoCParam0.y, r0.z);
  r0.w = -CoCParam2.w + r0.y;
  r0.y = cmp(r0.y < CoCParam0.y);
  r0.w = max(CoCParam0.y, r0.w);
  r0.y = r0.y ? r0.z : r0.w;
  r0.z = -CoCParam0.y + r0.y;
  r0.y = CoCParam0.z * r0.y;
  r0.z = CoCParam0.x * r0.z;
  r0.y = r0.z / r0.y;
  r0.z = CoCParam1.y * -r0.y;
  r0.y = CoCParam1.y * r0.y;
  r0.y = CoCParam2.y * r0.y;
  o0.y = min(CoCParam3.y, r0.y);
  r0.y = CoCParam2.x * r0.z;
  r0.y = min(CoCParam3.x, r0.y);
  o0.x = max(r0.y, r0.x);
  o0.zw = float2(0,0);
  return;
}