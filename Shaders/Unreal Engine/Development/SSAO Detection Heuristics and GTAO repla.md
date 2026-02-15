SSAO Detection Heuristics and GTAO replacement plan

# Shader Side:

GTAO Required Inputs:

We should try to detect ssao params, unsure on how much these param changes across UE version. Here is the definition from UE 4.26

```
// [0]: .x:AmbientOcclusionPower, .y:AmbientOcclusionBias/BiasDistance, .z:1/AmbientOcclusionDistance, .w:AmbientOcclusionIntensity
// [1]: .xy:ViewportUVToRandomUV, .z:AORadiusInShader, .w:Ratio
// [2]: .x:ScaleFactor(e.g. 4 if current RT is a quarter in size), .y:InvThreshold, .z:ScaleRadiusInWorldSpace(0:VS/1:WS), .w:MipBlend
// [3]: .xy:TemporalAARandomOffset, .z:StaticFraction, .w: InvTanHalfFov
// [4]: .x:Multipler for FadeDistance/Radius, .y:Additive for FadeDistance/Radius, .z:clamped HzbStepMipLevelFactorValue .w: unused
float4 ScreenSpaceAOParams[5];
```

Radius: Should be detected from SSAO shader being replaced
Radius Multiplier: Should be detected from SSAO shader being replaced. or GTAO default
Thin Object Occlusion: Should be detected from SSAO shader being replaced. or GTAO default
ViewportSize: Should come from LumaCBuffer filled on cpp side of the addon, detected from SSAO shader or use tex.getdimensions from depthbuffer
FOV: Will come from projection matrix in luma cbuffer.
WorldToView matrix (to linearize and convert depth from world to view space): should be detected from SSAO shader.
This is the usual depth linearization pattern
```
mad r1.x, r0.w, cb1[53].x, cb1[53].y
mad r0.w, r0.w, cb1[53].z, -cb1[53].w
div r0.w, l(1.000000, 1.000000, 1.000000, 1.000000), r0.w
add r1.y, r0.w, r1.x
```
Normals: Sometimes there is a normal texture we can maybe use this, but it might be simpler to just compute it everytime ourselves from depth.

For denoiser pass, we probably want to leverage whatever UE already does, saves us the effor of having to detect the denoiser as well.

# CPP Addon side:

GTAO inputs

* Create and prepare GTAO inputs like linearized depth pre-pass/ mips generation
* reuse SSAO outputs if possible to maintain consistency with pipeline and leverage UE downsampler/denoiser/upsampler

SSAO shader detection:
Possible things we can use to detect SSAO shader by reading the bytecode

* Depth linearization formula tends to be 2 mads, 1 div, 1 add consecutive while accessing all 4 values in one vector.
We can probably look for buffer operands that access all the values in one index in very close proximity and the looks if they are in mad instructions and followed by div by 1 and addition. Or we can iterate the shader for mad mad div add pattern and then check operands.
* Probably want to find some patterns in the resource declaration to avoid scanning too many shaders
* Look for the unrolled loop or forloop with the AO operations
* We will possibly have to check for two versions of AO, one with only spatial filter and another with spatio-temporal filtering, we can check precense of motion vectors and their staple decoding pattern in ue4 (see Luma_MotionVec_UE4_Decode.hlsl and taa detection in shader_detect.hpp)

* We should do additional checks on cpp side to further verify/filter possible SSAO shaders by checking the input resource type against what is expected for UE4 SSAO.
* We have to also find the render target so that we can properly write the results from the GTAO pass to it. Depending on if the detected shader is a CS or PS we have to read render targets or UAV
