Shader "Custom/LambertPhong-PerVertex"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Gloss ("Gloss", Range(8.0, 256)) = 20
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
				fixed3 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Gloss;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//将模型空间的法线转到世界空间,内置函数没有归一化.
				float3 worldNormal = normalize(UnityObjectToWorldDir(v.normal));
				//灯光方向
				float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射
				fixed3 diffuse = _LightColor0.rgb * saturate(dot(worldNormal, worldLight));

				//计算灯光反射方向
				fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal)); 
				//计算观察方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				//计算高光
				fixed specular = _LightColor0.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

				o.color = ambient + diffuse + specular;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * fixed4(i.color, 1);
				return col;
			}
			ENDCG
		}
	}
}
