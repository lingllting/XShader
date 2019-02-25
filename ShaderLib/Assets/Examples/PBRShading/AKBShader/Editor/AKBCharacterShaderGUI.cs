using System;
using UnityEngine;

namespace UnityEditor
{
    public class AKBCharacterShaderGUI : ShaderGUI
    {
        public enum BlendMode
        {
            Opaque,
            Cutout,
            Transparent // Physically plausible transparency mode, implemented as alpha pre-multiply
        }

        public enum CullMode
        {
            Off,
            Front,
            Back
        }


        private static class Styles
        {
            public static GUIContent clothEnableText = new GUIContent("Cloth Enable", "Is Cloth?");
            public static GUIContent uvVerticalText = new GUIContent("UV Vertical", "Is UV Vertical?");

            public static GUIContent albedoText = new GUIContent("Main Tex", "Albedo (RGB) and Transparency (A)");
            public static GUIContent normalText = new GUIContent("Normal Tex", "");
            public static GUIContent maskText = new GUIContent("Mask Tex", "r Metallic, g Ramp Mask, b Roughness, a Rim Mask");
            public static GUIContent diffuseRampText = new GUIContent("Diffuse Ramp Map", "");
            public static GUIContent multiRampText = new GUIContent("Multi Ramp Map", "");
            public static GUIContent rimlightText = new GUIContent("RimLight", "");
            public static GUIContent vertexMapText = new GUIContent("Vertex Map", "r offset, g scale");
            public static GUIContent hairText = new GUIContent("Hair", "");

            public static GUIContent anisoTexText = new GUIContent("Aniso Tex", "b Normal Scale, a Specular Mask");
            public static GUIContent hairNoiseText = new GUIContent("Hair Noise Tex", "");

            public static GUIContent faceRedText = new GUIContent("Face Red", "");
            public static GUIContent faceRedTexText = new GUIContent("Change Mask Map", "");

            public static GUIContent specialMatText = new GUIContent("Special Mat", "");
            public static GUIContent matMaskText = new GUIContent("Material Mask", "");
            public static GUIContent glitterMapText = new GUIContent("Glitter Map", "");

            public static GUIContent gemInnerTexText = new GUIContent("Gem Inner Tex", "");
            

            public static GUIContent alphaCutoffText = new GUIContent("Alpha Cutoff", "Threshold for alpha cutoff");


            public static string advancedText = "Advanced Options";
            public static GUIContent emissiveWarning = new GUIContent("Emissive value is animated but the material has not been configured to support emissive. Please make sure the material itself has some amount of emissive.");
            public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));
            public static readonly string[] cullNames = Enum.GetNames(typeof(CullMode));
        }

        //Shown
        MaterialProperty _RenderShown = null;
        MaterialProperty _MainShown = null;
        MaterialProperty _RampShown = null;
        MaterialProperty _RimLightShown = null;
        MaterialProperty _OutlineShown = null;
        MaterialProperty _HairShown = null;
        MaterialProperty _IBLShown = null;
        MaterialProperty _FaceRedShown = null;
        MaterialProperty _SpecialMatShown = null;
        
        //Render
        MaterialProperty _ClothEnable = null;
        MaterialProperty blendMode = null;
        MaterialProperty cullMode = null;
        MaterialProperty _Stencil = null;
        MaterialProperty alphaCutoff = null;
        MaterialProperty _Cutoff = null;

        //Base
        MaterialProperty _MainTex = null;
        MaterialProperty _Color = null;
        MaterialProperty _NormalTex = null;
        MaterialProperty _MaskTex = null;
        MaterialProperty _Metallic = null;
        MaterialProperty _Smoothness = null;
        MaterialProperty _OcclusionStrength = null;

        //Ramp
        MaterialProperty _DiffuseRampTex = null;
        MaterialProperty _MultiRampTex = null;
        MaterialProperty _TintLayer1 = null;
        MaterialProperty _TintLayer2 = null;
        MaterialProperty _TintLayer3 = null;
        MaterialProperty _VerticalCoord = null;
        MaterialProperty _RampOffset = null;

        //Rimlight
        MaterialProperty _RimlightEnable = null;
        MaterialProperty _RimRange = null;
        MaterialProperty _RimIntensity = null;
        MaterialProperty _RimColor = null;

        //Outline
        MaterialProperty _VertexTex = null;
        MaterialProperty _OutlineColor = null;
        MaterialProperty _OutlineWidth = null;
        MaterialProperty _MaxOutlineZOffset = null;
        MaterialProperty _Scale = null;
 
        //Hair Aniso
        MaterialProperty _AnisoEnable = null;
        MaterialProperty _UVVertical = null;
        MaterialProperty _AnisoTex = null;
        MaterialProperty _HairNoiseTex = null;
        MaterialProperty _NoiseScale = null;
        MaterialProperty _SpecularRange1 = null;
        MaterialProperty _SpecularOffset1 = null;
        MaterialProperty _ChangeLightDir1 = null;
        MaterialProperty _SpecularColor1 = null;
        MaterialProperty _SpecularIntensity1 = null;
        MaterialProperty _SpecularRange2 = null;
        MaterialProperty _SpecularOffset2 = null;
        MaterialProperty _ChangeLightDir2 = null;
        MaterialProperty _SpecularColor2 = null;
        MaterialProperty _SpecularIntensity2 = null;
        
        //IBL
        MaterialProperty _IBLIntensity = null;
        MaterialProperty _SpecColor = null;
        MaterialProperty _SpecInt = null;
        MaterialProperty _Shininess = null;
        MaterialProperty _Fresnel = null;

        //Face Red
        MaterialProperty _FaceRedEnable = null;
        MaterialProperty _ChangeMaskMap = null;
        MaterialProperty _ChangeColor = null;

        //Special Mat
        MaterialProperty _SpecialMatEnable = null;
        MaterialProperty _MatMaskMap = null;

        //Glitter
        MaterialProperty _FakeLight = null;
        MaterialProperty _GlitterMap = null;
        MaterialProperty _GlitterColor = null;
        MaterialProperty _GlitterPower = null;
        MaterialProperty _GlitterContrast = null;
        MaterialProperty _GlitterySpeed = null;
        MaterialProperty _GlitteryMaskScale = null;
        MaterialProperty _MaskAdjust = null;
        MaterialProperty _GlitterThreshold = null;

        //Gem
        MaterialProperty _RefractIndex = null;
        MaterialProperty _GemInnerTex = null;

        //Emission
        MaterialProperty _EmissionColor = null;
        MaterialProperty _EmissionIntensity = null;


        MaterialEditor m_MaterialEditor;
        bool m_FirstTimeApply = true;


        public void FindProperties(MaterialProperty[] props)
        {
            _RenderShown = FindProperty("_RenderShown", props);
            _ClothEnable = FindProperty("_ClothEnable", props);
            blendMode = FindProperty("_Mode", props);
            cullMode = FindProperty("_Cull", props);
            alphaCutoff = FindProperty("_Cutoff", props);
            _Stencil = FindProperty("_Stencil", props);
            
            _MainShown = FindProperty("_MainShown", props);
            _MainTex = FindProperty("_MainTex", props);
            _Color = FindProperty("_Color", props);
            _NormalTex = FindProperty("_NormalTex", props);
            _MaskTex = FindProperty("_MaskTex", props);
            _Metallic = FindProperty("_Metallic", props);
            _Smoothness = FindProperty("_Smoothness", props);
            _OcclusionStrength = FindProperty("_OcclusionStrength", props);

            _RampShown = FindProperty("_RampShown", props);
            _DiffuseRampTex = FindProperty("_DiffuseRampTex", props);
            _MultiRampTex = FindProperty("_MultiRampTex", props);
            _TintLayer1 = FindProperty("_TintLayer1", props);
            _TintLayer2 = FindProperty("_TintLayer2", props);
            _TintLayer3 = FindProperty("_TintLayer3", props);
            _VerticalCoord = FindProperty("_VerticalCoord", props);
            _RampOffset = FindProperty("_RampOffset", props);

            _RimLightShown = FindProperty("_RimLightShown", props);
            _RimlightEnable = FindProperty("_RimlightEnable", props);
            _RimRange = FindProperty("_RimRange", props);
            _RimIntensity = FindProperty("_RimIntensity", props);
            _RimColor = FindProperty("_RimColor", props);

            _OutlineShown = FindProperty("_OutlineShown", props);
            _VertexTex = FindProperty("_VertexTex", props);
            _OutlineColor = FindProperty("_OutlineColor", props);
            _OutlineWidth = FindProperty("_OutlineWidth", props);
            _MaxOutlineZOffset = FindProperty("_MaxOutlineZOffset", props);
            _Scale = FindProperty("_Scale", props);

            _HairShown = FindProperty("_HairShown", props);
            _AnisoEnable = FindProperty("_AnisoEnable", props);
            _UVVertical = FindProperty("_UVVertical", props);
            _AnisoTex = FindProperty("_AnisoTex", props);
            _HairNoiseTex = FindProperty("_HairNoiseTex", props);
            _NoiseScale = FindProperty("_NoiseScale", props);
            _SpecularRange1 = FindProperty("_SpecularRange1", props);
            _SpecularOffset1 = FindProperty("_SpecularOffset1", props);
            _ChangeLightDir1 = FindProperty("_ChangeLightDir1", props);
            _SpecularColor1 = FindProperty("_SpecularColor1", props);
            _SpecularIntensity1 = FindProperty("_SpecularIntensity1", props);
            _SpecularRange2 = FindProperty("_SpecularRange2", props);
            _SpecularOffset2 = FindProperty("_SpecularOffset2", props);
            _ChangeLightDir2 = FindProperty("_ChangeLightDir2", props);
            _SpecularColor2 = FindProperty("_SpecularColor2", props);
            _SpecularIntensity2 = FindProperty("_SpecularIntensity2", props);

            _IBLShown = FindProperty("_IBLShown", props);
            _IBLIntensity = FindProperty("_IBLIntensity", props);
            _SpecColor = FindProperty("_SpecColor", props);
            _SpecInt = FindProperty("_SpecInt", props);
            _Shininess = FindProperty("_Shininess", props);
            _Fresnel = FindProperty("_Fresnel", props);

            _FaceRedShown = FindProperty("_FaceRedShown", props);
            _FaceRedEnable = FindProperty("_FaceRedEnable", props);
            _ChangeMaskMap = FindProperty("_ChangeMaskMap", props);
            _ChangeColor = FindProperty("_ChangeColor", props);

            _SpecialMatShown = FindProperty("_SpecialMatShown", props);
            _SpecialMatEnable = FindProperty("_SpecialMatEnable", props);
            _MatMaskMap = FindProperty("_MatMaskMap", props);
            _FakeLight = FindProperty("_FakeLight", props);
            _GlitterMap = FindProperty("_GlitterMap", props);
            _GlitterColor = FindProperty("_GlitterColor", props);
            _GlitterPower = FindProperty("_GlitterPower", props);
            _GlitterContrast = FindProperty("_GlitterContrast", props);
            _GlitterySpeed = FindProperty("_GlitterySpeed", props);
            _GlitteryMaskScale = FindProperty("_GlitteryMaskScale", props);
            _MaskAdjust = FindProperty("_MaskAdjust", props);
            _GlitterThreshold = FindProperty("_GlitterThreshold", props);


            _RefractIndex = FindProperty("_RefractIndex", props);
            _GemInnerTex = FindProperty("_GemInnerTex", props);
            _EmissionColor = FindProperty("_EmissionColor", props);
            _EmissionIntensity = FindProperty("_EmissionIntensity", props);
        }


        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            FindProperties(props); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
            m_MaterialEditor = materialEditor;
            Material material = materialEditor.target as Material;

            // Make sure that needed setup (ie keywords/renderqueue) are set up if we're switching some existing
            // material to a standard shader.
            // Do this before any GUI code has been issued to prevent layout issues in subsequent GUILayout statements (case 780071)
            if (m_FirstTimeApply)
            {
                MaterialChanged(material);
                m_FirstTimeApply = false;
            }

            ShaderPropertiesGUI(material);
        }


        public void ShaderPropertiesGUI(Material material)
        {
            Color oldColor = GUI.backgroundColor;

            EditorGUI.BeginChangeCheck();
            {
                GUI.backgroundColor = new Color(0.4f, 0.95f, 0.5f, 0.4f);
                EditorGUILayout.BeginVertical("Button");
                GUI.backgroundColor = oldColor;
                GUILayout.Label("Render", EditorStyles.boldLabel);

                if (true)
                {
                    Color col = GUI.color;
                    GUI.color = new Color(1, 1, 0, 1);
                    Rect rect = GUILayoutUtility.GetLastRect();
                    rect.x += EditorGUIUtility.currentViewWidth - 47;
                    EditorGUI.BeginChangeCheck();
                    float nval = EditorGUI.Foldout(rect, _RenderShown.floatValue == 1, "") ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                    {
                        _RenderShown.floatValue = nval;
                    }
                    GUI.color = col;
                }

                if (_RenderShown.floatValue == 1 || _RenderShown.hasMixedValue)
                {
                    m_MaterialEditor.ShaderProperty(_ClothEnable, Styles.clothEnableText);
                    EditorGUILayout.BeginVertical(GUILayout.MaxWidth(300));
                    BlendModePopup();
                    CullModePopup();
                    EditorGUILayout.EndVertical();
                    m_MaterialEditor.ShaderProperty(_Stencil, "Stencil Value");
                }
                EditorGUILayout.EndVertical();


                //Base
                GUI.backgroundColor = new Color(0.95f, 0.95f, 1.0f, 0.7f);
                EditorGUILayout.BeginVertical("Button");
                GUI.backgroundColor = oldColor;
                GUILayout.Label("Base", EditorStyles.boldLabel);

                if (true)
                {
                    Color col = GUI.color;
                    GUI.color = new Color(1, 1, 0, 1);
                    Rect rect = GUILayoutUtility.GetLastRect();
                    rect.x += EditorGUIUtility.currentViewWidth - 47;
                    EditorGUI.BeginChangeCheck();
                    float nval = EditorGUI.Foldout(rect, _MainShown.floatValue == 1, "") ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                    {
                        _MainShown.floatValue = nval;
                    }
                    GUI.color = col;
                }

                if (_MainShown.floatValue == 1 || _MainShown.hasMixedValue)
                {
                    //m_MaterialEditor.ShaderProperty(_ClothEnable, Styles.clothEnableText);
                    m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, _MainTex, _Color);
                    m_MaterialEditor.TexturePropertySingleLine(Styles.normalText, _NormalTex);
                    m_MaterialEditor.TexturePropertySingleLine(Styles.maskText, _MaskTex);

                    m_MaterialEditor.ShaderProperty(_Metallic, "Metallic");
                    m_MaterialEditor.ShaderProperty(_Smoothness, "Smoothness");
                    m_MaterialEditor.ShaderProperty(_OcclusionStrength, "OcclusionStrength");
                }

                EditorGUILayout.EndVertical();

                //Ramp
                GUI.backgroundColor = new Color(0.95f, 1.0f, 0.98f, 0.4f);
                EditorGUILayout.BeginVertical("Button");
                GUI.backgroundColor = oldColor;
                GUILayout.Label("Ramp", EditorStyles.boldLabel);

                if (true)
                {
                    Color col = GUI.color;
                    GUI.color = new Color(1, 1, 0, 1);
                    Rect rect = GUILayoutUtility.GetLastRect();
                    rect.x += EditorGUIUtility.currentViewWidth - 47;
                    EditorGUI.BeginChangeCheck();
                    float nval = EditorGUI.Foldout(rect, _RampShown.floatValue == 1, "") ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                    {
                        _RampShown.floatValue = nval;
                    }
                    GUI.color = col;
                }
                if (_RampShown.floatValue == 1 || _RampShown.hasMixedValue)
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.diffuseRampText, _DiffuseRampTex);
                    m_MaterialEditor.TexturePropertySingleLine(Styles.multiRampText, _MultiRampTex);

                    m_MaterialEditor.ShaderProperty(_TintLayer1, "Tint Layer1");
                    m_MaterialEditor.ShaderProperty(_TintLayer2, "Tint Layer2");
                    m_MaterialEditor.ShaderProperty(_TintLayer3, "Tint Layer3");
                    m_MaterialEditor.ShaderProperty(_VerticalCoord, "Vertical Coord");
                    m_MaterialEditor.ShaderProperty(_RampOffset, "Ramp Offset");
                }
                EditorGUILayout.EndVertical();

                //Outline
                GUI.backgroundColor = new Color(1.0f, 0.7f, 0.7f, 0.7f);
                EditorGUILayout.BeginVertical("Button");
                GUI.backgroundColor = oldColor;
                GUILayout.Label("Outline", EditorStyles.boldLabel);

                if (true)
                {
                    Color col = GUI.color;
                    GUI.color = new Color(1, 1, 0, 1);
                    Rect rect = GUILayoutUtility.GetLastRect();
                    rect.x += EditorGUIUtility.currentViewWidth - 47;
                    EditorGUI.BeginChangeCheck();
                    float nval = EditorGUI.Foldout(rect, _OutlineShown.floatValue == 1, "") ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                    {
                        _OutlineShown.floatValue = nval;
                    }
                    GUI.color = col;
                }
                if (_OutlineShown.floatValue == 1 || _OutlineShown.hasMixedValue)
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.vertexMapText, _VertexTex);

                    m_MaterialEditor.ShaderProperty(_OutlineColor, "Outline Color");
                    m_MaterialEditor.ShaderProperty(_OutlineWidth, "Outline Width");
                    m_MaterialEditor.ShaderProperty(_MaxOutlineZOffset, "Max Outline Z Offset");
                    m_MaterialEditor.ShaderProperty(_Scale, "Outline Scale");
                }
                EditorGUILayout.EndVertical();

                //IBL
                GUI.backgroundColor = new Color(0.5f, 1.0f, 0.98f, 0.6f);
                EditorGUILayout.BeginVertical("Button");
                GUI.backgroundColor = oldColor;
                GUILayout.Label("IBL", EditorStyles.boldLabel);

                if (true)
                {
                    Color col = GUI.color;
                    GUI.color = new Color(1, 1, 0, 1);
                    Rect rect = GUILayoutUtility.GetLastRect();
                    rect.x += EditorGUIUtility.currentViewWidth - 47;
                    EditorGUI.BeginChangeCheck();
                    float nval = EditorGUI.Foldout(rect, _IBLShown.floatValue == 1, "") ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                    {
                        _IBLShown.floatValue = nval;
                    }
                    GUI.color = col;
                }
                if (_IBLShown.floatValue == 1 || _IBLShown.hasMixedValue)
                {
                    m_MaterialEditor.ShaderProperty(_IBLIntensity, "IBL Intensity");
                    m_MaterialEditor.ShaderProperty(_SpecColor, "Specular Color");
                    m_MaterialEditor.ShaderProperty(_SpecInt, "Specular Intensity");
                    m_MaterialEditor.ShaderProperty(_Shininess, "Specular Sharpness");
                    m_MaterialEditor.ShaderProperty(_Fresnel, "Fresnel Strength");
                }
                EditorGUILayout.EndVertical();

                //Rimlight
                GUI.backgroundColor = new Color(0.7f, 0.7f, 1.0f, 0.8f);
                EditorGUILayout.BeginVertical("Button");
                GUI.backgroundColor = oldColor;

                {
                    EditorGUI.showMixedValue = _RimlightEnable.hasMixedValue;
                    float nval;
                    EditorGUI.BeginChangeCheck();
                    if (_RimlightEnable.floatValue == 1)
                    {
                        nval = EditorGUILayout.ToggleLeft(Styles.rimlightText, _RimlightEnable.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
                    }
                    else
                    {
                        nval = EditorGUILayout.ToggleLeft(Styles.rimlightText, _RimlightEnable.floatValue == 1, EditorStyles.boldLabel) ? 1 : 0;
                    }
                    if (EditorGUI.EndChangeCheck())
                    {
                        _RimlightEnable.floatValue = nval;
                    }
                    EditorGUI.showMixedValue = false;
                }

                SetKeyword(material, "RIMLIGHT_ENABLE", _RimlightEnable.floatValue == 1);

                if (_RimlightEnable.floatValue == 1)
                {
                    Color col = GUI.color;
                    GUI.color = new Color(1.0f, 1.0f, 0f, 1f);
                    Rect rect = GUILayoutUtility.GetLastRect();
                    rect.x += EditorGUIUtility.currentViewWidth - 47;

                    EditorGUI.BeginChangeCheck();
                    float nval = EditorGUI.Foldout(rect, _RimLightShown.floatValue == 1, "") ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                    {
                        _RimLightShown.floatValue = nval;
                    }
                    GUI.color = col;
                }

                if (_RimlightEnable.floatValue == 1 && (_RimLightShown.floatValue == 1 || _RimLightShown.hasMixedValue))
                {
                    m_MaterialEditor.ShaderProperty(_RimRange, "Rim Range");
                    m_MaterialEditor.ShaderProperty(_RimIntensity, "Rim Intensity");
                    m_MaterialEditor.ShaderProperty(_RimColor, "Rim Color");
                }
                EditorGUILayout.EndVertical();

                //Hair Aniso
                GUI.backgroundColor = new Color(0.7f, 1.0f, 0.7f, 0.75f);
                EditorGUILayout.BeginVertical("Button");
                GUI.backgroundColor = oldColor;

                {
                    EditorGUI.showMixedValue = _AnisoEnable.hasMixedValue;
                    float nval;
                    EditorGUI.BeginChangeCheck();
                    if (_AnisoEnable.floatValue == 1)
                    {
                        nval = EditorGUILayout.ToggleLeft(Styles.hairText, _AnisoEnable.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
                    }
                    else
                    {
                        nval = EditorGUILayout.ToggleLeft(Styles.hairText, _AnisoEnable.floatValue == 1, EditorStyles.boldLabel) ? 1 : 0;
                    }
                    if (EditorGUI.EndChangeCheck())
                    {
                        _AnisoEnable.floatValue = nval;
                    }
                    EditorGUI.showMixedValue = false;
                }

                SetKeyword(material, "ANISO_ENABLE", _AnisoEnable.floatValue == 1);

                if (_AnisoEnable.floatValue == 1)
                {
                    Color col = GUI.color;
                    GUI.color = new Color(1.0f, 1.0f, 0f, 1f);
                    Rect rect = GUILayoutUtility.GetLastRect();
                    rect.x += EditorGUIUtility.currentViewWidth - 47;

                    EditorGUI.BeginChangeCheck();
                    float nval = EditorGUI.Foldout(rect, _HairShown.floatValue == 1, "") ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                    {
                        _HairShown.floatValue = nval;
                    }
                    GUI.color = col;
                }

                if (_AnisoEnable.floatValue == 1 && (_HairShown.floatValue == 1 || _HairShown.hasMixedValue))
                {
                    m_MaterialEditor.ShaderProperty(_UVVertical, Styles.uvVerticalText);
                    m_MaterialEditor.TexturePropertySingleLine(Styles.anisoTexText, _AnisoTex);
                    m_MaterialEditor.TexturePropertySingleLine(Styles.hairNoiseText, _HairNoiseTex);

                    m_MaterialEditor.ShaderProperty(_NoiseScale, "Noise Scale");
                    m_MaterialEditor.ShaderProperty(_SpecularRange1, "Specular Range1");
                    m_MaterialEditor.ShaderProperty(_SpecularOffset1, "Specular Offset1");
                    m_MaterialEditor.ShaderProperty(_ChangeLightDir1, "Change LightDir1");
                    m_MaterialEditor.ShaderProperty(_SpecularColor1, "Specular Color1");
                    m_MaterialEditor.ShaderProperty(_SpecularIntensity1, "Specular Intensity1");

                    GUILayout.Space(10);

                    m_MaterialEditor.ShaderProperty(_SpecularRange2, "Specular Range2");
                    m_MaterialEditor.ShaderProperty(_SpecularOffset2, "Specular Offset2");
                    m_MaterialEditor.ShaderProperty(_ChangeLightDir2, "Change LightDir2");
                    m_MaterialEditor.ShaderProperty(_SpecularColor2, "Specular Color2");
                    m_MaterialEditor.ShaderProperty(_SpecularIntensity2, "Specular Intensity2");
                }
                EditorGUILayout.EndVertical();


                //Face Red
                GUI.backgroundColor = new Color(0.9f, 0.5f, 0.4f, 0.8f);
                EditorGUILayout.BeginVertical("Button");
                GUI.backgroundColor = oldColor;

                {
                    EditorGUI.showMixedValue = _FaceRedEnable.hasMixedValue;
                    float nval;
                    EditorGUI.BeginChangeCheck();
                    if (_FaceRedEnable.floatValue == 1)
                    {
                        nval = EditorGUILayout.ToggleLeft(Styles.faceRedText, _FaceRedEnable.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
                    }
                    else
                    {
                        nval = EditorGUILayout.ToggleLeft(Styles.faceRedText, _FaceRedEnable.floatValue == 1, EditorStyles.boldLabel) ? 1 : 0;
                    }
                    if (EditorGUI.EndChangeCheck())
                    {
                        _FaceRedEnable.floatValue = nval;
                    }
                    EditorGUI.showMixedValue = false;
                }

                SetKeyword(material, "FACE_RED_ENABLE", _FaceRedEnable.floatValue == 1);

                if (_FaceRedEnable.floatValue == 1)
                {
                    Color col = GUI.color;
                    GUI.color = new Color(1.0f, 1.0f, 0f, 1f);
                    Rect rect = GUILayoutUtility.GetLastRect();
                    rect.x += EditorGUIUtility.currentViewWidth - 47;

                    EditorGUI.BeginChangeCheck();
                    float nval = EditorGUI.Foldout(rect, _FaceRedShown.floatValue == 1, "") ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                    {
                        _FaceRedShown.floatValue = nval;
                    }
                    GUI.color = col;
                }

                if (_FaceRedEnable.floatValue == 1 && (_FaceRedShown.floatValue == 1 || _FaceRedShown.hasMixedValue))
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.faceRedTexText, _ChangeMaskMap);

                    m_MaterialEditor.ShaderProperty(_ChangeColor, "Change Color");
                }
                EditorGUILayout.EndVertical();

                //Special Mat
                GUI.backgroundColor = new Color(0.2f, 0.5f, 0.7f, 0.3f);
                EditorGUILayout.BeginVertical("Button");
                GUI.backgroundColor = oldColor;

                {
                    EditorGUI.showMixedValue = _SpecialMatEnable.hasMixedValue;
                    float nval;
                    EditorGUI.BeginChangeCheck();
                    if (_SpecialMatEnable.floatValue == 1)
                    {
                        nval = EditorGUILayout.ToggleLeft(Styles.specialMatText, _SpecialMatEnable.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
                    }
                    else
                    {
                        nval = EditorGUILayout.ToggleLeft(Styles.specialMatText, _SpecialMatEnable.floatValue == 1, EditorStyles.boldLabel) ? 1 : 0;
                    }
                    if (EditorGUI.EndChangeCheck())
                    {
                        _SpecialMatEnable.floatValue = nval;
                    }
                    EditorGUI.showMixedValue = false;
                }

                SetKeyword(material, "SPECIAL_MAT_ENABLE", _SpecialMatEnable.floatValue == 1);

                if (_SpecialMatEnable.floatValue == 1)
                {
                    Color col = GUI.color;
                    GUI.color = new Color(1.0f, 1.0f, 0f, 1f);
                    Rect rect = GUILayoutUtility.GetLastRect();
                    rect.x += EditorGUIUtility.currentViewWidth - 47;

                    EditorGUI.BeginChangeCheck();
                    float nval = EditorGUI.Foldout(rect, _SpecialMatShown.floatValue == 1, "") ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                    {
                        _SpecialMatShown.floatValue = nval;
                    }
                    GUI.color = col;
                }

                if (_SpecialMatEnable.floatValue == 1 && (_SpecialMatShown.floatValue == 1 || _SpecialMatShown.hasMixedValue))
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.matMaskText, _MatMaskMap);

                    m_MaterialEditor.ShaderProperty(_FakeLight, "Fake Light");
                    m_MaterialEditor.TexturePropertySingleLine(Styles.glitterMapText, _GlitterMap);
                    m_MaterialEditor.TextureScaleOffsetProperty(_GlitterMap);
                    m_MaterialEditor.ShaderProperty(_GlitterColor, "Glitter Color");
                    m_MaterialEditor.ShaderProperty(_GlitterPower, "Glitter Power");
                    m_MaterialEditor.ShaderProperty(_GlitterContrast, "Glitter Contrast");
                    m_MaterialEditor.ShaderProperty(_GlitterySpeed, "Glittery Speed");
                    m_MaterialEditor.ShaderProperty(_GlitteryMaskScale, "Glittery Mask Scale");
                    m_MaterialEditor.ShaderProperty(_MaskAdjust, "Mask Adjust");
                    m_MaterialEditor.ShaderProperty(_GlitterThreshold, "Glitter Threshold");


                    m_MaterialEditor.ShaderProperty(_RefractIndex, "Refract Index");
                    m_MaterialEditor.TexturePropertySingleLine(Styles.gemInnerTexText, _GemInnerTex);

                    m_MaterialEditor.ShaderProperty(_EmissionColor, "Emission Color");
                    m_MaterialEditor.ShaderProperty(_EmissionIntensity, "Emission Intensity");
                }
                EditorGUILayout.EndVertical();
            }


            if (EditorGUI.EndChangeCheck())
            {
                foreach (var obj in blendMode.targets)
                    MaterialChanged((Material)obj);
            }

            EditorGUILayout.Space();
            m_MaterialEditor.RenderQueueField();
            // NB renderqueue editor is not shown on purpose: we want to override it based on blend mode
            GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
            m_MaterialEditor.EnableInstancingField();
            m_MaterialEditor.DoubleSidedGIField();
        }

        void BlendModePopup()
        {
            EditorGUI.showMixedValue = blendMode.hasMixedValue;
            var mode = (BlendMode)blendMode.floatValue;

            EditorGUI.BeginChangeCheck();
            mode = (BlendMode)EditorGUILayout.Popup("Rendering Mode", (int)mode, Styles.blendNames);
            if (EditorGUI.EndChangeCheck())
            {
                m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
                blendMode.floatValue = (float)mode;
            }

            EditorGUI.showMixedValue = false;
        }

        void CullModePopup()
        {
            EditorGUI.showMixedValue = cullMode.hasMixedValue;
            var mode = (CullMode)cullMode.floatValue;

            EditorGUI.BeginChangeCheck();
            mode = (CullMode)EditorGUILayout.Popup("Cull Mode", (int)mode, Styles.cullNames);
            if (EditorGUI.EndChangeCheck())
            {
                m_MaterialEditor.RegisterPropertyChangeUndo("Cull Mode");
                cullMode.floatValue = (float)mode;
            }

            EditorGUI.showMixedValue = false;
        }


        static void MaterialChanged(Material material)
        {
            SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));
        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            base.AssignNewShaderToMaterial(material, oldShader, newShader);
            BlendMode blendMode = BlendMode.Opaque;
            material.SetFloat("_Mode", (float)blendMode);
            MaterialChanged(material);
        }

        static void SetKeyword(Material m, string keyword, bool state)
        {
            if (state)
                m.EnableKeyword(keyword);
            else
                m.DisableKeyword(keyword);
        }

        public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
        {
            switch (blendMode)
            {
                case BlendMode.Opaque:
                    material.SetOverrideTag("RenderType", "Character");
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    material.DisableKeyword("_ALPHATEST_ON");
                    material.renderQueue = -1;
                    break;
                case BlendMode.Cutout:
                    material.SetOverrideTag("RenderType", "Character");
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    material.EnableKeyword("_ALPHATEST_ON");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
                case BlendMode.Transparent:
                    material.SetOverrideTag("RenderType", "Character");
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    material.SetInt("_ZWrite", 1);
                    material.DisableKeyword("_ALPHATEST_ON");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
            }
        }
    }

}
