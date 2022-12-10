using UnityEditor;
using UnityEngine;

/// <summary>
/// 配置管理器（开发阶段）
/// 只能在开发阶段使用，发布后无法修改存储数据
/// </summary>
public class ConfigManager
{
    public static T Get<T>() where T : ScriptableObject
    {
        var className = typeof(T).Name;
        var settings = Resources.Load<T>(className);
        if (settings == null)
        {
            settings = ScriptableObject.CreateInstance<T>();

#if UNITY_EDITOR
            AssetDatabase.CreateAsset(settings, $"Assets/Resources/{className}.asset");
            AssetDatabase.Refresh();
#endif
        }

        return settings;
    }
}

