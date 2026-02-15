// ---- Created with 3Dmigoto v1.4.1 on Wed Dec 17 12:44:57 2025
Texture2D<float4> t6 : register(t6);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[144];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[5];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = cb1[131].zw * v0.xy;
  r0.zw = t3.SampleLevel(s0_s, r0.xy, 0).zw;
  r0.w = 255 * r0.w;
  r0.w = round(r0.w);
  r0.w = (uint)r0.w;
  r1.x = (int)r0.w & 15;
  r1.xy = cmp((int2)r1.xx == int2(4,0));
  if (r1.x != 0) {
    r1.xz = t4.SampleLevel(s0_s, r0.xy, 0).xy;
    r0.w = (int)r0.w & 16;
    r1.xz = r0.ww ? float2(0,0) : r1.xz;
    r0.w = r1.z + -r0.z;
    r0.z = r1.x * r0.w + r0.z;
  }
  r0.w = r0.z * cb0[1].y + 2;
  r0.w = min(1, r0.w);
  r1.x = cmp(0 >= r0.w);
  r1.x = (int)r1.y | (int)r1.x;
  if (r1.x == 0) {
    r1.xy = -cb1[129].xy + v0.xy;
    r1.xy = cb1[130].zw * r1.xy;
    r1.xy = r1.xy + r1.xy;
    r2.xyz = t2.SampleLevel(s0_s, r0.xy, 0).xyz;
    r0.x = t0.SampleLevel(s0_s, r0.xy, 0).x;
    r0.y = r0.x * cb1[65].x + cb1[65].y;
    r0.x = r0.x * cb1[65].z + -cb1[65].w;
    r0.x = 1 / r0.x;
    r0.x = r0.y + r0.x;
    r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r0.y = dot(r2.xyz, r2.xyz);
    r0.y = rsqrt(r0.y);
    r2.xyz = r2.xyz * r0.yyy;
    r1.xy = r1.xy * float2(1,-1) + float2(-1,1);
    r1.xy = r1.xy * r0.xx;
    r1.yzw = cb1[53].xyz * r1.yyy;
    r1.xyz = r1.xxx * cb1[52].xyz + r1.yzw;
    r1.xyz = r0.xxx * cb1[54].xyz + r1.xyz;
    r1.xyz = cb1[55].xyz + r1.xyz;
    r3.xyz = cb1[68].xyz + -r1.xyz;
    r0.y = dot(r3.xyz, r3.xyz);
    r0.y = rsqrt(r0.y);
    r3.xyz = r3.xyz * r0.yyy;
    r0.y = asuint(cb1[143].y);
    r4.xy = r0.yy * float2(32.6650009,11.8149996) + v0.xy;
    r0.y = dot(r4.xy, float2(0.0671105608,0.00583714992));
    r0.y = frac(r0.y);
    r0.y = 52.9829178 * r0.y;
    r0.y = frac(r0.y);
    r0.y = -0.5 + r0.y;
    r1.w = dot(-r3.xyz, r2.xyz);
    r1.w = r1.w + r1.w;
    r2.xyz = r2.xyz * -r1.www + -r3.xyz;
    r3.xyzw = cb1[1].xyzw * r1.yyyy;
    r3.xyzw = r1.xxxx * cb1[0].xyzw + r3.xyzw;
    r3.xyzw = r1.zzzz * cb1[2].xyzw + r3.xyzw;
    r3.xyzw = cb1[3].xyzw + r3.xyzw;
    r1.xyz = r2.xyz * r0.xxx + r1.xyz;
    r2.xyzw = cb1[1].xyzw * r1.yyyy;
    r2.xyzw = r1.xxxx * cb1[0].xyzw + r2.xyzw;
    r1.xyzw = r1.zzzz * cb1[2].xyzw + r2.xyzw;
    r1.xyzw = cb1[3].xyzw + r1.xyzw;
    r2.x = rcp(r3.w);
    r2.xyz = r3.xyz * r2.xxx;
    r1.w = rcp(r1.w);
    r3.xy = r0.xx * cb1[30].zw + r3.zw;
    r0.x = rcp(r3.y);
    r1.xyz = r1.xyz * r1.www + -r2.xyz;
    r1.w = dot(r1.xy, r1.xy);
    r1.w = sqrt(r1.w);
    r2.w = 0.5 * r1.w;
    r3.yz = r2.xy * r2.ww + r1.xy;
    r3.yz = -r1.ww * float2(0.5,0.5) + abs(r3.yz);
    r3.yz = max(float2(0,0), r3.yz);
    r3.yz = r3.yz / abs(r1.xy);
    r3.yz = float2(1,1) + -r3.yz;
    r1.w = min(r3.y, r3.z);
    r1.w = r1.w / r2.w;
    r1.xyz = r1.xyz * r1.www;
    r0.x = -r3.x * r0.x + r2.z;
    r0.x = 4 * r0.x;
    r0.x = max(abs(r1.z), r0.x);
    r3.xy = r2.xy * float2(0.5,-0.5) + float2(0.5,0.5);
    r2.xy = cb0[3].xy * r3.xy;
    r1.xy = cb0[3].xy * r1.xy;
    r1.w = 0.0625 * r0.x;
    r1.xyz = float3(0.03125,-0.03125,0.0625) * r1.xyz;
    r2.xyz = r1.xyz * r0.yyy + r2.xyz;
    r0.y = 1;
    r3.xyz = float3(0,0,0);
    r2.w = 0;
    r4.xw = float2(0,0);
    r5.xw = float2(0,0);
    r6.xy = float2(0,0);
    while (true) {
      r6.z = cmp((uint)r6.y >= 16);
      if (r6.z != 0) break;
      r6.z = (uint)r6.y;
      r7.xyzw = float4(1,2,3,4) + r6.zzzz;
      r8.xyzw = r7.xxxy * r1.xyzz + r2.xyzz;
      r9.xyzw = r7.yyzz * r1.xyxy + r2.xyxy;
      r7.xyzw = r7.wwzw * r1.xyzz + r2.xyzz;
      r6.z = r0.z * 0.5 + r0.y;
      r6.w = r0.z * 0.5 + r6.z;
      r10.x = t6.SampleLevel(s2_s, r8.xy, r0.y).x;
      r10.y = t6.SampleLevel(s2_s, r9.xy, r0.y).x;
      r10.z = t6.SampleLevel(s2_s, r9.zw, r6.z).x;
      r10.w = t6.SampleLevel(s2_s, r7.xy, r6.z).x;
      r7.xy = r8.zw;
      r7.xyzw = r7.xyzw + -r10.xyzw;
      r8.xyzw = r0.xxxx * float4(0.0625,0.0625,0.0625,0.0625) + r7.xyzw;
      r8.xyzw = cmp(abs(r8.xyzw) < r1.wwww);
      r9.xy = (int2)r8.zw | (int2)r8.xy;
      r6.z = (int)r9.y | (int)r9.x;
      if (r6.z != 0) {
        r5.x = r7.x;
        r3.xyz = r7.yzw;
        r2.w = r8.x;
        r4.w = r8.y;
        r5.w = r8.z;
        r6.x = -1;
        break;
      }
      r4.x = r7.w;
      r6.y = (int)r6.y + 4;
      r0.y = r6.w;
      r5.x = r7.x;
      r3.xyz = r7.yzw;
      r2.w = r8.x;
      r4.w = r8.y;
      r5.w = r8.z;
      r6.xy = r6.zy;
    }
    if (r6.x != 0) {
      r3.w = 2;
      r0.xy = r3.yz;
      r0.z = 3;
      r0.xyz = r5.www ? r3.xyw : r0.xyz;
      r5.y = r3.x;
      r5.z = 1;
      r0.xyz = r4.www ? r5.xyz : r0.xyz;
      r4.y = r5.x;
      r4.z = 0;
      r0.xyz = r2.www ? r4.xyz : r0.xyz;
      r1.w = (uint)r6.y;
      r0.z = r1.w + r0.z;
      r0.y = r0.x + -r0.y;
      r0.x = saturate(r0.x / r0.y);
      r0.x = r0.z + r0.x;
      r0.xyz = r1.xyz * r0.xxx + r2.xyz;
      r0.xy = cb0[3].zw * r0.xy;
      r0.xy = r0.xy * float2(2,-2) + float2(-1,1);
      r1.xy = cb1[66].xy * r0.xy;
      r0.xy = r0.xy * cb1[66].xy + cb1[66].wz;
      r1.xy = r1.xy / cb1[66].xy;
      r2.xyz = cb1[123].xyw * r1.yyy;
      r2.xyz = r1.xxx * cb1[122].xyw + r2.xyz;
      r2.xyz = r0.zzz * cb1[124].xyw + r2.xyz;
      r2.xyz = cb1[125].xyw + r2.xyz;
      r1.zw = r2.xy / r2.zz;
      r0.xy = t1.SampleLevel(s0_s, r0.xy, 0).xy;
      r0.z = cmp(0 < r0.x);
      r0.xy = r0.xy * float2(4.00801611,4.00801611) + float2(-2.00397754,-2.00397754);
      r0.xy = r1.xy + -r0.xy;
      r0.xy = r0.zz ? r0.xy : r1.zw;
      r1.zw = r0.xy * cb0[4].xy + cb0[4].zw;
      r1.xy = saturate(abs(r1.xy) * float2(5,5) + float2(-4,-4));
      r0.z = dot(r1.xy, r1.xy);
      r0.z = 1 + -r0.z;
      r0.xy = saturate(abs(r0.xy) * float2(5,5) + float2(-4,-4));
      r0.x = dot(r0.xy, r0.xy);
      r0.x = 1 + -r0.x;
      r0.xz = max(float2(0,0), r0.xz);
      r0.x = min(r0.z, r0.x);
      r1.xyz = t5.SampleLevel(s1_s, r1.zw, 0).xyz;
      r1.xyz = min(float3(0,0,0), -r1.xyz);
      r1.xyz = -r1.xyz;
      r1.w = 1;
      r1.xyzw = r1.xyzw * r0.xxxx;
    } else {
      r1.xyzw = float4(0,0,0,0);
    }
    r0.xyzw = r1.xyzw * r0.wwww;
    r0.xyzw = cb0[1].xxxx * r0.xyzw;
    o0.xyz = cb0[2].xxx * r0.xyz;
    o0.w = r0.w;
  } else {
    o0.xyzw = float4(0,0,0,0);
  }
  return;
}