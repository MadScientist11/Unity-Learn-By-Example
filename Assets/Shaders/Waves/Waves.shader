Shader "Unlit/Waves"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

    }
    SubShader
    {
        Tags {}

        Pass
        {
            CGPROGRAM
            #pragma vertex vs
            #pragma fragment fs

            #include "UnityCG.cginc"
            #include "Packages/com.quizandpuzzle.shaderlib/Runtime/math.cginc"
            #include "Packages/com.quizandpuzzle.shaderlib/Runtime/shaderlib.cginc"
            #include "Packages/com.quizandpuzzle.shaderlib/Runtime/sdf.cginc"

            sampler2D _MainTex;

            float _Samples[64];


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
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float squared(float value) { return value * value; }

            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;
                uv = uv * 2 - 1;
                uv.x *= 1.77;

                float lineIntensity;
                float glowWidth;
                float3 color = 0.;
                for (float i = 0; i < 5; i++)
                {
                    uv.y += (0.2 * sin(uv.x + i / 7 - tt * 0.6));
                    float Y = uv.y;
                    float mod = fmod(interpolators.uv.x + i / 1.3 + tt, 2.0) - 1.0;
                    float expression = 1.6 * abs(mod);
                    lineIntensity = 0.4 + squared(expression);
                    glowWidth = abs(lineIntensity / (150.0 * Y));
                    color += float3(glowWidth.xxx);
                }
                 

                return float4(color, 1);
            }
            ENDCG
        }
    }
}