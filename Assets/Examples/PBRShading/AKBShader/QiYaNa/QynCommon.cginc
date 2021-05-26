#ifndef QYN_COMMON_CGINC
#define QYN_COMMON_CGINC

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"

#define GAMMA_CORRECTION

#include "../AKBCommon.cginc"

#ifndef GAMMA_CORRECTION
#define GAMMA_SPACE
#endif

#ifdef GAMMA_CORRECTION
#define Mo_unity_ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) // standard dielectric reflectivity coef at incident angle (= 4%)
#else // Linear values
#define Mo_unity_ColorSpaceDielectricSpec half4(0.220916301, 0.220916301, 0.220916301, 1.0 - 0.220916301)
#endif




#define CROSS_STAR_INTENSITY 3


half4 _Color;
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _NormalTex, _MaskTex;
half _Smoothness, _Metallic, _OcclusionStrength;

sampler2D _DiffuseRampTex;
sampler2D _MultiRampTex;
sampler2D _SpecularRampTex;
half4 _TintLayer1;
half4 _TintLayer2;
half4 _TintLayer3;
half _VerticalCoord;
float _RampOffset;

#if RIMLIGHT_ENABLE
float _RimRange;
float _RimIntensity;
half4 _RimColor;
#endif

#if _ALPHATEST_ON
half _Cutoff;
#endif

sampler2D _AnisoTex;
sampler2D _HairNoiseTex;
float4 _HairNoiseTex_ST;
half _NoiseScale;
float _SpecularRange1;
float _SpecularOffset1;
half4 _ChangeLightDir1;
half4 _SpecularColor1;
float _SpecularIntensity1;

float _SpecularRange2;
float _SpecularOffset2;
half4 _ChangeLightDir2;
half4 _SpecularColor2;
float _SpecularIntensity2;

float _IBLIntensity;

#if FACE_RED_ENABLE
sampler2D _ChangeMaskMap;
half4 _ChangeColor;		
#endif

#if SPECIAL_MAT_ENABLE
half _FakeLight;
half4 _GlitterColor;
half _GlitteryMaskScale;
half _GlitterySpeed;
sampler2D _GlitterMap;  
half4 _GlitterMap_ST;
half _GlitterContrast;
half _SpecularContrast;
half _MaskAdjust;
half _GlitterPower;
half _SpecularPower;
half _GlitterThreshold;

float _RefractIndex;
sampler2D _GemInnerTex;
half4 _GemInnerTex_ST;
sampler2D _MatMaskMap;
#endif

half4 _EmissionColor;
sampler2D _EmissionTex;
half _EmissionIntensity;

half _SpotLightIntensity;

//Outline Pass
half _OutlineWidth;
half4 _OutlineColor;
half _MaxOutlineZOffset;
half _Scale;
sampler2D _OutlineTex;
sampler2D _VertexTex;

half4 MoBRDFRamp(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, half3 normal, half3 viewDir, 
			UnityLight light, UnityIndirect gi, half atten, half rampMask)
{
	half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    half3 halfDir = Unity_SafeNormalize (light.dir + viewDir);

    half nv = saturate(dot(normal, viewDir)); 
    half nl = saturate(dot(normal, light.dir));
    half nh = saturate(dot(normal, halfDir));
    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

	//Ramp
	#if CLOTH_ENABLE
	half ramp_nl = min(min(atten, nl), max(0, nl+_RampOffset));
	#else
	half ramp_nl = min(min(atten, nl), max(0, nv+_RampOffset));
	#endif
	//half ramp_nl = min(atten, nl);
	half3 multiRamp = tex2D(_MultiRampTex, half2(1-ramp_nl, _VerticalCoord)).rgb; 
	half3 diffuseRamp = tex2D(_DiffuseRampTex, half2(ramp_nl, _VerticalCoord)).rgb;
	half3 ramp1 = lerp(_TintLayer1.rgb, 1, multiRamp.r); 
	half3 ramp2 = lerp(_TintLayer2.rgb, 1, multiRamp.g); 
	half3 ramp3 = lerp(_TintLayer3.rgb, 1, multiRamp.b);

	#if CLOTH_ENABLE
	half3 diffRamp1 = lerp(diffuseRamp, ramp1, _TintLayer1.a * rampMask);
	half3 diffRamp2 = lerp(diffRamp1, ramp2, _TintLayer2.a * rampMask);
	half3 diffRamp3 = lerp(diffRamp2, ramp3, _TintLayer3.a * rampMask);
	half3 diffuseTerm = diffRamp3;
	#else
	half3 diffRamp1 = lerp(diffuseRamp, saturate(1-((1-diffuseRamp)/_TintLayer1.rgb)), 1-multiRamp.r);
	diffRamp1 = lerp(diffuseRamp, diffRamp1, _TintLayer1.a * rampMask);
	half3 diffRamp2 = lerp(diffRamp1, saturate(1-((1-diffRamp1)/_TintLayer2.rgb)), 1-multiRamp.g);
	diffRamp2 = lerp(diffRamp1, diffRamp2, _TintLayer2.a * rampMask);
	half3 diffRamp3 = lerp(diffRamp2, saturate(1-((1-diffRamp2)/_TintLayer3.rgb)), 1-multiRamp.b);
	diffRamp3 = lerp(diffRamp2, diffRamp3, _TintLayer3.a * rampMask);
	half3 diffuseTerm = diffRamp3;
	#endif
	
	diffuseTerm = diffuseTerm; 

    //half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

    half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

    roughness = max(roughness, 0.002);
    half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    half D = GGXTerm (nh, roughness);
    half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

#ifdef GAMMA_SPACE
	specularTerm = sqrt(max(1e-4h, specularTerm));
#endif

    specularTerm = max(0, specularTerm * nl);
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
#endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
#ifdef GAMMA_SPACE
	surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#else
	surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#endif

    // To provide true Lambert lighting, we need to be able to kill specular completely.
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =  diffColor * (gi.diffuse + light.color * diffuseTerm)
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
	
    return half4(color, 1);
}


half4 MoBRDF(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, half3 normal, half3 viewDir, UnityLight light, UnityIndirect gi)
{
	half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    half3 halfDir = Unity_SafeNormalize (light.dir + viewDir);

    half nv = saturate(dot(normal, viewDir)); 
    half nl = saturate(dot(normal, light.dir));
    half nh = saturate(dot(normal, halfDir));
    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));
    half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

    half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

    roughness = max(roughness, 0.002);
    half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    half D = GGXTerm (nh, roughness);
    half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

#ifdef GAMMA_SPACE
	specularTerm = sqrt(max(1e-4h, specularTerm));
#endif

    specularTerm = max(0, specularTerm * nl);
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
#endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
#ifdef GAMMA_SPACE
	surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#else
	surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#endif

    // To provide true Lambert lighting, we need to be able to kill specular completely.
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =  diffColor * (gi.diffuse + light.color * diffuseTerm)
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
	
    return half4(color, 1);
}

inline half3 MoDiffuseAndSpecularFromMetallic(half3 albedo, half metalic, out half3 specColor, out half oneMinusReflectivity)
{
	specColor = lerp(Mo_unity_ColorSpaceDielectricSpec.rgb, albedo, metalic);
	oneMinusReflectivity = Mo_unity_ColorSpaceDielectricSpec.a - metalic * Mo_unity_ColorSpaceDielectricSpec.a;
	return albedo * oneMinusReflectivity;
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

half4 MoBRDFRampAniso(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, half3 normal, half3 viewDir, 
			UnityLight light, UnityIndirect gi, half atten, half rampMask, half3 aniso, half3 aniso2, half anisoMask)
{
	half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    half3 halfDir = Unity_SafeNormalize (light.dir + viewDir);

    half nv = saturate(dot(normal, viewDir)); 
    half nl = saturate(dot(normal, light.dir));
    half nh = saturate(dot(normal, halfDir));
    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

	//Ramp
	half ramp_nv = min(atten, nv);
	half3 multiRamp = tex2D(_MultiRampTex, half2(1-ramp_nv, _VerticalCoord)).rgb; 
	half3 diffuseRamp = tex2D(_DiffuseRampTex, half2(ramp_nv, _VerticalCoord)).rgb;
	half3 ramp1 = lerp(_TintLayer1.rgb, 1, multiRamp.r); 
	half3 ramp2 = lerp(_TintLayer2.rgb, 1, multiRamp.g); 
	half3 ramp3 = lerp(_TintLayer3.rgb, 1, multiRamp.b);
	half3 diffRamp1 = lerp(diffuseRamp, saturate(1-((1-diffuseRamp)/_TintLayer1.rgb)), 1-multiRamp.r);
	diffRamp1 = lerp(diffuseRamp, diffRamp1, _TintLayer1.a * rampMask);
	half3 diffRamp2 = lerp(diffRamp1, saturate(1-((1-diffRamp1)/_TintLayer2.rgb)), 1-multiRamp.g);
	diffRamp2 = lerp(diffRamp1, diffRamp2, _TintLayer2.a * rampMask);
	half3 diffRamp3 = lerp(diffRamp2, saturate(1-((1-diffRamp2)/_TintLayer3.rgb)), 1-multiRamp.b);
	diffRamp3 = lerp(diffRamp2, diffRamp3, _TintLayer3.a * rampMask);
	half3 diffuseTerm = diffRamp3;
	
	//half rampOffset = lerp(_RampOffset, 0, nv);
	//half ramp_nl = min(atten, max(0, nl + _RampOffset));
	//half3 multiRamp2 = tex2D(_MultiRampTex, half2(1-ramp_nl, _VerticalCoord)).rgb; 
	//half3 diffuseRamp2 = tex2D(_DiffuseRampTex, half2(ramp_nl, _VerticalCoord)).rgb;

	//ramp1 = lerp(_TintLayer1.rgb, 1, multiRamp2.r); 
	//ramp2 = lerp(_TintLayer2.rgb, 1, multiRamp2.g); 
	//ramp3 = lerp(_TintLayer3.rgb, 1, multiRamp2.b);
	//diffRamp1 = lerp(diffuseRamp2, ramp1, _TintLayer1.a * rampMask);
	//diffRamp2 = lerp(diffRamp1, ramp2,  _TintLayer2.a * rampMask);
	//diffRamp3 = lerp(diffRamp2, ramp3, _TintLayer3.a * rampMask);
	//half3 diffuseTerm = diffRamp3;
	//diffuseTerm =  diffRamp3;

    //half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

	half ggx_roughness = perceptualRoughness;
	half VdotH = saturate(dot(viewDir, halfDir));   
	half SG = exp2((5 * 1.442695 + 1.089235) * (- VdotH));
	half3 F_Schlick = (1 - specColor) * SG + specColor;
				
	half gr4 = ggx_roughness * ggx_roughness;
	gr4 *= gr4;
	half D_GGX = (gr4 * aniso - aniso) * aniso + 1;
	D_GGX = min(gr4 / (D_GGX * D_GGX), 10000.0);
				
	float tem1 = ggx_roughness * 0.5 + 0.5;
	tem1 *= tem1; 
	float tem2 = (1 - tem1) * VdotH + tem1;
	float tem3 = (1 - tem1) * nl + tem1;
	half G_Schlick_Disney = 0.25 / (tem2 * tem3);
	half3 DFG = D_GGX * F_Schlick * G_Schlick_Disney * nl * _SpecularColor1 * _SpecularIntensity1;
				
	//second specular 
	half D_GGX2 = (gr4 * aniso2 - aniso2) * aniso2 + 1;
	D_GGX2 = min(gr4 / (D_GGX2 * D_GGX2), 10000.0);
	half3 DFG2 = D_GGX2 * F_Schlick * G_Schlick_Disney * nl * _SpecularColor2 * _SpecularIntensity2;
	DFG += DFG2;


    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =  diffColor * (gi.diffuse + light.color * diffuseTerm);
	color += DFG * anisoMask;
	//color += specColor * StrandSpecular(anisoDir, viewDir, light.dir, _SpecularPower) * gi.light.color;
	
	half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
#ifdef GAMMA_SPACE
	surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#else
	surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#endif
    color += surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);

    return half4(color, 1);
}

//global Lighting

half3 MoShadeSH9 (half4 normal)
{
    // Linear + constant polynomial terms
    half3 res = SHEvalLinearL0L1 (normal);

    // Quadratic polynomials
    res += SHEvalLinearL2 (normal);

	#ifdef GAMMA_SPACE
		res = LinearToGammaSpace (res);
	#endif

    return res;
}


half3 MoShadeSHPerVertex (half3 normal, half3 ambient)
{
    #if UNITY_SAMPLE_FULL_SH_PER_PIXEL
        // Completely per-pixel
        // nothing to do here
    #elif (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        // Completely per-vertex
        ambient += max(half3(0,0,0), MoShadeSH9 (half4(normal, 1.0)));
    #else
        // L2 per-vertex, L0..L1 & gamma-correction per-pixel

        // NOTE: SH data is always in Linear AND calculation is split between vertex & pixel
        // Convert ambient to Linear and do final gamma-correction at the end (per-pixel)
        #ifdef UNITY_COLORSPACE_GAMMA
            ambient = GammaToLinearSpace (ambient);
        #endif
        ambient += SHEvalLinearL2 (half4(normal, 1.0));     // no max since this is only L2 contribution
    #endif

    return ambient;
}

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
        #ifdef GAMMA_SPACE
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
        o_gi.indirect.diffuse = data.ambient; // MoShadeSHPerPixel (normalWorld, data.ambient, data.worldPos);
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
    //o_gi.indirect.specular = UnityGI_IndirectSpecular(data, occlusion, glossIn);
	o_gi.indirect.specular = half3(0, 0, 0);
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



#endif // QYN_COMMON_CGINC
