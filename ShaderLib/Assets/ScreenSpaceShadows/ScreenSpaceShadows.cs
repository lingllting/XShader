using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScreenSpaceShadows : MonoBehaviour 
{
	public Camera ShadowCamera;

	private Camera _mainCamera;
	private Shader _renderDepthShader;
	private Shader _ssrShader;
	private Material _ssrMaterial;
	private RenderTexture _shadowTexture = null;

	void OnEnable()
	{
		if (_mainCamera == null)
		{
			_mainCamera = gameObject.GetComponent<Camera>();
		}
		_mainCamera.depthTextureMode |= DepthTextureMode.Depth;
	}

	void OnPreCull()
	{
		if (!CheckShaderAndMaterial())
		{
			return;
		}
		if (_shadowTexture == null)
		{
			_shadowTexture = new RenderTexture (1024, 1024, 16, RenderTextureFormat.ARGB32);
			_shadowTexture.filterMode = FilterMode.Point;
		}
		ShadowCamera.targetTexture = _shadowTexture;
		ShadowCamera.RenderWithShader (_renderDepthShader, "RenderType");
	}

	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (!CheckShaderAndMaterial())
		{
			Graphics.Blit(source, destination);
			return;
		}
		_ssrMaterial.SetTexture("_ShadowMap", _shadowTexture);
		_ssrMaterial.SetMatrix("_MainCameraViewToWorldMatrix", _mainCamera.worldToCameraMatrix.inverse);
		//_ssrMaterial.SetMatrix("_WorldToLightClipSpaceMatrix", GL.GetGPUProjectionMatrix(ShadowCamera.projectionMatrix, true) * ShadowCamera.worldToCameraMatrix);
		_ssrMaterial.SetMatrix("_WorldToLightClipSpaceMatrix", ShadowCamera.projectionMatrix * ShadowCamera.worldToCameraMatrix);
		Graphics.Blit(source, destination, _ssrMaterial);
	}

	bool CheckShaderAndMaterial()
	{
		if (_renderDepthShader == null)
		{
			_renderDepthShader = Shader.Find ("Custom/RenderDepth");
		}
		if (_ssrShader == null)
		{
			_ssrShader = Shader.Find ("Custom/ScreenSpaceShadows");
		}
		if (_ssrMaterial == null)
		{
			_ssrMaterial = new Material (_ssrShader);
		}

		if (_renderDepthShader == null || _ssrShader == null || _ssrMaterial == null)
		{
			return false;
		}
		return true;
	}
}
