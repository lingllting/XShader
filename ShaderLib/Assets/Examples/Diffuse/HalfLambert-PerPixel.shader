Shader "Custom/HalfLambert-PerPixel"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			    //环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//归一化法线
				fixed3 worldNormal = normalize(i.worldNormal);
				//灯光方向
				float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射
				fixed3 diffuse = _LightColor0.rgb * (dot(worldNormal, worldLight) * 0.5 + 0.5);
				fixed3 finalColor = ambient + diffuse;
				fixed4 col = tex2D(_MainTex, i.uv) * fixed4(finalColor, 1);
				return col;
			}
			ENDCG
		}
	}
}
