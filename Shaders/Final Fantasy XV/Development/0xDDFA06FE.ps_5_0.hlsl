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

SamplerState pointSampler_s : register(s0);
Texture2D<float4> srcColorTex : register(t0);
Texture2D<float4> srcCoCTex : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  out float4 o0 : SV_TARGET0,
  out float4 o1 : SV_TARGET1)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = srcCoCTex.Gather(pointSampler_s, w1.xy).xyzw;
  r1.xyzw = srcCoCTex.Gather(pointSampler_s, w1.xy).xyzw;
  r2.xyzw = max(r1.wzxy, r0.wzxy);
  r0.xy = max(r0.wx, r0.zy);
  o1.x = max(r0.x, r0.y);
  r0.xy = min(r1.wx, r1.zy);
  o1.y = min(r0.x, r0.y);
  r0.xyzw = CoCParam0.wwww * r2.xyzw;
  r0.xyzw = cmp(r0.xyzw >= float4(2,2,2,2));
  r0.xyzw = r0.xyzw ? float4(1,1,1,1) : 0;
  r1.w = r0.x;
  r2.w = r0.y;
  r3.xyzw = srcColorTex.Gather(pointSampler_s, w1.xy).yxzw;
  r4.x = r3.w;
  r5.xyzw = srcColorTex.Gather(pointSampler_s, w1.xy).xyzw;
  r4.y = r5.w;
  r6.xyzw = srcColorTex.Gather(pointSampler_s, w1.xy).xyzw;
  r4.z = r6.w;
  r1.xyz = r4.xyz * r0.xxx;
  r7.x = r3.z;
  r7.y = r5.z;
  r7.z = r6.z;
  r2.xyz = r7.xyz * r0.yyy;
  r4.xyz = r7.xyz + r4.xyz;
  r1.xyzw = r2.xyzw + r1.xyzw;
  r2.w = r0.z;
  r7.x = r3.y;
  r7.y = r5.x;
  r3.y = r5.y;
  r7.z = r6.x;
  r3.z = r6.y;
  r2.xyz = r7.xyz * r0.zzz;
  r4.xyz = r7.xyz + r4.xyz;
  r4.xyz = r4.xyz + r3.xyz;
  r0.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r4.xyz;
  r1.xyzw = r2.xyzw + r1.xyzw;
  r0.xyzw = r1.xyzw + r0.xyzw;
  r1.x = max(0.100000001, r0.w);
  r0.xyz = r0.xyz / r1.xxx;
  r0.w = cmp(r0.w == 0.000000);
  o0.xyz = r0.www ? r3.xyz : r0.xyz;
  o0.w = 0;
  o1.zw = float2(0,0);
  return;
}