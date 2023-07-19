using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ortho : MonoBehaviour
{
    public Transform planeTransform; // Reference to your plane object

    void Start()
    {
        Camera camera = GetComponent<Camera>();
        // Get the dimensions of the plane in world space
        Vector3 planeDimensions = planeTransform.lossyScale;

// Calculate the distance from the camera to the plane
        float distance = planeDimensions.z / (2 * Mathf.Tan(camera.fieldOfView * 0.5f * Mathf.Deg2Rad));

// Set the camera's position and rotation to point at the center of the plane
        Vector3 planeCenter = planeTransform.position;
        Vector3 cameraPosition = planeCenter - distance * camera.transform.forward;
        camera.transform.position = cameraPosition;
        camera.transform.LookAt(planeCenter);

// Adjust the field of view angle to fill the plane
        float verticalFOV = Mathf.Atan(planeDimensions.y / distance) * 2.0f * Mathf.Rad2Deg;
        camera.fieldOfView = verticalFOV;

    }
}