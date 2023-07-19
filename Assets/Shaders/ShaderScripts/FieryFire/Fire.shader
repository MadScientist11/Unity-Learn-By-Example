Shader "Unlit/Fire"
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

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float hash11(float p)
            {
                p = frac(p * .1031);
                p *= p + 33.33;
                p *= p + p;
                return frac(p);
            }

            float hash12(float2 p)
            {
                float3 p3 = frac(float3(p.xyx) * .1031);
                p3 += dot(p3, p3.yzx + 33.33);
                return frac((p3.x + p3.y) * p3.z);
            }


            float SmoothNoise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = smoothstep(0, 1, frac(uv));

                float2 bl = hash12(i);
                float2 br = hash12(i + float2(1, 0));
                float2 b = Lerp(bl, br, f.x);

                float2 tl = hash12(i + float2(0, 1));
                float2 tr = hash12(i + float2(1, 1));
                float2 t = Lerp(tl, tr, f.x);

                return Lerp(b, t, f.y);
            }

            float Noise(float2 uv)
            {
                float octave1 = SmoothNoise(uv * 4);
                octave1 += SmoothNoise(uv * 8) * 0.5;
                octave1 += SmoothNoise(uv * 16) * 0.25;
                octave1 += SmoothNoise(uv * 32) * 0.125;
                octave1 += SmoothNoise(uv * 64) * 0.0625;
                return octave1 / 2.25;
            }

            float FireShape(float2 uv)
            {
                return saturate(sin((uv.x-0.3) * TAU*1.3) - 0.55 - uv.y);
            }

            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;
                float nx = Noise(float2(uv.x, uv.y - tt / 4))*1.5 ;
                float n2 = Noise(float2(uv.x - tt / 8, uv.y))*1;
                float ny = Noise(float2(uv.x, uv.y - tt / 2)) * 1.3;
                float3 color = FireShape(float2(uv.x , uv.y - ny));
                color = color * nx* (uv.y+1);
                color = pow(color, 4) * float3(50.0, 5.0, 1.0);

                // tonemapping
                color = color / (1.0 + color);
                color = pow(color, float(1.0 / 2.2).xxx);
                color = clamp(color, 0.0, 1.0);

                return float4(color, 1);
            }
            ENDCG
        }
    }
}