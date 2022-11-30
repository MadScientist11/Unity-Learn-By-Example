using UnityEngine;

public class ObjectBuilder : MonoBehaviour
{
    [SerializeField] private GameObject _prefab;
    
    // Results in this context menu when right-clicking on the field
    [ContextMenuItem("Reset Position", "ResetPosition")]
    [SerializeField] private Vector3 _spawnPoint;

    public void CreateObject()
    {
        if (_prefab == null)
        {
            Debug.LogError("You are trying to build object, but prefab is not set in inspector");
            return;
        }
        Instantiate(_prefab, _spawnPoint, Quaternion.identity);
    }

    private void ResetPosition()
    {
        _spawnPoint = Vector3.zero;
        Debug.Log("Position was reset");
    }
}
