Shader "Custom/Flow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RimMin("RimMin", Range(-1, 1)) = 0.0
        _RimMax("RimMax", Range(0, 2)) = 1.0
        _InnerColor("Inner Color", Color) = (1, 1, 1, 1)
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimIntensity("Rim Intensity", Float) = 1.0
        _FlowTex("Flow Tex", 2D) = "gray"{}
        _FlowTiling("Flow Tiling", Vector) = (1, 1, 0, 0)
        _FlowSpeed("Flow Speed", Float) = 1.0
        _FlowIntensity("Flow Intensity", Float) = 1.0
        _InnerAlpha("Inner Alpha", Float) = 0.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            
            ZWrite On
//            Blend SrcAlpha One
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 pivotWS :TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _RimMin;
            half _RimMax;
            half4 _InnerColor;
            half4 _RimColor;
            half _RimIntensity;
            float4 _FlowTiling;
            half _FlowSpeed;
            sampler2D _FlowTex;
            half _FlowIntensity;
            half _InnerAlpha;

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionCS = TransformObjectToHClip(v.positionOS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWS = normalize(TransformObjectToWorldNormal(v.normalOS));
                o.positionWS = TransformObjectToWorld(v.positionOS);
                o.pivotWS = TransformObjectToWorld(half4(0.0, 0.0, 0.0, 1.0));
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half3 worldNormal = normalize(i.normalWS);
                half3 worldView = normalize(_WorldSpaceCameraPos - i.positionWS);
                half NdotV = saturate(dot(worldNormal, worldView));
                half fresnel = 1 - NdotV;
                fresnel = smoothstep(_RimMin, _RimMax, fresnel);
                half4 diffuse = tex2D(_MainTex, i.uv);
                half emiss = diffuse.r;
                emiss = pow(emiss, 5);
                
                half finalFresnel = saturate(fresnel + emiss);
 
                half3 finalRimColor = lerp(_InnerColor.xyz, _RimColor.xyz * _RimIntensity, finalFresnel);
                half finalRimAlpha = finalRimColor;

                half2 flowUV = (i.positionWS.xy - i.pivotWS.xy) * _FlowTiling.x;
                flowUV = flowUV + float2(0, _Time.y * _FlowSpeed);
                float4 flowRGBA = tex2D(_FlowTex, flowUV) * _FlowIntensity;

                float3 finalColor = finalRimColor + flowRGBA.xyz + diffuse;
                float finalAlpha = saturate(finalRimAlpha + flowRGBA.a + _InnerAlpha);
                return half4(finalColor, finalAlpha);
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Back

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}
