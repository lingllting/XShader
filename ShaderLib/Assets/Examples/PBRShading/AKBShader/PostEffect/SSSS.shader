Shader "Hidden/AKB/SSSS" {
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

	int nSamples;
	float4 kernel[11];
	
	float sssWidth;
	half2 dir;
	float cameraFov;

	v2f vert(appdata_img v) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;

		return o;
	} 

	half4 fragBlur(v2f i) : SV_Target 
	{
		half4 colorM = tex2D(_MainTex, i.uv);
		half depthM =  LinearEyeDepth(tex2D (_CameraDepthTexture, i.uv));
	
		float distanceToProjectionWindow = 1.0 / tan(0.5 * radians(cameraFov));
		float scale = distanceToProjectionWindow / depthM;
		float2 finalStep = sssWidth * scale * dir;

		finalStep *= colorM.a; // Modulate it using the alpha channel.
		finalStep *= 1.0 / 3.0; // Divide by 3 as the kernels range from -3 to 3.

		half4 colorBlurred = colorM;
		colorBlurred.rgb *= kernel[0].rgb;

		for (int j = 1; j < nSamples; ++j) 
		{
			// Fetch color and depth for current sample:
			float2 offset = i.uv + kernel[j].a * finalStep;
			half4 colTex =  tex2D(_MainTex, offset);
			half4 color = colTex.a < 1 ? colorM : colTex;

			float depth = LinearEyeDepth(tex2D (_CameraDepthTexture, offset));
			float s = saturate(300.0f * distanceToProjectionWindow *
								   sssWidth * abs(depthM - depth));
			color.rgb = lerp(color.rgb, colorM.rgb, s);
		
			colorBlurred.rgb += kernel[j].rgb * color.rgb;
		}
		
		return colorBlurred;
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
	} 
	FallBack off
}

