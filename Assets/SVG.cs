using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using Unity.VectorGraphics;

[RequireComponent(typeof(SpriteRenderer))]
public class SVG : MonoBehaviour
{
    
    [Multiline()]
    public string svg = "";
    public int pixelsPerUnit;
    public bool flipYAxis;

    void Start()
    {
        List<VectorUtils.Geometry> geometries = GetGeometries();
 
        var sprite = VectorUtils.BuildSprite(geometries, pixelsPerUnit, VectorUtils.Alignment.Center, Vector2.zero, 128, flipYAxis);
        GetComponent<SpriteRenderer>().sprite = sprite;
    }

    protected List<VectorUtils.Geometry> GetGeometries()
    {
        using var textReader = new StringReader(svg);
        
        
        var sceneInfo = SVGParser.ImportSVG(textReader);
 
        return VectorUtils.TessellateScene(sceneInfo.Scene, new VectorUtils.TessellationOptions
        {
            StepDistance = 10,
            SamplingStepSize = 100,
            MaxCordDeviation = 0.5f,
            MaxTanAngleDeviation = 0.1f
        });
    }
}
