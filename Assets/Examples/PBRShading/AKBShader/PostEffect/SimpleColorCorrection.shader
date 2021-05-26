Shader "Hidden/AKB/SimpleColorCorrection" 
{
	Properties 
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Brightness ("Brightness", float) = 1
		_Saturation ("Saturation", float) = 1
		_Contrast ("Contrast", float) = 1
	}
	SubShader 
	{
		Pass
		{
			ZTest Always Cull Off ZWrite Off

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 
			#pragma multi_compile _ SCREEN_GAMMA_CORRECTION
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half _Brightness;
			half _Saturation;
			half _Contrast;

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

			fixed4 frag(v2f i) : SV_Target 
			{
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				//亮度
				fixed3 finalCol = mainTex * _Brightness;
				
				//饱和度
				fixed luminance = 0.2125 * mainTex.r + 0.7154 * mainTex.g + 0.0721 * mainTex.b;
				fixed3 luminanceCol = fixed3(luminance, luminance, luminance);
				finalCol = lerp(luminanceCol, finalCol, _Saturation);

				//对比度
				fixed3 avgCol = fixed3(0.5, 0.5, 0.5);
				finalCol = lerp(avgCol, finalCol, _Contrast);
				
				#if defined(SCREEN_GAMMA_CORRECTION)
				finalCol = pow(finalCol, 0.454);
				#endif

				return fixed4(finalCol, 1.0);
			}
			ENDCG
		}
	}
}
