Shader "Unlit/Flow2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RenderTexture ("RenderTexture", 2D) = "white" {}
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

            float fBm(in float3 p, float repScale)
            {
               

                return Pseudo3dNoise(float3(p * repScale)) * .57 + Pseudo3dNoise(float3(p * repScale*2)) * .28 + Pseudo3dNoise(float3(p * repScale*4)) * .15;
            }

            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = AspectRatioUV(interpolators.uv - 0.5);
                float3 color = 0;

                float scSizeFactor = pow(800 / 450., .333);
                float scale = 72. * scSizeFactor;
                float2 gridUV = uv * scale;
                float2 ip = floor(gridUV);
                gridUV -= ip + .5; // The centered local cell coordinates. Same as: p = fract(p) - .5;

                for (int j = -3; j <= 3; j++)
                {
                    for (int i = -3; i <= 3; i++)
                    {
                        float2 o = float2(i, j);
                        float2 renderIndex = ip + o;
                        // o += hash22() * .25;
                        float alpha = 1.;
                        float3 col2 = 0.;

                        const int lNum = 6;
                        for (int n = 0; n < lNum; n++)
                        {
                            float a = (fBm(float3(uv,tt), 1));


                            // The length of the direction vector needs to be such that the total
                            // lines drawn don't exceed the NxN grid area boundaries.
                            const float rl = 3.5 / 6.; // 3.5/float(lNum);

                            // Standard way to take an angle and convert it to a direction vector.
                            float2 r = float2(cos(a), sin(a)) * rl;


                            // Drawing a line from one point to the next point in the segment. By the way, lines
                            // aren't mandatory. You could draw points, and so forth.
                            //float l = SegmentSDF(gridUV, o - gridUV, o + r - gridUV);
                            float l = (dot(o - gridUV, o - gridUV)) * 2.;
                            //float l = distLine(o - p, o + r - p);
                            //float l = length(o + r/2. - p) - .1;

                            l = (1. - smoothstep(0., .0045 / scSizeFactor, (l - .005) / scale));
                            //l = max(1. - l*4., 0.)*1.; // Alternate.

                            // The "alpha*(1. - alpha)" is a weighted distribution trick that I'd forgotten about.
                            // You'll see IQ use it when he's layering things. You can also square the term. Anyway,
                            // it's not mandatory. Something like "alpha*.2" would work, but it tends to layer things 
                            // in a less nice way, whereas weighted distribution layering alleviates the subtle grid
                            // marks.
                            l *= alpha * (1. - alpha) * .8;
                            //l *= alpha*.25;


                            // Max blend. No join marks with overlapping line segments. Some texture coloring
                            // is applied as well.
                            col2 = max(col2, float3(1, 0, 0) * l);

                            // Additive blend. You can see the overlapping joins when using this method...
                            // which might be preferable, in some cases.
                            //col2 += vec3(l)*tx*.8;


                            // Advance the line position by the angular direction ray.
                            o += r;

                            // Falloff with increasing strand length. 
                            alpha -= 1. / 6.; // Hardcoding "1./float(sNum);"
                        }
                        color += col2;
                    }
                }

                return float4(color, 1);
            }
            ENDCG
        }
    }
}