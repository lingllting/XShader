using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

public class TextureInfo
{
    public string Name;
    public int Width;
    public int Height;
    public int Bytes;
}

public class EffectPerformanceReport
{
    public string Path;
    public float LoadTime;
    public float InstantiateTime;
    public float MinRenderTime;
    public float MaxRenderTime;
    public float TopAverageRenderTime;
    public float MaxRenderTimeOccurTime;
    public int ActiveRendererCount;
    public int TotalParticleSystemCount;
    public int MaterialCount;
    public int MaxParticleCount;
    public int TextureMemoryBytes;
    public int TextureMemoryCount;
    public Dictionary<string, TextureInfo> TextureInfoDict = new Dictionary<string, TextureInfo>();
}

public class EffectPerformanceTool : MonoBehaviour
{
    public int InstanceCount = 20;
    public float TestDuration = 5;
    public int TopNFrame = 5;
    public const string FX_PATH = "Assets\\Resources\\";

    private List<EffectPerformanceReport> mReportList = new List<EffectPerformanceReport>();
    private List<GameObject> mFxInstanceList = new List<GameObject>();

    private bool isCoroutineRunning = false;

    void Start()
    {
        if (!Directory.Exists(FX_PATH))
        {
            Debug.LogError("无法找到FX文件夹： " + FX_PATH);
            return;
        }

        StartCoroutine(StartAnalyze());
    }

    IEnumerator StartAnalyze()
    {
        DirectoryInfo directoryInfo = new DirectoryInfo(FX_PATH);
        FileInfo[] files = directoryInfo.GetFiles("*.prefab", SearchOption.AllDirectories);

        while (mReportList.Count < files.Length)
        {
            if (!isCoroutineRunning)
            {
                string fxPath = files[mReportList.Count].DirectoryName.Substring(files[mReportList.Count].DirectoryName.LastIndexOf("Assets"));
                fxPath.Replace("\\", "/");
                fxPath = fxPath + "/" + files[mReportList.Count].Name;
                this.transform.name = string.Format("Analyzing...({0}/{1})", mReportList.Count, files.Length);
                yield return StartCoroutine(AnalyzeSingleFx(fxPath));
            }
        }

        ExcelAccess.WriteExcel(mReportList, ExcelAccess.FilePath("EffectReportTool/EffectReport.xlsx"));
        AssetDatabase.Refresh();
    }


    IEnumerator AnalyzeSingleFx(string fxPath)
    {
        isCoroutineRunning = true;

        EffectPerformanceReport report = new EffectPerformanceReport();
        report.Path = fxPath;

        //清除缓存资源
        System.GC.Collect();
        AsyncOperation async = Resources.UnloadUnusedAssets();
        yield return async;
        yield return new WaitForEndOfFrame();
        yield return new WaitForEndOfFrame();

        //加载
        float t1 = Time.realtimeSinceStartup;
        //GameObject fxAsset = Resources.Load<GameObject>(fxPath);
        GameObject fxAsset;
        try
        {
            fxAsset = AssetDatabase.LoadAssetAtPath<GameObject>(fxPath);
        }
        catch (System.Exception e)
        {
            yield break;
        }
        float t2 = Time.realtimeSinceStartup;
        report.LoadTime = (t2 - t1) * 1000;
        yield return new WaitForEndOfFrame();
        yield return new WaitForEndOfFrame();
        if (fxAsset == null)
        {
            yield break;
        }

        report.TotalParticleSystemCount = fxAsset.GetComponentsInChildren<ParticleSystem>(true).Length;
        Renderer[] fxRenderers = fxAsset.GetComponentsInChildren<Renderer>();
        Dictionary<Material, bool> fxMaterials = new Dictionary<Material, bool>();
        int activeRendererCount = 0; 
        foreach (var renderer in fxRenderers)
        {
            bool has = false;
            if (renderer.sharedMaterial != null && fxMaterials.TryGetValue(renderer.sharedMaterial, out has) == false)
            {
                fxMaterials.Add(renderer.sharedMaterial, true);
            }
            if (renderer.enabled)
            {
                activeRendererCount++;
            }
        }
        report.ActiveRendererCount = activeRendererCount;
        report.MaterialCount = fxMaterials.Count;
        yield return new WaitForEndOfFrame();
        yield return new WaitForEndOfFrame();

        //实例化
        GameObject fxInstance = null;
        t2 = Time.realtimeSinceStartup;
        for (int i = 0; i < InstanceCount; i++)
        {
            GameObject go = GameObject.Instantiate(fxAsset);
            go.transform.position = Vector3.zero;
            mFxInstanceList.Add(go);
            if (i == 0)
            {
                fxInstance = go;
            }
        }
        float t3 = Time.realtimeSinceStartup;
        report.InstantiateTime = (t3 - t2) * 1000f / InstanceCount;
        yield return new WaitForEndOfFrame();
        yield return new WaitForEndOfFrame();
        yield return new WaitForEndOfFrame();

        //渲染
        ParticleSystem[] systems = fxInstance.GetComponentsInChildren<ParticleSystem>();
        float t4 = 0;
        int frame = 0;
        report.MinRenderTime = float.MaxValue;
        report.MaxRenderTime = float.MinValue;
        List<float> timeList = new List<float>();
        while (t4 < TestDuration)
        {
            float dt = Time.deltaTime;
            frame++;
            report.MinRenderTime = Mathf.Min(report.MinRenderTime, dt);
            if (dt > report.MaxRenderTime)
            {
                report.MaxRenderTime = dt;
                report.MaxRenderTimeOccurTime = t4;
            }
            timeList.Add(dt * 1000);
            t4 += dt;
            int particleCount = 0;
            for (int i = 0; i < systems.Length; i++)
            {
                particleCount += systems[i].particleCount;
            }
            if (report.MaxParticleCount < particleCount)
            {
                report.MaxParticleCount = particleCount;
            }
            yield return new WaitForEndOfFrame();
        }

        report.MinRenderTime *= 1000 / InstanceCount;
        report.MaxRenderTime *= 1000 / InstanceCount;
        timeList.Sort();
        timeList.Reverse();
        float avg = 0;
        int topN = Mathf.Min(TopNFrame, timeList.Count);
        for (int i = 0; i < topN; i++)
        {
            avg += timeList[i];
        }
        report.TopAverageRenderTime = avg / topN / InstanceCount;
        yield return new WaitForEndOfFrame();

        Dictionary<string, TextureInfo> texNames = GetTextureMemoryAndCount(systems);
        foreach (var t in texNames)
        {
            //if ()
            report.TextureInfoDict.Add(t.Key, t.Value);
            report.TextureMemoryBytes += t.Value.Bytes;
            report.TextureMemoryCount++;
        }

        //清理
        foreach(var fx in mFxInstanceList)
        {
            Object.DestroyImmediate(fx);
        }
        mFxInstanceList.Clear();
        yield return new WaitForEndOfFrame();
        yield return new WaitForEndOfFrame();
        yield return new WaitForEndOfFrame();
        yield return new WaitForEndOfFrame();

        mReportList.Add(report);
        isCoroutineRunning = false;
    }

    private Dictionary<string, TextureInfo> GetTextureMemoryAndCount(ParticleSystem[] systems)
    {
        Dictionary<string, TextureInfo> textureInfoDict = new Dictionary<string, TextureInfo>();
        Texture[] textures = Resources.FindObjectsOfTypeAll<Texture>();
        for (int i = 0; i < textures.Length; i++)
        {
            for (int j = 0; j < systems.Length; j++)
            {
                if (textures[i] == systems[j].GetComponent<Renderer>().sharedMaterial.mainTexture)
                {
                    TextureInfo textureInfo = new TextureInfo();
                    textureInfo.Name = textures[i].name;
                    textureInfo.Width = textures[i].width;
                    textureInfo.Height = textures[i].height;
                    textureInfo.Bytes = (int)UnityEngine.Profiling.Profiler.GetRuntimeMemorySizeLong(textures[i]) / 1024;
                    textureInfoDict[textureInfo.Name] = textureInfo;
                }
            }
        }
        return textureInfoDict;
    }
}
