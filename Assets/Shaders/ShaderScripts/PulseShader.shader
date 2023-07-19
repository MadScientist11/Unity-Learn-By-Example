Shader "Unlit/PulseShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
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
                float i;
                interpolators.uv -= float2(0.5f, 0.5f);
                interpolators.uv*=20;
                float sinewave1 = sin(interpolators.uv.x * 2) * 2.65f;
                float sinewave2 = sin(interpolators.uv.x* 1.45f) * 2 + interpolators.uv.y;
                float pulse = sinewave1 + sinewave2;
                return fixed4(pulse.xxx,  1);
            }
            ENDCG
        }
    }
}