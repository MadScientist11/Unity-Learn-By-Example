using UnityEngine;

public class QuadraticBezier : MonoBehaviour
{
    [SerializeField] private Transform _point1;
    [SerializeField] private Transform _point2;
    [SerializeField] private Transform _controlPoint;
    [SerializeField, Min(1)] private int _iterations;

    private Vector3 _previousCurvePoint;
    private void OnDrawGizmos()
    {
        DrawQuadraticBezier();
    }

    private void DrawQuadraticBezier()
    {
        _previousCurvePoint = _point1.position;
        float step = 1 / (float)_iterations;
        for (float t = 0; t < 1.0001f; t += step)
        {
            Vector3 lerp1 = Vector3.Lerp(_point1.position, _controlPoint.position, t);
            Vector3 lerp2 = Vector3.Lerp(_controlPoint.position, _point2.position, t);
            Vector3 curvePoint = Vector3.Lerp(lerp1, lerp2, t);
            Gizmos.color = Color.blue;
            Gizmos.DrawLine(_previousCurvePoint, curvePoint);
            _previousCurvePoint = curvePoint;
        }
    }
}
