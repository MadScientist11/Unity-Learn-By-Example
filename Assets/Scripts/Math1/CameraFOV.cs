using UnityEditor;
using UnityEngine;

public class CameraFOV : MonoBehaviour
{
    [SerializeField] private Camera _camera;
    [SerializeField] private Transform _inFOVpoint;

    private void OnDrawGizmos()
    {
        var toPointVector = _inFOVpoint.position - _camera.transform.position;
        Handles.DrawAAPolyLine(null, 5, _camera.transform.position, _camera.transform.position + toPointVector);

        var angle = AngleBetweenCameraAndFOVPoint3(_camera.transform, _inFOVpoint.position);
        if (angle > _camera.fieldOfView / 2)
        {
            _camera.fieldOfView = angle * 2;
        }
    }

    //Example, finding the Field Of View angle with a dot product 
    private float AngleBetweenCameraAndFOVPoint1(Transform cameraTransform, Vector3 pointPos)
    {
        var toPointVectorNormalized = (pointPos - cameraTransform.position).normalized;
        return Mathf.Acos(Vector3.Dot(cameraTransform.forward, toPointVectorNormalized)) * Mathf.Rad2Deg;
    }

    //Example, finding the Field Of View angle with trigonometric functions, using dot product to find the adjacent
    private float AngleBetweenCameraAndFOVPoint2(Transform cameraTransform, Vector3 pointPos)
    {
        var hypotenuse = pointPos - cameraTransform.position;
        var adjacent = Vector3.Dot(cameraTransform.forward, hypotenuse) * cameraTransform.forward;
        return Mathf.Acos(adjacent.magnitude / hypotenuse.magnitude) * Mathf.Rad2Deg;
    }

    //Example, finding the Field Of View angle with trigonometric functions, using transform direction to find the adjacent
    private float AngleBetweenCameraAndFOVPoint3(Transform cameraTransform, Vector3 pointPos)
    {
        var hypotenuse = pointPos - cameraTransform.position;
        var adjacent = transform.InverseTransformDirection(hypotenuse.normalized).z * cameraTransform.forward *
                       hypotenuse.magnitude;
        return Mathf.Acos(adjacent.magnitude / hypotenuse.magnitude) * Mathf.Rad2Deg;
    }
 
}