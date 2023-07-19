Shader "Unlit/LightRings"
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

            float2 _MousePosition;

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

            float squared(float value) { return value * value; }


            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = AspectRatioUV(interpolators.uv - .5) * 2 * 1.5;
                float2 mousePos = _MousePosition;
                float3 light_color = float3(0.9, 0.65, 0.5);
                float2 offset = float2(cos(tt / 2.0) * mousePos.x, sin(tt / 2.0) * mousePos.y);
                float light = 0.1 / distance(normalize(uv), uv);

                if (length(uv) < 1.0)
                {
                    light *= 0.1 / distance(normalize(uv - offset), uv - offset);
                }


                float3 color = light_color * light;
                return float4(color, 1);
            }
            ENDCG
        }
    }
}