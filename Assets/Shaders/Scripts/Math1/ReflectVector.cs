using UnityEditor;
#if UNITY_EDITOR
using UnityEngine;
#endif

public class ReflectVector : MonoBehaviour
{
    private void OnDrawGizmos()
    {
        if (Physics.Raycast(transform.position, transform.right, out RaycastHit hit))
        {
            var normal = hit.normal;
            var hitVector = hit.point - transform.position;

            //Finding reflect vector, can be done with Vector3.Reflect - Vector3.Reflect(hitVector, normal)
            var projectedDistance = Vector3.Dot(hitVector, normal);
            var projectedVectorManual = hitVector - 2 * projectedDistance * normal;

#if UNITY_EDITOR
            Handles.color = Color.cyan;
            Handles.DrawAAPolyLine(hit.point, hit.point + hit.normal);

            Handles.color = Color.blue;
            Handles.DrawAAPolyLine(transform.position, transform.position + hitVector);

            Handles.color = Color.red;
            Handles.DrawAAPolyLine(hit.point, hit.point + projectedVectorManual);
#endif
        }
    }
}