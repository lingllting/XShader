using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

public class AKBMenuItem 
{
    [MenuItem("Tools/重新导入Character模型")]
    public static void ReImportCharaterModel()
    {
        string path = "Assets/GameData/Models/Character/";
        AssetDatabase.ImportAsset(path, ImportAssetOptions.ImportRecursive);
        EditorUtility.DisplayDialog("ReImport Character", "ReImport Models success", "OK");
    }


    /*[MenuItem("Tools/Material重新设置Shader")]
    public static void ResetMaterialShaderAll()
    {
        string[] ids = AssetDatabase.FindAssets("t:Material");
        for (int i = 0; i < ids.Length; ++i)
        {
            string path = AssetDatabase.GUIDToAssetPath(ids[i]);
            Material mat = AssetDatabase.LoadAssetAtPath(path, typeof(Material)) as Material;
            mat.shader = mat.shader;
        }
        AssetDatabase.SaveAssets();
        EditorUtility.DisplayDialog("Reset Material Shader", "Reset success", "OK");
    }*/

    [MenuItem("Assets/材质检查工具/刷新Material")]
    public static void UpdateMaterial()
    {
        Material[] mats = Selection.GetFiltered<Material>(SelectionMode.DeepAssets);
        for (int i = 0; i < mats.Length; i++)
        {
            mats[i].shader = mats[i].shader;
        }
        AssetDatabase.SaveAssets();
        EditorUtility.DisplayDialog("Reset Material Shader", "Reset success", "OK");
    }

    [MenuItem("Assets/材质检查工具/检查无用Material")]
    public static void CheckInvalidMaterial()
    {
        Material[] mats = Selection.GetFiltered<Material>(SelectionMode.DeepAssets);
        for (int i = 0; i < mats.Length; i++)
        {
            if (!mats[i].shader.isSupported)
            {
                Debug.Log("Invalid Material, Path : " + AssetDatabase.GetAssetPath(mats[i].GetInstanceID()));
            }
        }
        EditorUtility.DisplayDialog("Check Material Valid", "Check Complete", "OK");
    }

    [MenuItem("Assets/材质检查工具/检查并删除无用Material")]
    public static void DeleteInvalidMaterial()
    {
        Material[] mats = Selection.GetFiltered<Material>(SelectionMode.DeepAssets);
        for (int i = 0; i < mats.Length; i++)
        {
            if (!mats[i].shader.isSupported)
            {
                Debug.Log("Invalid Material, Path : " + AssetDatabase.GetAssetPath(mats[i].GetInstanceID()));
                AssetDatabase.DeleteAsset(AssetDatabase.GetAssetPath(mats[i].GetInstanceID()));
            }
        }
        AssetDatabase.Refresh();
        EditorUtility.DisplayDialog("Delete Invalid Material", "Delete Complete", "OK");
    }


    #region 场景设置
    static void RecursiveSetMeshRender(Transform t, Action<MeshRenderer> meshRenderAction)
    {
        MeshRenderer mr = t.GetComponent<MeshRenderer>();
        if (mr)
        {
            meshRenderAction(mr);
        }

        for (int i = 0; i < t.childCount; ++i)
        {
            RecursiveSetMeshRender(t.GetChild(i), meshRenderAction);
        }
    }

    [MenuItem("GameObject/场景物件设置/打开Probe", false, 20)]
    public static void EnableProbe()
    {
        if (Selection.activeGameObject == null)
        {
            Debug.LogError("请选择根节点");
            return;
        }
        RecursiveSetMeshRender(Selection.activeGameObject.transform, (mr) =>
        {
            mr.lightProbeUsage = LightProbeUsage.BlendProbes;
            mr.reflectionProbeUsage = ReflectionProbeUsage.BlendProbes;
        });
    }

    [MenuItem("GameObject/场景物件设置/关闭Probe", false, 20)]
    public static void DisableProbe()
    {
        if (Selection.activeGameObject == null)
        {
            Debug.LogError("请选择根节点");
            return;
        }
        RecursiveSetMeshRender(Selection.activeGameObject.transform, (mr) =>
        {
            mr.lightProbeUsage = LightProbeUsage.Off;
            mr.reflectionProbeUsage = ReflectionProbeUsage.Off;
        });
    }


    [MenuItem("GameObject/场景物件设置/打开Cast Shadow", false, 20)]
    public static void EnableCastShadow()
    {
        if (Selection.activeGameObject == null)
        {
            Debug.LogError("请选择根节点");
            return;
        }
        RecursiveSetMeshRender(Selection.activeGameObject.transform, (mr) => mr.shadowCastingMode = ShadowCastingMode.On);
    }

    [MenuItem("GameObject/场景物件设置/关闭Cast Shadow", false, 20)]
    public static void DisableCastShadow()
    {
        if (Selection.activeGameObject == null)
        {
            Debug.LogError("请选择根节点");
            return;
        }
        RecursiveSetMeshRender(Selection.activeGameObject.transform, (mr) => mr.shadowCastingMode = ShadowCastingMode.Off);
    }


    [MenuItem("GameObject/场景物件设置/打开Receive Shadow", false, 20)]
    public static void EnableReceiveShadow()
    {
        if (Selection.activeGameObject == null)
        {
            Debug.LogError("请选择根节点");
            return;
        }
        RecursiveSetMeshRender(Selection.activeGameObject.transform, (mr) => mr.receiveShadows = true);
    }

    [MenuItem("GameObject/场景物件设置/关闭Receive Shadow", false, 20)]
    public static void DisableReceiveShadow()
    {
        if (Selection.activeGameObject == null)
        {
            Debug.LogError("请选择根节点");
            return;
        }
        RecursiveSetMeshRender(Selection.activeGameObject.transform, (mr) => mr.receiveShadows = false);
    }
    #endregion
}
