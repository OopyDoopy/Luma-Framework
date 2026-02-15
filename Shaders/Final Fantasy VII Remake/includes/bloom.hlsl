    // Simple hash to get pseudo-random noise from integer coordinates
    float hash13(float3 p)
    {
        float3 p3 = frac(p * 0.1031);
        p3 += dot(p3, p3.yzx + 33.33);
        return frac((p3.x + p3.y) * p3.z);
    }

    // To be added in gamma space
    float getAdditiveFilmGrain(float fLinearLuminance, float2 vUV, float2 vScreenSize, float vBaseVertSize = 1080.f)
    {
        // Resolution-dependent grain pixel size. e.g.
        // at 1080p height -> 1 pixel
        // at 2160p height -> ~2 pixels
        float fGrainPixels = vScreenSize.y / vBaseVertSize;

        float2 vPixelPos   = vUV * vScreenSize;
        float2 vGrainCell  = floor(vPixelPos / fGrainPixels);

        float fGrain = hash13(float3(vGrainCell, g_iGrainFrameIndex));
        fGrain = fGrain * 2.0 - 1.0; // -1..1

        float fGammaLuminance = pow(max(fLinearLuminance, 0.f), 1.f / 2.2f);

        float fShadowWeight = smoothstep( 1.0 - 0.333, 1.0, 1.0 - fGammaLuminance ) * 0.1; // 0 to 0.175 shadow (disabled until needed)
        float fHighlightWeight = smoothstep( 0.333, 1.0, fGammaLuminance ); // 0.45 to 1.0 highlight
        fHighlightWeight += max(fGammaLuminance - 1.0, 0.0); // Preserve values beyond 1, to further boost grain there

        float fStrength = max(fShadowWeight + fHighlightWeight, 0.125) * 0.0333;

        return fGrain * fStrength;
    }

    // Helper that is 0 at mid grey and 1 towards black or white for the ring average
    float RingExtremeness(float ringY)
    {
        float g_MidGrey = 0.5f;

        // Map [0..1] -> 0 at mid grey, 1 at {0,1}
        float d = ringY - g_MidGrey;       // distance from mid grey
        float e = 4.0f * d * d;            // max=1 when ringY=0 or 1
        return saturate(e);
    }


float4 draw_bink_PS( float4 test : D3T_SV_POSITION, float2 texCoord : TEXCOORD0, float4 color : COLOR0 ) : D3T_SV_TARGET0
	{
	  const float4 crc = g_fCrc;
	  const float4 crb = g_fCbc;
	  const float4 adj = g_fAdj;
	  float4 p;
	
	  float y = D3T_SAMPLE2D( g_sBinkTexture0, texCoord ).a;
	  float cr = D3T_SAMPLE2D( g_sBinkTexture1, texCoord ).a;
	  float cb = D3T_SAMPLE2D( g_sBinkTexture2, texCoord ).a;
	
	  p = y * g_fYScale;
	
	  p += crc * cr;
	  p += crb * cb;
	  p += adj;
	
	  p.w = 1;

	  if( all(texCoord == saturate(texCoord)) )
	  {
			float2 vTexSize;
			D3T_TEXTURE2D_DIMENSIONS( g_sBinkTexture0, vTexSize.x, vTexSize.y );

			bool bDoGrain = false;
			float fGrainScale = 2.f; // 2160p to 1080p grain
			float fGrainIntensity = 1.f;
			float fLinearLuminance = 0.f;
			bool bForceSDR = false; // texCoord.x >= 0.5
			if (g_fAllowHDRVideoIntensity > 0.f && g_bHDR && !bForceSDR)
			{
				float fAspectRatio = vTexSize.x / vTexSize.y;

				// --- n samples around the UV in a circle (n rings x n directions) ---
				const int NUM_RINGS = 14;
				const int ANGLES_PER_RING = 14;
				const int NUM_SAMPLES = NUM_RINGS * ANGLES_PER_RING + 1;
				const float UV_RADIUS = 1.0 / 80.0; // e.g. 64 horizontal pixels at 3840
				float  ringYSum  = 0.f;
				int numValidSamples = 1;
				[unroll]
				for (int r = 0; r < NUM_RINGS; ++r)
				{
					// Radius grows linearly from 0.25 * UV_RADIUS to 1.0 * UV_RADIUS (at NUM_RINGS == 4)
					float ringScale = (float)(r + 1) / (float)NUM_RINGS;
					float ringRadius = UV_RADIUS * ringScale;
					[unroll]
					for (int a = 0; a < ANGLES_PER_RING; ++a)
					{
						float angle = (float)a / (float)ANGLES_PER_RING * M_PI * 2;
						float s, c;
						sincos(angle, s, c);
						// Aspect-corrected UV offsets:
						// - radius is defined in "vertical UV units"
						// - shrink X by aspect ratio so the circle is round in texture space
						float2 dir    = float2(c, s);
						float2 offset = float2(dir.x * ringRadius / fAspectRatio, dir.y * ringRadius);

						float ringY = D3T_SAMPLE2D( g_sBinkTexture0, saturate(texCoord + offset) ).a;
						//if (abs(ringY - y) <= 0.75) // Workaround to avoid text on backgorunds causing weird blurs
						{
							ringYSum += ringY;
							numValidSamples++;
						}
					}
				}

				float averageY = (ringYSum + y) / (float)numValidSamples;

				// Ring average should be either very dark or very bright
				// this is to put focus on small sized highlights, and large sized highlights, leaving mid sized highlights as they were in SDR
				float ringWeight = RingExtremeness(averageY);

				float factor = /*sqrt*/(y) * ringWeight;

				p.xyz = pow(abs(p.xyz), 2.2) * sign(p.xyz); // Linearize
				p.rgb = lerp(p.rgb, applyAutoHDR( p.rgb ), factor);

				//p.rgb = pow(factor, 2.2); // debug view factor

				fLinearLuminance = luminance( p.rgb );

				p.xyz = pow(abs(p.xyz), 1.0 / 2.2) * sign(p.xyz); // Gammify
				bDoGrain = g_bAllowGrainVideo; // TODOFT: add both film grain and dither to fix banding, especially with AutoHDR. Evaluate them in SDR (flipped?) and maybe force it in HDR.
				//fGrainScale = 4.f; // 2160p to 540p grain, it's needed to avoid artifacts
			}
			else
			{
#if 1 // Flip the film grain "direction" in SDR, to maintain the vanilla gameplay behaviour (somehow film grain was focused on shadow, instead of highlights as it actually is in most film stocks)
				fLinearLuminance = luminance( pow(saturate(1.0 - p.xyz), 2.2) );
#else
				fLinearLuminance = luminance( pow(abs(p.xyz), 2.2) * sign(p.xyz) );
#endif
				bDoGrain = g_bAllowGrainVideo;
				fGrainIntensity = 0.5f;
			}

			// Do film grain to lower banding on gradients and clipped highlights, given there's loads of them
			// We do it at native bink res, as if it came from within the videos (which it can't, as it ruins encoding quality)
			if (bDoGrain)
			{
				p.xyz += getAdditiveFilmGrain(fLinearLuminance, texCoord, vTexSize, vTexSize.y / fGrainScale) * fGrainIntensity;
			}
	  }
	  
	  p *= color;
	
	  p.xyz = pow(abs(p.xyz), g_fUserGamma) * sign(p.xyz); // HDR friendly (bink videos often have some colors slightly beyond 0-1, we retain more quality by preserving them)
	
	  return p;
	}