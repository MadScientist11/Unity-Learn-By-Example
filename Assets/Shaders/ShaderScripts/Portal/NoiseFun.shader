Shader "Unlit/NoiseFun"
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

              float fbmC(float2 p)
            {
                float f = 0.0;
                float2x2 mtx = float2x2(0.80, 0.60, -0.60, 0.80);

                f += 0.500000 * ValueNoise(p + tt);
                p = mul(p, mtx) * 2.02;
                f += 0.031250 * ValueNoise(p);
                p = mul(p, mtx) * 2.01;
                f += 0.250000 * ValueNoise(p);
                p = mul(p, mtx) * 2.03;
                f += 0.125000 * ValueNoise(p);
                p = mul(p, mtx) * 2.01;
                f += 0.062500 * ValueNoise(p);
                p = mul(p, mtx) * 2.04;
                f += 0.015625 * ValueNoise(p + sin(tt));

                return f / 0.96875;
            }

            float noise(in float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);

                float3 u = f * f * (3.0 - 2.0 * f);

                return lerp(lerp(lerp(dot(hash13(i + float3(0.0, 0.0, 0.0)), f - float3(0.0, 0.0, 0.0)),
                                      dot(hash13(i + float3(1.0, 0.0, 0.0)), f - float3(1.0, 0.0, 0.0)), u.x),
                                 lerp(dot(hash13(i + float3(0.0, 1.0, 0.0)), f - float3(0.0, 1.0, 0.0)),
                                      dot(hash13(i + float3(1.0, 1.0, 0.0)), f - float3(1.0, 1.0, 0.0)), u.x), u.y),
                            lerp(lerp(dot(hash13(i + float3(0.0, 0.0, 1.0)), f - float3(0.0, 0.0, 1.0)),
                                      dot(hash13(i + float3(1.0, 0.0, 1.0)), f - float3(1.0, 0.0, 1.0)), u.x),
                                 lerp(dot(hash13(i + float3(0.0, 1.0, 1.0)), f - float3(0.0, 1.0, 1.0)),
                                      dot(hash13(i + float3(1.0, 1.0, 1.0)), f - float3(1.0, 1.0, 1.0)), u.x), u.y), u.z);
            }

            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = AspectRatioUV(interpolators.uv);

                float3 color = fbmC(uv + fbmC(uv + fbmC(uv)));
                //float3 color = ValueNoiseFBM(uv + tt, 15, 0.25, 4);
                //float3 color = noise(float3(uv*4,tt));
                //color = lerp(float3(0.2,0.43, 0.71),float3(0.69,0.11, 0.58), color *color);
                return float4(color, 1);
            }
            ENDCG
        }
    }
}