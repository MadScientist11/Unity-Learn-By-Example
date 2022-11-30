using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ObjectBuilder))]
public class ObjectBuilderEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var objectBuilder = target as ObjectBuilder;
        
        GUILayout.Space(10);
        
        // Draws button and returns true if button is pressed
        var isPressed = GUILayout.Button("Build Object",GUILayout.Height(35));

        if (isPressed)
        {
            objectBuilder.CreateObject();
        }

    }
}