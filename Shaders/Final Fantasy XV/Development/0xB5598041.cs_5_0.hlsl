// ---- Created with 3Dmigoto v1.4.1 on Thu Feb  5 12:35:15 2026
groupshared struct { float val[1]; } g2[256];
groupshared struct { float val[1]; } g1[256];
groupshared struct { float val[1]; } g0[256];

cbuffer cbMotion : register(b0)
{
  float4x4 g_motionMat : packoffset(c0);
  float4 g_unprojectParams : packoffset(c4);
  float4 g_fullscreenDims : packoffset(c5);
  float g_sharpness : packoffset(c6);
  float g_linearDepthThresholdInv : packoffset(c6.y);
  float g_foreVersusBackLinearDepthThresholdInv : packoffset(c6.z);
  float g_temporalLinearDepthThreshold : packoffset(c6.w);
  float g_gamePaused : packoffset(c7);
  float g_velocityScaleStatic : packoffset(c7.y);
  float g_velocityScaleDynamic : packoffset(c7.z);
  float g_camMotionBlend_velocityScaleStatic : packoffset(c7.w);
  float g_camMotionBlend_oneMinusCameraMotionStrength : packoffset(c8);
}

cbuffer cbMotion2 : register(b1)
{
  float4 g_screenDims : packoffset(c0);
}

SamplerState pointClampSampler_s : register(s0);
Texture2D<float4> g_depthTex : register(t0);
Texture2D<float4> g_velTex : register(t1);
Texture2D<float4> g_temporalMip1VelTex : register(t2);
Texture2D<float4> g_temporalMipXVelTex : register(t3);
RWTexture2D<unorm> g_outVelMaskTex : register(u0);
RWTexture2D<uint> g_outMip1TileTex : register(u1);
RWTexture2D<uint> g_outMipXTileTex : register(u2);
RWTexture2D<uint> g_outMaxTileTex : register(u3);


// 3Dmigoto declarations
#define cmp -


void main)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_uav_typed_texture2d (unorm,unorm,unorm,unorm) u0
// Needs manual fix for instruction:
// unknown dcl_: dcl_uav_typed_texture2d (uint,uint,uint,uint) u1
// Needs manual fix for instruction:
// unknown dcl_: dcl_uav_typed_texture2d (uint,uint,uint,uint) u2
// Needs manual fix for instruction:
// unknown dcl_: dcl_uav_typed_texture2d (uint,uint,uint,uint) u3
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

// Needs manual fix for instruction:
// unknown dcl_: dcl_thread_group 16, 16, 1
  r0.x = mad((int)vThreadIDInGroup.y, 16, (int)vThreadIDInGroup.x);
  r0.yz = (int2)vThreadID.xy;
  r0.yz = float2(0.5,0.5) + r0.yz;
  r1.xy = g_screenDims.zw * r0.yz;
  r2.xy = r0.yz * g_screenDims.zw + g_screenDims.zw;
  r3.xyzw = g_screenDims.zwzw * float4(1,0,0,1) + r1.xyxy;
  r4.xyzw = g_velTex.Gather(pointClampSampler_s, r1.xy).xyzw;
  r5.xyzw = g_velTex.Gather(pointClampSampler_s, r1.xy).xzyw;
  r6.xyzw = g_depthTex.Gather(pointClampSampler_s, r1.xy).xyzw;
  r7.xyzw = cmp(abs(r4.xyzw) >= float4(4,4,4,4));
  r8.xyzw = cmp(r5.xzyw != float4(1,1,1,1));
  r7.xyzw = r7.xyzw ? r8.xyzw : 0;
  r9.xyzw = cmp(float4(0,0,0,0) < r4.xyzw);
  r10.xyzw = cmp(r4.xyzw < float4(0,0,0,0));
  r9.xyzw = (int4)-r9.xyzw + (int4)r10.xyzw;
  r9.xyzw = (int4)r9.xyzw;
  r9.xyzw = float4(-4,-4,-4,-4) * r9.xyzw;
  r7.xyzw = r7.xyzw ? r9.xyzw : 0;
  r4.xyzw = r7.xyzw + r4.xyzw;
  r7.x = g_motionMat._m00;
  r7.y = g_motionMat._m01;
  r7.z = g_motionMat._m02;
  r7.w = g_motionMat._m03;
  r9.xy = r3.zw;
  r9.z = r6.x;
  r9.w = 1;
  r10.x = dot(r7.xyzw, r9.xyzw);
  r11.x = g_motionMat._m10;
  r11.y = g_motionMat._m11;
  r11.z = g_motionMat._m12;
  r11.w = g_motionMat._m13;
  r10.y = dot(r11.xyzw, r9.xyzw);
  r12.x = g_motionMat._m30;
  r12.y = g_motionMat._m31;
  r12.z = g_motionMat._m32;
  r12.w = g_motionMat._m33;
  r0.w = dot(r12.xyzw, r9.xyzw);
  r9.xy = r10.xy / r0.ww;
  r9.xy = r9.xy + -r3.zw;
  r9.xy = g_velocityScaleStatic * r9.xy;
  r10.xz = r4.xy;
  r10.yw = r5.xz;
  r10.xyzw = g_velocityScaleDynamic * r10.xyzw;
  r9.xy = r8.xx ? r10.xy : r9.xy;
  r2.z = r6.y;
  r2.w = 1;
  r4.x = dot(r7.xyzw, r2.xyzw);
  r4.y = dot(r11.xyzw, r2.xyzw);
  r0.w = dot(r12.xyzw, r2.xyzw);
  r2.zw = r4.xy / r0.ww;
  r2.xy = r2.zw + -r2.xy;
  r2.xy = g_velocityScaleStatic * r2.xy;
  r2.xy = r8.yy ? r10.zw : r2.xy;
  r3.z = r6.z;
  r3.w = 1;
  r4.x = dot(r7.xyzw, r3.xyzw);
  r4.y = dot(r11.xyzw, r3.xyzw);
  r0.w = dot(r12.xyzw, r3.xyzw);
  r3.zw = r4.xy / r0.ww;
  r3.xy = r3.zw + -r3.xy;
  r3.xy = g_velocityScaleStatic * r3.xy;
  r5.xz = r4.zw;
  r4.xyzw = g_velocityScaleDynamic * r5.xyzw;
  r3.xy = r8.zz ? r4.xy : r3.xy;
  r1.z = r6.w;
  r1.w = 1;
  r4.x = dot(r7.xyzw, r1.xyzw);
  r4.y = dot(r11.xyzw, r1.xyzw);
  r0.w = dot(r12.xyzw, r1.xyzw);
  r1.xy = r4.xy / r0.ww;
  r0.yz = -r0.yz * g_screenDims.zw + r1.xy;
  r0.yz = g_velocityScaleStatic * r0.yz;
  r1.xy = r8.ww ? r4.zw : r0.yz;
  r9.w = dot(r9.xy, r9.xy);
  r2.w = dot(r2.xy, r2.xy);
  r3.w = dot(r3.xy, r3.xy);
  r1.w = dot(r1.xy, r1.xy);
  r4.xyzw = r6.xyzw * g_unprojectParams.zzzz + g_unprojectParams.wwww;
  r4.xyzw = float4(-1,-1,-1,-1) / r4.xyzw;
  r0.y = cmp(r4.y < r4.x);
  r2.z = r4.y;
  r9.z = r4.x;
  r5.xyzw = r0.yyyy ? r2.xyzw : r9.xyzw;
  r0.y = cmp(r4.z < r5.z);
  r3.z = r4.z;
  r5.xyzw = r0.yyyy ? r3.xyzw : r5.xyzw;
  r0.y = cmp(r4.w < r5.z);
  r1.z = r4.w;
  r5.xyzw = r0.yyyy ? r1.zxyw : r5.zxyw;
  r0.y = cmp(0.5 < r5.w);
  r0.z = 0.5 / r5.w;
  r0.zw = r5.yz * r0.zz;
  r0.yz = r0.yy ? r0.zw : r5.yz;
  g0[r0.x].val[0/4] = r0.y;
  g1[r0.x].val[0/4] = r0.z;
  g2[r0.x].val[0/4] = r5.x;
  r0.w = cmp(g_gamePaused != 1.000000);
  if (r0.w != 0) {
    r6.xy = vThreadID.xy;
    r6.zw = float2(0,0);
    r5.yzw = g_temporalMip1VelTex.Load(r6.xyz).xyz;
    r1.z = r5.w + -r5.x;
    r1.z = dot(r1.zz, r1.zz);
    r1.z = cmp(g_foreVersusBackLinearDepthThresholdInv >= r1.z);
    r1.z = r1.z ? 0.900000 : 0;
    r5.yz = r5.yz + -r0.yz;
    r0.yz = r1.zz * r5.yz + r0.yz;
    r5.x = min(r5.x, r5.w);
  }
  r0.yz = f32tof16(r0.yz);
  r0.y = mad((int)r0.y, 0x00010000, (int)r0.z);
  r0.z = f32tof16(r5.x);
  r5.xyz = (uint3)vThreadID.xxy << int3(1,1,1);
  r5.w = vThreadID.y;
// No code for instruction (needs manual fix):
store_uav_typed u1.xyzw, r5.xwww, r0.yyyy
  r6.xyz = mad((int3)vThreadID.xxy, int3(2,2,2), int3(1,1,0));
  r6.w = vThreadID.y;
// No code for instruction (needs manual fix):
store_uav_typed u1.xyzw, r6.xwww, r0.zzzz
  GroupMemoryBarrierWithGroupSync();
  r0.x = (uint)r0.x >> 1;
  r7.xyz = (int3)r0.xxx + int3(2,18,16);
  r8.x = g0[r0.x].val[0/4];
  r8.y = g1[r0.x].val[0/4];
  r8.z = g2[r0.x].val[0/4];
  r10.x = g0[r7.x].val[0/4];
  r10.y = g1[r7.x].val[0/4];
  r10.z = g2[r7.x].val[0/4];
  r11.x = g0[r7.y].val[0/4];
  r11.y = g1[r7.y].val[0/4];
  r11.z = g2[r7.y].val[0/4];
  r12.x = g0[r7.z].val[0/4];
  r12.y = g1[r7.z].val[0/4];
  r12.z = g2[r7.z].val[0/4];
  r8.w = dot(r8.xy, r8.xy);
  r10.w = dot(r10.xy, r10.xy);
  r11.w = dot(r11.xy, r11.xy);
  r0.y = dot(r12.xy, r12.xy);
  r0.z = cmp(r8.w < r10.w);
  r7.xyzw = r0.zzzz ? r10.xyzw : r8.xyzw;
  r0.z = cmp(r7.w < r11.w);
  r7.xyzw = r0.zzzz ? r11.xyzw : r7.xyzw;
  r0.y = cmp(r7.w < r0.y);
  r7.xyz = r0.yyy ? r12.xyz : r7.xyz;
  g0[r0.x].val[0/4] = r7.x;
  g1[r0.x].val[0/4] = r7.y;
  g2[r0.x].val[0/4] = r7.z;
  GroupMemoryBarrierWithGroupSync();
  r0.x = (uint)r0.x >> 1;
  r7.xyz = (int3)r0.xxx + int3(4,20,16);
  r8.x = g0[r0.x].val[0/4];
  r8.y = g1[r0.x].val[0/4];
  r8.z = g2[r0.x].val[0/4];
  r10.x = g0[r7.x].val[0/4];
  r10.y = g1[r7.x].val[0/4];
  r10.z = g2[r7.x].val[0/4];
  r11.x = g0[r7.y].val[0/4];
  r11.y = g1[r7.y].val[0/4];
  r11.z = g2[r7.y].val[0/4];
  r12.x = g0[r7.z].val[0/4];
  r12.y = g1[r7.z].val[0/4];
  r12.z = g2[r7.z].val[0/4];
  r8.w = dot(r8.xy, r8.xy);
  r10.w = dot(r10.xy, r10.xy);
  r11.w = dot(r11.xy, r11.xy);
  r0.y = dot(r12.xy, r12.xy);
  r0.z = cmp(r8.w < r10.w);
  r7.xyzw = r0.zzzz ? r10.xyzw : r8.xyzw;
  r0.z = cmp(r7.w < r11.w);
  r7.xyzw = r0.zzzz ? r11.xyzw : r7.xyzw;
  r0.y = cmp(r7.w < r0.y);
  r7.xyz = r0.yyy ? r12.xyz : r7.xyz;
  g0[r0.x].val[0/4] = r7.x;
  g1[r0.x].val[0/4] = r7.y;
  g2[r0.x].val[0/4] = r7.z;
  GroupMemoryBarrierWithGroupSync();
  r0.y = (uint)r0.x >> 1;
  r7.xyz = (int3)r0.yyy + int3(8,24,16);
  r8.x = g0[r0.y].val[0/4];
  r8.y = g1[r0.y].val[0/4];
  r8.z = g2[r0.y].val[0/4];
  r10.x = g0[r7.x].val[0/4];
  r10.y = g1[r7.x].val[0/4];
  r10.z = g2[r7.x].val[0/4];
  r11.x = g0[r7.y].val[0/4];
  r11.y = g1[r7.y].val[0/4];
  r11.z = g2[r7.y].val[0/4];
  r12.x = g0[r7.z].val[0/4];
  r12.y = g1[r7.z].val[0/4];
  r12.z = g2[r7.z].val[0/4];
  r8.w = dot(r8.xy, r8.xy);
  r10.w = dot(r10.xy, r10.xy);
  r11.w = dot(r11.xy, r11.xy);
  r0.z = dot(r12.xy, r12.xy);
  r1.z = cmp(r8.w < r10.w);
  r7.xyzw = r1.zzzz ? r10.xyzw : r8.xyzw;
  r1.z = cmp(r7.w < r11.w);
  r7.xyzw = r1.zzzz ? r11.xyzw : r7.xyzw;
  r0.z = cmp(r7.w < r0.z);
  r7.xyz = r0.zzz ? r12.xyz : r7.xyz;
  r5.xw = (uint2)vThreadGroupID.xy << int2(1,1);
  if (1 == 0) r8.y = 0; else if (1+1 < 32) {   r8.y = (uint)r0.x << (32-(1 + 1)); r8.y = (uint)r8.y >> (32-1);  } else r8.y = (uint)r0.x >> 1;
  r8.z = (uint)r0.y >> 1;
  r8.yz = (int2)r5.xw + (int2)r8.yz;
  if (r0.w != 0) {
    r8.w = 0;
    r0.xyz = g_temporalMipXVelTex.Load(r8.yzw).xyz;
    r0.xyw = r0.zxy + -r7.zxy;
    r0.x = dot(r0.xx, r0.xx);
    r0.x = cmp(g_foreVersusBackLinearDepthThresholdInv >= r0.x);
    r0.x = r0.x ? 0.900000 : 0;
    r7.xy = r0.xx * r0.yw + r7.xy;
    r7.z = min(r7.z, r0.z);
  }
  r0.xyz = f32tof16(r7.xyz);
  r0.x = mad((int)r0.x, 0x00010000, (int)r0.y);
  r8.x = (uint)r8.y << 1;
// No code for instruction (needs manual fix):
store_uav_typed u2.xyzw, r8.xzzz, r0.xxxx
  r10.x = mad((int)r8.y, 2, 1);
  r10.yzw = r8.zzz;
// No code for instruction (needs manual fix):
store_uav_typed u2.xyzw, r10.xwww, r0.zzzz
  r7.w = dot(r7.xy, r7.xy);
  r0.xyzw = (int4)r8.yzzy + int4(-1,-1,-1,0);
  r0.xyz = max(int3(0,0,0), (int3)r0.xyz);
  r11.zw = min(int2(0,0), (int2)r0.xy);
  r11.y = (uint)r11.z << 1;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r0.x, r11.ywww, u2.xyzw
  r11.x = mad((int)r11.z, 2, 1);
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r0.y, r11.xwww, u2.yxzw
  r1.z = (uint)r0.x >> 16;
  r11.x = f16tof32(r1.z);
  r0.x = (int)r0.x & 0x0000ffff;
  r11.y = f16tof32(r0.x);
  r0.x = (int)r0.y & 0x0000ffff;
  r11.z = f16tof32(r0.x);
  r11.w = dot(r11.xy, r11.xy);
  r0.x = cmp(r7.w < r11.w);
  r7.xyzw = r0.xxxx ? r11.xyzw : r7.xyzw;
  r0.zw = min(int2(0,0), (int2)r0.wz);
  r0.y = (uint)r0.z << 1;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r0.y, r0.ywww, u2.yxzw
  r0.x = mad((int)r0.z, 2, 1);
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r0.x, r0.xwww, u2.xyzw
  r0.z = (uint)r0.y >> 16;
  r0.xy = (int2)r0.xy & int2(0xffff,0xffff);
  r11.xyz = f16tof32(r0.zyx);
  r11.w = dot(r11.xy, r11.xy);
  r0.x = cmp(r7.w < r11.w);
  r0.xyzw = r0.xxxx ? r11.xyzw : r7.xyzw;
  r7.xyzw = (int4)r8.yzyz + int4(1,-1,1,0);
  r11.w = max(0, (int)r7.y);
  r11.z = r7.x;
  r11.zw = min(int2(0,0), (int2)r11.zw);
  r11.y = (uint)r11.z << 1;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r1.z, r11.ywww, u2.yzxw
  r11.x = mad((int)r11.z, 2, 1);
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r2.z, r11.xwww, u2.yzxw
  r3.z = (uint)r1.z >> 16;
  r11.x = f16tof32(r3.z);
  r1.z = (int)r1.z & 0x0000ffff;
  r11.y = f16tof32(r1.z);
  r1.z = (int)r2.z & 0x0000ffff;
  r11.z = f16tof32(r1.z);
  r11.w = dot(r11.xy, r11.xy);
  r1.z = cmp(r0.w < r11.w);
  r0.xyzw = r1.zzzz ? r11.xyzw : r0.xyzw;
  r7.zw = min(int2(0,0), (int2)r7.zw);
  r7.y = (uint)r7.z << 1;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r1.z, r7.ywww, u2.yzxw
  r7.x = mad((int)r7.z, 2, 1);
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r2.z, r7.xwww, u2.yzxw
  r3.z = (uint)r1.z >> 16;
  r7.x = f16tof32(r3.z);
  r1.z = r1.z ? 0.000000 : 0;
  r7.y = f16tof32(r1.z);
  r1.z = (int)r2.z & 0x0000ffff;
  r7.z = f16tof32(r1.z);
  r7.w = dot(r7.xy, r7.xy);
  r1.z = cmp(r0.w < r7.w);
  r0.xyzw = r1.zzzz ? r7.xyzw : r0.xyzw;
  r7.xyzw = (int4)r8.yzyz + int4(1,1,0,1);
  r7.xyzw = min(int4(119,66,119,66), (int4)r7.xyzw);
  r11.xy = (uint2)r7.xz << int2(1,1);
  r11.zw = r7.yw;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r1.z, r11.xzzz, u2.yzxw
  r7.xy = mad((int2)r7.xz, int2(2,2), int2(1,1));
  r7.zw = r11.zw;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r2.z, r7.xzzz, u2.yzxw
  r3.z = (uint)r1.z >> 16;
  r12.x = f16tof32(r3.z);
  r1.z = r1.z ? 0.000000 : 0;
  r12.y = f16tof32(r1.z);
  r1.z = (int)r2.z & 0x0000ffff;
  r12.z = f16tof32(r1.z);
  r12.w = dot(r12.xy, r12.xy);
  r1.z = cmp(r0.w < r12.w);
  r0.xyzw = r1.zzzz ? r12.xyzw : r0.xyzw;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r1.z, r11.ywww, u2.yzxw
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r2.z, r7.ywww, u2.yzxw
  r3.z = (uint)r1.z >> 16;
  r7.x = f16tof32(r3.z);
  r1.z = r1.z ? 0.000000 : 0;
  r7.y = f16tof32(r1.z);
  r1.z = (int)r2.z & 0x0000ffff;
  r7.z = f16tof32(r1.z);
  r7.w = dot(r7.xy, r7.xy);
  r1.z = cmp(r0.w < r7.w);
  r0.xyzw = r1.zzzz ? r7.xyzw : r0.xyzw;
  r7.xyzw = (int4)r8.yyzz + int4(-1,-1,1,0);
  r7.xy = max(int2(0,0), (int2)r7.xy);
  r11.zw = min(int2(0,0), (int2)r7.xz);
  r11.y = (uint)r11.z << 1;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r1.z, r11.ywww, u2.yzxw
  r11.x = mad((int)r11.z, 2, 1);
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r2.z, r11.xwww, u2.yzxw
  r3.z = (uint)r1.z >> 16;
  r11.x = f16tof32(r3.z);
  r1.z = r1.z ? 0.000000 : 0;
  r11.y = f16tof32(r1.z);
  r1.z = (int)r2.z & 0x0000ffff;
  r11.z = f16tof32(r1.z);
  r11.w = dot(r11.xy, r11.xy);
  r1.z = cmp(r0.w < r11.w);
  r0.xyzw = r1.zzzz ? r11.xyzw : r0.xyzw;
  r7.zw = min(int2(0,0), (int2)r7.yw);
  r7.y = (uint)r7.z << 1;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r1.z, r7.ywww, u2.yzxw
  r7.x = mad((int)r7.z, 2, 1);
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r2.z, r7.xwww, u2.yzxw
  r3.z = (uint)r1.z >> 16;
  r7.x = f16tof32(r3.z);
  r1.z = r1.z ? 0.000000 : 0;
  r7.y = f16tof32(r1.z);
  r1.z = (int)r2.z & 0x0000ffff;
  r7.z = f16tof32(r1.z);
  r1.z = dot(r7.xy, r7.xy);
  r0.w = cmp(r0.w < r1.z);
  r0.xyz = r0.www ? r7.xyz : r0.xyz;
  r0.xyz = f32tof16(r0.xyz);
  r0.x = mad((int)r0.x, 0x00010000, (int)r0.y);
// No code for instruction (needs manual fix):
store_uav_typed u3.xyzw, r8.xzzz, r0.xxxx
// No code for instruction (needs manual fix):
store_uav_typed u3.xyzw, r10.xyzw, r0.zzzz
  r0.zw = (int2(28,28) == 0 ? 0 : (int2(28,28) + int2(3,3) < 32 ? (((int2)vThreadID.xy << (32 - int2(28,28) - int2(3,3))) >> (32 - int2(28,28))) : ((int2)vThreadID.xy >> int2(3,3))));
  r0.y = (uint)r0.z << 1;
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r0.y, r0.ywww, u3.yxzw
  r0.x = mad((int)r0.z, 2, 1);
// No code for instruction (needs manual fix):
ld_uav_typed_indexable(texture2d)(uint,uint,uint,uint) r0.x, r0.xwww, u3.xyzw
  r0.z = (uint)r0.y >> 16;
  r0.xy = (int2)r0.xy & int2(0xffff,0xffff);
  r7.xy = f16tof32(r0.zy);
  r0.x = f16tof32(r0.x);
  r0.y = dot(r7.xy, r7.xy);
  r4.xyzw = r4.xyzw + -r0.xxxx;
  r4.xyzw = saturate(-r4.xyzw * g_foreVersusBackLinearDepthThresholdInv + float4(1,1,1,1));
  r8.xyzw = cmp(r4.xyzw == float4(0,0,0,0));
  r0.x = cmp(r0.y < r9.w);
  r0.x = r0.x ? r8.x : 0;
  r0.z = cmp(r0.y < r2.w);
  r0.z = r0.z ? r8.y : 0;
  r0.w = cmp(r0.y < r3.w);
  r0.w = r0.w ? r8.z : 0;
  r0.y = cmp(r0.y < r1.w);
  r0.y = r0.y ? r8.w : 0;
  r0.xyzw = r0.xyzw ? float4(1,1,1,1) : r4.xwyz;
  r1.zw = r9.xy + -r7.xy;
  r1.zw = r0.xx * r1.zw + r7.xy;
  r2.xy = -r7.xy + r2.xy;
  r0.xz = r0.zz * r2.xy + r7.xy;
  r2.xy = -r7.xy + r3.xy;
  r2.xy = r0.ww * r2.xy + r7.xy;
  r1.xy = -r7.xy + r1.xy;
  r0.yw = r0.yy * r1.xy + r7.xy;
  r1.xy = g_fullscreenDims.xy * r1.zw;
  r1.zw = g_fullscreenDims.xy * r2.xy;
  r0.xyzw = g_fullscreenDims.xxyy * r0.xyzw;
  r2.x = dot(r1.xy, r1.xy);
  r2.y = dot(r0.xz, r0.xz);
  r2.z = dot(r1.zw, r1.zw);
  r2.w = dot(r0.yw, r0.yw);
  r0.xyzw = float4(-1,-1,-1,-1) + r2.xyzw;
  r0.xyzw = float4(0.0666666701,0.0666666701,0.0666666701,0.0666666701) * r0.xyzw;
// No code for instruction (needs manual fix):
store_uav_typed u0.xyzw, r5.yzzz, r0.wwww
// No code for instruction (needs manual fix):
store_uav_typed u0.xyzw, r6.yzzz, r0.zzzz
  r1.xyzw = mad((int4)vThreadID.xyxy, int4(2,2,2,2), int4(1,1,0,1));
// No code for instruction (needs manual fix):
store_uav_typed u0.xyzw, r1.xyyy, r0.yyyy
// No code for instruction (needs manual fix):
store_uav_typed u0.xyzw, r1.zwww, r0.xxxx
  return;
}