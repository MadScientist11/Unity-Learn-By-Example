#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

public class AreaCalculator : MonoBehaviour
{
    [SerializeField] private Mesh _mesh;
    [SerializeField] private float _fullArea;

    private void OnDrawGizmosSelected()
    {
        _fullArea = 0;
        if (_mesh == null) return;

        for (var i = 0; i < _mesh.triangles.Length; i += 3)
        {
            var vertex1 = _mesh.vertices[_mesh.triangles[i]];
            var vertex2 = _mesh.vertices[_mesh.triangles[i + 1]];
            var vertex3 = _mesh.vertices[_mesh.triangles[i + 2]];

            var vector1 = (vertex2 - vertex1);
            var vector2 = (vertex3 - vertex1);
            var cross = Vector3.Cross(vector1, vector2);
            //This is the area of a parallelogram, we need to divide it by 2 at the end
            var area = cross.magnitude;
            _fullArea += area;

#if UNITY_EDITOR
            Handles.color = Color.white;
            Handles.DrawAAPolyLine(vertex1, vertex2, vertex3, vertex1);
            Handles.color = Color.red;
            Handles.DrawAAPolyLine(vertex1, vertex1 + cross);
#endif
        }

        _fullArea /= 2;
    }
}