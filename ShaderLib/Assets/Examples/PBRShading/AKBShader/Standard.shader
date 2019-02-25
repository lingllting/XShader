Shader "AKB/Standard"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0

        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic", 2D) = "white" {}

		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

		_DetailMask("Detail Mask", 2D) = "white" {}

        _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
       

        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
    }


    SubShader
    {
        Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend] [_DstBlend], Zero OneMinusSrcAlpha
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma target 3.0

            #pragma shader_feature _NORMALMAP
            #pragma multi_compile _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _ _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature ___ _DETAIL_MULX2
			#pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF

            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing
			#pragma multi_compile_fog
				
			#pragma multi_compile _ GLOBAL_COLOR
			#pragma multi_compile _ CHANGE_SHADOW_COLOR
			#pragma multi_compile _ GLOBAL_EMISSION
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityStandardCoreForward.cginc"
			#include "AKBCommon.cginc"

			VertexOutputForwardBase vert (VertexInput v) 
			{ 
				UNITY_SETUP_INSTANCE_ID(v);
				VertexOutputForwardBase o;
				UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase, o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
				#if UNITY_REQUIRE_FRAG_WORLDPOS
					#if UNITY_PACK_WORLDPOS_WITH_TANGENT
						o.tangentToWorldAndPackedData[0].w = posWorld.x;
						o.tangentToWorldAndPackedData[1].w = posWorld.y;
						o.tangentToWorldAndPackedData[2].w = posWorld.z;
					#else
						o.posWorld = posWorld.xyz;
					#endif
				#endif
				o.pos = UnityObjectToClipPos(v.vertex);

				o.tex = TexCoords(v);
				o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
				float3 normalWorld = UnityObjectToWorldNormal(v.normal);
				#ifdef _TANGENT_TO_WORLD
					float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

					float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
					o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
					o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
					o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
				#else
					o.tangentToWorldAndPackedData[0].xyz = 0;
					o.tangentToWorldAndPackedData[1].xyz = 0;
					o.tangentToWorldAndPackedData[2].xyz = normalWorld;
				#endif

				//We need this for shadow receving
				UNITY_TRANSFER_SHADOW(o, v.uv1);

				o.ambientOrLightmapUV = VertexGIForward(v, posWorld, normalWorld);

				#ifdef _PARALLAXMAP
					TANGENT_SPACE_ROTATION;
					half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
					o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
					o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
					o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
				#endif

				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}

			half3 AKBAlbedo(float4 texcoords)
			{
				half3 albedoTex = tex2D (_MainTex, texcoords.xy).rgb;
				half3 albedo = _Color.rgb * albedoTex;
				#if _DETAIL_MULX2
				albedo *= LerpWhiteTo (albedoTex * unity_ColorSpaceDouble.rgb, 1);
				#endif
				return albedo;
			}

			inline FragmentCommonData AKBMetallicSetup (float4 i_tex)
			{
				half2 metallicGloss = MetallicGloss(i_tex.xy);
				half metallic = metallicGloss.x;
				half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

				half oneMinusReflectivity;
				half3 specColor;
				half3 diffColor = DiffuseAndSpecularFromMetallic (AKBAlbedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

				FragmentCommonData o = (FragmentCommonData)0;
				o.diffColor = diffColor;
				o.specColor = specColor;
				o.oneMinusReflectivity = oneMinusReflectivity;
				o.smoothness = smoothness;
				return o;
			}

			inline FragmentCommonData AKBFragmentSetup (inout float4 i_tex, half3 i_eyeVec, half3 i_viewDirForParallax, half4 tangentToWorld[3], half3 i_posWorld)
			{
				i_tex = Parallax(i_tex, i_viewDirForParallax);

				half alpha = Alpha(i_tex.xy);
				#if defined(_ALPHATEST_ON)
					clip (alpha - _Cutoff);
				#endif

				FragmentCommonData o = AKBMetallicSetup (i_tex);
				o.normalWorld = PerPixelWorldNormal(i_tex, tangentToWorld);
				o.eyeVec = NormalizePerPixelNormal(i_eyeVec);
				o.posWorld = i_posWorld;

				// NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
				o.diffColor = PreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha);
				return o;
			}
			

			half4 frag(VertexOutputForwardBase i) : SV_Target 
			{ 
				UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

				FragmentCommonData s = AKBFragmentSetup(i.tex, i.eyeVec, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i));

				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

				UnityLight mainLight = MainLight ();
				UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

				half occlusion = 1;//Occlusion(i.tex.xy);
				UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight);
				ChangeShadowColor(gi.light.color, atten);
				half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
				//c.rgb = c.rgb * lerp(_ShadowColor.rgb, 1, atten);

				#if GLOBAL_EMISSION
				c.rgb += Emission(i.tex.xy);
				#endif 

				UNITY_APPLY_FOG(i.fogCoord, c.rgb);

				SetGlobalColor(c);

				return OutputForward (c, s.alpha);
			}

            ENDCG
        }

		Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One
            Fog { Color (0,0,0,0) } // in additive pass fog should be black
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------


            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _PARALLAXMAP

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #include "UnityStandardCoreForward.cginc"

            ENDCG
        }
        
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }

        Pass
        {
            Name "META"
            Tags { "LightMode"="Meta" }

            Cull Off

            CGPROGRAM
            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature EDITOR_VISUALIZATION
			#pragma shader_feature ___ _DETAIL_MULX2

            #include "UnityStandardMeta.cginc"
            ENDCG
        }
    }

    FallBack "VertexLit"
    CustomEditor "AKBStandardShaderGUI"
}
