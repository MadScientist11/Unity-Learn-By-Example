using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ConverInputToVector3 : MonoBehaviour
{
    private void Update()
    {
        Vector2 input = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
        Vector3 inputVec3 = new Vector3(input.x, 0, input.y).normalized; // length will be always one
        Vector3 inputVec3Clamp = Vector3.ClampMagnitude(new Vector3(input.x, 0, input.y), 1); // length > 1 = 1, length < 1 = length
        print(inputVec3);
        print(inputVec3Clamp);
        
        
    }
}
