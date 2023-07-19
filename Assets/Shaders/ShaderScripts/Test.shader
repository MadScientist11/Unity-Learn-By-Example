Shader "Unlit/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tex2 ("Texture2", 2D) = "black" {}

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

            sampler2D _MainTex;
            sampler2D _Tex2;


            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float sdCircle(float2 uv, float r, float2 offset)
            {
                float x = uv.x - offset.x;
                float y = uv.y - offset.y;

                return length(float2(x, y)) - r;
            }

            float sdSquare(float2 uv, float size, float2 offset)
            {
                float x = uv.x - offset.x;
                float y = uv.y - offset.y;

                return max(abs(x), abs(y)) - size;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float angle = UNITY_PI;

                float2x2 rotationMatrix = float2x2(1, -.5,
                                                   0, 1);

                uv = mul(rotationMatrix, uv);
                
                float4 color = tex2D(_MainTex, uv);
                return float4(color);
            }
            ENDCG
        }
    }
}