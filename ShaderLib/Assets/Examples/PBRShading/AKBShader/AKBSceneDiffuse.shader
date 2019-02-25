﻿Shader "AKB/Scene/Diffuse" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert finalcolor:FinalColor
		#include "AKBCommon.cginc"

		#pragma multi_compile _ GLOBAL_COLOR
		#pragma multi_compile _ CHANGE_SHADOW_COLOR
		#pragma multi_compile _ GLOBAL_EMISSION

		sampler2D _MainTex;
		fixed4 _Color;

		struct Input 
		{
			float2 uv_MainTex;
		};

		void FinalColor(Input i, SurfaceOutput o, inout fixed4 color)
		{
			SetGlobalColor(color);
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	Fallback "Legacy Shaders/VertexLit"
}
