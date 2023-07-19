#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.Rendering;

public class CrossProductConstructSpace : MonoBehaviour
{
#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        var point = transform.position;
        Handles.zTest = CompareFunction.LessEqual;
        Handles.DrawAAPolyLine(point, point + transform.right);

        if (Physics.Raycast(point, transform.right, out RaycastHit info))
        {
            Handles.color = Color.green;
            Handles.DrawAAPolyLine(info.point, info.point + info.normal);

            Handles.color = Color.red;
            var xAxis = Vector3.Cross(info.normal, transform.right).normalized;
            Handles.DrawAAPolyLine(info.point, info.point + xAxis);
            
            Handles.color = Color.cyan;
            var zAxis = Vector3.Cross(xAxis, info.normal);
            Handles.DrawAAPolyLine(info.point, info.point + zAxis);
        }
    }
#endif
}
