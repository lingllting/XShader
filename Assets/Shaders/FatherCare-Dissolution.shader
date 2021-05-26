Shader "FatherCare/Dissolution" 
{
    Properties 
	{
        _TintColor ("Color&Alpha", Color) = (1,1,1,1)
        _MainTex ("Diffuse Texture", 2D) = "white" {}
		_ColorStrengthen ("Color Strengthen", Float) = 1
        _AlphaThreshold ("Alpha Threshold", Float ) = 0.3
		[Space(10)]
        _AlphaMaskTex1 ("Dissolve Texture", 2D) = "white" {}
		[Toggle] _InvertMaskTex1Alpha ("Invert DissolveTexture Alpha", Float) = 0
		[Space(10)]
		_AlphaMaskTex2 ("Dissolve Texture", 2D) = "white" {}
		[Toggle] _InvertMaskTex2Alpha ("Invert DissolveTexture Alpha", Float) = 0
		[Space(10)]
        _EdgeColor ("Edge Color", Color) = (1,0,0,1)
        _EdgeColorStrengthen ("Edge Color Strengthen", Float ) = 3
        _EdgeWidth ("Edge Width", Float ) = 0.01

		_ScrollXSpeed ("MainTexture : X Scroll Speed",Float) = 0  
		_ScrollYSpeed ("MainTexture : Y Scroll Speed", Float) = 0
		_Mask1ScrollXSpeed ("Dissolve Texture 1 : X Scroll Speed", Float) = 0  
		_Mask1ScrollYSpeed ("Dissolve Texture 1 : Y Scroll Speed", Float) = 0
		_Mask2ScrollXSpeed ("Dissolve Texture 2 : X Scroll Speed", Float) = 0  
		_Mask2ScrollYSpeed ("Dissolve Texture 2 : Y Scroll Speed", Float) = 0

		[Enum(Additive, 1, AlphaBlend, 10)] _DstBlend ("Additive/AlphaBlend", Float) = 1
    }

    SubShader 
	{
        Tags 
		{
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass 
		{
            Name "FORWARD"
            Tags 
			{
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha [_DstBlend]
            ZWrite Off
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 2.0

			uniform sampler2D _MainTex; 
			uniform float4 _MainTex_ST;
            uniform sampler2D _AlphaMaskTex1; 
			uniform float4 _AlphaMaskTex1_ST;
			uniform sampler2D _AlphaMaskTex2; 
			uniform float4 _AlphaMaskTex2_ST;

            uniform float4 _TintColor;
			uniform float _ColorStrengthen;
            uniform float _AlphaThreshold;
            uniform float _EdgeWidth;
            uniform float4 _EdgeColor;
            uniform float _EdgeColorStrengthen;
			uniform float _InvertMaskTex1Alpha;
			uniform float _InvertMaskTex2Alpha;

			fixed _ScrollXSpeed;  
			fixed _ScrollYSpeed;
			fixed _Mask1ScrollXSpeed;
			fixed _Mask1ScrollYSpeed;
			fixed _Mask2ScrollXSpeed;
			fixed _Mask2ScrollYSpeed;

            struct VertexInput 
			{
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput 
			{
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(VertexOutput i) : COLOR 
			{
                float4 mainTexColor = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex) + float2 (_ScrollXSpeed, _ScrollYSpeed) * _Time.y);
                float3 emissive = _TintColor.rgb * mainTexColor.rgb * i.vertexColor.rgb;
                float alphaThreshold = (i.vertexColor.a * _AlphaThreshold);

                float4 maskTexColor1 = tex2D(_AlphaMaskTex1,TRANSFORM_TEX(i.uv0, _AlphaMaskTex1) + float2 (_Mask1ScrollXSpeed, _Mask1ScrollYSpeed) * _Time.y);
				float4 maskTexColor2 = tex2D(_AlphaMaskTex2,TRANSFORM_TEX(i.uv0, _AlphaMaskTex2) + float2 (_Mask2ScrollXSpeed, _Mask2ScrollYSpeed) * _Time.y);
				float alpha = lerp(maskTexColor1.r, 1 - maskTexColor1.r, _InvertMaskTex1Alpha) * lerp(maskTexColor2.r, 1 - maskTexColor2.r, _InvertMaskTex2Alpha);
                float step1 = step(alphaThreshold, alpha);
                float step2 = step(alpha, alphaThreshold);
				//是否已被溶解：1-未被溶解，0-被溶解
                float isDissolved = lerp(step2, 1, step1 * step2);
                float step3 = step(alphaThreshold, (alpha + _EdgeWidth));
                float step4 = step((alpha + _EdgeWidth), alphaThreshold);
				//是否是边缘：1-是，0-否
                float isEdge = (isDissolved - lerp(step4, 1 ,step3 * step4));

                float3 finalColor = emissive * _ColorStrengthen + ((isEdge * _EdgeColor.rgb) * _EdgeColorStrengthen);
                return fixed4(finalColor, (_TintColor.a * (mainTexColor.a * (isDissolved + isEdge))));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
