Shader "Unlit/SirpinskyTriangle"
{
    Properties
    {
        _steps("steps", float) = 2
        _pointA("pointA", Vector) = (0.25,0.25,0)
        _pointB("pointB", Vector) = (0.5,0.75,0)
        _pointC("pointC", Vector) = (0.75,0.25,0)

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
            float2 _pointC;

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

            struct Trig
            {
                float2 A : TEXCOORD0;
                float2 B : TEXCOORD0;
                float2 C : TEXCOORD0;
            };


            Interpolators vs(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
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

            float Circle(float2 uv, float2 position, float size, float crispness)
            {
                float d = length(uv - position);
                return smoothstep(size + crispness, size, d);
            }


            float DrawTriangle(float2 uv, float2 parentA, float2 parentB, float2 parentC)
            {
                float color = Line(uv, parentA, parentB, 0.0025, 0.01);
                color += Line(uv, parentB, parentC, 0.0025, 0.01);
                color += Line(uv, parentA, parentC, 0.0025, 0.01);

                return color;
            }

            Trig ConstructTriangle(float2 pt, float len)
            {
                Trig trig;
                trig.A = pt;
                trig.B = trig.A + float2(1., 0.) * len * sqrt(2);

                float angle = acos(1 - pow(len * sqrt(2), 2) / (2 * len * len));
                float angle2 = (UNITY_PI - angle) / 2;

                float2 dir = normalize(float2(cos(angle2), sin(-angle2)));
                trig.C = trig.A + dir * len;
                return trig;
            }

            float2 CalculateTriangleOrigin(float2 rootA, float2 rootB, float iteration, float currentTriangle,
                                           float rootInterpolation)
            {
                const int LEFT = 0;
                const int TOP = 1;
                const int RIGHT = 2;
                float side = fmod(currentTriangle, 2);

                float fullLength = length(rootB - rootA);

                float partsOfThree = pow(3, iteration) / 3;

                float startingA = lerp(rootA, rootB, 0.5);
                //
                // (left) 0,1,2 left, top, right  | (top) 3,4,5 | (right) 6,7,8
                // (left) (left) 0,1,2 | (left) (top) 3,4,5 | (left) (right) 6,7,8...

                float2 newA = lerp(startingA, rootB, rootInterpolation);

                //float2 pointA =

                if (side == RIGHT)
                {
                    newA = newA + float2(1, 0) * fullLength * sqrt(2) * rootInterpolation * 2;
                }
            }

            Trig Calculate(float2 parentA, float2 parentB, float2 parentC, float iter, float t)
            {
                Trig trig;
                float2 pointA = parentA;
                float2 pointB = parentB;
                float2 pointC = parentC;


                float2 ABdir = normalize(pointB - pointA);
                float ABLength = length(pointB - pointA);

                float2 ACdir = normalize(pointC - pointA);
                float ACLength = length(pointC - pointA);

                float2 BCdir = normalize(pointC - pointB);
                float BCLength = length(pointC - pointB);

                trig.A = 0;
                trig.B = 0;
                trig.C = 0;

                float fullLength = length(pointB - pointA);
                float leftRightT = 0.5 * pow(0.5, iter);
                float topT = 0.75 * pow(0.5, iter);

                if (iter == 0)
                {
                    trig.A = pointA + ABdir * ABLength * 0.5;
                    trig.B = pointA + ACdir * ACLength * 0.5;
                    trig.C = pointB + BCdir * BCLength * 0.5;
                }
                if (iter == 1)
                {
                    if (t == 0) // left
                    {
                        float2 A = lerp(pointA, pointA + ABdir * ABLength, .25);
                        trig = ConstructTriangle(A, ABLength * .25);
                    }
                    else if (t == 1) // top
                    {
                        float2 A = lerp(pointA, pointA + ABdir * ABLength, 0.75);
                        trig = ConstructTriangle(A, ABLength * 0.25);
                    }
                    else if (t == 2) //right
                    {
                        float2 leftA = lerp(pointA, pointA + ABdir * fullLength, 0.25);
                        float2 A = leftA + float2(1, 0) * fullLength * sqrt(2) * 0.5;
                        trig = ConstructTriangle(A, ABLength * 0.25);
                    }
                    else
                    {
                        trig.A = 0;
                        trig.B = 0;
                        trig.C = 0;
                    }
                }
                if (iter == 2)
                {
                    if (t == 0) // left
                    {
                        float2 A = lerp(pointA, pointA + ABdir * fullLength, 0.25 / 2);
                        trig = ConstructTriangle(A, ABLength * 0.25 / 2);
                    }
                    else if (t == 1) // top
                    {
                        float2 A = lerp(pointA, pointA + ABdir * fullLength, 0.75 / 2);
                        trig = ConstructTriangle(A, ABLength * 0.25 / 2);
                    }
                    else if (t == 2) //right
                    {
                        float2 leftA = lerp(pointA, pointA + ABdir * fullLength, 0.25 / 2);
                        float2 A = leftA + float2(1, 0) * fullLength * sqrt(2) * 0.25;
                        trig = ConstructTriangle(A, ABLength * 0.25 / 2);
                    }
                    else if (t == 3)
                    {
                        pointA = lerp(pointA, pointA + ABdir * fullLength, 0.5);
                        float2 A = lerp(pointA, pointA + ABdir * fullLength, 0.25 / 2);
                        trig = ConstructTriangle(A, ABLength * 0.25 / 2);
                    }
                    else if (t == 4)
                    {
                        pointA = lerp(pointA, pointA + ABdir * fullLength, 0.5);
                        float2 A = lerp(pointA, pointA + ABdir * fullLength, 0.75 / 2);
                        trig = ConstructTriangle(A, ABLength * 0.25 / 2);
                    }
                    else if (t == 5)
                    {
                        pointA = lerp(pointA, pointA + ABdir * fullLength, 0.5);
                        float2 leftA = lerp(pointA, pointA + ABdir * fullLength, 0.25 / 2);
                        float2 A = leftA + float2(1, 0) * fullLength * sqrt(2) * 0.25;
                        trig = ConstructTriangle(A, ABLength * 0.25 / 2);
                    }
                    else if (t == 6)
                    {
                        float2 leftA = lerp(pointA, pointA + ABdir * fullLength, 0.25 / 2);
                        float2 A = leftA + float2(1, 0) * fullLength * sqrt(2) * 0.5;
                        trig = ConstructTriangle(A, ABLength * 0.25 / 2);
                    }
                    else if (t == 7)
                    {
                        float2 leftA = lerp(pointA, pointA + ABdir * fullLength, 0.75 / 2);
                        float2 A = leftA + float2(1, 0) * fullLength * sqrt(2) * 0.5;
                        trig = ConstructTriangle(A, ABLength * 0.25 / 2);
                    }
                    else if (t == 8)
                    {
                        float2 leftA = lerp(pointA, pointA + ABdir * fullLength, 0.25 / 2);
                        float2 A = leftA + float2(1, 0) * fullLength * sqrt(2) * 0.75;
                        trig = ConstructTriangle(A, ABLength * 0.25 / 2);
                    }
                    else
                    {
                        trig.A = 0;
                        trig.B = 0;
                        trig.C = 0;
                    }
                }

                return trig;
            }


            fixed4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;

                uv *= 10;

                float4 color = float4(0, 0, 0, 0);

                float2 points[100];
                points[0] = _pointA;
                points[1] = _pointB;
                points[2] = _pointC;

                for (int i = 3; i < 12; i++)
                {
                    points[i] = (points[0] + points[1]) / 2;
                    points[i] = (points[1] + points[1]) / 2;
                }

                //float2 pointA = _pointA;
                //float2 pointB = _pointB;
                //float2 pointC = _pointC;
                //
                //color += DrawTriangle(uv, pointA, pointB, pointC);
                //
                //for (int i = 0; i < 3; i++)
                //{
                //    // 0 - 1, 1 - 3; 2 - 9 3 - 27
                //    for (int t = 0; t < pow(3, i); t++)
                //    {
                //        Trig trig = Calculate(pointA, pointB, pointC, i, t);
                //        color += DrawTriangle(uv, trig.A, trig.B, trig.C);
                //    }
                //}


                return fixed4(color);
            }
            ENDCG
        }
    }
}