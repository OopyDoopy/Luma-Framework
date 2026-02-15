// ---- Created with 3Dmigoto v1.4.1 on Thu Feb  5 12:35:15 2026

SamplerState linearSampler_s : register(s0);
SamplerState pointSampler_s : register(s1);
Texture2D<float4> srcCoCTex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = srcCoCTex.SampleLevel(linearSampler_s, v1.zw, 0).x;
  r0.x = max(0, r0.x);
  r0.y = srcCoCTex.SampleLevel(linearSampler_s, v2.xy, 0).x;
  r0.x = max(r0.x, r0.y);
  r1.xyzw = srcCoCTex.SampleLevel(pointSampler_s, v2.zw, 0).xyzw;
  r0.x = max(r1.x, r0.x);
  o0.yzw = r1.yzw;
  r0.y = srcCoCTex.SampleLevel(linearSampler_s, v3.xy, 0).x;
  r0.x = max(r0.x, r0.y);
  r0.y = srcCoCTex.SampleLevel(linearSampler_s, v3.zw, 0).x;
  o0.x = max(r0.x, r0.y);
  return;
}