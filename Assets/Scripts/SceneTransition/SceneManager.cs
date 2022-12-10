using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneManager : MonoBehaviour
{
	private static SceneManager _instance = null;

	public static SceneManager Instance
	{
		get
		{
			if (_instance == null)
			{
				GameObject go = new GameObject("[SceneManager]");
				DontDestroyOnLoad(go);
				_instance = go.AddComponent<SceneManager>();
			}

			return _instance;
		}
	}

	private void OnDestroy()
	{
		_instance = null;
	}
}
