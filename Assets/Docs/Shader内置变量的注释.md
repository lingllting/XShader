## [官方文档](https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html)  
1. **_ZBufferParams** - 对ZBuffer值进行转换的参数.
2. **unity_WorldTransformParams.w** - 当物体的Scale值为负值时，w = -1，否则为1.
3. **VertexOutputForwardBase**
```
// ForwardBase Pass顶点着色器输出结构体
struct VertexOutputForwardBase
{
    //顶点的裁减空间坐标
    UNITY_POSITION(pos);
	//UV信息：xy为主纹理UV， zw为细节纹理UV
    float4 tex                          : TEXCOORD0;
	//归一化的视线方向（不一定会归一化...）
    half3 eyeVec                        : TEXCOORD1;
	//[3x3:世界空间到切空间的转换矩阵 or 切线空间下的视线方向（反方向） | 1x3:世界空间法线 or 世界空间坐标]
    half4 tangentToWorldAndPackedData[3]    : TEXCOORD2;    
	//光照贴图UV or 球谐光照UV
    half4 ambientOrLightmapUV           : TEXCOORD5;
	//阴影UV
    UNITY_SHADOW_COORDS(6)
	//雾UV
    UNITY_FOG_COORDS(7)
	//世界空间坐标
    #if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
        float3 posWorld                 : TEXCOORD8;
    #endif
	//GPU Instance
    UNITY_VERTEX_INPUT_INSTANCE_ID
	//VR
    UNITY_VERTEX_OUTPUT_STEREO
};
```
4. 

