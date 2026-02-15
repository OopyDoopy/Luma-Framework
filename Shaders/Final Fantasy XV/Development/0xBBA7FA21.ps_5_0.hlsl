// ---- Created with 3Dmigoto v1.4.1 on Thu Feb  5 12:35:15 2026

cbuffer BokehOffsets : register(b0)
{
  float4 blurBokehOffsets[225] : packoffset(c0);
}

cbuffer cbDof : register(b1)
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
SamplerState pointSampler_s : register(s1);
Texture2D<float4> srcColorTex : register(t0);
Texture2D<float4> srcCoCTex : register(t1);
Texture2D<float4> blurredCoCTex : register(t2);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = fullscreenDims.zwzw * float4(-0.5,-0.5,0.5,0.5) + v1.xyxy;
  r0.x = srcCoCTex.SampleLevel(pointSampler_s, r0.xy, 0).y;
  r0.y = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).y;
  r0.z = blurredCoCTex.SampleLevel(pointSampler_s, v1.xy, 0).x;
  r0.x = max(r0.x, r0.y);
  r1.xyzw = srcColorTex.SampleLevel(pointSampler_s, v1.xy, 0).xyzw;
  r0.y = max(r0.z, r0.x);
  r0.y = max(r0.z, r0.y);
  r0.w = CoCParam0.w * r0.y;
  r2.x = cmp(1.5 < r0.w);
  if (r2.x != 0) {
    r0.xz = CoCParam0.ww * r0.xz;
    r0.x = max(r0.z, r0.x);
    r0.x = cmp(r0.x == r0.z);
    if (r0.x != 0) {
      r0.x = blurBokehOffsets[0].z * r0.y;
      r2.xy = blurBokehOffsets[0].xy * r0.yy + v1.xy;
      r2.zw = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r2.z, r2.w);
      r2.z = 0.5 * CoCParam0.w;
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r4.xyz = r1.xyz;
        r4.w = 1;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r3.xyz = r1.xyz + r1.xyz;
        r3.w = 2;
      }
      r0.x = blurBokehOffsets[1].z * r0.y;
      r2.xy = blurBokehOffsets[1].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[2].z * r0.y;
      r2.xy = blurBokehOffsets[2].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[3].z * r0.y;
      r2.xy = blurBokehOffsets[3].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[4].z * r0.y;
      r2.xy = blurBokehOffsets[4].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[5].z * r0.y;
      r2.xy = blurBokehOffsets[5].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[6].z * r0.y;
      r2.xy = blurBokehOffsets[6].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[7].z * r0.y;
      r2.xy = blurBokehOffsets[7].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[8].z * r0.y;
      r2.xy = blurBokehOffsets[8].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[9].z * r0.y;
      r2.xy = blurBokehOffsets[9].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[10].z * r0.y;
      r2.xy = blurBokehOffsets[10].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[11].z * r0.y;
      r2.xy = blurBokehOffsets[11].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[12].z * r0.y;
      r2.xy = blurBokehOffsets[12].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[13].z * r0.y;
      r2.xy = blurBokehOffsets[13].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[14].z * r0.y;
      r2.xy = blurBokehOffsets[14].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[15].z * r0.y;
      r2.xy = blurBokehOffsets[15].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[16].z * r0.y;
      r2.xy = blurBokehOffsets[16].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[17].z * r0.y;
      r2.xy = blurBokehOffsets[17].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[18].z * r0.y;
      r2.xy = blurBokehOffsets[18].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[19].z * r0.y;
      r2.xy = blurBokehOffsets[19].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[20].z * r0.y;
      r2.xy = blurBokehOffsets[20].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[21].z * r0.y;
      r2.xy = blurBokehOffsets[21].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[22].z * r0.y;
      r2.xy = blurBokehOffsets[22].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[23].z * r0.y;
      r2.xy = blurBokehOffsets[23].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[24].z * r0.y;
      r2.xy = blurBokehOffsets[24].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[25].z * r0.y;
      r2.xy = blurBokehOffsets[25].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[26].z * r0.y;
      r2.xy = blurBokehOffsets[26].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[27].z * r0.y;
      r2.xy = blurBokehOffsets[27].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[28].z * r0.y;
      r2.xy = blurBokehOffsets[28].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[29].z * r0.y;
      r2.xy = blurBokehOffsets[29].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[30].z * r0.y;
      r2.xy = blurBokehOffsets[30].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[31].z * r0.y;
      r2.xy = blurBokehOffsets[31].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[32].z * r0.y;
      r2.xy = blurBokehOffsets[32].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[33].z * r0.y;
      r2.xy = blurBokehOffsets[33].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[34].z * r0.y;
      r2.xy = blurBokehOffsets[34].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[35].z * r0.y;
      r2.xy = blurBokehOffsets[35].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[36].z * r0.y;
      r2.xy = blurBokehOffsets[36].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[37].z * r0.y;
      r2.xy = blurBokehOffsets[37].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[38].z * r0.y;
      r2.xy = blurBokehOffsets[38].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[39].z * r0.y;
      r2.xy = blurBokehOffsets[39].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[40].z * r0.y;
      r2.xy = blurBokehOffsets[40].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[41].z * r0.y;
      r2.xy = blurBokehOffsets[41].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[42].z * r0.y;
      r2.xy = blurBokehOffsets[42].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[43].z * r0.y;
      r2.xy = blurBokehOffsets[43].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[44].z * r0.y;
      r2.xy = blurBokehOffsets[44].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[45].z * r0.y;
      r2.xy = blurBokehOffsets[45].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyw * r4.www;
        r4.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r4.xyzw = r5.xyzw + r3.xyzw;
      }
      r0.x = blurBokehOffsets[46].z * r0.y;
      r2.xy = blurBokehOffsets[46].xy * r0.yy + v1.xy;
      r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r3.x, r3.y);
      r3.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r3.w);
      if (r0.x != 0) {
        r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r3.xyz = r2.xyw * r3.www;
        r3.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r5.xyz = r1.xyz;
        r5.w = 1;
        r3.xyzw = r5.xyzw + r4.xyzw;
      }
      r0.x = blurBokehOffsets[47].z * r0.y;
      r2.xy = blurBokehOffsets[47].xy * r0.yy + v1.xy;
      r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
      r0.z = max(r4.x, r4.y);
      r4.w = saturate(r0.z * r2.z + -r0.x);
      r0.x = cmp(0 < r4.w);
      if (r0.x != 0) {
        r2.xyz = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
        r4.xyz = r2.xyz * r4.www;
        r2.xyzw = r4.xyzw + r3.xyzw;
      } else {
        r4.xyz = r1.xyz;
        r4.w = 1;
        r2.xyzw = r4.xyzw + r3.xyzw;
      }
      r1.xyz = r2.xyz / r2.www;
    } else {
      r0.x = cmp(r0.w >= 2);
      if (r0.x != 0) {
        r0.x = cmp(r0.w < 14);
        if (r0.x != 0) {
          r0.x = blurBokehOffsets[0].z * r0.y;
          r2.xy = blurBokehOffsets[0].xy * r0.yy + v1.xy;
          r2.zw = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
          r0.z = max(r2.z, r2.w);
          r2.z = 0.5 * CoCParam0.w;
          r3.w = saturate(r0.z * r2.z + -r0.x);
          r0.x = cmp(0 < r3.w);
          if (r0.x != 0) {
            r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
            r3.xyz = r2.xyw * r3.www;
            r4.xyz = r1.xyz;
            r4.w = 1;
            r4.xyzw = r4.xyzw + r3.xyzw;
          } else {
            r4.xyz = r1.xyz;
            r4.w = 1;
            r3.xyzw = float4(0,0,0,0);
          }
          r0.x = blurBokehOffsets[1].z * r0.y;
          r2.xy = blurBokehOffsets[1].xy * r0.yy + v1.xy;
          r5.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
          r0.z = max(r5.x, r5.y);
          r5.w = saturate(r0.z * r2.z + -r0.x);
          r0.x = cmp(0 < r5.w);
          if (r0.x != 0) {
            r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
            r5.xyz = r2.xyw * r5.www;
            r6.xyzw = r5.xyzw + r4.xyzw;
            r3.xyzw = r5.xyzw;
          } else {
            r6.xyzw = r4.xyzw + r3.xyzw;
          }
          r0.x = blurBokehOffsets[2].z * r0.y;
          r2.xy = blurBokehOffsets[2].xy * r0.yy + v1.xy;
          r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
          r0.z = max(r4.x, r4.y);
          r4.w = saturate(r0.z * r2.z + -r0.x);
          r0.x = cmp(0 < r4.w);
          if (r0.x != 0) {
            r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
            r4.xyz = r2.xyw * r4.www;
            r5.xyzw = r6.xyzw + r4.xyzw;
            r3.xyzw = r4.xyzw;
          } else {
            r5.xyzw = r6.xyzw + r3.xyzw;
          }
          r0.x = blurBokehOffsets[3].z * r0.y;
          r2.xy = blurBokehOffsets[3].xy * r0.yy + v1.xy;
          r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
          r0.z = max(r4.x, r4.y);
          r4.w = saturate(r0.z * r2.z + -r0.x);
          r0.x = cmp(0 < r4.w);
          if (r0.x != 0) {
            r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
            r4.xyz = r2.xyw * r4.www;
            r6.xyzw = r5.xyzw + r4.xyzw;
            r3.xyzw = r4.xyzw;
          } else {
            r6.xyzw = r5.xyzw + r3.xyzw;
          }
          r0.x = blurBokehOffsets[4].z * r0.y;
          r2.xy = blurBokehOffsets[4].xy * r0.yy + v1.xy;
          r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
          r0.z = max(r4.x, r4.y);
          r4.w = saturate(r0.z * r2.z + -r0.x);
          r0.x = cmp(0 < r4.w);
          if (r0.x != 0) {
            r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
            r4.xyz = r2.xyw * r4.www;
            r5.xyzw = r6.xyzw + r4.xyzw;
            r3.xyzw = r4.xyzw;
          } else {
            r5.xyzw = r6.xyzw + r3.xyzw;
          }
          r0.x = blurBokehOffsets[5].z * r0.y;
          r2.xy = blurBokehOffsets[5].xy * r0.yy + v1.xy;
          r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
          r0.z = max(r4.x, r4.y);
          r4.w = saturate(r0.z * r2.z + -r0.x);
          r0.x = cmp(0 < r4.w);
          if (r0.x != 0) {
            r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
            r4.xyz = r2.xyw * r4.www;
            r6.xyzw = r5.xyzw + r4.xyzw;
            r3.xyzw = r4.xyzw;
          } else {
            r6.xyzw = r5.xyzw + r3.xyzw;
          }
          r0.x = blurBokehOffsets[6].z * r0.y;
          r2.xy = blurBokehOffsets[6].xy * r0.yy + v1.xy;
          r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
          r0.z = max(r4.x, r4.y);
          r4.w = saturate(r0.z * r2.z + -r0.x);
          r0.x = cmp(0 < r4.w);
          if (r0.x != 0) {
            r2.xyw = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
            r4.xyz = r2.xyw * r4.www;
            r5.xyzw = r6.xyzw + r4.xyzw;
            r3.xyzw = r4.xyzw;
          } else {
            r5.xyzw = r6.xyzw + r3.xyzw;
          }
          r0.x = blurBokehOffsets[7].z * r0.y;
          r2.xy = blurBokehOffsets[7].xy * r0.yy + v1.xy;
          r4.xy = srcCoCTex.SampleLevel(pointSampler_s, r2.xy, 0).xy;
          r0.z = max(r4.x, r4.y);
          r4.w = saturate(r0.z * r2.z + -r0.x);
          r0.x = cmp(0 < r4.w);
          if (r0.x != 0) {
            r2.xyz = srcColorTex.SampleLevel(linearSampler_s, r2.xy, 0).xyz;
            r4.xyz = r2.xyz * r4.www;
            r2.xyzw = r5.xyzw + r4.xyzw;
          } else {
            r2.xyzw = r5.xyzw + r3.xyzw;
          }
        } else {
          r0.x = cmp(r0.w < 21);
          if (r0.x != 0) {
            r0.x = blurBokehOffsets[0].z * r0.y;
            r0.zw = blurBokehOffsets[0].xy * r0.yy + v1.xy;
            r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.y);
            r3.y = 0.5 * CoCParam0.w;
            r4.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r4.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r4.xyz = r0.xzw * r4.www;
              r5.xyz = r1.xyz;
              r5.w = 1;
              r5.xyzw = r5.xyzw + r4.xyzw;
            } else {
              r5.xyz = r1.xyz;
              r5.w = 1;
              r4.xyzw = float4(0,0,0,0);
            }
            r0.x = blurBokehOffsets[1].z * r0.y;
            r0.zw = blurBokehOffsets[1].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r6.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r6.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r6.xyz = r0.xzw * r6.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r6.xyzw;
            } else {
              r7.xyzw = r5.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[2].z * r0.y;
            r0.zw = blurBokehOffsets[2].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[3].z * r0.y;
            r0.zw = blurBokehOffsets[3].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[4].z * r0.y;
            r0.zw = blurBokehOffsets[4].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[5].z * r0.y;
            r0.zw = blurBokehOffsets[5].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[6].z * r0.y;
            r0.zw = blurBokehOffsets[6].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[7].z * r0.y;
            r0.zw = blurBokehOffsets[7].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[8].z * r0.y;
            r0.zw = blurBokehOffsets[8].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[9].z * r0.y;
            r0.zw = blurBokehOffsets[9].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[10].z * r0.y;
            r0.zw = blurBokehOffsets[10].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[11].z * r0.y;
            r0.zw = blurBokehOffsets[11].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[12].z * r0.y;
            r0.zw = blurBokehOffsets[12].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[13].z * r0.y;
            r0.zw = blurBokehOffsets[13].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[14].z * r0.y;
            r0.zw = blurBokehOffsets[14].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[15].z * r0.y;
            r0.zw = blurBokehOffsets[15].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[16].z * r0.y;
            r0.zw = blurBokehOffsets[16].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[17].z * r0.y;
            r0.zw = blurBokehOffsets[17].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[18].z * r0.y;
            r0.zw = blurBokehOffsets[18].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[19].z * r0.y;
            r0.zw = blurBokehOffsets[19].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[20].z * r0.y;
            r0.zw = blurBokehOffsets[20].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[21].z * r0.y;
            r0.zw = blurBokehOffsets[21].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[22].z * r0.y;
            r0.zw = blurBokehOffsets[22].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[23].z * r0.y;
            r0.zw = blurBokehOffsets[23].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r3.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r3.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r3.xyz = r0.xzw * r3.www;
              r2.xyzw = r6.xyzw + r3.xyzw;
            } else {
              r2.xyzw = r6.xyzw + r4.xyzw;
            }
          } else {
            r0.x = blurBokehOffsets[0].z * r0.y;
            r0.zw = blurBokehOffsets[0].xy * r0.yy + v1.xy;
            r3.xy = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.y);
            r3.y = 0.5 * CoCParam0.w;
            r4.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r4.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r4.xyz = r0.xzw * r4.www;
              r5.xyz = r1.xyz;
              r5.w = 1;
              r5.xyzw = r5.xyzw + r4.xyzw;
            } else {
              r5.xyz = r1.xyz;
              r5.w = 1;
              r4.xyzw = float4(0,0,0,0);
            }
            r0.x = blurBokehOffsets[1].z * r0.y;
            r0.zw = blurBokehOffsets[1].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r6.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r6.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r6.xyz = r0.xzw * r6.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r6.xyzw;
            } else {
              r7.xyzw = r5.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[2].z * r0.y;
            r0.zw = blurBokehOffsets[2].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[3].z * r0.y;
            r0.zw = blurBokehOffsets[3].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[4].z * r0.y;
            r0.zw = blurBokehOffsets[4].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[5].z * r0.y;
            r0.zw = blurBokehOffsets[5].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[6].z * r0.y;
            r0.zw = blurBokehOffsets[6].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[7].z * r0.y;
            r0.zw = blurBokehOffsets[7].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[8].z * r0.y;
            r0.zw = blurBokehOffsets[8].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[9].z * r0.y;
            r0.zw = blurBokehOffsets[9].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[10].z * r0.y;
            r0.zw = blurBokehOffsets[10].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[11].z * r0.y;
            r0.zw = blurBokehOffsets[11].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[12].z * r0.y;
            r0.zw = blurBokehOffsets[12].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[13].z * r0.y;
            r0.zw = blurBokehOffsets[13].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[14].z * r0.y;
            r0.zw = blurBokehOffsets[14].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[15].z * r0.y;
            r0.zw = blurBokehOffsets[15].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[16].z * r0.y;
            r0.zw = blurBokehOffsets[16].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[17].z * r0.y;
            r0.zw = blurBokehOffsets[17].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[18].z * r0.y;
            r0.zw = blurBokehOffsets[18].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[19].z * r0.y;
            r0.zw = blurBokehOffsets[19].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[20].z * r0.y;
            r0.zw = blurBokehOffsets[20].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[21].z * r0.y;
            r0.zw = blurBokehOffsets[21].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[22].z * r0.y;
            r0.zw = blurBokehOffsets[22].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[23].z * r0.y;
            r0.zw = blurBokehOffsets[23].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[24].z * r0.y;
            r0.zw = blurBokehOffsets[24].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[25].z * r0.y;
            r0.zw = blurBokehOffsets[25].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[26].z * r0.y;
            r0.zw = blurBokehOffsets[26].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[27].z * r0.y;
            r0.zw = blurBokehOffsets[27].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[28].z * r0.y;
            r0.zw = blurBokehOffsets[28].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[29].z * r0.y;
            r0.zw = blurBokehOffsets[29].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[30].z * r0.y;
            r0.zw = blurBokehOffsets[30].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[31].z * r0.y;
            r0.zw = blurBokehOffsets[31].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[32].z * r0.y;
            r0.zw = blurBokehOffsets[32].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[33].z * r0.y;
            r0.zw = blurBokehOffsets[33].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[34].z * r0.y;
            r0.zw = blurBokehOffsets[34].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[35].z * r0.y;
            r0.zw = blurBokehOffsets[35].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[36].z * r0.y;
            r0.zw = blurBokehOffsets[36].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[37].z * r0.y;
            r0.zw = blurBokehOffsets[37].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[38].z * r0.y;
            r0.zw = blurBokehOffsets[38].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[39].z * r0.y;
            r0.zw = blurBokehOffsets[39].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[40].z * r0.y;
            r0.zw = blurBokehOffsets[40].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[41].z * r0.y;
            r0.zw = blurBokehOffsets[41].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[42].z * r0.y;
            r0.zw = blurBokehOffsets[42].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[43].z * r0.y;
            r0.zw = blurBokehOffsets[43].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[44].z * r0.y;
            r0.zw = blurBokehOffsets[44].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[45].z * r0.y;
            r0.zw = blurBokehOffsets[45].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r7.xyzw = r6.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r7.xyzw = r6.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[46].z * r0.y;
            r0.zw = blurBokehOffsets[46].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.zw, 0).xy;
            r3.x = max(r3.x, r3.z);
            r5.w = saturate(r3.x * r3.y + -r0.x);
            r0.x = cmp(0 < r5.w);
            if (r0.x != 0) {
              r0.xzw = srcColorTex.SampleLevel(linearSampler_s, r0.zw, 0).xyz;
              r5.xyz = r0.xzw * r5.www;
              r6.xyzw = r7.xyzw + r5.xyzw;
              r4.xyzw = r5.xyzw;
            } else {
              r6.xyzw = r7.xyzw + r4.xyzw;
            }
            r0.x = blurBokehOffsets[47].z * r0.y;
            r0.yz = blurBokehOffsets[47].xy * r0.yy + v1.xy;
            r3.xz = srcCoCTex.SampleLevel(pointSampler_s, r0.yz, 0).xy;
            r0.w = max(r3.x, r3.z);
            r3.w = saturate(r0.w * r3.y + -r0.x);
            r0.x = cmp(0 < r3.w);
            if (r0.x != 0) {
              r0.xyz = srcColorTex.SampleLevel(linearSampler_s, r0.yz, 0).xyz;
              r3.xyz = r0.xyz * r3.www;
              r2.xyzw = r6.xyzw + r3.xyzw;
            } else {
              r2.xyzw = r6.xyzw + r4.xyzw;
            }
          }
        }
        r1.xyz = r2.xyz / r2.www;
      }
    }
  }
  o0.xyzw = r1.xyzw;
  return;
}