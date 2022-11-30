#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

public class RadialTrigger : MonoBehaviour
{
    [SerializeField] private Transform _triggerObject;
    
    [Range(0.5f,3)]
    [SerializeField] private float _triggerRadius = 1;
    
    [field: SerializeField] private float DistanceToObjectMagnitude { get; set; }
    
    //Compile out this cuz we using Handles
#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        //Same as (_triggerObject.position - transform.position).magnitude;
        DistanceToObjectMagnitude = Vector3.Distance(transform.position, _triggerObject.position);
        
        var isInsideTrigger = DistanceToObjectMagnitude <= _triggerRadius;
        var color = isInsideTrigger ? Color.green : Color.red;
        DrawRadialTrigger(color);
    }

    private void DrawRadialTrigger(Color drawingColor)
    {
        Handles.color = drawingColor;
        Handles.DrawWireDisc(transform.position, Vector3.forward, _triggerRadius,2);
    }
#endif
}
