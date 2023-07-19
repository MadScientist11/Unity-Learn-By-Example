using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;

public class Flow2 : MonoBehaviour
{
    private Material _material;
    private Camera _camera;
    public Texture _texture;
    private RenderTexture _renderTexture;

    private void Start()
    {
        _material = GetComponent<Image>().material;
        _renderTexture = new RenderTexture(512, 512, 0);
        RenderTexture.active = _renderTexture;
    }

    private void Update()
    {
        //_material.SetTexture("_RenderTexture",_texture);
        Graphics.Blit(null, _renderTexture, _material);
        Texture2D texture = new Texture2D(_renderTexture.width, _renderTexture.height, TextureFormat.RGB24, false);

        // Read the RenderTexture data into the Texture2D
        texture.ReadPixels(new Rect(0, 0, _renderTexture.width, _renderTexture.height), 0, 0);
        texture.Apply();

        // Convert the Texture2D to a byte array
        byte[] bytes = texture.EncodeToPNG();

        // Save the byte array as a PNG file
        File.WriteAllBytes(Application.dataPath + "/renderTexture.png", bytes);
    }
}