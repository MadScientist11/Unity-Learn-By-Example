using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProjectionHlper : MonoBehaviour
{
    [SerializeField] float radius;
    private bool _disappear;

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalVector("_Position", transform.position);
        Shader.SetGlobalFloat("_Radius", radius);
        Debug.Log("Hi");
    }
}