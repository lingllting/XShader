Shader "AKB/BillboardGPUInstance"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Vertical ("Vertical Restraint", Range(0, 1)) = 1
		_InstanceID("InstanceID",float) = 0
	}
	SubShader
	{
		// No culling or depth
		///Tags { "Queue"="AlphaTest" "RenderType"="Opaque" "IgnoreProjector"="True"}
		Tags {  "RenderType"="Opaque" }
		Cull Off ZWrite On ZTest lequal

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			
			#include "UnityCG.cginc"
			#include "AKBCommon.cginc"

				sampler2D _MainTex;
			half4 _MainTex_ST;
			fixed4 _Color;
			half _Vertical;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			v2f vert (appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				float3 center = float3(0, 0, 0);
				float3 view = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
				float3 normalDir = view - center;
				normalDir.y = normalDir.y * _Vertical;
				normalDir = normalize(normalDir);

				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));
				upDir = normalize(cross(normalDir, rightDir));

				float3 centerOffset = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + normalDir * centerOffset.z;
				o.vertex = UnityObjectToClipPos(float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
		

			fixed4 frag (v2f i) : SV_Target
			{
			UNITY_SETUP_INSTANCE_ID(i)
				
				half4 c = tex2D(_MainTex, i.uv);
				c.a = c.a * _Color.a;
				c.rgb *= _Color.rgb;

				SetGlobalColor(c);
				
				return c;
			}
			ENDCG
		}
	}
}
