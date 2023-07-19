using Unity.VectorGraphics;
using UnityEngine;

public class TransformSpaces : MonoBehaviour
{
    [SerializeField] private Transform _point;
    [SerializeField] private Transform _localPoint;
    [SerializeField] private Vector3 _localCoords;
    [SerializeField] private Vector3 _worldCoords;
    
    private void OnDrawGizmos()
    {
        if (!transform.hasChanged) return;
        
        //Getting _point to act like a child of the transform with position of _localCoords
        var worldCoords = TransformPointToGlobal(transform, _localCoords);
        _point.position = worldCoords;

        //Getting coords of point in local space, so that point would always stay in same _worldCoords
        var localCoords = TransformPointToLocal(transform, _worldCoords);
        //Position is always in world coords, so using localPosition here
        _localPoint.localPosition = localCoords;
            
        transform.hasChanged = false;
    }
    
    //Transform point and get position relative to local space of origin
    private Vector3 TransformPointToLocal(Transform origin, Vector3 point)
    {
        var vectorToPoint = point - origin.position;
        // handle rotation
        var x = Vector3.Dot(origin.right, vectorToPoint); 
        var y = Vector3.Dot(origin.up, vectorToPoint);
        return new Vector3(x, y, 0);
    }
    
    //Transform point and get position relative to world space
    private Vector3 TransformPointToGlobal(Transform origin, Vector3 point)
    {
        // handle rotation, it does make sense cuz point and origin is in local space
        
        Vector2 right = new Vector2(1, 0);
        Vector2 up = new Vector2(0, 1);

        //Same thing but done with matrix
        Matrix4x4 matrix = new Matrix4x4();//localWorld matrix
        matrix.SetRow(0, origin.right);
        matrix.SetRow(1, origin.up);
        matrix.SetRow(2, new Vector4(0,0,1,0));
        matrix.SetRow(3, new Vector4(0,0,0,1));
        var pointt = matrix.MultiplyPoint(point);
        

        var vectorToPoint = point.x * origin.right + point.y * origin.up;
        pointt = new Vector3(Vector3.Dot(origin.right, point), Vector3.Dot(origin.up, point), 0); // also the same
        Debug.Log($"{pointt} - pointt");
        Debug.Log($"{vectorToPoint} - vect");
        var res = transform.position + vectorToPoint;
        
        return res;
    }
}
