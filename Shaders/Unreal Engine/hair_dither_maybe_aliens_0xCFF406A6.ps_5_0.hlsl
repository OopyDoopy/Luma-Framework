// ---- Created with 3Dmigoto v1.4.1 on Thu Dec 18 13:26:47 2025
Texture2D<float4> t6 : register(t6);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[10];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[21];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[189];
}




// 3Dmigoto declarations
#define cmp -


void main(
  linear centroid float4 v0 : TEXCOORD10,
  linear centroid float4 v1 : TEXCOORD11,
  float2 v2 : TEXCOORD0,
  float4 v3 : SV_Position0,
  uint v4 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float4 o3 : SV_Target3,
  out float4 o4 : SV_Target4,
  out float oDepthLE : SV_DepthLessEqual)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.zxy * v0.yzx;
  r0.xyz = v1.yzx * v0.zxy + -r0.xyz;
  r0.xyz = v1.www * r0.xyz;
  r1.xy = -cb0[129].xy + v3.xy;
  r1.xy = r1.xy * cb0[130].zw + float2(-0.5,-0.5);
  r1.xy = v3.ww * r1.xy;
  r1.zw = v3.zw;
  r2.xyw = float3(2,-2,1);
  r2.z = v3.w;
  r3.xyzw = r2.xyzw * r1.xyzw;
  r4.xyzw = cb0[45].xyzw * v3.yyyy;
  r4.xyzw = v3.xxxx * cb0[44].xyzw + r4.xyzw;
  r4.xyzw = v3.zzzz * cb0[46].xyzw + r4.xyzw;
  r4.xyzw = cb0[47].xyzw + r4.xyzw;
  r1.xyz = r4.xyz / r4.www;
  r0.w = dot(-r1.xyz, -r1.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = -r1.xyz * r0.www;
  r0.w = cb1[4].w * cb0[140].w;
  r4.x = v4.x ? 1 : -1;
  r0.w = r4.x * r0.w;
  r4.xy = t3.Sample(s0_s, v2.xy).xy;
  r5.xy = r4.xy + r4.xy;
  r4.xy = r4.xy * float2(2,2) + float2(-1,-1);
  r4.x = dot(r4.xy, r4.xy);
  r4.x = 1 + -r4.x;
  r4.x = max(0, r4.x);
  r5.z = sqrt(r4.x);
  r4.xyz = float3(-1,-1,-1) + r5.xyz;
  r4.xyz = cb2[6].xxx * r4.xyz + float3(0,0,1);
  r4.xyz = r4.xyz * cb0[137].www + cb0[137].xyz;
  r4.w = dot(r4.xyz, r4.xyz);
  r4.w = rsqrt(r4.w);
  r4.xyz = r4.xyz * r4.www;
  r0.xyz = r4.yyy * r0.xyz;
  r0.xyz = r4.xxx * v0.xyz + r0.xyz;
  r0.xyz = r4.zzz * v1.xyz + r0.xyz;
  r4.x = dot(r0.xyz, r0.xyz);
  r4.x = rsqrt(r4.x);
  r0.xyz = r4.xxx * r0.xyz;
  r4.xyz = r0.xyz * r0.www;
  r5.xyz = cb2[6].yyy * cb2[1].xyz;
  r0.z = t4.Sample(s0_s, v2.xy).x;
  r0.z = saturate(cb2[6].z * r0.z);
  r0.z = max(9.99999997e-07, r0.z);
  r0.z = log2(r0.z);
  r0.z = cb2[6].w * r0.z;
  r0.z = exp2(r0.z);
  r6.xyz = -cb2[5].xyz + cb2[4].xyz;
  r6.xyz = r0.zzz * r6.xyz + cb2[5].xyz;
  r7.xyz = t5.SampleBias(s0_s, v2.xy, cb2[7].x).yzw;
  r6.xyz = r7.xxx * r6.xyz;
  r7.xw = cb2[7].yy * v2.xy;
  r0.z = t6.Sample(s0_s, r7.xw).x;
  r6.xyz = r6.xyz * r0.zzz + r6.xyz;
  r6.xyz = cb2[7].zzz * r6.xyz;
  r6.xyz = max(float3(0.00100000005,0.00100000005,0.00100000005), r6.xyz);
  r6.xyz = min(float3(0.999000013,0.999000013,0.999000013), r6.xyz);
  r7.xw = r1.ww * r2.ww + float2(-549,-350);
  r7.xw = saturate(float2(0.0199999996,0.00111111114) * r7.xw);
  r0.z = cb2[8].x + -cb2[7].w;
  r8.x = saturate(r7.x * r0.z + cb2[7].w);
  r0.z = max(9.99999997e-07, r7.y);
  r4.w = r0.z * r0.z;
  r5.w = 3 + -cb2[8].w;
  r5.w = r7.w * r5.w + cb2[8].w;
  r6.w = dot(r2.xyz, v1.xyz);
  r6.w = 1.5 * abs(r6.w);
  r7.x = cb2[9].y + -cb2[9].z;
  r6.w = saturate(r6.w * r7.x + cb2[9].z);
  r7.x = 1 + -r5.w;
  r5.w = r6.w * r7.x + r5.w;
  r0.z = -r0.z * r0.z + 1;
  r0.z = r5.w * r0.z + r4.w;
  r4.w = 0.5 + -r7.y;
  r4.w = r4.w * cb2[9].w + r3.w;
  r4.w = r3.z / r4.w;
  r4.w = min(v3.z, r4.w);
  r3.z = -r4.w * r3.w + r3.z;
  r3.z = r3.z / r4.w;
  r1.w = r1.w * r2.w + r3.z;
  r2.w = v3.y * 2 + v3.x;
  r2.w = cb0[151].x + r2.w;
  r2.w = -1.5 + r2.w;
  r2.w = 0.200000003 * r2.w;
  r2.w = frac(r2.w);
  r3.w = dot(float2(2.4084506,3.2535212), v3.xy);
  r3.w = frac(r3.w);
  r2.w = r2.w * 5 + r3.w;
  r2.w = 0.166666672 * r2.w;
  r0.z = r0.z * r7.z + r2.w;
  r0.z = -0.833299994 + r0.z;
  r0.z = cmp(r0.z < 0);
  if (r0.z != 0) discard;
  r7.xy = saturate(cb2[8].yz);
  r8.z = r7.y * cb0[138].y + cb0[138].x;
  r0.z = cmp(0 < cb1[20].x);
  r2.w = cmp(0 < cb0[188].w);
  r0.z = r0.z ? r2.w : 0;
  r3.xy = r3.xy / r1.ww;
  r3.xy = r3.xy * cb0[66].xy + cb0[66].wz;
  r9.xyzw = t0.SampleLevel(s1_s, r3.xy, 0).xyzw;
  r10.xyzw = t1.SampleLevel(s1_s, r3.xy, 0).xyzw;
  r3.xyw = t2.SampleLevel(s1_s, r3.xy, 0).xyz;
  r7.yzw = r10.xyz * float3(2,2,2) + float3(-1.00392163,-1.00392163,-1.00392163);
  r8.yw = float2(0.5,1) + -r9.ww;
  r1.w = saturate(5 * r8.w);
  r2.w = 1 + -r1.w;
  r2.w = max(r10.w, r2.w);
  r10.xyz = r7.yzw * r1.www;
  r10.xyz = r4.xyz * r2.www + r10.xyz;
  r11.xy = r0.xy * r0.ww + r7.yz;
  r11.z = r4.z;
  r0.x = dot(r11.xyz, r11.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyw = r11.xyz * r0.xxx + -r10.xyz;
  r0.xyw = r3.www * r0.xyw + r10.xyz;
  r8.y = saturate(r8.y);
  r1.w = r8.y + r8.y;
  r3.xy = r3.xy + -r8.zx;
  r7.yzw = r9.xyz + -r6.xyz;
  r7.yzw = r1.www * r7.yzw + r6.xyz;
  r3.xy = r1.ww * r3.yx + r8.xz;
  r9.xyz = r0.zzz ? r0.xyw : r4.xyz;
  r0.xyw = r0.zzz ? r7.yzw : r6.xyz;
  r3.xy = r0.zz ? r3.xy : r8.xz;
  r0.z = 0.0799999982 * r7.x;
  r4.xyz = -r7.xxx * float3(0.0799999982,0.0799999982,0.0799999982) + r0.xyw;
  r4.xyz = r3.xxx * r4.xyz + r0.zzz;
  r6.xyz = -r0.xyw * r3.xxx + r0.xyw;
  r6.xyz = r6.xyz * cb0[135].www + cb0[135].xyz;
  r4.xyz = r4.xyz * cb0[136].www + cb0[136].xyz;
  r0.z = cmp(0 != cb0[177].w);
  r7.yzw = r4.xyz * float3(0.449999988,0.449999988,0.449999988) + r6.xyz;
  r6.xyz = r0.zzz ? r7.yzw : r6.xyz;
  r4.xyz = r0.zzz ? float3(0,0,0) : r4.xyz;
  r0.z = dot(r4.xyz, float3(0.300000012,0.589999974,0.109999999));
  r1.w = r0.z * 2.04040003 + -0.332399994;
  r1.w = r0.z * -4.79510021 + r1.w;
  r0.z = r0.z * 2.75519991 + r1.w;
  r0.z = 1.33200002 + r0.z;
  o3.w = max(1, r0.z);
  r9.w = 1;
  r8.x = dot(cb0[181].xyzw, r9.xyzw);
  r8.y = dot(cb0[182].xyzw, r9.xyzw);
  r8.z = dot(cb0[183].xyzw, r9.xyzw);
  r10.xyzw = r9.xyzz * r9.yzzx;
  r11.x = dot(cb0[184].xyzw, r10.xyzw);
  r11.y = dot(cb0[185].xyzw, r10.xyzw);
  r11.z = dot(cb0[186].xyzw, r10.xyzw);
  r0.z = r9.y * r9.y;
  r0.z = r9.x * r9.x + -r0.z;
  r7.yzw = r11.xyz + r8.xyz;
  r7.yzw = cb0[187].xyz * r0.zzz + r7.yzw;
  r7.yzw = max(float3(0,0,0), r7.yzw);
  r7.yzw = cb0[180].xyz * r7.yzw;
  r7.yzw = r7.yzw * r6.xyz;
  r8.xyz = r0.xyw * float3(2.04040003,2.04040003,2.04040003) + float3(-0.332399994,-0.332399994,-0.332399994);
  r8.xyz = r0.xyw * float3(-4.79510021,-4.79510021,-4.79510021) + r8.xyz;
  r8.xyz = r0.xyw * float3(2.75519991,2.75519991,2.75519991) + r8.xyz;
  r8.xyz = float3(1.33200002,1.33200002,1.33200002) + r8.xyz;
  r8.xyz = max(float3(1,1,1), r8.xyz);
  r7.yzw = r8.xyz * r7.yzw;
  r4.xyz = r4.xyz * float3(0.449999988,0.449999988,0.449999988) + r6.xyz;
  r5.xyz = max(float3(0,0,0), r5.xyz);
  r0.z = cmp(0 < cb0[139].x);
  if (r0.z != 0) {
    r1.xyz = -cb0[70].xyz + r1.xyz;
    r1.xyz = r2.xyz * r3.zzz + r1.xyz;
    r2.xyz = -cb1[5].xyz + r1.xyz;
    r6.xyz = float3(1,1,1) + cb1[19].xyz;
    r2.xyz = cmp(r6.xyz < abs(r2.xyz));
    r0.z = (int)r2.y | (int)r2.x;
    r0.z = (int)r2.z | (int)r0.z;
    r1.x = dot(r1.xyz, float3(0.577000022,0.577000022,0.577000022));
    r1.x = 0.00200000009 * r1.x;
    r1.x = frac(r1.x);
    r1.x = cmp(0.5 < r1.x);
    r1.xyz = r1.xxx ? float3(0,1,1) : float3(1,1,0);
    r5.xyz = r0.zzz ? r1.xyz : r5.xyz;
  }
  r1.xyz = cb0[144].yyy * r4.xyz + r7.yzw;
  r1.xyz = r1.xyz + r5.xyz;
  o1.xyz = r9.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.xyz = cb0[134].yyy * r1.xyz;
  o0.w = 0;
  o1.w = cb1[20].y;
  o2.y = r7.x;
  o2.w = 0.694117665;
  o2.xz = r3.xy;
  o3.xyz = r0.xyw;
  o4.xyzw = float4(0,0,0,0);
  oDepthLE = r4.w;
  return;
}