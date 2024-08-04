using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class WorldToLocal : MonoBehaviour
{
    public Transform tr;
    
    private void OnDrawGizmos()
    {
        //tr relative to our object

        Vector2 localPosition = tr.position - transform.position;
        float x = Vector2.Dot(transform.right, localPosition);
        float y = Vector2.Dot(transform.up, localPosition);
        Debug.Log(new Vector2(x, y));
        //Gizmos.DrawSphere(transform.position + wsRotated, .5f);
    }
}
