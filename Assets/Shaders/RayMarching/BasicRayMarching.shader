Shader "Unlit/BasicRayMarching"
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
            #include "Assets/UnityRayMarchingFramework/Shaders/ShaderLibs/SDF.cginc"

            #define MAX_STEPS 100;
            #define MAX_DIST 100;






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

          

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float dot2(float2 v) { return dot(v, v); }

            #define TAU 6.28318530718

            float sdfCircle(float2 p, float size)
            {
                return length(p) - size;
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
            #define SURF_DIST 1e-3


            float GetDist(float3 p)
            {
                return length(p) - 0.25;
            }

            float RayMarch(float3 ro, float3 rd)
            {
                float d = 0.;
                for (int i = 0; i < 100; i++)
                {
                    float3 pos = ro + rd * d;
                    float dd = GetDist(pos);
                    d += dd;
                    if(dd < 0.001 || d > 100) break;
                }
                return d;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                uv -= 0.5;

                float3 ro = float3(0,0,-3);
                float3 rd = normalize(float3(uv.x, uv.y, 1));

                float scene = RayMarch(ro,rd);
                float3 color = float3(0,0,0);
                
                if(scene < 100)
                {
                    color.r = 1;
                }
                return float4(color, 1);
            }
            ENDCG
        }
    }
}
