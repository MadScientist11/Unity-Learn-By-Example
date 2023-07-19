using UnityEditor;
using UnityEngine;

public class AngleBetweenTwoVectorsVisualizer : MonoBehaviour
{
    [SerializeField, Range(0,1)] private float _yellowValue;
    [SerializeField, Range(0,1)] private float _greenValue;

    //Tau is a constant that equals 2 * pi, full turn
    private const float Tau = 6.28318530718f;

    private void OnDrawGizmos()
    {
        var yellowRotationRad = Tau * _yellowValue;
        var yellowVec = AngleToDirection(yellowRotationRad);
        
        var greenRotationRad = Tau * _greenValue;
        var greenVec = AngleToDirection(greenRotationRad);

        //Find angle between two vectors
        var from = greenRotationRad > yellowRotationRad ? yellowVec : greenVec;
        var to = from == yellowVec ? greenVec : yellowVec;
        
        //Calculating the angle between two vectors,
        //atan2 gives result relative to positive x coordinate and by subtracting two angles we end up with angle between vectors
        var angleDeg = (DirectionToAngle(to) - DirectionToAngle(from)) * Mathf.Rad2Deg;

        //Atan2 gives range (−π, π], so we add 360 if angle is negative
        if (angleDeg < 0) angleDeg = 360 + angleDeg;
        
        Debug.Log("Angle=" + angleDeg);
        Handles.DrawWireArc(transform.position, transform.forward, from, angleDeg, 0.4f, 2);
        
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(Vector3.zero, yellowVec);
        Gizmos.color = Color.green;
        Gizmos.DrawLine(Vector3.zero, greenVec);
    }

    private Vector2 AngleToDirection(float angleRad)
    {
        var x = Mathf.Cos(angleRad);
        var y = Mathf.Sin(angleRad);
        return new Vector2(x, y);
    }

    private float DirectionToAngle(Vector2 direction)
    {
        var angle = Mathf.Atan2(direction.y, direction.x);
        return angle;
    }
}
