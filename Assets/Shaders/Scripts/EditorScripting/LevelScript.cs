using System;
using UnityEngine;

public class LevelScript : MonoBehaviour
{
    [SerializeField] private int _expAmount = 1000;
    
    private int _levelCap = Int32.MaxValue;
    
    public int LevelCap
    {
        get
        {
            if(!HasLevelCap) _levelCap = Int32.MaxValue;
            return _levelCap;
        }
        set => _levelCap = HasLevelCap ? value : Int32.MaxValue;
    }

    public int Level => Mathf.Clamp(_expAmount / 200, 0, LevelCap);

    public bool HasLevelCap { get; set; } = false;
}
