#ifndef MO_LIGHTING_CGINC
#define MO_LIGHTING_CGINC

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"

//Unity自带brdf去掉对gamma的处理，因为已经做过gamma矫正
half4 MoBRDF(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, half3 normal, half3 viewDir, UnityLight light, UnityIndirect gi)
{
	half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
	half3 halfDir = Unity_SafeNormalize (light.dir + viewDir);
				
	half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact

	half nl = saturate(dot(normal, light.dir));
	half nh = saturate(dot(normal, halfDir));
	half lv = saturate(dot(light.dir, viewDir));
	half lh = saturate(dot(light.dir, halfDir));

	// Diffuse term
	half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

	// Specular term
	// HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
	// BUT 1) that will make shader look significantly darker than Legacy ones
	// and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
	half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
	// GGX with roughtness to 0 would mean no specular at all, using max(roughness, 0.002) here to match HDrenderloop roughtness remapping.
	roughness = max(roughness, 0.002);
	half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
	half D = GGXTerm (nh, roughness);
	half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

	// specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
	specularTerm = max(0, specularTerm * nl);

	#if defined(_SPECULARHIGHLIGHTS_OFF)
	specularTerm = 0.0;
	#endif

	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
	surfaceReduction = 1.0 / (roughness*roughness + 1.0);

	// To provide true Lambert lighting, we need to be able to kill specular completely.
	specularTerm *= any(specColor) ? 1.0 : 0.0;
	half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
	half3 color =   diffColor * (gi.diffuse + light.color * diffuseTerm)
					+ specularTerm * light.color * FresnelTerm (specColor, lh)
					+ surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);

	return half4(color, 1);
}

half4 MoBRDF2(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, half3 normal, half3 viewDir, UnityLight light, UnityIndirect gi)
{
    half3 halfDir = Unity_SafeNormalize (light.dir + viewDir);

    half nl = saturate(dot(normal, light.dir));
    half nh = saturate(dot(normal, halfDir));
    half nv = saturate(dot(normal, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    // Specular term
    half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
	
	// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
	// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
	// https://community.arm.com/events/1155
	half a = roughness;
	half a2 = a*a;
	half d = nh * nh * (a2 - 1.h) + 1.00001h;
	half specularTerm = a2 / (max(0.1h, lh*lh) * (roughness + 0.5h) * (d * d) * 4);

	// on mobiles (where half actually means something) denominator have risk of overflow
	// clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
	// sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
	#if defined (SHADER_API_MOBILE)
	specularTerm = specularTerm - 1e-4h;
	#endif

	#if defined (SHADER_API_MOBILE)
		specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
	#endif

    half surfaceReduction = (0.6-0.08*perceptualRoughness);
	half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   (diffColor + specularTerm * specColor) * light.color * nl 
					+ gi.diffuse * diffColor 
					+ surfaceReduction * gi.specular * FresnelLerpFast (specColor, grazingTerm, nv);

    return half4(color, 1);
}

//Specular
inline half4 MoLightingStandardSpecular (SurfaceOutputStandardSpecular s, half3 viewDir, UnityGI gi)
{
	s.Normal = normalize(s.Normal);
	// energy conservation
	half oneMinusReflectivity;
	s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);
	// shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
	// this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
	half outputAlpha;
	s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);
	half4 c = MoBRDF(s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
	return c;
}

inline half3 MoDiffuseAndSpecularFromMetallic(half3 albedo, half metalic, out half3 specColor, out half oneMinusReflectivity)
{
	half4 dielectricSpec = half4(0.04, 0.04, 0.04, 1-0.04); //线性空间的值
	specColor = lerp(dielectricSpec.rgb, albedo, metalic);
	oneMinusReflectivity = dielectricSpec.a - metalic * dielectricSpec.a;
	return albedo * oneMinusReflectivity;
}

//Metalic
inline half4 MoLightingStandard (SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
{
	s.Normal = normalize(s.Normal);
	half oneMinusReflectivity;
    half3 specColor;
    s.Albedo = MoDiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);
	half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);
    half4 c = MoBRDF (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
	return c;
}

//Giltter
inline half4 MoLightingStandardGlitter (SurfaceOutputStandard s, half3 viewDir, UnityGI gi, half3 addSpeCol)
{
	s.Normal = normalize(s.Normal);
	half oneMinusReflectivity;
    half3 specColor;
    s.Albedo = MoDiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);
	half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);
	specColor += addSpeCol;
    half4 c = MoBRDF (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
	return c;
}

//Hair
float StrandSpecular ( half3 T, half3 V, half3 L, float exponent)
{
	half3 H = normalize ( L + V );
	float dotTH = dot ( T, H );
	float sinTH = sqrt ( 1 - dotTH * dotTH);
	float dirAtten = smoothstep( -1, 0, dotTH );
	return dirAtten * pow(sinTH, exponent);
}

half4 MoHairBRDF(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, half3 normal, half3 viewDir, UnityLight light, UnityIndirect gi)
{
	half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
	half3 halfDir = Unity_SafeNormalize (light.dir + viewDir);
				
	half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact

	half nl = saturate(dot(normal, light.dir));
	half nh = saturate(dot(normal, halfDir));
	half lv = saturate(dot(light.dir, viewDir));
	half lh = saturate(dot(light.dir, halfDir));

	// Diffuse term
	half diffuseTerm = saturate(DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl);
	half3 color = diffColor * (gi.diffuse + light.color * diffuseTerm);
				
	return half4(color, 1);
}

inline half4 MoHairLighting(SurfaceOutputStandardSpecular s, half3 viewDir, UnityGI gi, half3 tangent, float _SpecularPower)
{	
	half4 c = half4(0, 0, 0, 1);
	s.Normal = normalize(s.Normal);

	half oneMinusReflectivity;
	s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);
	half outputAlpha;
	s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);
	c += MoHairBRDF(s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);

	half3 L = normalize(gi.light.dir);
	c.rgb += s.Specular * StrandSpecular(tangent, viewDir, L, _SpecularPower) * gi.light.color;

	return c;
}




//global Lighting
half3 MoShadeSHPerPixel (half3 normal, half3 ambient, float3 worldPos)
{
    half3 ambient_contrib = 0.0;

    #if UNITY_SAMPLE_FULL_SH_PER_PIXEL
        // Completely per-pixel
        ambient_contrib = ShadeSH9 (half4(normal, 1.0));
        ambient += max(half3(0, 0, 0), ambient_contrib);
    #elif (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        // Completely per-vertex
        // nothing to do here
    #else
        // L2 per-vertex, L0..L1 & gamma-correction per-pixel
        // Ambient in this case is expected to be always Linear, see ShadeSHPerVertex()
        #if UNITY_LIGHT_PROBE_PROXY_VOLUME
            if (unity_ProbeVolumeParams.x == 1.0)
                ambient_contrib = SHEvalLinearL0L1_SampleProbeVolume (half4(normal, 1.0), worldPos);
            else
                ambient_contrib = SHEvalLinearL0L1 (half4(normal, 1.0));
        #else
            ambient_contrib = SHEvalLinearL0L1 (half4(normal, 1.0));
        #endif
		
        ambient = max(half3(0, 0, 0), ambient+ambient_contrib);     // include L2 contribution in vertex shader before clamp.
        #ifdef UNITY_COLORSPACE_GAMMA
            ambient = LinearToGammaSpace (ambient);
        #endif
    #endif

    return ambient;
}

inline UnityGI MoUnityGI_Base(UnityGIInput data, half occlusion, half3 normalWorld)
{
    UnityGI o_gi;
    ResetUnityGI(o_gi);

    // Base pass with Lightmap support is responsible for handling ShadowMask / blending here for performance reason
    #if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
        half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
        float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
        float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
        data.atten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
    #endif

    o_gi.light = data.light;
    o_gi.light.color *= data.atten;

    #if UNITY_SHOULD_SAMPLE_SH
        o_gi.indirect.diffuse = MoShadeSHPerPixel (normalWorld, data.ambient, data.worldPos);
    #endif

    #if defined(LIGHTMAP_ON)
        // Baked lightmaps
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy);
        half3 bakedColor = DecodeLightmap(bakedColorTex);

        #ifdef DIRLIGHTMAP_COMBINED
            fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER (unity_LightmapInd, unity_Lightmap, data.lightmapUV.xy);
            o_gi.indirect.diffuse = DecodeDirectionalLightmap (bakedColor, bakedDirTex, normalWorld);

            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetUnityLight(o_gi.light);
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap (o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
            #endif

        #else // not directional lightmap
            o_gi.indirect.diffuse = bakedColor;

            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetUnityLight(o_gi.light);
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap(o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
            #endif

        #endif
    #endif

    #ifdef DYNAMICLIGHTMAP_ON
        // Dynamic lightmaps
        fixed4 realtimeColorTex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, data.lightmapUV.zw);
        half3 realtimeColor = DecodeRealtimeLightmap (realtimeColorTex);

        #ifdef DIRLIGHTMAP_COMBINED
            half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, data.lightmapUV.zw);
            o_gi.indirect.diffuse += DecodeDirectionalLightmap (realtimeColor, realtimeDirTex, normalWorld);
        #else
            o_gi.indirect.diffuse += realtimeColor;
        #endif
    #endif

    o_gi.indirect.diffuse *= occlusion;
    return o_gi;
}

inline UnityGI MoUnityGlobalIllumination (UnityGIInput data, half occlusion, half3 normalWorld, Unity_GlossyEnvironmentData glossIn)
{
    UnityGI o_gi = MoUnityGI_Base(data, occlusion, normalWorld);
    o_gi.indirect.specular = UnityGI_IndirectSpecular(data, occlusion, glossIn);
    return o_gi;
}

inline void MoLightingStandard_GI (SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
#else
    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
    gi = MoUnityGlobalIllumination(data, s.Occlusion, s.Normal, g);
#endif
}

inline void MoLightingStandardStage_GI (SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
#else
    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(1/*s.Smoothness*/, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
    gi = MoUnityGlobalIllumination(data, s.Occlusion, s.Normal, g);
#endif
}

#endif // MO_LIGHTING_CGINC
