Shader "Unlit/Lighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Dissolve ("Dissolve", Range(0,1)) = 0.1 
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
            float _Dissolve;
            
            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv - 0.5;
                uv *= 16.5;
                uv.x += fmod(tt*5,12);
                float color = 1.74 * sin(uv.x * 1.45) + uv.y;
                color += 2.28 * sin(uv.x * 2.54);
                color = abs(color);
                color = _Dissolve / color;
                float3 gradient = tex2D(_MainTex, float2(color, 1));
                float3 res = Lerp(float3(0,0,0), gradient, color);
                // res = Lerp(float3(0,0,0), float3(0,0,1), InverseLerp(0,2, color));
                res *= fmod(tt, .5) >= .1;
                return float4(res, color);


                //uv.x*=5;
                //uv.y -=0.5;
                //float i = floor(uv.x);
                //float f = frac(uv.x);
                //float color = Lerp(hash11(i+tt*.001), hash11(i + 1.0+tt*.001), f * f * (3 - 2 * f)) + uv.y;
                //color = abs(color);
                //abs((sin(uv.x*TAU+1)*.2 + uv.y) - sin(uv.x*TAU*2+4)*1 - sin(uv.x*TAU*4+PI)*1.5);
                return float4(color.xxx, 1);
            }
            ENDCG
        }
    }
}