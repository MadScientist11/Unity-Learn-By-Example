using UnityEngine;
using UnityEngine.Video;

public class Pintable : MonoBehaviour
{
    [SerializeField] private GameObject _pintable;
    private MeshRenderer _meshRenderer;
    
    public VideoPlayer videoPlayer;
    public Material material;
    public int frameNumber;

    private Texture2D texture;


    private void Start()
    {
        videoPlayer.Play();
        material = _pintable.GetComponent<MeshRenderer>().material;
    }

    private void Update()
    {
        // Check if video is ready and we haven't already extracted the frame
        if (videoPlayer.isPrepared && texture == null)
        {
            // Set the current frame number
            videoPlayer.frame = frameNumber;

            // Create a new texture with the same dimensions as the video
            texture = new Texture2D((int)videoPlayer.width, (int)videoPlayer.height, TextureFormat.RGBA32, false);

            // Copy the current frame from the video to the texture
            RenderTexture renderTexture = videoPlayer.targetTexture;
            RenderTexture.active = renderTexture;
            texture.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0);
            texture.Apply();

            // Set the texture on the material
            material.SetTexture("_MainTex", texture);
        }
    }

  

    void OnDestroy()
    {
        // Destroy the texture when we're done with it
        if (texture != null)
        {
            Destroy(texture);
            texture = null;
        }
    }
}
