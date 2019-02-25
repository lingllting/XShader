using UnityEngine;
using UnityEditor;
using System.Collections;

public class AKBEditorHelper : MonoBehaviour 
{
    //不同的style
    public static GUIStyle TitleStyle()
    {
        GUIStyle title = new GUIStyle(EditorStyles.largeLabel);

        title.fontSize = 16;

        title.clipping = TextClipping.Overflow;

        return title;
    }

    public static GUIStyle ThinButtonStyle()
    {
        GUIStyle thinButton = new GUIStyle(EditorStyles.toolbarButton);
        thinButton.fontStyle = FontStyle.Bold;
        thinButton.fixedHeight = 24f;
        return thinButton;
    }

    public static GUIStyle ThinButtonRedStyle()
    {
        GUIStyle thinButtonRed = new GUIStyle(EditorStyles.toolbarButton);
        thinButtonRed.fontStyle = FontStyle.Bold;
        thinButtonRed.fixedHeight = 24f;
        thinButtonRed.normal.textColor = Color.red;
        return thinButtonRed;
    }

    public static GUIStyle ThinButtonPressedStyle()
    {
        GUIStyle thinButtonPressed = new GUIStyle(EditorStyles.toolbarButton);
        thinButtonPressed.fontStyle = FontStyle.Bold;
        thinButtonPressed.fixedHeight = 24f;
        return thinButtonPressed;
    }

    public static GUIStyle DropDownButtonStyle()
    {
        GUIStyle dropDownButton = new GUIStyle(EditorStyles.toolbarDropDown);
        dropDownButton.fontStyle = FontStyle.Bold;
        dropDownButton.fixedHeight = 20f;
        return dropDownButton;
    }

    public static GUIStyle EnumStyleButton()
    {
        GUIStyle enumStyleButton = new GUIStyle(EditorStyles.toolbarDropDown);
        enumStyleButton.onActive.background = ThinButtonStyle().onActive.background;
        enumStyleButton.fixedHeight = 24f;
        return enumStyleButton;
    }

    public static GUIStyle FoldOutButtonStyle()
    {
        GUIStyle foldOutButton = new GUIStyle(EditorStyles.foldout);
        foldOutButton.fontStyle = FontStyle.Bold;
        return foldOutButton;
    }

    //分割线
    public static void DrawGuiDivider()
    {
        GUILayout.Space(12f);
        if (Event.current.type == EventType.Repaint)
        {
            Texture2D tex = EditorGUIUtility.whiteTexture;
            Rect rect = GUILayoutUtility.GetLastRect();
            GUI.color = new Color(0f, 0f, 0f, 0.25f);
            GUI.DrawTexture(new Rect(0f, rect.yMin + 6f, Screen.width, 4f), tex);
            GUI.DrawTexture(new Rect(0f, rect.yMin + 6f, Screen.width, 1f), tex);
            GUI.DrawTexture(new Rect(0f, rect.yMin + 9f, Screen.width, 1f), tex);
            GUI.color = Color.white;
        }
    }

    public static void DrawGuiInBoxDivider()
    {
        GUILayout.Space(8f);

        if (Event.current.type == EventType.Repaint)
        {

            int extra = 0;
#if UNITY_4_3
			extra = 10;
#endif

            Texture2D tex = EditorGUIUtility.whiteTexture;
            Rect rect = GUILayoutUtility.GetLastRect();
            GUI.color = new Color(0.5f, 0.5f, 0.5f, 0.25f);
            GUI.DrawTexture(new Rect(5f + extra, rect.yMin + 5f, Screen.width - 11, 1f), tex);
            GUI.color = Color.white;
        }
    }
}
