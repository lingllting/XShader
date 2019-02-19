Shader "FatherCare/Additive AlphaBlend (UVScroll)" 
{
	Properties 
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_BlendTex1 ("Particle Texture", 2D) = "white" {}
		_BlendTex2 ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_Strengthen ("Strengthen Ratio", Range(1.0, 10.0)) = 1.0

		_MainTexScrollSpeed_X ("Texture1 X Speed",Float) = 0  
		_MainTexScrollSpeed_Y ("Texture1 Y Speed", Float) = 0
		_BlendTex1ScrollSpeed_X ("Texture2 X Speed",Float) = 0  
		_BlendTex1ScrollSpeed_Y ("Texture2 Y Speed", Float) = 0
		_BlendTex2ScrollSpeed_X ("Texture3 X Speed",Float) = 0  
		_BlendTex2ScrollSpeed_Y ("Texture3 Y Speed", Float) = 0

		[Enum(Additive, 1, AlphaBlend, 10)] _DstBlend ("Additive/AlphaBlend", Float) = 1
	}

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
		Blend SrcAlpha [_DstBlend]
		//ColorMask RGB
		Cull Off Lighting Off ZWrite Off

		SubShader 
		{
			Pass 
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_particles
				#pragma multi_compile_fog
			
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				sampler2D _BlendTex1;
				sampler2D _BlendTex2;
				fixed4 _TintColor;
				float _Strengthen;

				fixed _MainTexScrollSpeed_X;  
				fixed _MainTexScrollSpeed_Y;
				fixed _BlendTex1ScrollSpeed_X;  
				fixed _BlendTex1ScrollSpeed_Y;
				fixed _BlendTex2ScrollSpeed_X;  
				fixed _BlendTex2ScrollSpeed_Y;
			
				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					float2 blendTex1Coord : TEXCOORD3;
					float2 blendTex2Coord : TEXCOORD4;
					UNITY_VERTEX_OUTPUT_STEREO
				};
			
				float4 _MainTex_ST;
				float4 _BlendTex1_ST;
				float4 _BlendTex2_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.vertex = UnityObjectToClipPos(v.vertex);
					#ifdef SOFTPARTICLES_ON
					o.projPos = ComputeScreenPos (o.vertex);
					COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.blendTex1Coord = TRANSFORM_TEX(v.texcoord, _BlendTex1);
					o.blendTex2Coord = TRANSFORM_TEX(v.texcoord, _BlendTex2);
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
				float _InvFade;
			
				fixed4 frag (v2f i) : SV_Target
				{
					#ifdef SOFTPARTICLES_ON
					float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float partZ = i.projPos.z;
					float fade = saturate (_InvFade * (sceneZ-partZ));
					i.color.a *= fade;
					#endif
				
					fixed4 texColor = tex2D(_MainTex, i.texcoord + float2 (_MainTexScrollSpeed_X, _MainTexScrollSpeed_Y) * _Time.y);
					fixed4 blendTex1Color = tex2D(_BlendTex1, i.blendTex1Coord + float2 (_BlendTex1ScrollSpeed_X, _BlendTex1ScrollSpeed_Y) * _Time.y);
					fixed4 blendTex2Color = tex2D(_BlendTex2, i.blendTex2Coord + float2 (_BlendTex2ScrollSpeed_X, _BlendTex2ScrollSpeed_Y) * _Time.y);
					fixed3 col = 2.0f * texColor.rgb * i.color.rgb * _TintColor.rgb * blendTex1Color.rgb * _Strengthen;
					return fixed4(col, texColor.a * i.color.a * _TintColor.a * blendTex1Color.a * blendTex2Color.a);
					//return col;
				}
				ENDCG 
			}
		}	
	}
}
