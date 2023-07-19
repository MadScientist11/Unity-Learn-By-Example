Shader "Unlit/Portal"
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

            float circle(float2 p)
            {
                float r = length(p);
                float radius = 0.4;
                float height = 1.;
                float width = 150.;

                return height - pow(r - radius, 2.) * width;
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


            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = AspectRatioUV(interpolators.uv - 0.5);

                float2 st = float2(
                    atan2(uv.y, uv.x),
                    length(uv) * 1. + tt * .5
                );
                st.x += st.y * 1.1; // - iTime; * 0.3;
                st.x = fmod(st.x, TAU);

                float n = fbmC(st) * 5 -2 ;

                n = max(n, 0.1);

                float temp = 1. - circle(uv);
                float circle = max(temp, 0);


                float color = n / circle;

                float mask = smoothstep(0.48, 0.4, length(uv));


                color *= mask;
                float3 rez = float3(1., 0.5, 0.25) * color;
                return float4(rez, 1);
            }
            ENDCG
        }
    }
}