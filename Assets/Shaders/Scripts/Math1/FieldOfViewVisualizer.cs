#if UNITY_EDITOR
using UnityEditor;
#endif

using UnityEngine;

public class FieldOfViewVisualizer : MonoBehaviour
{
    [Tooltip("Field Of View in degrees")]
    [Range(0,360)]
    [SerializeField] private float _fieldOfView = 60;
    
    [Range(.5f,5)]
    [SerializeField] private float _radius = 1;
    
    //Compile this code out, cuz we use handles
#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        //direction transform is facing
        var lookDirection = transform.right;

        //rotation angle of the transform
        var lookDirAngleRad = Mathf.Acos(lookDirection.x);
        //Because arccos is unsigned, figure out sign
        var lookDirAngleRadSigned =lookDirection.y < 0 ? -lookDirAngleRad : lookDirAngleRad;
  
        //Draw the direction transform is facing
        Gizmos.color = Color.red;
        Gizmos.DrawLine(transform.position, lookDirection);
        
        //Calculate point from where to start to draw an arc, so that middle of arc was transform.right point
        var fromAngleRad = lookDirAngleRadSigned + (Mathf.Deg2Rad * (-_fieldOfView / 2));
        var fromX = Mathf.Cos(fromAngleRad);
        var fromY = Mathf.Sin(fromAngleRad);
        var from = new Vector3(fromX, fromY, 0);
        from *= _radius;
        
        //Calculate end of the field of view arc
        var toAngleRad = lookDirAngleRadSigned + (Mathf.Deg2Rad * (_fieldOfView / 2));
        var toX = Mathf.Cos(toAngleRad);
        var toY = Mathf.Sin(toAngleRad);
        var to = new Vector3(toX, toY, 0);
        to *= _radius;
        
        //Visualize field of view constraints
        Gizmos.color = Color.cyan;
        Gizmos.DrawLine(transform.position, from);
        Gizmos.DrawLine(transform.position, to);

        Handles.DrawWireArc(transform.position, transform.forward, from, _fieldOfView, _radius);
    }
#endif
}
