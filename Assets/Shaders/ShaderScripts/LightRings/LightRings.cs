using Unity.Mathematics;
using UnityEngine;
using UnityEngine.UI;

public class LightRings : MonoBehaviour
{
    [SerializeField] private RawImage _image;
    private Material _material;
    private Vector2 _mousePos;

    private void Start()
    {
        _material = _image.material;
    }

    public static float2 GetScreenPosition()
    {
        Vector3 posn = Input.mousePosition;
        return new float2(posn.x, posn.y);
    }

    public static float2 GetViewportPosition()
    {
        float2 screenPos = GetScreenPosition();
        return screenPos / new float2(Screen.width, Screen.height);
    }

    private void Update()
    {
        _mousePos = GetViewportPosition();
        Debug.Log(_mousePos);
        _material.SetVector("_MousePosition", _mousePos);
    }
}