// ---- Created with 3Dmigoto v1.4.1 on Thu Feb  5 12:35:15 2026

cbuffer _Globals : register(b0)
{
  float4 centerTexel : packoffset(c0);
  float lensScale : packoffset(c1);
  float screenScale : packoffset(c1.y);
}

SamplerState srcSampler_s : register(s0);
Texture2D<float4> srcSamplerTexture : register(t0);


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

  r0.xy = -centerTexel.xy + v1.xy;
  r0.xy = r0.xy + r0.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.xy = screenScale * r0.xy;
  r0.z = sqrt(r0.z);
  r0.w = lensScale * r0.z;
  r0.z = r0.w * r0.z + 1;
  r0.w = lensScale * 2 + 1;
  r0.z = r0.z / r0.w;
  r0.xy = r0.xy * r0.zz;
  r0.xy = r0.xy * float2(0.5,0.5) + centerTexel.xy;
  o0.xyzw = srcSamplerTexture.Sample(srcSampler_s, r0.xy).xyzw;
  return;
}