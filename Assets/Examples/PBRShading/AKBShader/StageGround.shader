Shader "AKB/StageGround" 
{
	Properties 
	{
		[KeywordEnum(Zero, One, Two)] _StageLayer("Stage Layer", Float) = 0
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}

		[Toggle (DETAIL_ENABLE)] _DetailEnable("Detail Enable",float) = 1
		_DetailTex("Detail Tex", 2D) = "white" {}

		[Toggle (NORMAL_ENABLE)] _NormalEnable("Normal Enable", float) = 1
		_NormalTex ("Normal Tex", 2D) = "bump" {}
		//_MaskTex("Mask Tex(r Metallic, g Smoothness)", 2D) = "white" {}
		_Metallic("Metallic", Range(0, 1)) = 0
		_Smoothness("Smoothness", Range(0, 1)) = 0

		[Toggle (AO_ENABLE)] _AOEnable("AO Enable", float) = 1
        _OcclusionMap("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0

		[Toggle (EMISSION_ENABLE)] _EmissionEnable("Emission Enable", float) = 1
		_EmissionColor("Emission Color", Color) = (0, 0, 0, 0)
		_EmissionTex("Emission Tex", 2D) = "white" {}
		_EmissionIntensity("Emission Intensity", Range(0, 100)) = 1

		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 2
		//[Toggle(ENABLE_ALPHATEST)] _AlphaTest("AlphaTest", Float) = 0
		//_Cutoff ("Cut Off Threshold", Range(0, 1)) = 0

		[Toggle (NOISE_ENABLE)] _NoiseEnable("Noise Enable", float) = 1
		_ReflectionNoiseTex("Reflection Noise Tex", 2D) = "bump" {}
		_BlurStrength ("Reflection Blur Strength", Range(0, 1)) = 0

		[Toggle (MASK_ENABLE)] _MaskEnable("Mask Enable", float) = 1
		_ReflectionMaskTex("Reflection Mask Tex", 2D) = "white" {}
		_StepNormalZ("Step Normal Z", Range(0, 1)) = 0.9
		_ReflectionProbeIntensity("Reflection Probe Intensity", Float) = 0
		_FresnelStrength("Fresnel Strength", Range(0, 1)) = 1
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque"  "Queue" = "Geometry" }
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Tags {"LightMode" = "ForwardBase"}
			Cull [_Cull]

			CGPROGRAM
			#define UNITY_PASS_FORWARDBASE
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			//#pragma shader_feature _ALPHATEST_ON
			#pragma multi_compile RENDER_REFRACTIVE RENDER_REFLECTIVE RENDER_SIMPLE
			#pragma multi_compile __ GLOBAL_COLOR
			#pragma multi_compile _STAGELAYER_ZERO _STAGELAYER_ONE _STAGELAYER_TWO

			#pragma shader_feature DETAIL_ENABLE
			#pragma shader_feature NORMAL_ENABLE
			#pragma shader_feature AO_ENABLE
			#pragma shader_feature EMISSION_ENABLE
			#pragma shader_feature NOISE_ENABLE
			#pragma shader_feature MASK_ENABLE
			

			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AKBCommon.cginc"
			#include "MoLighting.cginc"

			#if defined (RENDER_REFLECTIVE) || defined (RENDER_REFRACTIVE)
			#define HAS_REFLECTION 1
			#endif
			#if defined (RENDER_REFRACTIVE)
			#define HAS_REFRACTION 1
			#endif

			struct v2f
			{
				UNITY_POSITION(pos);
				half2 uv : TEXCOORD0; 
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				#if UNITY_SHOULD_SAMPLE_SH
				half3 sh : TEXCOORD4; 
				#endif
				UNITY_SHADOW_COORDS(5)
				float4 lmap : TEXCOORD6;
				#if defined(HAS_REFLECTION) || defined(HAS_REFRACTION)
				float4 screenPos : TEXCOORD7;
				#endif
				half2 uv2 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			half4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DetailTex;
			sampler2D _ReflectionMaskTex;
			sampler2D _NormalTex;
			sampler2D _ReflectionNoiseTex;
			half _Smoothness, _Metallic;
			sampler2D   _OcclusionMap;
			half        _OcclusionStrength;
			sampler2D _EmissionTex;
			half4 _EmissionColor;
			half _EmissionIntensity;
			//#if _ALPHATEST_ON
			//half _Cutoff;
			//#endif

			#if defined (RENDER_REFLECTIVE) || defined (RENDER_REFRACTIVE)
			sampler2D _ReflectionTex0;
			float _ReflectionTex0Sel;
			sampler2D _ReflectionTex1;
			float _ReflectionTex1Sel;
			sampler2D _ReflectionTex2;
			float _ReflectionTex2Sel;
			float _BlurStrength;
			#endif

			#if defined (RENDER_REFRACTIVE)
			sampler2D _RefractionTex;
			#endif
			half _StepNormalZ;
			float _ReflectionProbeIntensity;
			float _FresnelStrength;

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
					o.sh = ShadeSHPerVertex (worldNormal, o.sh);
				#endif
				#endif // !LIGHTMAP_ON

				#if defined(HAS_REFLECTION) || defined(HAS_REFRACTION)
				o.screenPos = ComputeScreenPos(o.pos);
				#endif

				o.uv2 = v.texcoord3;

				UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
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

				#if DETAIL_ENABLE
				half4 detailTex = tex2D(_DetailTex, i.uv2);
				#else
				half4 detailTex = 1;
				#endif

				//#if _ALPHATEST_ON
				//clip(mainTex.a - _Cutoff);
				//#endif
				GAMMA_TO_LINEAR(mainTex)
				o.Albedo = mainTex.rgb * _Color.rgb;
				o.Metallic = _Metallic;
				o.Smoothness = _Smoothness;

				#if EMISSION_ENABLE
				o.Emission = tex2D(_EmissionTex, i.uv2)*_EmissionColor;
				#else
				o.Emission = half4(0, 0, 0, 1);
				#endif
				
				o.Alpha = 1;

				#if NORMAL_ENABLE
				half3 normalTex = UnpackNormal(tex2D(_NormalTex, i.uv));
				#else 
				half3 normalTex = half3(0, 0, 1);
				#endif

				o.Normal = normalTex;

				#if NOISE_ENABLE
				float3 offsetNormal = UnpackNormal(tex2D(_ReflectionNoiseTex, i.uv));
				#else
				float3 offsetNormal = float3(0, 0, 1);
				#endif

				#if AO_ENABLE
				half3 occ = tex2D(_OcclusionMap, i.uv2).rgb;
				#else
				half3 occ = half3(1, 1, 1);
				#endif
				

				o.Occlusion = LerpOneTo (occ, _OcclusionStrength);
				

				// compute lighting & shadowing factor
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos)

				fixed4 c = 0;
				fixed3 worldN;
				worldN.x = dot(i.tSpace0.xyz, o.Normal);
				worldN.y = dot(i.tSpace1.xyz, o.Normal);
				worldN.z = dot(i.tSpace2.xyz, o.Normal);
				o.Normal = normalize(worldN);
				

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

				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
				giInput.lightmapUV = i.lmap;
				#else
				giInput.lightmapUV = 0.0;
				#endif
				
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

				MoLightingStandardStage_GI(o, giInput, gi);

				
				half oneMinusReflectivity;
				half3 specColor;
				o.Albedo = MoDiffuseAndSpecularFromMetallic (o.Albedo, o.Metallic, specColor, oneMinusReflectivity);
				half outputAlpha;
				o.Albedo = PreMultiplyAlpha (o.Albedo, o.Alpha, oneMinusReflectivity, outputAlpha);
				c += MoBRDF (o.Albedo, specColor, oneMinusReflectivity, o.Smoothness, o.Normal, worldViewDir, gi.light, gi.indirect);
				c.rgb = lerp(c.rgb, gi.indirect.specular * _ReflectionProbeIntensity, o.Smoothness);

				half refractFactor = mainTex.a * _Color.a;
				#if defined(RENDER_REFLECTIVE)
				half2 ref_uv = i.screenPos.xy/i.screenPos.w;

				#if MASK_ENABLE
				half offsetScale = tex2D(_ReflectionMaskTex, i.uv2).r;
				#else 
				half offsetScale = 1;
				#endif


				#if _STAGELAYER_ZERO
				half4 refColor = tex2D(_ReflectionTex0, ref_uv + offsetNormal.xy * _BlurStrength * 0.1 * offsetScale);
				#elif _STAGELAYER_ONE
				half4 refColor = tex2D(_ReflectionTex1, ref_uv + offsetNormal.xy * _BlurStrength * 0.1 * offsetScale);
				#else
				half4 refColor = tex2D(_ReflectionTex2, ref_uv + offsetNormal.xy * _BlurStrength * 0.1 * offsetScale);
				#endif
				half frenel = lerp(1, 1 - saturate(dot(worldViewDir, o.Normal)),  _FresnelStrength);


				//c.rgb = lerp(c.rgb, refColor.rgb, o.Smoothness * frenel * step(_StepNormalZ, normalTex.z) * (1-refColor.a));

				//上面是原公式，但是在有Additive时不对，根据RT最后用Blend One SrcAlpha公式混合得出下面的推导公式
				half afactor = o.Smoothness * frenel * step(_StepNormalZ, normalTex.z);
				half3 srcColor = refColor.rgb * afactor;
				c.rgb = srcColor + c.rgb * (1-(1-refColor.a)* afactor);
				#endif

				c.rgb += o.Emission;

				c.rgb = c.rgb * detailTex.rgb;

				SetGlobalColor(c);

				LINEAR_TO_GAMMA(c)
				c.a =  refractFactor;
				return c;
			}
			ENDCG
		} //Pass

		Pass 
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardAdd" }
			ZWrite Off 
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdadd_fullshadows

			#define UNITY_PASS_FORWARDADD
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			struct v2f
			{
				UNITY_POSITION(pos);
				float2 uv : TEXCOORD0; // _MainTex
				half3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_SHADOW_COORDS(3)
				half2 uv2 : TEXCOORD4;
			};
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalTex;
			half _Smoothness, _Metallic;
			half4 _Color;
			sampler2D   _OcclusionMap;
			half        _OcclusionStrength;

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
				  o.worldPos = worldPos;
				  o.worldNormal = worldNormal;

				  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
				  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader

				  o.uv2 = v.texcoord3;

				  return o;
			}

			
			fixed4 frag (v2f i) : SV_Target 
			{
				UNITY_SETUP_INSTANCE_ID(i);
				float3 worldPos = i.worldPos;
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

				half4 mainTex = tex2D (_MainTex, i.uv);
				o.Albedo = mainTex.rgb * _Color.rgb;
				o.Metallic = _Metallic;
				o.Smoothness = _Smoothness;
				o.Emission = 0.0;
				o.Alpha = 1;
				o.Normal = normalize(i.worldNormal);

				#if AO_ENABLE
				half3 occ = tex2D(_OcclusionMap, i.uv2).rgb;
				#else
				half3 occ = half3(1, 1, 1);
				#endif

				o.Occlusion = LerpOneTo (occ, _OcclusionStrength);
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos)
				fixed4 c = 0;

				// Setup lighting environment
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				gi.light.color = _LightColor0.rgb;
				gi.light.dir = lightDir;
				gi.light.color *= atten;
				c += LightingStandard (o, worldViewDir, gi);
				c.a = 1;
				UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
				
				return c;
			}

			ENDCG
		}

	} //SubShader

	FallBack "Legacy Shaders/Diffuse"
	CustomEditor "LegacyIlluminShaderGUI"
}
