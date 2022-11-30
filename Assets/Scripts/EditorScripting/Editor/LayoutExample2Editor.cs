using UnityEditor;
using UnityEditor.AnimatedValues;
using UnityEngine;

[CustomEditor(typeof(LayoutExample2))]
public class LayoutExample2Editor : Editor
{
    private SerializedObject _serializedObject;
    private SerializedProperty _point1Prop;
    private SerializedProperty _point2Prop;
    private SerializedProperty _colorProp;
    private SerializedProperty _gameObjectProp;
    private SerializedProperty _valueProp;

    private AnimBool _fadeGroup;
    private void OnEnable()
    {
        _serializedObject = serializedObject;
        _point1Prop = _serializedObject.FindProperty("Point1");
        _point2Prop = _serializedObject.FindProperty("_point2");
        _colorProp = _serializedObject.FindProperty("_color");
        _gameObjectProp = _serializedObject.FindProperty("_gameObject");
        _valueProp = _serializedObject.FindProperty("_value");

        _fadeGroup = new AnimBool(false);
        _fadeGroup.valueChanged.AddListener(Repaint);
    }

    public override void OnInspectorGUI()
    {
        //Bad
        var layoutExample2 = target as LayoutExample2;
        
        _serializedObject.Update();
        
        
        EditorGUILayout.LabelField("Fields:", EditorStyles.boldLabel);
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            //Good way of doing thing.
            EditorGUILayout.PropertyField(_point1Prop);
            EditorGUILayout.PropertyField(_point2Prop);
            
        }
        //Bad way of doing thing, cuz changing this field won't be handled by undo system, also multi-editing and prefab overrides are not handled 
        //by this method.
        layoutExample2.Point3 = EditorGUILayout.Vector3Field("Point 3",layoutExample2.Point3);

   
        
        EditorGUILayout.LabelField("Fade Group:", EditorStyles.boldLabel);
        
        _fadeGroup.target = GUILayout.Toggle(_fadeGroup.target,"Toggle FadeGroup");
        using (var group = new EditorGUILayout.FadeGroupScope(_fadeGroup.faded))
        {
            if (group.visible)
            {
                EditorGUILayout.PropertyField(_colorProp);
                EditorGUILayout.PropertyField(_gameObjectProp);
                EditorGUILayout.PropertyField(_valueProp);
            }

        }
        
        _serializedObject.ApplyModifiedProperties();
    }
}
