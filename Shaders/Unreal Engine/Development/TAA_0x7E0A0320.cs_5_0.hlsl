// ---- Created with 3Dmigoto v1.4.1 on Wed Dec 17 12:44:57 2025
groupshared struct { float val[1]; } g0[400];
Texture2D<float4> t5 : register(t5);

Texture2D<uint4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[135];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[24];
}




// 3Dmigoto declarations
#define cmp -


void main)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_uav_typed_texture2d (float,float,float,float) u0
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14;
  uint4 bitmask, uiDest;
  float4 fDest;

// Needs manual fix for instruction:
// unknown dcl_: dcl_thread_group 8, 8, 1
  r0.xyzw = (uint4)vThreadID.xyyy;
  r1.xy = float2(0.5,0.5) + r0.xw;
  r1.xy = cb0[22].zw * r1.xy;
  r1.z = t0.Load(float4(0,0,0,0)).x;
  r1.z = cb1[134].z * r1.z;
  r2.xy = r1.xy + r1.xy;
  r3.xy = (uint2)vThreadGroupID.xy << int2(3,3);
  r3.xy = (uint2)r3.xy;
  r3.xy = cb0[23].xy + r3.xy;
  r1.w = mad((int)vThreadIDInGroup.y, 8, (int)vThreadIDInGroup.x);
  r3.zw = (uint2)vThreadIDInGroup.xx << int2(1,2);
  r3.zw = mad((int2)vThreadIDInGroup.yy, int2(16,32), (int2)r3.zw);
  uiDest.x = (uint)r3.z / 12;
  r5.x = (uint)r3.z % 12;
  r4.x = uiDest.x;
  r3.z = mad((int)r4.x, 24, (int)r5.x);
  r4.y = cmp((uint)r3.z < 144);
  if (r4.y != 0) {
    r5.y = (uint)r4.x << 1;
    r4.xy = float2(-2,-2) + r3.xy;
    r4.xy = (uint2)r4.xy;
    r4.xy = (int2)r5.xy + (int2)r4.xy;
    r4.xy = (uint2)r4.xy;
    r4.xy = float2(0.5,0.5) + r4.xy;
    r4.xy = cb0[19].zw * r4.xy;
    r4.xyzw = t2.Gather(s0_s, r4.xy).xyzw;
    r5.x = (int)r3.z + 12;
    g0[r5.x].val[0/4] = r4.x;
    r4.x = (int)r5.x + 1;
    g0[r4.x].val[0/4] = r4.y;
    r4.x = (int)r3.z + 1;
    g0[r4.x].val[0/4] = r4.z;
    g0[r3.z].val[0/4] = r4.w;
  }
  GroupMemoryBarrierWithGroupSync();
  r4.xyzw = (int4)vThreadIDInGroup.xyxy + int4(2,2,4,0);
  r4.xy = mad((int2)r4.yw, int2(12,12), (int2)r4.xz);
  r5.x = g0[r4.x].val[0/4];
  r3.z = mad((int)vThreadIDInGroup.y, 12, (int)vThreadIDInGroup.x);
  r3.z = g0[r3.z].val[0/4];
  r4.x = g0[r4.y].val[0/4];
  r6.xyzw = (int4)vThreadIDInGroup.xyxy + int4(0,4,4,4);
  r4.yz = mad((int2)r6.yw, int2(12,12), (int2)r6.xz);
  r4.y = g0[r4.y].val[0/4];
  r4.z = g0[r4.z].val[0/4];
  GroupMemoryBarrierWithGroupSync();
  r3.xy = float2(-1,-1) + r3.xy;
  r3.xy = (uint2)r3.xy;
  uiDest.x = (uint)r1.w / 10;
  r7.x = (uint)r1.w % 10;
  r6.x = uiDest.x;
  r7.y = r6.x;
  r6.xy = (int2)r3.xy + (int2)r7.xy;
  r6.zw = float2(0,0);
  r6.xyz = t1.Load(r6.xyz).xyz;
  r4.w = dot(r6.xzy, float3(1,1,2));
  r5.w = dot(r6.xz, float2(2,-2));
  r6.x = dot(r6.xzy, float3(-1,-1,2));
  r6.y = r4.w * r1.z + 4;
  r6.y = rcp(r6.y);
  g0[r3.w].val[0/4] = r4.w;
  r6.zw = (int2)r3.ww + int2(1,3);
  g0[r6.z].val[0/4] = r5.w;
  bitmask.x = ((~(-1 << 30)) << 2) & 0xffffffff;  r7.x = (((uint)r1.w << 2) & bitmask.x) | ((uint)2 & ~bitmask.x);
  bitmask.y = ((~(-1 << 6)) << 0) & 0xffffffff;  r7.y = (((uint)r1.w << 0) & bitmask.y) | ((uint)64 & ~bitmask.y);
  g0[r7.x].val[0/4] = r6.x;
  g0[r6.w].val[0/4] = r6.y;
  r3.w = cmp((uint)r7.y < 100);
  if (r3.w != 0) {
    uiDest.x = (uint)r7.y / 10;
    r7.x = (uint)r7.y % 10;
    r6.x = uiDest.x;
    r7.y = r6.x;
    r6.xy = (int2)r3.xy + (int2)r7.xy;
    r6.zw = float2(0,0);
    r3.xyw = t1.Load(r6.xyz).xyz;
    r4.w = dot(r3.xwy, float3(1,1,2));
    r5.w = dot(r3.xw, float2(2,-2));
    r3.x = dot(r3.xwy, float3(-1,-1,2));
    r3.y = r4.w * r1.z + 4;
    r3.y = rcp(r3.y);
    r1.w = mad((int)r1.w, 4, 256);
    g0[r1.w].val[0/4] = r4.w;
    r6.xyz = (int3)r1.www | int3(257,258,259);
    g0[r6.x].val[0/4] = r5.w;
    g0[r6.y].val[0/4] = r3.x;
    g0[r6.z].val[0/4] = r3.y;
  }
  GroupMemoryBarrierWithGroupSync();
  r6.xyzw = (int4)vThreadIDInGroup.xyxy + int4(1,0,0,1);
  r6.xyzw = mad((int4)r6.yyyw, int4(10,10,10,10), (int4)r6.xxxz);
  r3.xy = (uint2)r6.zw << int2(2,2);
  r7.x = g0[r3.x].val[0/4];
  r8.xyzw = mad((int4)r6.xyzw, int4(4,4,4,4), int4(1,2,3,1));
  r7.y = g0[r8.x].val[0/4];
  r7.z = g0[r8.y].val[0/4];
  r1.w = g0[r8.z].val[0/4];
  r6.x = g0[r3.y].val[0/4];
  r6.y = g0[r8.w].val[0/4];
  r9.xy = mad((int2)r6.ww, int2(4,4), int2(2,3));
  r6.z = g0[r9.x].val[0/4];
  r3.w = g0[r9.y].val[0/4];
  r10.xyzw = (int4)vThreadIDInGroup.xyxy + int4(1,1,2,1);
  r10.xyzw = mad((int4)r10.yyyw, int4(10,10,10,10), (int4)r10.xxxz);
  r9.yz = (uint2)r10.zw << int2(2,2);
  r11.x = g0[r9.y].val[0/4];
  r12.xyzw = mad((int4)r10.xyzw, int4(4,4,4,4), int4(1,2,3,1));
  r11.y = g0[r12.x].val[0/4];
  r11.z = g0[r12.y].val[0/4];
  r4.w = g0[r12.z].val[0/4];
  r10.x = g0[r9.z].val[0/4];
  r10.y = g0[r12.w].val[0/4];
  r13.xy = mad((int2)r10.ww, int2(4,4), int2(2,3));
  r10.z = g0[r13.x].val[0/4];
  r5.w = g0[r13.y].val[0/4];
  r13.yz = (int2)vThreadIDInGroup.xy + int2(1,2);
  r6.w = mad((int)r13.z, 10, (int)r13.y);
  r7.w = (uint)r6.w << 2;
  r14.x = g0[r7.w].val[0/4];
  r13.yzw = mad((int3)r6.www, int3(4,4,4), int3(1,2,3));
  r14.y = g0[r13.y].val[0/4];
  r14.z = g0[r13.z].val[0/4];
  r6.w = g0[r13.w].val[0/4];
  r2.zw = r2.xy * float2(1,-1) + float2(-1,1);
  r2.yz = cb0[22].zw * float2(2,2) + abs(r2.zw);
  r2.y = max(r2.y, r2.z);
  r2.y = cmp(r2.y >= 1);
  if (r2.y != 0) {
  } else {
    r2.y = cb0[10].x * r1.w;
    r2.z = cb0[11].x * r3.w;
    r6.xyz = r2.zzz * r6.xyz;
    r6.xyz = r2.yyy * r7.xyz + r6.xyz;
    r1.w = cb0[10].x * r1.w + r2.z;
    r2.y = cb0[12].x * r4.w;
    r6.xyz = r2.yyy * r11.xyz + r6.xyz;
    r1.w = cb0[12].x * r4.w + r1.w;
    r2.y = cb0[13].x * r5.w;
    r6.xyz = r2.yyy * r10.xyz + r6.xyz;
    r1.w = cb0[13].x * r5.w + r1.w;
    r2.y = cb0[14].x * r6.w;
    r6.xyz = r2.yyy * r14.xyz + r6.xyz;
    r1.w = cb0[14].x * r6.w + r1.w;
    r1.w = rcp(r1.w);
    r11.xyz = r6.xyz * r1.www;
  }
  r0.xyzw = cb0[23].xyyy + r0.xyzw;
  r0.xyzw = (uint4)r0.xyzw;
  r2.yz = (uint2)r0.xw;
  r2.yz = cmp(r2.yz < cb0[23].zw);
  r1.w = r2.z ? r2.y : 0;
  if (r1.w != 0) {
    r2.xyz = float3(-1,0,-1) + r2.xwx;
    r1.w = -r1.y * 2 + 1;
    r1.xy = r1.xy * cb0[15].xy + cb0[15].zw;
    r6.xy = cb0[19].xy * r1.xy;
    r6.xy = trunc(r6.xy);
    r6.xy = (int2)r6.xy;
    r6.zw = float2(0,0);
    r2.w = t4.Load(r6.xyz).y;
    r2.w = (int)r2.w & 8;
    r3.w = cmp(r4.x < r3.z);
    r6.y = r3.w ? -2 : 2;
    r3.w = cmp(r4.z < r4.y);
    r7.y = r3.w ? -2 : 2;
    r3.z = max(r4.x, r3.z);
    r3.w = max(r4.y, r4.z);
    r4.x = cmp(r3.w < r3.z);
    r6.z = -2;
    r7.z = 2;
    r4.xy = r4.xx ? r6.yz : r7.yz;
    r6.x = max(r3.z, r3.w);
    r3.z = cmp(r5.x < r6.x);
    r6.yz = cb0[19].zw * r4.xy;
    r5.yz = float2(0,0);
    r4.xyz = r3.zzz ? r6.xyz : r5.xyz;
    r5.xyz = cb1[123].xyw * r1.www;
    r5.xyz = r2.xxx * cb1[122].xyw + r5.xyz;
    r5.xyz = r4.xxx * cb1[124].xyw + r5.xyz;
    r5.xyz = cb1[125].xyw + r5.xyz;
    r3.zw = r5.yx / r5.zz;
    r3.zw = -r3.zw + r2.yz;
    r4.xy = r4.yz + r1.xy;
    r4.xy = t3.SampleLevel(s1_s, r4.xy, 0).xy;
    r1.w = cmp(0 < r4.x);
    r4.xy = r4.yx * float2(4.00801611,4.00801611) + float2(-2.00397754,-2.00397754);
    r3.zw = r1.ww ? r4.xy : r3.zw;
    r4.xy = cb0[22].xy * r3.wz;
    r1.w = dot(r4.xy, r4.xy);
    r1.w = sqrt(r1.w);
    r2.xy = -r3.zw + r2.yz;
    r2.z = max(abs(r2.y), abs(r2.x));
    r2.z = cmp(r2.z >= 1);
    r3.x = g0[r3.x].val[0/4];
    r3.z = g0[r8.x].val[0/4];
    r3.w = g0[r8.y].val[0/4];
    r3.y = g0[r3.y].val[0/4];
    r4.x = g0[r8.w].val[0/4];
    r4.y = g0[r9.x].val[0/4];
    r4.z = g0[r9.y].val[0/4];
    r4.w = g0[r12.x].val[0/4];
    r5.x = g0[r12.y].val[0/4];
    r5.y = g0[r9.z].val[0/4];
    r5.z = g0[r12.w].val[0/4];
    r5.w = g0[r13.x].val[0/4];
    r6.x = g0[r7.w].val[0/4];
    r6.y = g0[r13.y].val[0/4];
    r6.z = g0[r13.z].val[0/4];
    r6.w = min(r4.z, r3.y);
    r6.w = min(r6.w, r3.x);
    r7.x = min(r4.x, r4.w);
    r7.y = min(r5.x, r4.y);
    r7.xy = min(r7.xy, r3.zw);
    r7.z = min(r6.x, r5.y);
    r8.x = min(r7.z, r6.w);
    r6.w = min(r6.y, r5.z);
    r8.y = min(r7.x, r6.w);
    r6.w = min(r6.z, r5.w);
    r8.z = min(r7.y, r6.w);
    r3.y = max(r4.z, r3.y);
    r3.x = max(r3.x, r3.y);
    r3.y = max(r4.x, r4.w);
    r3.y = max(r3.z, r3.y);
    r3.z = max(r5.x, r4.y);
    r3.z = max(r3.w, r3.z);
    r3.w = max(r6.x, r5.y);
    r4.x = max(r3.x, r3.w);
    r3.x = max(r6.y, r5.z);
    r4.y = max(r3.y, r3.x);
    r3.x = max(r6.z, r5.w);
    r4.z = max(r3.z, r3.x);
    r2.xy = r2.xy * cb0[18].yx + cb0[18].wz;
    r2.xy = max(cb0[21].yx, r2.xy);
    r2.xy = min(cb0[21].wz, r2.xy);
    r3.xy = r2.yx * cb0[20].xy + float2(-0.5,-0.5);
    r3.xy = floor(r3.xy);
    r5.xyzw = float4(0.5,0.5,-0.5,-0.5) + r3.xyxy;
    r2.xy = r2.xy * cb0[20].yx + -r5.yx;
    r3.zw = r2.yx * r2.yx;
    r6.xy = r3.zw * r2.yx;
    r6.zw = r3.wz * r2.xy + r2.xy;
    r6.zw = -r6.zw * float2(0.5,0.5) + r3.wz;
    r7.xy = float2(2.5,2.5) * r3.wz;
    r6.xy = r6.yx * float2(1.5,1.5) + -r7.xy;
    r6.xy = float2(1,1) + r6.xy;
    r2.xy = r3.zw * r2.yx + -r3.zw;
    r3.zw = float2(0.5,0.5) * r2.xy;
    r7.xy = float2(1,1) + -r6.wz;
    r7.xy = r7.xy + -r6.yx;
    r2.xy = -r2.xy * float2(0.5,0.5) + r7.xy;
    r6.xy = r6.xy + r2.yx;
    r2.xy = r2.xy / r6.yx;
    r2.xy = r5.xy + r2.xy;
    r3.xy = float2(2.5,2.5) + r3.xy;
    r5.xy = cb0[20].wz * r5.wz;
    r7.zw = cb0[20].wz * r2.yx;
    r2.xy = cb0[20].zw * r3.xy;
    r3.xy = r6.yx * r6.zw;
    r4.w = r6.y * r6.x;
    r5.zw = r6.xy * r3.zw;
    r6.z = r3.x + r3.y;
    r6.z = r6.y * r6.x + r6.z;
    r3.z = r3.z * r6.x + r6.z;
    r3.z = r3.w * r6.y + r3.z;
    r3.z = 1 / r3.z;
    r7.xy = max(cb0[21].yx, r5.xy);
    r6.xyzw = t5.SampleLevel(s2_s, r7.wx, 0).xyzw;
    r9.xyzw = t5.SampleLevel(s2_s, r7.yz, 0).xyzw;
    r9.xyzw = r9.xyzw * r3.yyyy;
    r6.xyzw = r6.xyzw * r3.xxxx + r9.xyzw;
    r9.xyzw = t5.SampleLevel(s2_s, r7.wz, 0).xyzw;
    r6.xyzw = r9.xyzw * r4.wwww + r6.xyzw;
    r7.xy = min(cb0[21].zw, r2.xy);
    r9.xyzw = t5.SampleLevel(s2_s, r7.xz, 0).xyzw;
    r6.xyzw = r9.xyzw * r5.zzzz + r6.xyzw;
    r7.xyzw = t5.SampleLevel(s2_s, r7.wy, 0).xyzw;
    r5.xyzw = r7.xyzw * r5.wwww + r6.xyzw;
    r3.xyzw = r5.xyzw * r3.zzzz;
    r3.xyz = cb0[0].xxx * r3.xyz;
    r5.x = dot(r3.xzy, float3(1,1,2));
    r5.y = dot(r3.xz, float2(2,-2));
    r5.z = dot(r3.xzy, float3(-1,-1,2));
    r2.x = cmp(asint(cb0[0].z) != 0);
    r2.x = (int)r2.x | (int)r2.z;
    r2.y = t3.SampleLevel(s1_s, r1.xy, 0, int2(0, -1)).x;
    r2.y = cmp(0 < r2.y);
    r2.z = t3.SampleLevel(s1_s, r1.xy, 0, int2(-1, 0)).x;
    r2.z = cmp(0 < r2.z);
    r3.x = t3.SampleLevel(s1_s, r1.xy, 0).x;
    r3.x = cmp(0 < r3.x);
    r3.y = t3.SampleLevel(s1_s, r1.xy, 0, int2(1, 0)).x;
    r3.y = cmp(0 < r3.y);
    r1.x = t3.SampleLevel(s1_s, r1.xy, 0, int2(0, 1)).x;
    r1.x = cmp(0 < r1.x);
    r1.y = (int)r2.z | (int)r2.y;
    r1.y = (int)r3.x | (int)r1.y;
    r1.y = (int)r3.y | (int)r1.y;
    r1.x = (int)r1.x | (int)r1.y;
    r1.x = ~(int)r1.x;
    r1.y = cmp(0 < r3.w);
    r1.x = r1.y ? r1.x : 0;
    r1.x = (int)r1.x | (int)r2.x;
    r2.xyz = max(r5.xyz, r8.xyz);
    r2.xyz = min(r2.xyz, r4.xyz);
    r1.y = 0.0250000004 * r1.w;
    r1.y = min(1, r1.y);
    r1.w = 0.200000003 + -cb0[0].y;
    r1.y = r1.y * r1.w + cb0[0].y;
    r1.w = 0.00999999978 * r5.x;
    r3.y = r11.x + -r5.x;
    r1.w = saturate(r1.w / abs(r3.y));
    r1.y = max(r1.y, r1.w);
    r1.y = r2.w ? 0.25 : r1.y;
    r1.y = cb0[0].z ? 1 : r1.y;
    r2.xyz = r1.xxx ? r11.xyz : r2.xyz;
    r1.x = r11.x * r1.z + 4;
    r1.z = r2.x * r1.z + 4;
    r1.xz = rcp(r1.xz);
    r1.w = 1 + -r1.y;
    r2.w = r1.w * r1.z;
    r1.x = r1.y * r1.x;
    r1.y = r1.w * r1.z + r1.x;
    r1.y = rcp(r1.y);
    r1.z = r2.w * r1.y;
    r1.x = r1.x * r1.y;
    r1.xyw = r11.xyz * r1.xxx;
    r1.xyz = r2.xyz * r1.zzz + r1.xyw;
    r2.xyz = float3(0.25,0.25,0.25) * r1.xyz;
    r4.yz = r2.xx + r2.yz;
    r4.x = -r1.z * 0.25 + r4.y;
    r1.x = r1.x * 0.25 + -r2.y;
    r4.w = -r1.z * 0.25 + r1.x;
    r1.xyz = min(float3(0,0,0), -r4.xzw);
    r1.xyz = -r1.xyz;
    r1.w = r3.x ? 1.000000 : 0;
  // No code for instruction (needs manual fix):
    store_uav_typed u0.xyzw, r0.xyzw, r1.xyzw
  }
  return;
}