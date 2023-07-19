Shader "Unlit/PintableTest"
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
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;

                float4 vertex : SV_POSITION;
            };

            float Rand(float x)
            {
                return frac(sin(x * 866353.13) * 613.73);
            }

            float rand(float co) { return frac(sin(co * (91.3458)) * 47453.5453); }


            Interpolators vs(MeshData v)
            {
                Interpolators o;
                o.uv = float2(v.vertex.x + .5, v.vertex.y + .5);
                v.vertex.y += o.uv.y * (sin(tt) * 0.5 + 0.5);

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }


            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;
                float4 color =  tex2D(_MainTex, uv);
;
                return float4(uv.xy,0,1);
            }
            ENDCG
        }
    }
}