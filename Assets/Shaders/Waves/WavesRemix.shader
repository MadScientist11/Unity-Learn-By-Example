Shader "Unlit/WavesRemix"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB


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

                v.vertex.y = o.uv.x * (v.vertex.y + sin(v.vertex.x * 2 + tt * 2.) * .2);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float squared(float value) { return value * value; }

            float hash(float2 p)
            {
                float3 p3 = frac(float3(p.xyx) * 0.13);
                p3 += dot(p3, p3.yzx + 3.333);
                return frac((p3.x + p3.y) * p3.z);
            }


            float noise(float2 x)
            {
                float2 i = floor(x);
                float2 f = frac(x);

                // Four corners in 2D of a tile
                float a = hash(i);
                float b = hash(i + float2(1.0, 0.0));
                float c = hash(i + float2(0.0, 1.0));
                float d = hash(i + float2(1.0, 1.0));

                // Simple 2D lerp using smoothstep envelope between the values.
                // return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
                //			mix(c, d, smoothstep(0.0, 1.0, f.x)),
                //			smoothstep(0.0, 1.0, f.y)));

                // Same code, with the clamps in smoothstep and common subexpressions
                // optimized away.
                float2 u = f * f * (3.0 - 2.0 * f);
                return Lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }

            float fbm(float2 x)
            {
                float v = 0.0;
                float a = 0.5;
                float2 shift = float2(100.0,100.0);
                // Rotate to reduce axial bias
                float2x2 rot = float2x2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
                for (int i = 0; i < 5; ++i)
                {
                    v += a * noise(x);
                    x = mul(rot,x) * 2.0 + shift;
                    a *= 0.5;
                }
                return v;
            }

            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;
                uv = uv * 2 - 1;

                float lineIntensity = 0;
                float glowWidth;
                float3 color = 0.;
                float hline = Annular(uv.y + sin(uv.x * TAU + tt) * .2, 0);
                for (float i = 0; i < 5; i++)
                {
                    lineIntensity += abs(fmod(interpolators.uv.x + i / 1.3 + tt, 2.0) - 1) - .01;
                }

                color = lineIntensity.xxx / (hline * 15) * -(uv.x-0.75) * 1.5; // * (uv.x - sin(tt) * 2);

                color = saturate(color);
                float alpha = smoothstep(color, 0, 0.2) * fbm(uv*5);
                color = alpha * float3(1,0,0);
                return float4(color, alpha);
            }
            ENDCG
        }
    }
}