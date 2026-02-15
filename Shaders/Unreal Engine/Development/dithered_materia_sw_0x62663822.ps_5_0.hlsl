// ---- Created with 3Dmigoto v1.4.1 on Thu Dec 18 13:26:47 2025
Texture2D<float4> t19 : register(t19);

Texture2D<float4> t18 : register(t18);

Texture2D<float4> t17 : register(t17);

Texture2D<float4> t16 : register(t16);

Texture2D<float4> t15 : register(t15);

Texture2D<float4> t14 : register(t14);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t11 : register(t11);

Texture2D<float4> t10 : register(t10);

Texture2D<float4> t9 : register(t9);

Texture2D<float4> t8 : register(t8);

Texture2D<float4> t7 : register(t7);

Texture2D<float4> t6 : register(t6);

Texture2D<float4> t5 : register(t5);

Texture3D<float4> t4 : register(t4);

Texture3D<float4> t3 : register(t3);

Texture3D<float4> t2 : register(t2);

Texture3D<float4> t1 : register(t1);

Texture3D<uint4> t0 : register(t0);

SamplerState s8_s : register(s8);

SamplerState s7_s : register(s7);

SamplerState s6_s : register(s6);

SamplerState s5_s : register(s5);

SamplerState s4_s : register(s4);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb3 : register(b3)
{
  float4 cb3[14];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[20];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[184];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[31];
}




// 3Dmigoto declarations
#define cmp -


void main(
  linear centroid float4 v0 : TEXCOORD10,
  linear centroid float4 v1 : TEXCOORD11,
  float4 v2 : COLOR1,
  float4 v3 : TEXCOORD0,
  float4 v4 : VELOCITY_PREV_POS0,
  float4 v5 : SV_Position0,
  uint v6 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float4 o3 : SV_Target3,
  out float4 o4 : SV_Target4,
  out float4 o5 : SV_Target5)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.zxy * v0.yzx;
  r0.xyz = v1.yzx * v0.zxy + -r0.xyz;
  r0.xyz = v1.www * r0.xyz;
  r1.xy = -cb1[121].xy + v5.xy;
  r1.xy = r1.xy * cb1[122].zw + float2(-0.5,-0.5);
  r1.xy = v5.ww * r1.xy;
  r1.z = v5.w;
  r1.xyz = float3(2,-2,1) * r1.xyz;
  r2.xyzw = cb1[41].xyzw * v5.yyyy;
  r2.xyzw = v5.xxxx * cb1[40].xyzw + r2.xyzw;
  r2.xyzw = v5.zzzz * cb1[42].xyzw + r2.xyzw;
  r2.xyzw = cb1[43].xyzw + r2.xyzw;
  r2.xyz = r2.xyz / r2.www;
  r2.xyz = -cb1[62].xyz + r2.xyz;
  r3.xyzw = cb3[9].xxzz * v3.xyxy;
  r4.xy = t9.Sample(s0_s, r3.xy).xy;
  r4.xy = r4.xy * float2(2,2) + float2(-1,-1);
  r4.xy = cb3[9].yy * r4.xy;
  r4.zw = t10.Sample(s0_s, r3.zw).xy;
  r4.zw = r4.zw * float2(2,2) + float2(-1,-1);
  r5.xyzw = t11.SampleBias(s4_s, v3.xy, cb1[134].x).xyzw;
  r6.xyzw = float4(1,1,1,1) + -r5.yxwz;
  r0.w = -r6.x * r6.y + 1;
  r1.w = 1 + -r0.w;
  r1.w = r1.w + r1.w;
  r5.xy = cb3[10].xx * r3.zw;
  r5.x = t12.Sample(s0_s, r5.xy).w;
  r5.y = 1 + -r5.x;
  r1.w = -r1.w * r5.y + 1;
  r5.x = dot(r0.ww, r5.xx);
  r0.w = cmp(r0.w >= 0.5);
  r0.w = r0.w ? r1.w : r5.x;
  r0.w = cb3[10].y * r0.w;
  r0.w = max(0, r0.w);
  r0.w = log2(r0.w);
  r0.w = cb3[10].z * r0.w;
  r0.w = exp2(r0.w);
  r0.w = min(1, r0.w);
  r4.zw = r4.zw * cb3[9].ww + -r4.xy;
  r4.xy = r0.ww * r4.zw + r4.xy;
  r4.zw = t13.SampleBias(s5_s, v3.xy, cb1[134].x).xy;
  r4.zw = r4.zw * float2(2,2) + float2(-1,-1);
  r4.xy = r4.zw * cb3[10].ww + r4.xy;
  r7.xyzw = float4(0.125,0.125,0.125,0.125) * v1.xzyz;
  r7.xyzw = r2.xzyz * float4(-0.0142857144,-0.0142857144,-0.0142857144,-0.0142857144) + r7.xyzw;
  r1.w = -1 + cb1[134].x;
  r8.xyz = t14.SampleLevel(s6_s, r7.xy, r1.w).xyz;
  r7.xyz = t14.SampleLevel(s6_s, r7.zw, r1.w).xyz;
  r7.xyz = r7.xyz + -r8.xyz;
  r7.xyz = abs(v1.xxx) * r7.xyz + r8.xyz;
  r5.xy = float2(0.0078125,0.0078125) * r2.xy;
  r8.xyz = t15.SampleLevel(s7_s, r5.xy, r1.w).xyz;
  r9.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r2.xyz;
  r10.xyz = r9.xyz;
  r1.w = 0;
  r4.w = 1;
  r5.x = 0;
  while (true) {
    r5.y = cmp((uint)r5.x >= 1);
    if (r5.y != 0) break;
    r5.y = dot(r10.xyz, float3(0.333333343,0.333333343,0.333333343));
    r11.xyz = r10.xyz + r5.yyy;
    r12.xyz = floor(r11.xyz);
    r13.xyz = float3(1,1,1) + r12.xyz;
    r11.xyz = -r12.xyz + r11.xyz;
    r5.y = max(r11.y, r11.z);
    r5.y = max(r11.x, r5.y);
    r6.x = min(r11.y, r11.z);
    r6.x = min(r11.x, r6.x);
    r14.xyz = cmp(r11.xyz == r5.yyy);
    r14.xyz = r14.xyz ? float3(1,1,1) : 0;
    r14.xyz = r14.xyz + r12.xyz;
    r11.xyz = cmp(r11.xyz != r6.xxx);
    r11.xyz = r11.xyz ? float3(1,1,1) : 0;
    r11.xyz = r12.xyz + r11.xyz;
    r6.xy = r12.zz * float2(17,89) + r12.xy;
    r6.xy = float2(0.5,0.5) + r6.xy;
    r6.xy = float2(0.0078125,0.0078125) * r6.xy;
    r15.xyz = t5.SampleLevel(s1_s, r6.xy, 0).xyz;
    r15.xyz = r15.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xy = r13.zz * float2(17,89) + r13.xy;
    r6.xy = float2(0.5,0.5) + r6.xy;
    r6.xy = float2(0.0078125,0.0078125) * r6.xy;
    r16.xyz = t5.SampleLevel(s1_s, r6.xy, 0).xyz;
    r16.xyz = r16.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xy = r14.zz * float2(17,89) + r14.xy;
    r6.xy = float2(0.5,0.5) + r6.xy;
    r6.xy = float2(0.0078125,0.0078125) * r6.xy;
    r17.xyz = t5.SampleLevel(s1_s, r6.xy, 0).xyz;
    r17.xyz = r17.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xy = r11.zz * float2(17,89) + r11.xy;
    r6.xy = float2(0.5,0.5) + r6.xy;
    r6.xy = float2(0.0078125,0.0078125) * r6.xy;
    r18.xyz = t5.SampleLevel(s1_s, r6.xy, 0).xyz;
    r18.xyz = r18.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r5.y = dot(r12.xyz, float3(0.166666672,0.166666672,0.166666672));
    r12.xyz = r12.xyz + -r5.yyy;
    r5.y = dot(r13.xyz, float3(0.166666672,0.166666672,0.166666672));
    r13.xyz = r13.xyz + -r5.yyy;
    r5.y = dot(r14.xyz, float3(0.166666672,0.166666672,0.166666672));
    r14.xyz = r14.xyz + -r5.yyy;
    r5.y = dot(r11.xyz, float3(0.166666672,0.166666672,0.166666672));
    r11.xyz = r11.xyz + -r5.yyy;
    r12.xyz = -r12.xyz + r10.xyz;
    r5.y = dot(r12.xyz, r12.xyz);
    r5.y = 0.600000024 + -r5.y;
    r5.y = max(0, r5.y);
    r5.y = r5.y * r5.y;
    r5.y = r5.y * r5.y;
    r6.x = dot(r15.xyz, r12.xyz);
    r12.xyz = -r13.xyz + r10.xyz;
    r6.y = dot(r12.xyz, r12.xyz);
    r6.y = 0.600000024 + -r6.y;
    r6.y = max(0, r6.y);
    r6.y = r6.y * r6.y;
    r6.y = r6.y * r6.y;
    r7.w = dot(r16.xyz, r12.xyz);
    r6.y = r7.w * r6.y;
    r12.xyz = -r14.xyz + r10.xyz;
    r7.w = dot(r12.xyz, r12.xyz);
    r7.w = 0.600000024 + -r7.w;
    r7.w = max(0, r7.w);
    r7.w = r7.w * r7.w;
    r7.w = r7.w * r7.w;
    r8.w = dot(r17.xyz, r12.xyz);
    r11.xyz = -r11.xyz + r10.xyz;
    r9.w = dot(r11.xyz, r11.xyz);
    r9.w = 0.600000024 + -r9.w;
    r9.w = max(0, r9.w);
    r9.w = r9.w * r9.w;
    r9.w = r9.w * r9.w;
    r10.w = dot(r18.xyz, r11.xyz);
    r5.y = r6.x * r5.y + r6.y;
    r5.y = r8.w * r7.w + r5.y;
    r5.y = r10.w * r9.w + r5.y;
    r5.y = r5.y * r4.w;
    r1.w = r5.y * 32 + r1.w;
    r10.xyz = r10.xyz + r10.xyz;
    r4.w = 0.5 * r4.w;
    r5.x = (int)r5.x + 1;
  }
  r1.w = r1.w * 0.5 + 0.5;
  r1.w = r1.w * 0.75 + 0.25;
  r1.w = max(0, r1.w);
  r1.w = r1.w * r1.w;
  r8.xyz = float3(-0.5,-0.5,-1) + r8.xyz;
  r8.xyz = r1.www * r8.xyz + float3(0.5,0.5,1);
  r1.w = -0.800000012 + v1.z;
  r1.w = saturate(5 * r1.w);
  r8.xyz = r8.xyz + -r7.xyz;
  r7.xyz = r1.www * r8.xyz + r7.xyz;
  r2.w = 1;
  r1.w = dot(r2.yw, float2(4.3e-05,1.15719604));
  r4.w = dot(r2.xw, float2(4.3e-05,0.906120002));
  r2.w = dot(r2.zw, float2(-3.19999999e-05,-0.149491996));
  r5.x = saturate(r1.w * 0.5 + 0.5);
  r1.w = r4.w * 0.5 + 0.5;
  r5.y = saturate(1 + -r1.w);
  r1.w = t16.SampleLevel(s8_s, r5.xy, 0).x;
  r1.w = 1 + -r1.w;
  r2.w = -0.00499999989 + r2.w;
  r1.w = -r2.w + r1.w;
  r1.w = saturate(200 * r1.w);
  r7.xyz = r7.xyz * float3(2,2,2) + float3(-1,-1,-2);
  r7.xyz = r1.www * r7.xyz + float3(0,0,1);
  r4.z = 2.01250005;
  r8.xyz = float3(-1,-1,1) * r7.xyz;
  r1.w = dot(r4.xyz, r8.xyz);
  r7.xyz = float3(-2.01250005,-2.01250005,2.01250005) * r7.xyz;
  r4.xyz = r4.xyz * r1.www + -r7.xyz;
  r4.xyz = r4.xyz * cb1[128].www + cb1[128].xyz;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  r0.xyz = r4.yyy * r0.xyz;
  r0.xyz = r4.xxx * v0.xyz + r0.xyz;
  r0.xyz = r4.zzz * v1.xyz + r0.xyz;
  r1.w = dot(r0.xyz, r0.xyz);
  r1.w = rsqrt(r1.w);
  r0.xyz = r1.www * r0.xyz;
  r4.xyz = t17.Sample(s0_s, r3.xy).xyz;
  r7.xyz = cb3[5].xyz + r5.www;
  r7.xyz = r7.xyz * r6.zzz;
  r7.xyz = r7.xyz * cb3[11].xxx + -cb3[6].xyz;
  r5.xyw = r5.www * r7.xyz + cb3[6].xyz;
  r4.xyz = r5.xyw * r4.xyz;
  r5.xyw = t18.Sample(s0_s, r3.zw).xyz;
  r5.xyw = r5.xyw * cb3[8].xyz + -r4.xyz;
  r4.xyz = saturate(r0.www * r5.xyw + r4.xyz);
  r5.xyw = t19.Sample(s0_s, r3.xy).xyz;
  r3.xyz = t12.Sample(s0_s, r3.zw).xyz;
  r3.yz = r3.yz + -r5.yw;
  r1.w = cb3[11].y * r5.x;
  r2.w = r3.x * cb3[11].z + -r1.w;
  r1.w = r0.w * r2.w + r1.w;
  r1.w = 1 + -r1.w;
  r1.w = saturate(-r1.w * r6.z + 1);
  r3.xy = r0.ww * r3.yz + r5.yw;
  r0.w = cb3[13].x * r6.w + r5.z;
  r0.w = r0.w * r5.z;
  r0.w = saturate(r3.y * r0.w);
  r3.x = saturate(r3.x);
  r3.z = r1.w * cb1[129].y + cb1[129].x;
  r1.w = 7.99900007 * cb2[14].y;
  r1.w = (uint)r1.w;
  r1.w = (int)r1.w & 3;
  r5.xyz = r1.www ? float3(0,0,1) : v1.xyz;
  r1.w = cb1[182].x * cb1[180].x;
  r1.w = cb1[182].w * r1.w;
  r1.w = 1 / r1.w;
  r1.w = 0.5 * r1.w;
  r5.xyz = r5.xyz * r1.www + r2.xyz;
  r5.xyz = r5.xyz * cb1[180].xyz + cb1[181].xyz;
  r5.xyz = max(float3(0,0,0), r5.xyz);
  r5.xyz = min(float3(0.99000001,0.99000001,0.99000001), r5.xyz);
  r5.xyz = cb1[182].xyz * r5.xyz;
  r6.xyz = (int3)r5.xyz;
  r6.w = 0;
  r6.xyzw = t0.Load(r6.xyzw).xyzw;
  r6.xyzw = (uint4)r6.xyzw;
  r1.w = 1 + cb1[182].w;
  r5.xyz = r5.xyz / r6.www;
  r5.xyz = frac(r5.xyz);
  r5.xyz = cb1[182].www * r5.xyz;
  r5.xyz = r6.xyz * r1.www + r5.xyz;
  r5.xyz = float3(0.5,0.5,0.5) + r5.xyz;
  r5.xyz = cb1[183].xyz * r5.xyz;
  r1.w = cmp(0 < cb2[14].x);
  r2.w = cmp(0 < cb1[165].w);
  r1.w = r1.w ? r2.w : 0;
  r1.xy = r1.xy / r1.zz;
  r6.xy = r1.xy * cb1[58].xy + cb1[58].wz;
  r7.xyzw = t6.SampleLevel(s3_s, r6.xy, 0).xyzw;
  r8.xyzw = t7.SampleLevel(s3_s, r6.xy, 0).xyzw;
  r6.xyzw = t8.SampleLevel(s3_s, r6.xy, 0).xyzw;
  r8.xyz = r8.xyz * float3(2,2,2) + float3(-1.00392163,-1.00392163,-1.00392163);
  r8.xyz = r0.xyz * r8.www + r8.xyz;
  r9.xz = r3.xz * r6.ww + r6.xz;
  r9.y = r6.w * 0.5 + r6.y;
  r6.xyz = r4.xyz * r7.www + r7.xyz;
  r0.xyz = r1.www ? r8.xyz : r0.xyz;
  r4.xyz = r1.www ? r6.xyz : r4.xyz;
  r3.y = 0.5;
  r3.xyz = r1.www ? r9.xyz : r3.xyz;
  r1.zw = v4.xy / v4.ww;
  r1.xyzw = -cb1[118].xyzw + r1.xyzw;
  r1.xy = r1.xy + -r1.zw;
  r1.z = cmp(cb0[30].z != 0.000000);
  r6.xy = cb0[30].xy / v5.ww;
  r1.xy = r1.zz ? r6.xy : r1.xy;
  r1.xy = r1.xy * float2(0.249500006,0.249500006) + float2(0.499992371,0.499992371);
  o4.xy = v4.zz * r1.xy;
  o4.zw = float2(0,0);
  r1.x = 0.0799999982 * r3.y;
  r1.yzw = -r3.yyy * float3(0.0799999982,0.0799999982,0.0799999982) + r4.xyz;
  r1.xyz = r3.xxx * r1.yzw + r1.xxx;
  r6.xyz = -r4.xyz * r3.xxx + r4.xyz;
  r6.xyz = r6.xyz * cb1[126].www + cb1[126].xyz;
  r1.xyz = r1.xyz * cb1[127].www + cb1[127].xyz;
  r1.w = dot(r1.xyz, float3(0.300000012,0.589999974,0.109999999));
  r7.xyz = r1.www * float3(2.04040003,-4.79510021,2.75519991) + float3(-0.332399994,0.641700029,0.690299988);
  r1.w = r0.w * r7.x + r7.y;
  r1.w = r1.w * r0.w + r7.z;
  r1.w = r1.w * r0.w;
  r1.w = max(r1.w, r0.w);
  r7.xyz = t1.SampleLevel(s2_s, r5.xyz, 0).xyz;
  r8.xyzw = t2.SampleLevel(s2_s, r5.xyz, 0).xyzw;
  r8.xyzw = r8.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r9.xyzw = t3.SampleLevel(s2_s, r5.xyz, 0).xyzw;
  r9.xyzw = r9.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r5.xyzw = t4.SampleLevel(s2_s, r5.xyz, 0).xyzw;
  r10.w = r5.w * 2 + -1;
  r8.xyz = r8.xyz * r7.xxx;
  r11.yzw = float3(1.73205125,1.73205125,1.73205125) * r8.xyz;
  r8.xyz = r9.xyz * r7.yyy;
  r12.yzw = float3(1.73205125,1.73205125,1.73205125) * r8.xyz;
  r10.y = r8.w;
  r10.z = r9.w;
  r8.xyz = r10.yzw * r7.zzz;
  r8.yzw = float3(1.73205125,1.73205125,1.73205125) * r8.xyz;
  r9.yzw = float3(-1.02332771,1.02332771,-1.02332771) * r0.yzx;
  r11.x = r7.x;
  r9.x = 0.886227548;
  r10.x = dot(r11.xyzw, r9.xyzw);
  r12.x = r7.y;
  r10.y = dot(r12.xyzw, r9.xyzw);
  r8.x = r7.z;
  r10.z = dot(r8.xyzw, r9.xyzw);
  r7.xyz = max(float3(0,0,0), r10.xyz);
  r7.xyz = cb1[147].www * r7.xyz;
  r7.xyz = cb1[147].xyz * r7.xyz;
  r7.xyz = cb2[19].yyy * r7.xyz;
  r2.w = cmp(0 < cb1[156].y);
  if (r2.w != 0) {
    r5.xyz = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r2.w = dot(r5.xyz, r5.xyz);
    r8.x = sqrt(r2.w);
    r2.w = max(9.99999975e-05, r8.x);
    r5.xyz = r5.xyz / r2.www;
    r2.w = 1 + -r8.x;
    r2.w = -r2.w * r2.w + 1;
    r9.xyz = -r5.xyz + r0.xyz;
    r9.xyz = r2.www * r9.xyz + r5.xyz;
    r3.w = saturate(dot(r5.xyz, r0.xyz));
    r4.w = 1 + -r3.w;
    r8.y = r2.w * r4.w + r3.w;
  } else {
    r9.xyz = r0.xyz;
    r8.xy = float2(1,1);
  }
  r9.w = 1;
  r5.x = dot(cb1[158].xyzw, r9.xyzw);
  r5.y = dot(cb1[159].xyzw, r9.xyzw);
  r5.z = dot(cb1[160].xyzw, r9.xyzw);
  r10.xyzw = r9.xyzz * r9.yzzx;
  r11.x = dot(cb1[161].xyzw, r10.xyzw);
  r11.y = dot(cb1[162].xyzw, r10.xyzw);
  r11.z = dot(cb1[163].xyzw, r10.xyzw);
  r2.w = r9.y * r9.y;
  r2.w = r9.x * r9.x + -r2.w;
  r5.xyz = r11.xyz + r5.xyz;
  r5.xyz = cb1[164].xyz * r2.www + r5.xyz;
  r5.xyz = max(float3(0,0,0), r5.xyz);
  r5.xyz = cb1[157].xyz * r5.xyz;
  r2.w = r8.x * r8.y;
  r2.w = cb2[19].z * r2.w;
  r5.xyz = r5.xyz * r2.www;
  r5.xyz = r7.xyz * float3(0.318309873,0.318309873,0.318309873) + r5.xyz;
  r2.w = dot(r5.xyz, float3(0.300000012,0.589999974,0.109999999));
  r5.xyz = r5.xyz * r6.xyz;
  r7.xyz = r4.xyz * float3(2.04040003,2.04040003,2.04040003) + float3(-0.332399994,-0.332399994,-0.332399994);
  r8.xyz = r4.xyz * float3(-4.79510021,-4.79510021,-4.79510021) + float3(0.641700029,0.641700029,0.641700029);
  r9.xyz = r4.xyz * float3(2.75519991,2.75519991,2.75519991) + float3(0.690299988,0.690299988,0.690299988);
  r7.xyz = r0.www * r7.xyz + r8.xyz;
  r7.xyz = r7.xyz * r0.www + r9.xyz;
  r7.xyz = r7.xyz * r0.www;
  r7.xyz = max(r7.xyz, r0.www);
  r5.xyz = r7.xyz * r5.xyz;
  r1.xyz = r1.xyz * float3(0.449999988,0.449999988,0.449999988) + r6.xyz;
  r6.xyz = max(float3(0,0,0), cb3[2].xyz);
  r6.xyz = float3(250,250,250) * r6.xyz;
  r0.w = cmp(0 < cb1[131].z);
  if (r0.w != 0) {
    r7.xyz = -cb2[5].xyz + r2.xyz;
    r8.xyz = float3(1,1,1) + cb2[13].xyz;
    r7.xyz = cmp(r8.xyz < abs(r7.xyz));
    r0.w = (int)r7.y | (int)r7.x;
    r0.w = (int)r7.z | (int)r0.w;
    r2.x = dot(r2.xyz, float3(0.577000022,0.577000022,0.577000022));
    r2.x = 0.00200000009 * r2.x;
    r2.x = frac(r2.x);
    r2.x = cmp(0.5 < r2.x);
    r2.xyz = r2.xxx ? float3(0,1,1) : float3(1,1,0);
    r6.xyz = r0.www ? r2.xyz : r6.xyz;
  }
  r1.xyz = cb1[135].zzz * r1.xyz + r5.xyz;
  r1.xyz = r1.xyz + r6.xyz;
  r2.xyz = float3(0.0078125,0.0078125,0.0078125) * v5.xyx;
  r2.xyz = frac(r2.xyz);
  r2.xyz = r2.xyz * float3(128,128,128) + float3(-64.3406219,-72.4656219,-64.3406219);
  r2.xyz = r2.xyz * r2.xyy;
  r0.w = dot(r2.xyz, float3(20.390625,60.703125,2.42812085));
  r0.w = frac(r0.w);
  r0.w = -0.5 + r0.w;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r0.x = r2.w * r1.w;
  r0.x = r0.x * cb1[125].y + 0.00390625;
  r0.x = log2(r0.x);
  r0.x = r0.x * 0.0625 + 0.5;
  o5.w = r0.w * 0.00392156886 + r0.x;
  o0.xyz = cb1[125].yyy * r1.xyz;
  o0.w = 0;
  o1.w = cb2[14].y;
  o2.xyz = r3.xyz;
  o2.w = 0;
  o3.xyz = r4.xyz;
  o3.w = 0;
  o5.xyz = float3(0.192156866,0,0);
  return;
}