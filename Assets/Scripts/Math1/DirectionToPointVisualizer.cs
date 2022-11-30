using UnityEngine;

public class DirectionToPointVisualizer : MonoBehaviour
{
    [Tooltip("Follow Point")]
    [SerializeField] private Transform _point;

    [Tooltip("Offset of the origin")]
    [SerializeField] private Vector3 _originOffset = Vector3.zero;
    
    [Tooltip("Distance to point in units")]
    [field: SerializeField] private float DistanceToPointMagnitude { get; set; }
    
    private void OnDrawGizmos()
    {
        //Just for better understanding
        DistanceToPointMagnitude = (_point.position - _originOffset).Magnitude();

        DrawDirectionToPoint(_point, _originOffset, Color.blue);
    }
    
    private void DrawDirectionToPoint(Transform point, Vector3 fromOffset, Color drawingColor)
    {
        Gizmos.color = drawingColor;
        
        //Vector to point from origin, which is - (0,0) + _offset
        var distanceToPointVector = point.position - fromOffset;
        
        //Normalized vector(unit vector) 
        var directionToPoint = distanceToPointVector.Normalize2();
        
        //Draws a line starting at from towards to. 
        Gizmos.DrawLine(Vector3.zero + fromOffset, directionToPoint + fromOffset);
    }
}

public static class ManualMathExtensions
{
    public static float Magnitude(this Vector3 v)
    {
        //Formula for magnitude is actually pythagorean theorem sqrt(a^2 +b^2) = c,
        //whenever we find magnitude we basically find hypotenuse of the right triangle
        float sqrMagnitude = v.x * v.x + v.y * v.y + v.z * v.z;
        return Mathf.Sqrt(sqrMagnitude);
    }
    
    public static Vector3 Normalize2(this Vector3 v)
    {
        float magnitude = v.Magnitude();
        if(magnitude == 0) return Vector3.zero;
        
        //To normalize the vector, you need to find the magnitude and then divide each component by it, also can be written as v / magnitude
        return new Vector3(v.x / magnitude, v.y / magnitude, v.z / magnitude);
    }
}
