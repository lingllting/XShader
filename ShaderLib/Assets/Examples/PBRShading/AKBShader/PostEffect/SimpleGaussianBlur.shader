Shader "Hidden/AKB/SimpleGaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize ("Blur Size", float) = 1.0
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		float _BlurSize;
		
		struct v2f 
		{
			float4 pos : SV_POSITION;
			half2 uv[5] : TEXCOORD0;
		};

		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			half2 uv = v.texcoord;

			#ifdef BLUR_HORIZONTAL
			half2 _BlurDir = half2(1, 0); 
			#else
			half2 _BlurDir = half2(0, 1); 
			#endif
			o.uv[0] = uv;
			o.uv[1] = uv + _BlurDir * _MainTex_TexelSize.xy * _BlurSize;
			o.uv[2] = uv - _BlurDir * _MainTex_TexelSize.xy * _BlurSize;
			o.uv[3] = uv + _BlurDir * _MainTex_TexelSize.xy * 2 * _BlurSize;
			o.uv[4] = uv - _BlurDir * _MainTex_TexelSize.xy * 2 * _BlurSize;

			return o;
		}
		static const float weight[3] = {0.4026, 0.2442, 0.0545};
		fixed4 frag(v2f i) : SV_Target
		{
			fixed3 col = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
			col += tex2D(_MainTex, i.uv[1]).rgb * weight[1];
			col += tex2D(_MainTex, i.uv[2]).rgb * weight[1];
			col += tex2D(_MainTex, i.uv[3]).rgb * weight[2];
			col += tex2D(_MainTex, i.uv[4]).rgb * weight[2];

			return fixed4(col, 1);
		}

		ENDCG
		
		Pass
		{
			NAME "GAUSSIAN_BLUR_HORIZONTAL"
			CGPROGRAM
			#pragma multi_compile BLUR_HORIZONTAL
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		Pass 
		{
			NAME "GAUSSIAN_BLUR_VERTICAL"
			CGPROGRAM
			#pragma multi_compile BLUR_VERTICAL
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
