Shader "Unlit/HealthBar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _health ("Health", Range(0.0, 1.0)) = 1

        _fullHealthColor ("FullHealthColor", Color) = (0,1,0,1)
        _lowHealthColor ("LowHealthColor", Color) = (1,0,0,1)
        _bgColor ("BGColor", Color) = (0,0,0,1)


    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"


            float _health;
            float4 _lowHealthColor;
            float4 _fullHealthColor;
            float4 _bgColor;

            sampler2D _MainTex;


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


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float InverseLerp(float a, float b, float v) {
                return (v-a) / (b-a);
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

            float4 frag (Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;

                float dx = ddx(uv.x);
                float dy = ddy(uv.y);
                float aspect = dy/dx;
                uv.x *= aspect;
                clip(Line(uv, float2(0.4, 0.5), float2(aspect - 0.4, 0.5), .3, .01) - 0.01);



                //float t = saturate(InverseLerp(0.2, 0.8, _health));
                //float3 fillColor = lerp(_lowHealthColor, _fullHealthColor, t);
                //float3 color = lerp(_bgColor, fillColor, fill);

                float fill = 1 - step(_health * aspect, uv.x);
                float3 healthBarColor = tex2D(_MainTex,float2(_health, uv.y));
                float3 color = lerp(_bgColor,healthBarColor, fill);
                float3 flash = ((cos(_Time.y * 4) * 0.1) * (step(_health, 0.2))) + 1;

                color *= fill * flash;




                return float4(color , 1);
            }
            ENDCG
        }
    }
}


