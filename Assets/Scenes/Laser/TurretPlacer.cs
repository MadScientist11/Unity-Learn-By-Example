using System;
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using Unity.VisualScripting;
using UnityEngine;
using Cache = UnityEngine.Cache;

namespace Scenes.Laser
{
    public class TurretPlacer : MonoBehaviour
    {
        [SerializeField] private GameObject _turret;

        private void OnDrawGizmos()
        {
            bool raycast = Physics.Raycast(transform.position, transform.forward, out RaycastHit hit, 
                Mathf.Infinity);

            if (!raycast)
            {
                return;
            }
            
            Gizmos.color = Color.cyan;
            Gizmos.DrawLine(transform.position, hit.point);
            _turret.transform.position = hit.point;

            Vector3 right = Vector3.Cross(hit.normal, transform.forward).normalized;
            Vector3 forward = Vector3.Cross(right, hit.normal).normalized;
            
            //Vector3 forward = Vector3.Cross(transform.right, hit.normal).normalized;

            _turret.transform.rotation = Quaternion.LookRotation(forward, hit.normal);
            
            Gizmos.color = Color.green;
            Gizmos.DrawLine(hit.point, hit.point + hit.normal);
            Gizmos.color = Color.red;
            //Gizmos.DrawLine(hit.point, hit.point + right);
            Gizmos.color = Color.blue;
            Gizmos.DrawLine(hit.point, hit.point + forward);

        }
    }

  


}
