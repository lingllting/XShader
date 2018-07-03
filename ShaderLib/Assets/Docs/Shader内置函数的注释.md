1. **float Linear01Depth(float z)** - 把ZBuffer里面的值转换到线性的0-1的空间中。
2. **float LinearEyeDepth(float z)** - 把ZBuffer里面的值转换到相机局部空间中（非视空间）。
3. **COMPUTE_EYEDEPTH(o)** - 把o设置为顶点在相机局部空间的Z值（需要v.vertex为模型空间）。
4. **float4 ComputeScreenPos(float4 pos)** - 把顶点从裁减空间转换到屏幕空间。
5. **UNITY_INITIALIZE_OUTPUT(type,name)** name = (type)0 - 结构体初始化函数
6. **float3 UnityObjectToWorldNormal(float3 dir)** - 把法线从模型空间转换到世界空间（归一化）。
7. **float3 UnityObjectToWorldDir( in float3 dir )** - 把方向从模型空间转换到世界空间（归一化）。
8. **float3 ObjSpaceViewDir( in float4 v )** - 计算模型空间下的视线方向（v为模型空间坐标，方向是看向相机）。
9. **float4 Parallax (float4 texcoords, half3 viewDir)** - 根据视差来调整UV坐标（texcoords为原始的UV坐标，viewDir为切空间下的视线方向（反））。
10. **half2 MetallicGloss(float2 uv)** - 获取材质像素点的金属度（x分量）和光泽度（y分量）。
11. **half3 DiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)** - 根据反射率（albedo）金属度（metallic）求出高光反射率（specColor）和漫反射率（返回值）。
12. **FragmentCommonData MetallicSetup (float4 i_tex)** - （金属流）设置漫反射率，高光反射率，1-高光反射比例，光泽度。
13. **half3 PerPixelWorldNormal(float4 i_tex, half4 tangentToWorld[3])** - 计算逐像素的世界空间法线（归一化）。
14. **half3 PreMultiplyAlpha (half3 diffColor, half alpha, half oneMinusReflectivity, out half outModifiedAlpha)** - 漫反射率在混合之前预先乘以alpha（返回值）outModifiedAlpha（预乘后的alpha值）。
15. **UnityGI UnityGlobalIllumination (UnityGIInput data, half occlusion, half smoothness, half3 normalWorld, bool reflections)** - 计算全局光照信息，reflections（是否需要计算间接光照的高光）。
16. **half3 FresnelTerm (half3 F0, half cosA)** - Schlick菲涅耳近似。

