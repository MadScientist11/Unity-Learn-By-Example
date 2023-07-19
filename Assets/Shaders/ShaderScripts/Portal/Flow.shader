Shader "Unlit/Flow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ResultTexture ("Texture", 2D) = "white" {}
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

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float2 grad(float2 z) // replace this anything that returns a random vector
            {
                // 2D to 1D  (feel free to replace by some other)
                int n = z.x + z.y * 11111;

                // Hugo Elias hash (feel free to replace by another one)
                n = (n << 13) ^ n;
                n = (n * (n * n * 15731 + 789221) + 1376312589) >> 16;

                #if 0

    // simple random vectors
    return vec2(cos(float(n)),sin(float(n)));
    
                #else

                // Perlin style vectors
                n &= 7;
                float2 gr = float2(n & 1, n >> 1) * 2.0 - 1.0;
                return (n >= 6) ? float2(0.0, gr.x) : (n >= 4) ? float2(gr.x, 0.0) : gr;
                #endif
            }

            float noise(in float2 p)
            {
                float2 i = float2(floor(p));
                float2 f = frac(p);

                float2 u = f * f * (3.0 - 2.0 * f); // feel free to replace by a quintic smoothstep instead

                return lerp(lerp(dot(grad(i + float2(0, 0)), f - float2(0.0, 0.0)),
                                 dot(grad(i + float2(1, 0)), f - float2(1.0, 0.0)), u.x),
                            lerp(dot(grad(i + float2(0, 1)), f - float2(0.0, 1.0)),
                                 dot(grad(i + float2(1, 1)), f - float2(1.0, 1.0)), u.x), u.y);
            }

            const float2x2 m = float2x2(0.80, 0.60, -0.60, 0.80);

            float fbm(float2 p)
            {
                float f = 0.0;
                f += 0.500000 * noise(p);
                p.xy = mul(m, p.xy) * 2.02;
                f += 0.250000 * noise(p);
                p.xy = mul(m, p.xy) * 2.03;
                f += 0.125000 * noise(p);
                p.xy = mul(m, p.xy) * 2.01;
                f += 0.062500 * noise(p);
                p.xy = mul(m, p.xy) * 2.04;
                f += 0.031250 * noise(p);
                p.xy = mul(m, p.xy) * 2.01;
                f += 0.015625 * noise(p);
                return f / 0.96875;
            }

            float PerlinFBM(float2 uv, float octaves = 6, float gain = 0.5, float lacunarity = 2)
            {
                float value = 0.0;
                float amplitude = .5;
                float frequency = 1.;
                float range = frequency;

                for (int i = 0; i < octaves; i++)
                {
                    value += amplitude * noise(uv * frequency);
                    frequency *= lacunarity;
                    amplitude *= gain;
                    range += amplitude;
                }

                return value / range;
            }

            float Segment_float(in float2 p, in float2 a, in float2 b)
            {
                float2 pa = p - a, ba = b - a;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                return length(pa - ba * h);
            }

            float2 GetGradient(float2 intPos, float t)
            {
                float rand = frac(sin(dot(intPos, float2(12.9898, 78.233))) * 43758.5453);;


                // Rotate gradient: random starting rotation, random rotation rate
                float angle = 6.283185 * rand + 4.0 * t * rand;
                return float2(cos(angle), sin(angle));
            }


            float Pseudo3dNoise(float3 pos)
            {
                float2 i = floor(pos.xy);
                float2 f = pos.xy - i;
                float2 blend = f * f * (3.0 - 2.0 * f);
                float noiseVal =
                    lerp(
                        lerp(
                            dot(GetGradient(i + float2(0, 0), pos.z), f - float2(0, 0)),
                            dot(GetGradient(i + float2(1, 0), pos.z), f - float2(1, 0)),
                            blend.x),
                        lerp(
                            dot(GetGradient(i + float2(0, 1), pos.z), f - float2(0, 1)),
                            dot(GetGradient(i + float2(1, 1), pos.z), f - float2(1, 1)),
                            blend.x),
                        blend.y
                    );
                return noiseVal / 0.7; // normalize to about [-1..1]
            }

            float rand(float co) { return frac(sin(co * (91.3458)) * 47453.5453); }

            float2 CalculatePosition(float2 uv, float2 ij, float a)
            {
                float2 hash = hash22(float2(ij.x, ij.y));
                return uv - float2(hash.x * 50, hash.y * 50) + float2(cos(a), sin(a)) * 5 + fmod(tt, 20);
            }

            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv - 0.5;
                float2 trueUV = interpolators.uv * 50;

                float scale = 50;
                uv *= scale;

                float2 id = floor(uv);
                float2 f = frac(uv);
                float n = PerlinFBM(float2(uv * .05 )) * 5;
                float nn = Pseudo3dNoise(float3(uv * .1, tt * .1));
                float a = nn * TAU;

                //float3 color = SampleHard(Segment_float(Rotate2D(f - 0.5, a), float2(0, 0.5), float2(0, 0)) - 0.05);

                float3 color = 0.;

                for (int i = 0; i < 50; i++)
                {
                    for (int j = 0; j < 50; j++)
                    {
                        float2 pos = CalculatePosition(trueUV, float2(i, j), a);

                        float2 ij = float2(i, j + 1);
                        float3 hash = hash23(float2(ij.x, ij.y));


                        color += SampleHard(SegmentSDF(trueUV,
                                                       pos, CalculatePosition(trueUV, ij, a)) - 0.1) * hash ;
                    }
                }
                return float4(color, 1);
            }
            ENDCG
        }
    }
}