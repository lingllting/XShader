Shader "Unlit/Dragon"
{
    Properties
    {
        _DiffuseColor ("Diffuse", Color) = (1, 1, 1, 1)
        _AddColor ("Add Color", Color) = (1, 1, 1, 1)
        _BackLightColor ("Back Light Color", Color) = (1, 1, 1, 1)
        _Opacity ("Opacity", Range(0.0, 1.0)) = 1.0
        _ThicknessMap ("Thickness Map", 2D) = "black"{}
        _Distort ("Distort", Float) = 1.0
        _Power ("Power", Float) = 1.0
        _Scale ("_Scale", Float) = 1.0
        _CubeMap ("Cube Map", Cube) = "white"{}
        _EnvRotate ("Env Rotate", Range(0, 360)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            
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

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ThicknessMap;

            float4 _LightColor0;
            float _Distort;
            float _Power;
            float _Scale;
            samplerCUBE _CubeMap;
            float4 _CubeMap_HDR;
            float _EnvRotate;
            float3 _DiffuseColor;
            float3 _AddColor;
            float3 _BackLightColor;
            float _Opacity;

            float3 Rotate(float angle, float3 target)
            {
                float radius = angle * 3.14159265359f / 180;
                float2x2 rotateMatrix = float2x2(cos(radius), -sin(radius), sin(radius), cos(radius));
                float2 rotatedReflectDir = mul(rotateMatrix, target.xz);
                target = float3(rotatedReflectDir.x, target.y, rotatedReflectDir.y);
                return target;
            }

            v2f vert (Attributes v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionWS = TransformObjectToWorld(v.positionOS);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                Light light = GetMainLight();
                Light additionalLight = GetAdditionalLight(0, i.positionWS);
                float3 normalWS = normalize(i.normalWS);
                float3 viewWS = normalize(_WorldSpaceCameraPos - i.positionWS);
                float3 lightDirWS = normalize(light.direction);

                // diffuse
                float diffuseTerm = saturate(dot(lightDirWS, normalWS));
                float3 diffuseColor = diffuseTerm * _DiffuseColor * light.color;

                float skyLight = (dot(normalWS, float3(0, 1, 0)) + 1) * 0.5;
                float3 skyLightColor = skyLight * diffuseColor;
                float3 finalDiffuseColor = diffuseColor + _AddColor + skyLightColor * _Opacity;

                // back light
                float3 backDir = -normalize(lightDirWS + normalWS * _Distort);
                // float NdotL = saturate(dot(normalWS, lightDirWS));
                float VdotL = saturate(dot(viewWS, backDir));
                float backLightTerm = pow(VdotL, _Power) * _Scale;
                float thickness = 1 - tex2D(_ThicknessMap, i.uv).r;
                float3 backColor = backLightTerm * light.color * _BackLightColor * thickness + backLightTerm * additionalLight.color * _BackLightColor * thickness * additionalLight.distanceAttenuation;

                //environment
                float3 reflectDir = reflect(-lightDirWS, normalWS);
                float3 rotatedReflectDir = Rotate(_EnvRotate, reflectDir);
                float fresnel = 1.0 - saturate(dot(normalWS, viewWS));
                float4 hdrColor = texCUBE(_CubeMap, rotatedReflectDir);
                float3 envColor = DecodeHDREnvironment(hdrColor, _CubeMap_HDR);
                float3 finalEnvColor = envColor * fresnel;

                float3 finalColor = backColor + finalEnvColor + finalDiffuseColor;
                return float4(finalColor, 1);
            }
            ENDHLSL
        }
    }
}
