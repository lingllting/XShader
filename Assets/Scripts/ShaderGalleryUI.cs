using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class ShaderGalleryUI : MonoBehaviour
{
    public Text ShaderTitle;
    
    public Button nextSceneButton;
    public Button previousSceneButton;
    public Button nextMaterialButton;
    public Button previousMaterialButton;

    private int _sceneIndex = 0;

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
        DontDestroyOnLoad(EventSystem.current);
    }

    public void Start()
    {
        SceneList sceneList = ConfigManager.Get<SceneList>();
        
        nextSceneButton.onClick.AddListener(() =>
        {
            _sceneIndex = _sceneIndex + 1;
            if (_sceneIndex > sceneList.scenes.Count - 1)
            {
                _sceneIndex = sceneList.scenes.Count - 1;
                return;
            }
            sceneList.scenes[_sceneIndex].LoadAsync(LoadSceneMode.Single);
        });
        
        previousSceneButton.onClick.AddListener(() =>
        {
            _sceneIndex = _sceneIndex - 1;
            if (_sceneIndex < 0)
            {
                _sceneIndex = 0;
                return;
            }
            sceneList.scenes[_sceneIndex].LoadAsync(LoadSceneMode.Single);
        });
    }
}
