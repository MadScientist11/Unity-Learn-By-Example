Shader "Unlit/Bezier"
{
    Properties
    {
        _mousePoint("mousePoint", Vector) = (0,0,0)
        _pointA("pointA", Vector) = (0.1,0.1,0)
        _controlPoint("controlPoint", Vector) = (0.75,0.25,0)
        _pointB("pointB", Vector) = (0.9,0.9,0)
        _steps("steps", float) = 10
    }
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

            float2 _pointA;
            float2 _pointB;
            float2 _controlPoint;

            float _steps;

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

            float Circle(float2 uv, float2 position, float size, float crispness)
            {
                float d = length(uv - position);
                return smoothstep(size + crispness, size, d);
            }

            float SDF(float2 uvPoint, float2 pointA, float2 pointB)
            {
                float2 AB = pointB - pointA;
                float2 AP = uvPoint - pointA;

                float projection = dot(AP, normalize(AB));
                float k = saturate(projection / length(AB));
                float2 AQ = AB * k;

                float2 PQ = AP - AQ;
                float sdf = length(PQ);
                return sdf;
            }

            float Line(float2 uv, float2 pointA, float2 pointB, float size, float crispness)
            {
                return smoothstep(size + crispness, size, SDF(uv, pointA, pointB));
            }

            float4 DrawBezierPoints(float2 uv, float2 pointA, float2 pointB, float2 controlPoint)
            {
                float4 points = Circle(uv, pointA, 0.03, 0.01) * float4(1, 0, 0, 1);
                points += Circle(uv, pointB, 0.03, 0.01) * float4(0, 1, 0, 1);
                points += Circle(uv, controlPoint, 0.03, 0.01) * float4(0, 0, 1, 1);
                return points;
            }

            float4 DrawBezierLines(float2 uv, float2 pointA, float2 pointB, float2 controlPoint)
            {
                float lines = Line(uv, pointA, controlPoint, 0.01, 0.01);
                lines = max(lines, Line(uv, controlPoint, pointB, 0.01, 0.01));
                return float4(lines.xxx, 1);
            }

            fixed4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;

                float4 color = DrawBezierPoints(uv, _pointA, _pointB, _controlPoint);
                color += DrawBezierLines(uv, _pointA, _pointB, _controlPoint);
                
                float t = sin(_Time.y) * 0.5 + 0.5;
                float2 lerp1 = lerp(_pointA, _controlPoint, t);
                color += Circle(uv, lerp1, 0.03, 0.01) * float4(1, 1, 0, 1);
                
                float2 lerp2 = lerp(_controlPoint, _pointB, t);
                color += Circle(uv, lerp2, 0.03, 0.01) * float4(1, 0, 1, 1);
                color += Line(uv, lerp1, lerp2, 0.01, 0.01);
                float2 lerp3 = lerp(lerp1, lerp2, t);
                color += Circle(uv, lerp3, 0.03, 0.01) * float4(0, 1, 1, 1);

                float step = 1 / _steps;
                float2 pp = _pointA;
                for (float t = 0; t < 1; t += step)
                {
                    float2 lerp1 = lerp(_pointA, _controlPoint, t);
                    float2 lerp2 = lerp(_controlPoint, _pointB, t);
                    float2 lerp3 = lerp(lerp1, lerp2, t);

                    color += Line(uv, pp, lerp3, 0.005, 0.01);
                    pp = lerp3;
                }


                return fixed4(color);
            }
            ENDCG
        }
    }
}