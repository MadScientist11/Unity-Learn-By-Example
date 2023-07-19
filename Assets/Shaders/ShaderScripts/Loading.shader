Shader "Unlit/Loading"
{
    Properties {}
    SubShader
    {
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vs
            #pragma fragment fs

            #include "UnityCG.cginc"
            #include "Assets/Shaders/ShaderScripts/ShaderLib/sdf.cginc"
            #include "Assets/Shaders/ShaderScripts/ShaderLib/math.cginc"
            #include "Assets/Shaders/ShaderScripts/ShaderLib/shaderlib.cginc"


            struct MeshData
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            Interpolators vs(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float OutElastic(float t)
            {
                float p = 0.3f;
                return (float)pow(2, -10 * t) * (float)sin((t - p / 4) * (2 * PI) / p) + 1;
            }


            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;
                uv = uv * 2 - 1;

                float thickness = 0.05;
                float ringSDF = RingSDF(uv, .6, thickness);

                float ring = SampleHard(ringSDF, 1.5);

                float angle = -tt * 4.;
                uv = Rotate2D(uv, angle);
                float radialGrad = (atan2(uv.x, uv.y) + PI) / TAU;
                float circle = CircleSDF(uv - float2(0, -.6), .05);
                circle = SampleHard(circle, 1.5);

                radialGrad = Lerp(0, 1,  radialGrad * radialGrad);

                float3 color = radialGrad * ring;
                color = max(color, circle);

                return float4(color, 1);
            }
            ENDCG
        }
    }
}