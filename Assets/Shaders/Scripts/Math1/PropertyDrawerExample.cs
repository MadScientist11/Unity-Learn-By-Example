using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PropertyDrawerExample : MonoBehaviour
{
    public Character _characterInfo;
    public int Some;
}

[Serializable]
public class Character
{
    public Texture Avatar;
    public string Name, Title;
    public AnimationCurve LevelAnimationCurve;
    public int Age;
    public int Level;
    public int Vigor;
    public int Intelligence;
    public int Faith;
    public int Strength;
    public int Endurance;
}
