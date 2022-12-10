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
            sceneList.scenes[1].LoadAsync(LoadSceneMode.Single);
        });
        
        previousSceneButton.onClick.AddListener(() =>
        {
            sceneList.scenes[0].LoadAsync(LoadSceneMode.Single);
        });
    }
}
