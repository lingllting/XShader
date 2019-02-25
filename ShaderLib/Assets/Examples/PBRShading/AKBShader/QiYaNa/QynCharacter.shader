Shader "AKB/QynCharacter" 
{
	Properties 
	{
		[Toggle(CLOTH_ENABLE)] _ClothEnable("Cloth Enable", Float) = 0

		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_NormalTex ("Normal Tex", 2D) = "bump" {}
		_MaskTex("Mask Tex(r Metallic, g Ramp Mask, b Roughness, a Rim Mask)", 2D) = "white" {}
		_Metallic("Metallic", Range(0, 1)) = 0
		_Smoothness("Smoothness", Range(0, 1)) = 0
		_OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0
		_Cutoff ("Cut Off Threshold", Range(0, 1)) = 0

		[Header(Ramp Setting)]
		_DiffuseRampTex("Diffuse Ramp Map", 2D) = "gray" {}
		_MultiRampTex("Multi Ramp Map", 2D) = "gray" {}
		_TintLayer1 ("Tint Layer1", Color) = (1, 1, 1, 1)
		_TintLayer2 ("Tint Layer2", Color) = (1, 1, 1, 1)
		_TintLayer3 ("Tint Layer3", Color) = (1, 1, 1, 1)
		_VerticalCoord("Vertical Coord", Range(0, 1)) = 1
		_RampOffset("Ramp Offset", Range(-1, 1)) = 0

		[Header(RimLight Setting)]
		[Toggle (RIMLIGHT_ENABLE)] _RimlightEnable("Rimlight Enable",float) = 1
		_RimRange("Rim Range", Range(0.01, 1)) = 1
		_RimIntensity("Rim Intensity", Range(0, 10)) = 1
		_RimColor("Rim Color", Color) = (1, 1, 1, 1)

		[Header(Outline Setting)]
		_VertexTex ("Vertex Map (r offset, g scale)", 2D) = "gray" {}
		_OutlineColor ("OutlineColor", Color) = (0,0,0,1)
		_OutlineWidth ("OutlineWidth", Range(0,0.1)) = 0.05
		_MaxOutlineZOffset ("MaxOutlineZOffset", Range(0,1)) = 0
		_Scale ("Scale", Range(0,0.1)) = 0.01

		[Header(Hair Setting)]
		[Toggle (ANISO_ENABLE)] _AnisoEnable("Aniso Enable",float) = 0
		[Toggle (UV_VERTICAL)] _UVVertical("_UV Vertical",float) = 0 
		_AnisoTex ("Aniso Tex(b Normal Scale, a Specular Mask)", 2D) = "black" {}

		_HairNoiseTex("Hair Noise Tex", 2D) = "gray" {}
		_NoiseScale ("Noise Scale", Range(0,1)) = 0
		_SpecularRange1("Specular Range1", Range(0.001, 2)) = 1
		_SpecularOffset1("Specular Offset1",  Range(-2, 2)) = 0
		_ChangeLightDir1 ("Change Light Dir1", Vector) = (0, 0, 0, 0)
		_SpecularColor1("Specular Color1", Color) = (1, 1, 1, 1)
		_SpecularIntensity1("Specular Intensity1", Range(0, 10)) = 1

		_SpecularRange2("Specular Range2", Range(0.001, 2)) = 1
		_SpecularOffset2("Specular Offset2", Range(-2, 2)) = 0
		_ChangeLightDir2 ("Change Light Dir1", Vector) = (0, 0, 0, 0)
		_SpecularColor2("Specular Color2", Color) = (0, 0, 0, 0)
		_SpecularIntensity2("Specular Intensity2", Range(0, 10)) = 0

		//[Header(IBL Setting)]
		_IBLIntensity("IBL Intensity", Range(0, 10)) = 1
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_SpecInt ("Specular Intensity", Float) = 1.0
		_Shininess ("Specular Sharpness", Range(2.0,8.0)) = 4.0
		_Fresnel ("Fresnel Strength", Range(0.0,1.0)) = 0.0

		[Header(Face Red Setting)]
		[Toggle (FACE_RED_ENABLE)] _FaceRedEnable("Face Red Enable",float) = 0
		_ChangeMaskMap("Change Mask Map", 2D) = "black" {}
		_ChangeColor("Change Color", Color) = (0, 0, 0, 0)


		[Header(Miscellaneous Setting)]
		[Toggle(_ALPHATEST_ON)] _AlphaTest("AlphaTest", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 2
		_Stencil ("Stencil Value", Float) = 2
		
		[Header(Special Mat Setting)]
		[Toggle(SPECIAL_MAT_ENABLE)] _SpecialMatEnable("Special Mat Enable", Float) = 0
		_MatMaskMap("Material Mask", 2D) = "black" {}

		[Header(Glitter Setting)]
		_FakeLight ("Fake light", Range(0, 10)) = 0.05
		_GlitterMap ("Glitter map", 2D) = "white" {}
        _GlitterColor ("Glitter color", Color) = (1,1,1,1)
        _GlitterPower ("Glitter power (0 - 10)", Range(0, 10)) = 2
        _GlitterContrast ("Glitter contrast (1 - 3)", Range(1, 3)) = 1.5
        _GlitterySpeed ("Glittery speed (0 - 1)", Range(0, 1)) = 0.5
        _GlitteryMaskScale ("Glittery & mask dots scale", Range(0.1, 8)) = 2.5
        _MaskAdjust ("Mask adjust (0.5 - 1.5)", Range(0.5, 1.5)) = 1
		_GlitterThreshold("Glitter Threshold", Range(0, 3)) = 0.5

		[Header(Gem Setting)]
		_RefractIndex("Refract Index", Range(0.01, 3)) = 1
		_GemInnerTex("Gem Inner Tex", 2D) = "black" {}

		[Header(Emission Setting)]
		_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Range(0, 100)) = 1

		_SpotLightIntensity("Spot Light Intensity", Float) = 0

		[Foldout] _RenderShown("", Float) = 1
		[Foldout] _MainShown("", Float) = 1
		[Foldout] _RampShown("", Float) = 1
		[Foldout] _RimLightShown("", Float) = 1
		[Foldout] _OutlineShown("", Float) = 1
		[Foldout] _HairShown("", Float) = 1
		[Foldout] _IBLShown("", Float) = 1
		[Foldout] _FaceRedShown("", Float) = 1
		[Foldout] _SpecialMatShown("", Float) = 1
		

		[HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0

	}

	SubShader 
	{
		Stencil
		{
			Ref [_Stencil]
			Comp Always
			Pass Replace
		}

		Tags { "RenderType"="Character" "PerformanceChecks"="False" }
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend] [_DstBlend], Zero OneMinusSrcAlpha
            ZWrite [_ZWrite]
			Cull [_Cull]

			CGPROGRAM
			#pragma target 3.0
			#define UNITY_PASS_FORWARDBASE
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature ANISO_ENABLE
			#pragma shader_feature CLOTH_ENABLE
			#pragma shader_feature FACE_RED_ENABLE
			#pragma shader_feature RIMLIGHT_ENABLE
			#pragma shader_feature SPECIAL_MAT_ENABLE

			#pragma shader_feature UV_VERTICAL

			#pragma multi_compile __ GLOBAL_COLOR

			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase


			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		
					
			#if MARMO_BOX_PROJECTION_ON	
				#define MARMO_BOX_PROJECTION
			#endif
		
		
			//#pragma multi_compile MARMO_SKY_BLEND_OFF MARMO_SKY_BLEND_ON
				
			#if MARMO_SKY_BLEND_ON
				#define MARMO_SKY_BLEND
			#endif
		
			#define MARMO_HQ
			#define MARMO_SKY_ROTATION
			#define MARMO_DIFFUSE_IBL
			#define MARMO_SPECULAR_IBL
			#define MARMO_DIFFUSE_DIRECT
			#define MARMO_SPECULAR_DIRECT
			//#define MARMO_NORMALMAP
			#define MARMO_MIP_GLOSS

			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "QynCommon.cginc"

			#include "MarmosetInput.cginc"
			#include "MarmosetCore.cginc"
			#include "MarmosetDirect.cginc"
			#include "MarmosetSurf.cginc"

			struct v2f 
			{
				UNITY_POSITION(pos);
				float2 uv : TEXCOORD0; // _texcoord
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				#if UNITY_SHOULD_SAMPLE_SH
				half3 sh : TEXCOORD4; // SH
				#endif
				SHADOW_COORDS(5)
				UNITY_FOG_COORDS(6)
				#if SHADER_TARGET >= 30
				float4 lmap : TEXCOORD7;
				#endif

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			

			half4 _ShadowMapTexture_TexelSize;

			v2f vert(appdata_full v) 
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
				o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
			
				#ifdef DYNAMICLIGHTMAP_ON
				o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif
				#ifdef LIGHTMAP_ON
				o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				// SH/ambient and vertex lights
				#ifndef LIGHTMAP_ON
				#if UNITY_SHOULD_SAMPLE_SH
					o.sh = 0;
					// Approximated illumination from non-important point lights
					#ifdef VERTEXLIGHT_ON
					o.sh += Shade4PointLights (
						unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
						unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
						unity_4LightAtten0, worldPos, worldNormal);
					#endif
					o.sh = MoShadeSHPerVertex (worldNormal, o.sh);
					o.sh = max(0, o.sh);
				#endif
				#endif // !LIGHTMAP_ON

				UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
				UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader

				TRANSFER_SHADOW(o); 
				return o;
			}

			fixed4 frag (v2f i) : SV_Target 
			{
				UNITY_SETUP_INSTANCE_ID(i);
				float3 worldPos = float3(i.tSpace0.w, i.tSpace1.w, i.tSpace2.w);
				#ifndef USING_DIRECTIONAL_LIGHT
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				#else
				fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				#ifdef UNITY_COMPILER_HLSL
				SurfaceOutputStandard o = (SurfaceOutputStandard)0;
				#else
				SurfaceOutputStandard o;
				#endif

				//设置参数
				half4 mainTex = tex2D (_MainTex, i.uv);

				#if _ALPHATEST_ON
				clip(mainTex.a - _Cutoff);
				#endif

				half4 diffuseTex = mainTex;
				GAMMA_TO_LINEAR(diffuseTex);

				o.Albedo = diffuseTex.rgb * _Color.rgb;
				half3 normalTex = tex2D(_NormalTex, i.uv);
				o.Normal.xy = normalTex.xy * 2 - 1; 
				o.Normal.z = sqrt(1 - saturate(dot(o.Normal.xy, o.Normal.xy)));

				half4 MaskTex = tex2D(_MaskTex, i.uv);
				o.Metallic = MaskTex.r * _Metallic;
				o.Smoothness = (1-MaskTex.b) * _Smoothness;
				o.Emission = 0; //tex2D(_EmissionTex, IN.uv)*_EmissionColor;
				o.Alpha = 1;
				o.Occlusion = lerp(1, normalTex.z, _OcclusionStrength);

				// compute lighting & shadowing factor
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos)
				half failoff = atten;

				fixed shadow = 1;
				#if defined (SHADOWS_SCREEN)
				float totalShadow = 0;
				float2 originUV = i._ShadowCoord.xy;
				for (float it = -2; it <= 2; it += 1)
				{
					for (float jt = -2; jt <= 2; jt += 1)
					{
						i._ShadowCoord.xy = float2(originUV +  _ShadowMapTexture_TexelSize.xy * half2(it, jt));
						totalShadow += SHADOW_ATTENUATION(i);
					}
				}
				shadow = totalShadow / 25;
				i._ShadowCoord.xy = originUV;
				failoff = shadow;
				#endif

				atten = 1;
				
				fixed3 worldN;
				worldN.x = dot(i.tSpace0.xyz, o.Normal);
				worldN.y = dot(i.tSpace1.xyz, o.Normal);
				worldN.z = dot(i.tSpace2.xyz, o.Normal);
				o.Normal = normalize(worldN);
				half3 worldTangent = normalize(half3(i.tSpace0.x, i.tSpace1.x, i.tSpace2.x));
				half3 worldBinormal = normalize(half3(i.tSpace0.y, i.tSpace1.y, i.tSpace2.y));
				half3 worldNormal = o.Normal;
				half3 worldReflect = normalize(reflect(-worldViewDir, o.Normal));

				// Setup lighting environment
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				gi.light.color = _LightColor0.rgb;
				gi.light.dir = lightDir;
				// Call GI (lightmaps/SH/reflections) lighting function
				UnityGIInput giInput;
				UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
				giInput.light = gi.light;
				giInput.worldPos = worldPos;
				giInput.worldViewDir = worldViewDir;
				giInput.atten = atten;
				giInput.lightmapUV = 0.0;
				#if UNITY_SHOULD_SAMPLE_SH
				giInput.ambient = i.sh;
				#else
				giInput.ambient.rgb = 0.0;
				#endif
				giInput.probeHDR[0] = unity_SpecCube0_HDR;
				giInput.probeHDR[1] = unity_SpecCube1_HDR;
				#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
				giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
				#endif
				#ifdef UNITY_SPECCUBE_BOX_PROJECTION
				giInput.boxMax[0] = unity_SpecCube0_BoxMax;
				giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
				giInput.boxMax[1] = unity_SpecCube1_BoxMax;
				giInput.boxMin[1] = unity_SpecCube1_BoxMin;
				giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
				#endif
				MoLightingStandard_GI(o, giInput, gi);

				half oneMinusReflectivity;
				half3 specColor;
				o.Albedo = MoDiffuseAndSpecularFromMetallic (o.Albedo, o.Metallic, specColor, oneMinusReflectivity);
				half outputAlpha;
				o.Albedo = PreMultiplyAlpha (o.Albedo, o.Alpha, oneMinusReflectivity, outputAlpha);
				
				fixed4 c = 0;
				#if ANISO_ENABLE
				half3 anisoTex = tex2D(_AnisoTex, i.uv).rgb;
				//anisoTex.g = 1-anisoTex.g;
				half2 anisoOffset = (anisoTex.rg - 0.5) * 2;
				half3 anisoDir = normalize(worldTangent * anisoOffset.x + worldBinormal * anisoOffset.y);

				#if UV_VERTICAL
				half2 noise_uv = i.uv;
				half shift = tex2D(_HairNoiseTex, TRANSFORM_TEX(noise_uv, _HairNoiseTex)).r;
				float normalShift1 = (shift - 0.5) * _NoiseScale + _SpecularOffset1;
				#else
				float normalShift1 = (anisoTex.b - 0.5) * _NoiseScale + _SpecularOffset1;
				#endif
				
				float normalShift2 = _SpecularOffset2;

				half3 anisoDir1 = normalize(anisoDir + normalShift1 * o.Normal);
				half3 anisoDir2 = normalize(anisoDir + normalShift2 * o.Normal);


				half3 newLightDir1 = normalize(lightDir + _ChangeLightDir1);
				half3 newLightDir2 = normalize(lightDir + _ChangeLightDir2);

				half dirAtten1 = StrandSpecular(anisoDir1, worldViewDir, newLightDir1, 1/_SpecularRange1);
				half dirAtten2 = StrandSpecular(anisoDir2, worldViewDir, newLightDir2, 1/_SpecularRange2);
				half anisoMask = tex2D(_AnisoTex, i.uv).a;
				c = MoBRDFRampAniso(o.Albedo, specColor, oneMinusReflectivity, o.Smoothness, o.Normal, worldViewDir, gi.light, gi.indirect, failoff, MaskTex.g, dirAtten1, dirAtten2, anisoMask);
				#else
				c = MoBRDFRamp(o.Albedo, specColor, oneMinusReflectivity, o.Smoothness, o.Normal, worldViewDir, gi.light, gi.indirect, failoff, MaskTex.g);
				#endif

				#if RIMLIGHT_ENABLE
				half rim = pow(saturate(1-dot(worldViewDir, o.Normal)), 1/_RimRange);
				c.rgb = c.rgb + texCUBE(_SpecCubeIBL, worldReflect).rgb * rim * _RimIntensity * _RimColor * MaskTex.a;
				#endif

				c.rgb += o.Emission;

				//IBL
				//#if IBL_ENABLE
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT(Input,surfIN);
				surfIN.texcoord.x = 1.0;
				surfIN.worldNormal.x = 1.0;
				surfIN.viewDir.x = 1.0;
				surfIN.worldP.x = 1.0;
				surfIN.texcoord = i.uv;
				surfIN.worldP = float4(worldPos, 1);
				fixed3 viewDir = i.tSpace0.xyz * worldViewDir.x + i.tSpace1.xyz * worldViewDir.y  + i.tSpace2.xyz * worldViewDir.z;
				surfIN.worldNormal = 0.0;
				surfIN.internalSurfaceTtoW0 = i.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = i.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = i.tSpace2.xyz;
				surfIN.viewDir = viewDir;
				#ifdef UNITY_COMPILER_HLSL
				MarmosetOutput o_m = (MarmosetOutput)0;
				#else
				MarmosetOutput o_m;
				#endif
				o_m.Albedo = o.Albedo;
				MarmosetSurf (surfIN, o_m, o.Normal, o.Albedo, specColor, o.Smoothness, o.Metallic);
				c.rgb += o_m.Emission * _IBLIntensity * o.Occlusion;
				//#endif


				//Change Color 脸红
				#if FACE_RED_ENABLE
				_ChangeColor *= atten;
				c.rgb = lerp(c.rgb, _ChangeColor.rgb, tex2D (_ChangeMaskMap, i.uv).r * _ChangeColor.a); 
				#endif
				
				c.rgb = min(c.rgb, half3(CROSS_STAR_INTENSITY, CROSS_STAR_INTENSITY, CROSS_STAR_INTENSITY));
				if (MaskTex.r < 0.5)
					c.rgb = c.rgb/(0.187 + c.rgb) * 1.035;
				else
					LINEAR_TO_GAMMA(c);

				#if SPECIAL_MAT_ENABLE
				half4 matMask = tex2D(_MatMaskMap, i.uv);
				
				//glitter
				half3 viewDirection = worldViewDir;
				float3x3 tangentTransform = float3x3( worldTangent, worldBinormal, worldNormal);
				half2 glitter_uv = (0.05*_GlitterySpeed*mul(tangentTransform, viewDirection).xy + i.uv).rg*((_GlitterySpeed/2.0)+1.0)*_GlitteryMaskScale;
                half4 glitter_col = tex2D(_GlitterMap,TRANSFORM_TEX(glitter_uv, _GlitterMap));
                float CONST_PI = 3.14;
                float cos_PI = cos(CONST_PI);
                float sin_PI = sin(CONST_PI);
                half2 piv_center = float2(0.5,0.5);
                half2 g_uv2 = mul((-0.05*_GlitterySpeed*mul(tangentTransform, viewDirection).xy + i.uv).rg-piv_center,float2x2( cos_PI, -sin_PI, sin_PI, cos_PI))+piv_center;
                half2 glitter_uv2 = (g_uv2*_GlitteryMaskScale*(1.0-(_GlitterySpeed/3.141592654))*_MaskAdjust);
                half4 glitter_col2 = tex2D(_GlitterMap,TRANSFORM_TEX(glitter_uv2, _GlitterMap));
                half3 specularColor = lerp(pow(((_GlitterPower*_GlitterColor.rgb)*glitter_col.rgb),_GlitterContrast), float3(0,0,0), max((1.0 - glitter_col2.rgb), 0));
                half3 glitterCol = specularColor*_FakeLight;
				//亮度不够的地方不要glitter效果
				c.rgb += glitterCol * matMask.g * step(_GlitterThreshold, c.r + c.g + c.b);


				//gem
				half3 worldRefract = refract(-worldViewDir, worldNormal, _RefractIndex);
				half3 viewRefact = mul((float3x3)UNITY_MATRIX_V, worldRefract);
				half3 gemInnerCol = tex2D(_GemInnerTex, TRANSFORM_TEX(viewRefact.xy, _GemInnerTex)).rgb;

				half3 refraction = texCUBE(_SpecCubeIBL, worldReflect).rgb;
				half4 reflection = texCUBE(_SpecCubeIBL, worldReflect);
				half3 reflection2 = reflection;
				half fresnelValue = saturate(1.0f - saturate(dot(worldNormal, worldViewDir)));
				half3 multiplier = reflection.rgb * fresnelValue;
				half3 gemCol = reflection2 + refraction.rgb * multiplier;
				c.rgb = lerp(c.rgb,  mainTex.rgb * (gemCol + gemInnerCol), matMask.r); //宝石

				half3 oldCol = c.rgb;
				SetGlobalColor(c); //舞台全局变色
				c.rgb = lerp(c.rgb, oldCol, _SpotLightIntensity);

				c.rgb = lerp(c.rgb, mainTex.rgb * _EmissionColor.rgb * _EmissionIntensity, matMask.b); //自发光
				#else
				half3 oldCol = c.rgb;
				SetGlobalColor(c); //舞台全局变色
				c.rgb = lerp(c.rgb, oldCol, _SpotLightIntensity);
				#endif
				

				c.a = mainTex.a * _Color.a;

				return c;
			}
			ENDCG
		} 

		Pass
		{
			Name "OUTLINE"
			Blend SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			
			#pragma multi_compile __ GLOBAL_COLOR
			#pragma multi_compile __ SPOT_LIGHT

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "QynCommon.cginc"

			struct v2f
			{
				half4 oColor : COLOR;
				half2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			

			v2f vert (appdata_full v)
			{
				v2f o = (v2f)0;
				fixed4 vertexColor = tex2Dlod(_VertexTex, float4(v.texcoord.xy, 0, 0));
				o.uv = v.texcoord.xy;

				//描边法线转换到世界空间
				fixed3 n = v.normal.xyz;
				fixed3 t = v.tangent.xyz;
				fixed3 b = cross(n, t);
				half3 myNormal = v.color.x * t + v.color.y * b + v.color.z * n;
				float3 scaledir = mul((float3x3)UNITY_MATRIX_MV, normalize(myNormal));
				
				o.oColor = _OutlineColor;

				scaledir.z = 0.01;
				scaledir = normalize(scaledir);
				
				float4 position_cs = mul(UNITY_MATRIX_MV,v.vertex);
				position_cs /= position_cs.w;
				
				float3 viewDir = normalize(position_cs.xyz);
				float3 offset_pos_cs = position_cs.xyz + viewDir * _MaxOutlineZOffset * _Scale * (vertexColor.r - 0.5);
				
				float linewidth = -position_cs.z / (unity_CameraProjection[1].y * _Scale);
				linewidth = sqrt(linewidth) * _OutlineWidth * _Scale * vertexColor.g;
				position_cs.xy = offset_pos_cs.xy + scaledir.xy * linewidth;
				position_cs.z = offset_pos_cs.z;
				
				o.vertex = mul(UNITY_MATRIX_P,position_cs);
				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half4 c = fixed4(i.oColor.rgb,1.0) * tex2D(_MainTex, i.uv);

				half3 oldCol = c.rgb;
				SetGlobalColor(c); //舞台全局变色
				c.rgb = lerp(c.rgb, oldCol, _SpotLightIntensity);

				c.a = 1;
				return c;
			}
			ENDCG
		}

	} 

	FallBack "Legacy Shaders/Diffuse"
	CustomEditor "AKBCharacterShaderGUI"
}
