Shader "Unlit/SDFs"
{
    Properties {}
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"


            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float Remap(float low1, float high1, float low2, float high2, float value)
            {
                return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float dot2(float2 v) { return dot(v, v); }

            #define TAU 6.28318530718

            float sdfCircle(float2 p, float2 pos, float size)
            {
                return length(p - pos) - size;
            }

            float sdBox(in float2 p, float2 pos, in float2 size)
            {
                p -= pos;
                float2 d = abs(p) - size;
                return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
            }

            float sdEquilateralTriangle(in float2 p)
            {
                p *= 2;
                const float k = sqrt(3.0);
                p.x = abs(p.x) - 1.0;
                p.y = p.y + 1.0 / k;
                if (p.x + k * p.y > 0.0) p = float2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
                p.x -= clamp(p.x, -2.0, 0.0);
                return -length(p) * sign(p.y);
            }

            float2 smin(float a, float b, float k)
            {
                float h = max(k - abs(a - b), 0.0) / k;
                float m = h * h * 0.5;
                float s = m * k * (1.0 / 2.0);
                return (a < b) ? float2(a - s, m) : float2(b - s, 1.0 - m);
            }

            float opSmoothUnion(float d1, float d2, float k)
            {
                float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
                return lerp(d2, d1, h) - k * h * (1.0 - h);
            }

            float opSmoothSubtraction(float d1, float d2, float k)
            {
                float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
                return lerp(d2, -d1, h) + k * h * (1.0 - h);
            }

            float opSmoothIntersection(float d1, float d2, float k)
            {
                float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
                return lerp(d2, d1, h) + k * h * (1.0 - h);
            }


            float4 frag(Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                uv = (uv - 0.5) * 2;

                float circle1 = sdfCircle(uv, float2(0, 0), .25);
                float circle2 = sdEquilateralTriangle(uv);

                float size = 0.2;
                float color = smoothstep(size + 0.01, size, circle1 - circle2);
                return float4(color.xxx, 1);
            }
            ENDCG
        }
    }
}