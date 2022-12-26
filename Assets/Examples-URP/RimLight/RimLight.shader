Shader "Custom/RimLight"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white"{}
        _MainColor("Main Color", Color) = (1,1,1,1)
        _RimPower("Rim Power", Float) = 1.0
        _Emiss("_Emiss", Float) = 1.0
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }
        Pass
        {
            ZWrite On
            ColorMask 0
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            float4 _color;

            Varyings vert(Attributes input)
            {
                Varyings o;
                o.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return o;
            }

            float4 frag(Varyings input) : SV_Target
            {
                return _color;
            }
            ENDHLSL
        }
        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha
            Blend SrcAlpha One
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half2 uv : TEXCOORD0;
                float3 normalOS : Normal;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                half2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            };

            float3 _MainColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _RimPower;
            float _Emiss;

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag(Varyings i) : SV_Target
            {
                float3 worldNormal = normalize(i.normalWS);
                float3 worldView = normalize(_WorldSpaceCameraPos - i.positionWS);
                float fresnel = pow(saturate(1 - dot(worldNormal, worldView)), _RimPower);

                float3 color = _MainColor * _Emiss;
                float alpha = fresnel * _Emiss;
                return float4(color, alpha);
            }
            ENDHLSL
        }
    }
}