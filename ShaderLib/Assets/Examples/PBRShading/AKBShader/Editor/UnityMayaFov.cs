using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


public class UnityMayaFov : EditorWindow
{
    [MenuItem("Tools/UnityMayaFov")]
    public static void ShowFovWindow()
    {
        EditorWindow.GetWindowWithRect(typeof(UnityMayaFov), new Rect(100, 100, 400, 300));
    }

    float aspect = 1;
    float width = 0;
    float height = 0;
    public float mayaFov = 0;
    public float unityFov = 0;


    void OnGUI()
    {
        width = EditorGUILayout.FloatField("Width", width);
        height = EditorGUILayout.FloatField("Height", height);
        mayaFov = EditorGUILayout.FloatField("Maya Fov", mayaFov);
        unityFov = EditorGUILayout.FloatField("Unity Fov", unityFov);

        if (width <= 0 || height <= 0 || mayaFov < 0 || mayaFov > 180 || unityFov < 0 || unityFov > 180
            || (mayaFov == 0 && unityFov == 0) || (mayaFov > 0 && unityFov > 0))
        {
            GUI.enabled = false;
        }
        else
        {
            aspect = width / height;
        }
        if (GUILayout.Button("计算", GUILayout.Width(60)))
        {
            if (mayaFov == 0)
            {
                mayaFov = Mathf.Atan(Mathf.Tan(unityFov/2 * Mathf.Deg2Rad)  * aspect) * 2 * Mathf.Rad2Deg;
            }
            else if (unityFov == 0)
            {
                unityFov = Mathf.Atan(Mathf.Tan(mayaFov / 2 * Mathf.Deg2Rad) / aspect) * 2 * Mathf.Rad2Deg;
            }
        }
        GUI.enabled = true;
    }
}
