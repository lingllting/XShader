using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CameraDepthEnable : MonoBehaviour 
{
	void OnEnable ()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
	}
}
