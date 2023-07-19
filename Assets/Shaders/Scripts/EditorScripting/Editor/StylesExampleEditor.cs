using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(StylesExample))]
public class StylesExampleEditor : Editor
{
   private int _selectedButtonToolbar;
   private bool isExpanded;
   public override void OnInspectorGUI()
   {
      
      GUILayout.Label("I'm a label that looks like a button", GUI.skin.button);
      GUILayout.Button(new GUIContent("Actual Button with logo", EditorGUIUtility.FindTexture("UnityLogo")));
      GUILayout.Label("I'm a label that looks like a toggle", GUI.skin.toggle);
      
      //GUIContent defines what to render and GUIStyle defines how to render it.
      GUILayout.Button(new GUIContent("Hover over me", "Nice!"));
      //Displays a tooltip in a label
      GUILayout.Label(GUI.tooltip);

      EditorGUILayout.TextField("Hey!", GUILayout.Width(EditorGUIUtility.fieldWidth));
      
      GUI.color = Color.blue;
      
      //IconContent return GUIContent as oppose to the EditorGUIUtility.FindTexture which returns a texture
      GUILayout.Button(EditorGUIUtility.IconContent("cs Script Icon"));
      GUI.color = Color.white;
      _selectedButtonToolbar = GUILayout.Toolbar(_selectedButtonToolbar, new[] { "First Button","Second Button" });
      
      using (new EditorGUI.DisabledScope(true))
      {
         GUILayout.Button("Disabled button");
      }
      GUIStyle toolbar = new GUIStyle(EditorStyles.objectField);
      toolbar.fontSize = 16;
      toolbar.fontStyle = FontStyle.Normal;
      GUILayout.Toggle(isExpanded, "✥ Movement", toolbar);
      


   }
}
