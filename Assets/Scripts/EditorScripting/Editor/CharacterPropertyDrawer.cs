using UnityEditor;
using UnityEngine;

[CustomPropertyDrawer(typeof(Character))]
public class CharacterPropertyDrawer : PropertyDrawer
{
    private readonly float _smallLabelWidth = EditorGUIUtility.labelWidth / 3.5f;
    private readonly float _fieldWidth = EditorGUIUtility.labelWidth * .7f;
    private readonly float _smallFieldWidth = EditorGUIUtility.labelWidth * .3f;
    private readonly float _largeFieldWidth = EditorGUIUtility.labelWidth * 1.62f;
    private readonly float _avatarSpacing = 7;
    private readonly float _spaceBetweenFields = 7;

    private int _levelPoints;
    private int _maxLevelPoints;
    
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        EditorGUI.BeginProperty(position, label, property);
        Rect rectFoldout = new Rect(position.min.x, position.min.y, position.size.x, EditorGUIUtility.singleLineHeight);

        property.isExpanded = EditorGUI.Foldout(rectFoldout, property.isExpanded, label);
        EditorGUI.indentLevel = 0;
         

        if (property.isExpanded)
        {
            var avatar = property.FindPropertyRelative("Avatar");
            var avatarY = (position.y + (EditorGUIUtility.singleLineHeight*1.5f));
            var avatarRect = new Rect(position.x, avatarY, 100, 100);
            avatar.objectReferenceValue = EditorGUI.ObjectField(avatarRect, avatar.objectReferenceValue, typeof(Texture2D), false);
            
            var avatarXOffset = position.x + 100 + _avatarSpacing;
            var avatarYOffset = avatarY + 100 + _avatarSpacing;
            
            var name = property.FindPropertyRelative("Name");
            var nameLabelRect = new Rect(avatarXOffset, avatarY, _smallLabelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(nameLabelRect, new GUIContent("Name:"));
            EditorGUI.PropertyField(new Rect(nameLabelRect.x + _smallLabelWidth, nameLabelRect.y, _fieldWidth, EditorGUIUtility.singleLineHeight),name, GUIContent.none);
            
            var title = property.FindPropertyRelative("Title");
            var titleLabelRect = new Rect(avatarXOffset, avatarY + EditorGUIUtility.singleLineHeight + _spaceBetweenFields, _smallLabelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(titleLabelRect, new GUIContent("Title:"));
            EditorGUI.PropertyField(new Rect(titleLabelRect.x + _smallLabelWidth, titleLabelRect.y, _fieldWidth, EditorGUIUtility.singleLineHeight),title, GUIContent.none);
            
            var age = property.FindPropertyRelative("Age");
            var ageLabelRect = new Rect(avatarXOffset, avatarY + ((EditorGUIUtility.singleLineHeight+ _spaceBetweenFields) * 2) , _smallLabelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(ageLabelRect, new GUIContent("Age:"));
            EditorGUI.PropertyField(new Rect(ageLabelRect.x + _smallLabelWidth, ageLabelRect.y, _smallFieldWidth, EditorGUIUtility.singleLineHeight),age, GUIContent.none);
            
            var level = property.FindPropertyRelative("Level");
            var levelLabelRect = new Rect(avatarXOffset, avatarY + ((EditorGUIUtility.singleLineHeight+ _spaceBetweenFields) * 3) , _smallLabelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(levelLabelRect, new GUIContent("Level:"));
            EditorGUI.PropertyField(new Rect(levelLabelRect.x + _smallLabelWidth, levelLabelRect.y, _smallFieldWidth, EditorGUIUtility.singleLineHeight),level, GUIContent.none);
            var levelAnimationCurve = property.FindPropertyRelative("LevelAnimationCurve");
            levelAnimationCurve.animationCurveValue = EditorGUI.CurveField(
                new Rect(levelLabelRect.x + _smallLabelWidth + _smallFieldWidth + _spaceBetweenFields, levelLabelRect.y,
                    EditorGUIUtility.labelWidth, EditorGUIUtility.singleLineHeight), levelAnimationCurve.animationCurveValue);

            var statsLabelRect = new Rect(position.x, avatarYOffset, EditorGUIUtility.labelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.LabelField(statsLabelRect,"Attributes", EditorStyles.boldLabel);

            var pointsLabelRect = new Rect(position.x, avatarYOffset + EditorGUIUtility.singleLineHeight + _spaceBetweenFields, EditorGUIUtility.labelWidth / 2, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(pointsLabelRect, new GUIContent("Level Points:"));
            _maxLevelPoints = (int)levelAnimationCurve.animationCurveValue.Evaluate(level.intValue);
            EditorGUI.SelectableLabel(new Rect(pointsLabelRect.x + EditorGUIUtility.labelWidth / 2, pointsLabelRect.y, _smallFieldWidth, EditorGUIUtility.singleLineHeight), $"{_levelPoints}");
            
            EditorGUI.BeginDisabledGroup(_levelPoints == 0);
            
            var vigor = property.FindPropertyRelative("Vigor");
            var vigorLabelRect = new Rect(position.x, avatarYOffset + ((EditorGUIUtility.singleLineHeight+ _spaceBetweenFields) * 2) , EditorGUIUtility.labelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(vigorLabelRect, new GUIContent("Vigor:"));
            vigor.intValue = EditorGUI.IntSlider(new Rect(vigorLabelRect.x + EditorGUIUtility.labelWidth, vigorLabelRect.y, _largeFieldWidth , EditorGUIUtility.singleLineHeight), vigor.intValue, 0, 100);
            
            var strength = property.FindPropertyRelative("Strength");
            var strengthLabelRect = new Rect(position.x, avatarYOffset + ((EditorGUIUtility.singleLineHeight+ _spaceBetweenFields) * 3) , EditorGUIUtility.labelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(strengthLabelRect, new GUIContent("Strength:"));
            strength.intValue = EditorGUI.IntSlider(new Rect(strengthLabelRect.x + EditorGUIUtility.labelWidth, strengthLabelRect.y, _largeFieldWidth , EditorGUIUtility.singleLineHeight), strength.intValue, 0, 100);
            
            var endurance = property.FindPropertyRelative("Endurance");
            var enduranceLabelRect = new Rect(position.x, avatarYOffset + ((EditorGUIUtility.singleLineHeight+ _spaceBetweenFields) * 4) , EditorGUIUtility.labelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(enduranceLabelRect, new GUIContent("Endurance:"));
            endurance.intValue = EditorGUI.IntSlider(new Rect(enduranceLabelRect.x + EditorGUIUtility.labelWidth, enduranceLabelRect.y, _largeFieldWidth , EditorGUIUtility.singleLineHeight), endurance.intValue, 0, 100);

            var intelligence = property.FindPropertyRelative("Intelligence");
            var intelligenceLabelRect = new Rect(position.x, avatarYOffset + ((EditorGUIUtility.singleLineHeight+ _spaceBetweenFields) * 5) , EditorGUIUtility.labelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(intelligenceLabelRect, new GUIContent("Intelligence:"));
            intelligence.intValue = EditorGUI.IntSlider(new Rect(intelligenceLabelRect.x + EditorGUIUtility.labelWidth, intelligenceLabelRect.y, _largeFieldWidth , EditorGUIUtility.singleLineHeight), intelligence.intValue, 0, 100);

            var faith = property.FindPropertyRelative("Faith");
            var faithLabelRect = new Rect(position.x, avatarYOffset + ((EditorGUIUtility.singleLineHeight+ _spaceBetweenFields) * 6) , EditorGUIUtility.labelWidth, EditorGUIUtility.singleLineHeight);
            EditorGUI.PrefixLabel(faithLabelRect, new GUIContent("Faith:"));
            faith.intValue = EditorGUI.IntSlider(new Rect(faithLabelRect.x + EditorGUIUtility.labelWidth, faithLabelRect.y, _largeFieldWidth , EditorGUIUtility.singleLineHeight), faith.intValue, 0, 100);
            _levelPoints = _maxLevelPoints - vigor.intValue - strength.intValue - endurance.intValue - intelligence.intValue - faith.intValue;
            
            EditorGUI.EndDisabledGroup();

            if (_levelPoints == 0)
            {
                var isPressed = GUI.Button(new Rect(position.x, avatarYOffset + ((EditorGUIUtility.singleLineHeight+ _spaceBetweenFields) * 7), _largeFieldWidth , EditorGUIUtility.singleLineHeight), "Reset");
                if(isPressed)
                {
                    vigor.intValue = 0;
                    strength.intValue = 0;
                    endurance.intValue = 0;
                    intelligence.intValue = 0;
                    faith.intValue = 0;
                }
            }
        }
    

        

        EditorGUI.EndProperty();
    }

    

    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        return EditorGUI.GetPropertyHeight(property, label) + 150;
    }
}




