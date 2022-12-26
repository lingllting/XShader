using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class StandardShaderTest : MonoBehaviour 
{
    bool isSimple = false;
	void Start () 
    {
		
	}
	
	void Update () 
    {
		if (Input.GetKeyDown(KeyCode.S))
        {
            isSimple = !isSimple;
            if (isSimple)
            {
                Shader.EnableKeyword("UNITY_NO_FULL_STANDARD_SHADER");
            }
            else
            {
                Shader.DisableKeyword("UNITY_NO_FULL_STANDARD_SHADER");
            }
        }
	}
}
