using UnityEngine;

public class LookAtTrigger : MonoBehaviour
{
    [SerializeField] private Transform _lookAtTarget;
    
    [Range(-1,1)]
    [SerializeField] private float _lookThreshold = 0;
    
    [field: SerializeField] private float CurrentLookValue { get; set; }

    private void OnDrawGizmos()
    {
        var dirToLookAtTarget = (_lookAtTarget.position - transform.position).Normalize2();
        
        // The dot product result is a value between -1 and 1, which shows whether the trigger is looking at LookAtTarget or not
        // For example, value 0 means that the trigger's direction when he is facing is perpendicular to the LookAtTarget direction
        CurrentLookValue = Vector3.Dot(dirToLookAtTarget, transform.right);
        
        DrawDirectionToTarget(dirToLookAtTarget);

        DrawTriggerFaceDirection();
    }

    private void DrawDirectionToTarget(Vector3 direction)
    {
        var isLookingAt = CurrentLookValue >= _lookThreshold;
        Color color = isLookingAt ? Color.green : Color.red;
        Gizmos.color = color;
        Gizmos.DrawLine(transform.position, transform.position + direction);
    }

    private void DrawTriggerFaceDirection()
    {
        Gizmos.color = Color.white;
        Gizmos.DrawLine(transform.position, transform.position + transform.right);
    }
}
