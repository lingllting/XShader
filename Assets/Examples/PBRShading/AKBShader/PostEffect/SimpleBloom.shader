Shader "Hidden/AKB/SimpleBloom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _BloomTex;
		float _LuminanceThreshold;
		float _BlurSize;
		float _Intensity;
		struct v2f 
		{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};

		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			return o;
		}
		
		fixed4 fragExtractBright(v2f i) : SV_Target
		{
			fixed4 col = tex2D(_MainTex, i.uv);
			float luminance = 0.2125*col.r + 0.7154*col.g + 0.0721*col.b;
			fixed val = clamp(luminance-_LuminanceThreshold, 0, 1);
			return col * val * _Intensity;
		}

		fixed4 fragBloom(v2f i) : SV_Target 
		{
			return tex2D(_MainTex, i.uv) + tex2D(_BloomTex, i.uv);
		}

		ENDCG
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragExtractBright
			ENDCG
		}

		UsePass "Hidden/AKB/SimpleGaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"
		UsePass "Hidden/AKB/SimpleGaussianBlur/GAUSSIAN_BLUR_VERTICAL"

		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragBloom
			ENDCG
		}
	}
}
