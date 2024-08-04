using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Laser : MonoBehaviour
{
    private Transform _hitTransform;
    private Vector3 _hitPoint;

    private List<Vector3> _hits = new();
    
    private void Update()
    {

    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        
        Vector2 rayOrigin = transform.position;
        Vector2 rayDirection = transform.right;

        for (int i = 0; i < 4; i++)
        {
            RaycastHit2D raycastHit2D = Physics2D.Raycast(rayOrigin, rayDirection, 100f);
        
            if (raycastHit2D.transform != null)
            {
                _hits.Add(rayOrigin);
                

                Vector2 normal = raycastHit2D.normal;            
                var hitVector = raycastHit2D.point - new Vector2(transform.position.x, transform.position.y);


                float dotProduct = Vector2.Dot(hitVector, normal);


                Vector2 p1 = raycastHit2D.point - 2 * dotProduct * normal;
                
                Gizmos.DrawSphere(p1, 1f);
                Vector2 p2 = p1 + hitVector;
                
                rayOrigin = raycastHit2D.point;

                rayDirection = (p2 - raycastHit2D.point).normalized;
            }
        }
        Gizmos.DrawLineList(_hits.ToArray());

        
        _hits.Clear();


    }
}
