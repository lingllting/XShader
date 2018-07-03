1. ==float Linear01Depth(float z)== - 把ZBuffer里面的值转换到线性的0-1的空间中。
2. ==float LinearEyeDepth(float z)== - 把ZBuffer里面的值转换到相机局部空间中（非视空间）。
3. ==COMPUTE_EYEDEPTH(o)== - 把o设置为顶点在相机局部空间的Z值（需要v.vertex为模型空间）。
4. ==float4 ComputeScreenPos(float4 pos)== - 把顶点从裁减空间转换到屏幕空间。
5. ==UNITY_INITIALIZE_OUTPUT(type,name)== name = (type)0 - 结构体初始化函数
6. ==float3 UnityObjectToWorldNormal(float3 dir)== - 把法线从模型空间转换到世界空间（归一化）。
7. ==float3 UnityObjectToWorldDir( in float3 dir )== - 把方向从模型空间转换到世界空间（归一化）。
8. 

