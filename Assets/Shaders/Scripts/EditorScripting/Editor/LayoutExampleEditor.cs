using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(LayoutExample))]
public class LayoutExampleEditor : Editor
{
    private Vector3 _vector = Vector3.zero;
    private Color _color = Color.red;
    private Transform _transform;
    
    public override void OnInspectorGUI()
    {
        //Old way to do layout was BeginVertical/Horizontal, new way will exit from layout block without needing to do EndVertical/Horizontal
        using (new GUILayout.VerticalScope(EditorStyles.helpBox))
        {
            DrawVectorSectionLayout();
            
            EditorGUILayout.Space(5);
            
            _transform = (Transform)EditorGUILayout.ObjectField("Transform", _transform, typeof(Transform), true);
            DrawTransformSectionLayout();

            DrawHeaderSectionLayout();
            
            EditorGUILayout.LabelField("Centered Grey Label", EditorStyles.centeredGreyMiniLabel);
        }
    }

    private void DrawVectorSectionLayout()
    {
        using (new GUILayout.HorizontalScope())
        {
            _vector = EditorGUILayout.Vector3Field("Vector", _vector);
            if (GUILayout.Button("Reset", GUILayout.Width(50)))
            {
                _vector = Vector3.zero;
                Debug.Log("Resets");
            }
        }
    }

    private void DrawTransformSectionLayout()
    {
        using (new GUILayout.HorizontalScope())
        {
            GUILayout.FlexibleSpace();
            if (GUILayout.Button("Clear", GUILayout.Width(EditorGUIUtility.fieldWidth)))
            {
                _transform = null;
            }
            if (GUILayout.Button("Find", GUILayout.Width(EditorGUIUtility.fieldWidth)))
            {
                _transform = FindObjectOfType<Transform>();
            }
        }
    }

    private void DrawHeaderSectionLayout()
    {
        EditorGUILayout.LabelField("Header", EditorStyles.boldLabel);
            
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.PrefixLabel("Color Field:");
        _color = EditorGUILayout.ColorField(_color);
        EditorGUILayout.EndHorizontal(); 
            
        EditorGUILayout.Space(5);
            
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.Space(EditorGUIUtility.labelWidth);

            if(GUILayout.Button("Process!"))
            {
            }
        }
        EditorGUILayout.EndHorizontal();
    }
}
