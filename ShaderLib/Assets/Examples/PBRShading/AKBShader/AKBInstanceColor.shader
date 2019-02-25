Shader "AKB/InstanceColor" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)	
		_MainTex("Main Tex", 2D) = "white" {}
		_InstanceID("InstanceID",float) = 0
		_Intensity("Intensity", Range(0, 10)) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		ZWrite On
		LOD 100
		Pass 
		{
			Lighting Off
			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 
			#pragma multi_compile_instancing

			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			UNITY_INSTANCING_CBUFFER_START(MyProp)
				UNITY_DEFINE_INSTANCED_PROP(half4, _Color)
			UNITY_INSTANCING_CBUFFER_END
			float _Intensity;
			sampler2D _MainTex;

			v2f vert(appdata_base v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;

				return o;
			}

			half4 frag(v2f i) : SV_Target 
			{
				UNITY_SETUP_INSTANCE_ID(i)
				half4 col = tex2D(_MainTex, i.uv) * UNITY_ACCESS_INSTANCED_PROP(_Color) * _Intensity;
				col.a = 1;

				return col;
			}


			ENDCG
		}	
	}
		
	FallBack "Diffuse"
}
