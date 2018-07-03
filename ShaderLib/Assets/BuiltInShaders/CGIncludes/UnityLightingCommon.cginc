// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_LIGHTING_COMMON_INCLUDED
#define UNITY_LIGHTING_COMMON_INCLUDED

fixed4 _LightColor0;
fixed4 _SpecColor;

struct UnityLight
{
    half3 color;
    half3 dir;
    half  ndotl; // Deprecated: Ndotl is now calculated on the fly and is no longer stored. Do not used it.
};

struct UnityIndirect
{
	//间接光照漫反射
    half3 diffuse;
	//间接光照高光反射
    half3 specular;
};

struct UnityGI
{
	//像素光信息
    UnityLight light;
	//间接光照信息
    UnityIndirect indirect;
};

struct UnityGIInput
{
	//像素光信息
    UnityLight light; // pixel light, sent from the engine
	//世界空间位置
    float3 worldPos;
	//世界空间视线（反）
    half3 worldViewDir;
	//光源衰减系数
    half atten;
	//环境光
    half3 ambient;

    // interpolated lightmap UVs are passed as full float precision data to fragment shaders
    // so lightmapUV (which is used as a tmp inside of lightmap fragment shaders) should
    // also be full float precision to avoid data loss before sampling a texture.
	//光照贴图UV
    float4 lightmapUV; // .xy = static lightmap UV, .zw = dynamic lightmap UV
	//Probe相关
    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    float4 boxMin[2];
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
    float4 boxMax[2];
    float4 probePosition[2];
    #endif
    // HDR cubemap properties, use to decompress HDR texture
    float4 probeHDR[2];
};

#endif
