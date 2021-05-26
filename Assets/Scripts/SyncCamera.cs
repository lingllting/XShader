using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SyncCamera : MonoBehaviour 
{
    public bool sync = true;
    public bool resume = true;

    private Vector3 lastPosition;
    private Quaternion lastRotation;


    void Start()
    {
        if (Application.isPlaying)
        {
            sync = false;
        }
    }


    void OnRenderObject()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            UnityEditorInternal.InternalEditorUtility.RepaintAllViews();
        }
#endif
    }

    void OnPreCull()
    {
#if UNITY_EDITOR
        if (sync)
        {
            UnityEditor.SceneView sceneView = UnityEditor.SceneView.lastActiveSceneView;
            if (sceneView)
            {
                Transform t = sceneView.camera.transform;
                lastPosition = transform.position;
                lastRotation = transform.rotation;
                transform.position = t.position;
                transform.rotation = t.rotation;
            }
        }
#endif
    }

    void OnPostRender()
    {
        if (sync && resume)
        {
            transform.position = lastPosition;
            transform.rotation = lastRotation;
        }
    }
	
}
