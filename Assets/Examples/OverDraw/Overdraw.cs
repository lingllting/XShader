using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Overdraw : MonoBehaviour 
{
    //上一个overdraw相机
    private static Camera s_mPreOverDrawCamera;
    private static RenderTexture s_mOverDrawRT;

    private Shader mOpaqueOverDrawShader;
    private Shader mTransparentOverDrawShader;
    private Camera mCamera;
    private Camera mOverDrawCamera;
    private CameraClearFlags mCurrentCameraClearFlags;
    private int mCullingMask;
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
        if (s_mOverDrawRT == null)
        {
            s_mOverDrawRT = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
        }
        mOverDrawCamera.targetTexture = s_mOverDrawRT;
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
        //同一个相机不同帧绘制
        if (s_mPreOverDrawCamera == mOverDrawCamera)
        {
            RenderTexture.active = s_mOverDrawRT;
            GL.Clear(true, true, Color.black);
        }
        //同一帧不同相机绘制
        else
        {
            if (mCamera.clearFlags == CameraClearFlags.Nothing)
            {

            }
            else if (mCamera.clearFlags == CameraClearFlags.Depth)
            {
                RenderTexture.active = s_mOverDrawRT;
                GL.Clear(true, false, Color.black);
            }
            else
            {
                RenderTexture.active = s_mOverDrawRT;
                GL.Clear(true, true, Color.black);
            }
        }
        mOverDrawCamera.SetReplacementShader(mOpaqueOverDrawShader, "RenderType");
        mOverDrawCamera.Render();
        mOverDrawCamera.SetReplacementShader(mTransparentOverDrawShader, "RenderType");
        mOverDrawCamera.Render();
        s_mPreOverDrawCamera = mOverDrawCamera;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (mOverDrawMode)
        {
            Graphics.Blit(s_mOverDrawRT, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
