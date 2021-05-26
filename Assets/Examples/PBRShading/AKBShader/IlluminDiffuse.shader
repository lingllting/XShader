Shader "AKB/SelfIllumin/Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Illum ("Illumin (A)", 2D) = "white" {}
	_Fade ("Soft Particles Factor", Range(0.01,1)) = 1
}
SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 200
	
CGPROGRAM
#pragma surface surf Lambert finalcolor:FinalModifyColor
#pragma multi_compile __ GLOBAL_COLOR
#include "AKBCommon.cginc"

sampler2D _MainTex;
sampler2D _Illum;
fixed4 _Color;
float _Fade;

struct Input {
	float2 uv_MainTex;
	float2 uv_Illum;
};

void FinalModifyColor(Input IN, SurfaceOutput o, inout fixed4 color)
{
	SetGlobalColor(color);
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	fixed4 c = tex * _Color;
	o.Albedo = c.rgb * _Fade;
	o.Emission = c.rgb * tex2D(_Illum, IN.uv_Illum).a * _Fade;
	o.Alpha = c.a * _Fade;
}
ENDCG
} 
FallBack "Legacy Shaders/Self-Illumin/VertexLit"
CustomEditor "LegacyIlluminShaderGUI"
}
