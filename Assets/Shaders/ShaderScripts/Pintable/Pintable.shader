Shader "Unlit/Pintable"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags {}

        Pass
        {
            ZTest Always
            Offset -1,-1
            CGPROGRAM
            #pragma vertex vs
            #pragma fragment fs

            #include "UnityCG.cginc"
            #include "Assets/Shaders/ShaderScripts/ShaderLib/sdf.cginc"
            #include "Assets/Shaders/ShaderScripts/ShaderLib/math.cginc"
            #include "Assets/Shaders/ShaderScripts/ShaderLib/shaderlib.cginc"

            sampler2D _MainTex;


            struct MeshData
            {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float Rand(float x)
            {
                return frac(sin(x * 866353.13) * 613.73);
            }

            float rand(float co) { return frac(sin(co * (91.3458)) * 47453.5453); }


            float MandelbrotSet(float2 uv)
            {
                float2 z;
                float iter;
                for (int iter = 0; iter < 255; iter++)
                {
                    z = float2(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + uv;
                    if (length(z) > 2) break;
                }
                return iter / 255;
            }


            Interpolators vs(MeshData v)
            {
                Interpolators o;
                o.uv = float2(v.vertex.x + 0.5, v.vertex.y + 0.5);
                o.uv1 = v.uv1;
                float mip = tex2Dlod(_MainTex, float4(o.uv1, 1.0, 0.));
                //float m = MandelbrotSet(o.uv1 + sin(tt));

                v.vertex.y += o.uv.y * 20 * mip;

                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }


            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv1;

                float4 color = tex2D(_MainTex, uv);

                //float m = MandelbrotSet(uv + sin(tt));
                //float4 color = m;
                //float4 color = uv.y;

                //return float4(interpolators.uv1,0,1);
                return float4(color);
            }
            ENDCG
        }
    }
}