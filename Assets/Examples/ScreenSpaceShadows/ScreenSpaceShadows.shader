Shader "Custom/ScreenSpaceShadows"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ShadowMap("ShadowMap", 2D) = "white"{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _ShadowMap;
			float4x4 _MainCameraViewToWorldMatrix;
			float4x4 _WorldToLightClipSpaceMatrix;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 projPos : SV_POSITION;
				float4 viewPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;
			float4 _FarCorner;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.projPos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				//采样深度图
				float camera_depth = tex2D(_CameraDepthTexture, i.uv).r;
				//把深度转换到线性的01空间，深度图中存储的深度是视空间z值经过投影矩阵转换再经过透视除法后的z值，非线性。
				float view_depth = LinearEyeDepth(camera_depth);
				camera_depth = Linear01Depth(camera_depth);
				//重建视空间坐标
				float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
				float4 viewPos = float4((i.uv * 2 - 1) / p11_22 * view_depth, -view_depth, 1.0);
				//世界空间坐标
				//float4 worldPos = mul(unity_CameraToWorld, viewPos);
				float4 worldPos = mul(_MainCameraViewToWorldMatrix, viewPos);
				//灯光裁剪空间的坐标
				float4 lightClipPos = mul(_WorldToLightClipSpaceMatrix, worldPos);
				//UV坐标
				float2 shadowUV = (lightClipPos.xy / lightClipPos.w) * 0.5 + 0.5;
				//灯光空间下的深度
				float light_depth = Linear01Depth(lightClipPos.z / lightClipPos.w);
				//
				float depth = tex2D(_ShadowMap, shadowUV).r;
				if (light_depth > depth)
				{
					col = fixed4(0, 0, 0, 1);
				}
				return col;
			}
			ENDCG
		}
	}
}
