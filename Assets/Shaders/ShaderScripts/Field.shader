Shader "Unlit/Field"
{
    Properties {}
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            Blend One One
            CGPROGRAM
            #pragma vertex vs
            #pragma fragment fs

            #include "UnityCG.cginc"

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

            fixed4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;
                //float offset = cos(uv.x * UNITY_TWO_PI * 7) * 0.25;
                //float pattern = 1 - (sin((uv.y - 0.5f) * UNITY_TWO_PI * 5 + offset - _Time.y) * 0.5f + 0.5f);
                //float res = pattern * (1- interpolators.uv.y);

                float offset = cos(uv.x * UNITY_TWO_PI * 7) * 0.25;
                float res = sin(uv.y * UNITY_TWO_PI * 5 + offset);
                return fixed4(res.xxx, 1);
            }
            ENDCG
        }
    }
}