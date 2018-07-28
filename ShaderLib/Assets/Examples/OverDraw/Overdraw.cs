using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Overdraw : MonoBehaviour 
{
    private Shader mOpaqueOverDrawShader;
    private Shader mTransparentOverDrawShader;
    private Camera mCamera;
    private Camera mOverDrawCamera;
    private CameraClearFlags mCurrentCameraClearFlags;
    private int mCullingMask;
    private RenderTexture mOverDrawRT;
    private bool mOverDrawMode = false;

    void Awake()
    {
        mCamera = GetComponent<Camera>();
        if (mOverDrawCamera == null)
        {
            mOverDrawCamera = new GameObject("OverDrawCamera", typeof(Camera)).GetComponent<Camera>();
            mOverDrawCamera.CopyFrom(mCamera);
            mOverDrawCamera.transform.parent = mCamera.transform;
            mOverDrawCamera.transform.localPosition = Vector3.zero;
            mOverDrawCamera.transform.localRotation = Quaternion.identity;
            mOverDrawCamera.transform.localScale = Vector3.one;
            mOverDrawCamera.enabled = false;
        }
        mCurrentCameraClearFlags = mCamera.clearFlags;
        mCullingMask = mCamera.cullingMask;
        mOpaqueOverDrawShader = Shader.Find("Custom/Overdraw-Opaque");
        mTransparentOverDrawShader = Shader.Find("Custom/Overdraw-Transparent");
    }

    void OnEnable()
    {
        mCamera.cullingMask = 0;
        mOverDrawCamera.clearFlags = CameraClearFlags.Nothing;
        if (mOverDrawRT == null)
        {
            mOverDrawRT = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
        }
        mOverDrawCamera.targetTexture = mOverDrawRT;
        mOverDrawMode = true;
    }

    void OnDisable()
    {
        mCamera.cullingMask = mCullingMask;
        mOverDrawCamera.targetTexture = null;
        mOverDrawCamera.clearFlags = mCurrentCameraClearFlags;
        mOverDrawCamera.ResetReplacementShader();
        mOverDrawMode = false;
    }

    void OnPreCull()
    {
        if (!mOverDrawMode)
        {
            return;
        }
        RenderTexture.active = mOverDrawRT;
        GL.Clear(true, true, Color.black);
        mOverDrawCamera.SetReplacementShader(mOpaqueOverDrawShader, "RenderType");
        mOverDrawCamera.Render();
        mOverDrawCamera.SetReplacementShader(mTransparentOverDrawShader, "RenderType");
        mOverDrawCamera.Render();
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (mOverDrawMode)
        {
            Graphics.Blit(mOverDrawRT, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
