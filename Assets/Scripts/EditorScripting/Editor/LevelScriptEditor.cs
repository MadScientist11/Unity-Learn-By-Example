using UnityEditor;

[CustomEditor(typeof(LevelScript))]
public class LevelScriptEditor : Editor
{
    public override void OnInspectorGUI()
    {
        // Keep already drawn values by inspector
        base.OnInspectorGUI();

        var levelScript = target as LevelScript;
        
        // EditorGUILayout is wrapper around EditorGUI that has auto-layout
        EditorGUILayout.LabelField("Level",levelScript.Level.ToString());
        levelScript.HasLevelCap = EditorGUILayout.Toggle("HasLevelCap", levelScript.HasLevelCap);
        
        if (levelScript.HasLevelCap)
        {
            levelScript.LevelCap = EditorGUILayout.IntField("LevelCap", levelScript.LevelCap);
        }
        
        EditorGUILayout.HelpBox("This is Level Script",MessageType.Info);
    }
}
