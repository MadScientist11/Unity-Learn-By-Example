using System;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

public class AutoSave : EditorWindow
{
    private bool _isCustomizable  = false;
    private float _saveTime = 300;
    private float _nextSave;

    private float SaveTimeInMinutes => _saveTime / 60;

    [MenuItem("Window/AutoSave")]
    public static void OpenAutoSaveWindow()
    {
        var autoSaveWindow = GetWindowWithRect<AutoSave>(new Rect(Screen.width /2, Screen.height /2, 450, 150));
        autoSaveWindow.titleContent = new GUIContent("AutoSave",EditorGUIUtility.FindTexture("d_UnityEditor.AnimationWindow"));
        autoSaveWindow.minSize = new Vector2(450, 150);
    }
    
    private void OnGUI()
    { 
       
        var remainingTime = _nextSave - EditorApplication.timeSinceStartup;
        var remainingTimeInMinutes = TimeSpan.FromSeconds(Mathf.RoundToInt((float)remainingTime));
        
        
        using (new EditorGUILayout.VerticalScope())
        {
            using (new EditorGUILayout.HorizontalScope())
            {
               
                var size = MyEditorStyles.SectionNameStyle.CalcSize(new GUIContent(remainingTimeInMinutes.ToString()));
                GUILayout.FlexibleSpace();
                EditorGUILayout.LabelField("Auto save after:", MyEditorStyles.LabelStyle, GUILayout.Width(90),
                    GUILayout.Height(55));
                EditorGUILayout.LabelField(remainingTimeInMinutes.ToString(), MyEditorStyles.SectionNameStyle, GUILayout.Width(size.x),
                    GUILayout.Height(size.y));
                GUILayout.FlexibleSpace();
            }
            
            EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);
            
            using (new EditorGUILayout.HorizontalScope())
            {
                using (new EditorGUILayout.VerticalScope())
                {
                    EditorGUI.indentLevel++;
                    var timeSinceStartup =
                        TimeSpan.FromSeconds(Mathf.RoundToInt((float)EditorApplication.timeSinceStartup));
                    EditorGUILayout.LabelField($"Session Time:", timeSinceStartup.ToString());
                    using (new EditorGUI.DisabledScope(!_isCustomizable))
                    {
                        string saveTimeInput = EditorGUILayout.TextField("Save Each(in minutes):", SaveTimeInMinutes.ToString());
                      
                        if (float.TryParse(saveTimeInput, out float saveTimeMinutes))
                        {
                            _saveTime = saveTimeMinutes * 60;
                        }
                        else
                        {
                            Debug.LogError("Cannot parse the time!");
                        }
                    }
                }

                GUILayout.FlexibleSpace();
                _isCustomizable = EditorGUILayout.ToggleLeft("Customizable", _isCustomizable);
                GUILayout.FlexibleSpace();
            }
        }

        if (EditorApplication.timeSinceStartup > _nextSave)
        {
            if(EditorApplication.isPlaying) return;
            EditorSceneManager.SaveOpenScenes();
            _nextSave = (float)EditorApplication.timeSinceStartup + _saveTime;
            Debug.Log("Save Scene");
        }
        
        Repaint();
    }
}

public static class MyEditorStyles
{
    public static GUIStyle SectionNameStyle;
    public static GUIStyle LabelStyle;
    public static GUIStyle CSharpScriptEntryStyle;
    
    static MyEditorStyles()
    {
        SectionNameStyle = new GUIStyle(EditorStyles.whiteLargeLabel)
        {
            alignment = TextAnchor.UpperCenter,
            fontSize = 55,
        };
        LabelStyle = new GUIStyle(EditorStyles.whiteLargeLabel)
        {
            alignment = TextAnchor.LowerRight,
            fontSize = 10,
        };
        CSharpScriptEntryStyle = new GUIStyle()
        {
            
        };

    }
}
