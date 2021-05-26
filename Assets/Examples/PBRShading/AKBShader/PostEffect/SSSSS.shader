Shader "Hidden/AKB/SSSSS" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	CGINCLUDE
	#pragma multi_compile HIGH_QUALITY LOW_QUALITY
	#include "UnityCG.cginc"
	
	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	half4 _MainTex_TexelSize;
	sampler2D _CameraDepthTexture;	//built-in
	
	float2 step;
	float correction;
	
	
	v2f vert(appdata_img v) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;

		return o;
	} 
	
	half4 GaussianBlur(v2f i)
	{
		
		// Gaussian weights for the six samples around the current pixel:
		//   -3 -2 -1 +1 +2 +3
		#if defined (HIGH_QUALITY)
		float w[6] = { 0.006f,   0.061f,   0.242f,  0.242f,  0.061f, 0.006f };
		float o[6] = {  -1.0f, -0.6667f, -0.3333f, 0.3333f, 0.6667f,   1.0f };
		#else
		float w[2] = {0.309f,  0.309f};
		float o[2] = {-0.3333f, 0.3333f};
		#endif

		// Fetch color and linear depth for current pixel:
		half4 colorM = tex2D(_MainTex, i.uv);
		half depthM =  Linear01Depth(tex2D (_CameraDepthTexture, i.uv));
		//float depthM =  DecodeFloatRG(tex2D (_CameraDepthNormalsTexture, i.uv).zw);
		// Accumulate center sample, multiplying it with its gaussian weight:
		half4 colorBlurred = colorM;
		colorBlurred.rgb *= 0.382f;
		
		// Calculate the step that we will use to fetch the surrounding pixels,
		// where "step" is:
		//     step = sssStrength * gaussianWidth * pixelSize * dir
		// The closer the pixel, the stronger the effect needs to be, hence
		// the factor 1.0 / depthM.
		half2 finalStep = colorM.a * step / depthM;
		#if defined (HIGH_QUALITY)
		for (int j = 0; j < 6; ++ j)
		#else
		for (int j = 0; j < 2; ++ j)
		#endif
		{
			// Fetch color and depth for current sample:
			half2 offset = i.uv + o[j] * finalStep;

			half4 colTex =  tex2D(_MainTex, offset);
			//减少衣服的颜色被模糊到皮肤上
			//float3 color = lerp(colorM.rgb, colTex.rgb, colTex.a);
			half3 color = colTex.a < 1 ? colorM : colTex;

			half depth =  Linear01Depth(tex2D (_CameraDepthTexture, offset));
			// If the difference in depth is huge, we lerp color back to "colorM":
			half s = min(0.0125 * correction * abs(depthM - depth), 1);
			color = lerp(color, colorM.rgb, s);
			// Accumulate:
			colorBlurred.rgb += w[j] * color;
		}
		return colorBlurred;
	}
	
	half4 fragBlur(v2f i) : SV_Target 
	{
		half4 o = GaussianBlur(i);

		return o;
	}
	

	float4 _BlendFactor;
	sampler2D _SumTex; 

	half4 fragSum(v2f i) : SV_Target
	{
		half4 colorBlurred = tex2D(_MainTex, i.uv);
		half4 colorSum = tex2D(_SumTex, i.uv);
		half4 o;
		o.rgb = lerp(colorSum.rgb, colorBlurred.rgb, _BlendFactor.rgb);
		o.a = colorBlurred.a;

		return o;
	}
	ENDCG 

	SubShader 
	{
		Stencil
		{
			Ref 3
			Comp Equal
		}

		Pass {
			ZTest Always Cull Off ZWrite Off

		    CGPROGRAM
		    #pragma vertex vert
		    #pragma fragment fragBlur
		    ENDCG
		}
		
		Pass {
			ZTest Always Cull Off ZWrite Off
 
		    CGPROGRAM
		    #pragma vertex vert
		    #pragma fragment fragSum
		    ENDCG
		}
	} 
	FallBack off
}