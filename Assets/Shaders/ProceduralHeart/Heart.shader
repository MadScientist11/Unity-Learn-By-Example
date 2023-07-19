Shader "Unlit/ProceduralHeart"
{
    Properties
    {
        _health ("Health", Range(0,1)) = 1

        _shape ("Shape", Range(0, 0.3)) = 0
        _border ("Border", Range(0, 0.25)) = 0
        _outline ("Outline", Range(-0.001, 0.25)) = -0.001

        _heartColor ("HeartColor", Color) = (1,0,0)
        _heartBgColor ("HeartBgColor", Color) = (0,0,0)
        _borderColor ("BorderColor", Color) = (1,1,1)
        _outlineColor ("OutlineColor", Color) = (1,0,0)

        [Toggle] _horizontalFill ("HorizontalFill", float) = 1
        [Toggle] _verticalFill ("VerticalFill", float) = 0
    }
    SubShader
    {
        Tags {
        "RenderType"="Transparent"
        "Queue"="Transparent"
        }
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag



            #include "UnityCG.cginc"

            float _shape;
            float _border;
            float _outline;

            float3 _heartColor;
            float3 _heartBgColor;
            float3 _borderColor;
            float3 _outlineColor;

            float _health;

            float _horizontalFill;
            float _verticalFill;

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

            float Remap(float low1, float high1, float low2, float high2, float value) {
                return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float dot2( float2 v ) { return dot(v,v); }

            #define TAU 6.28318530718


            float sdfHeart( float2 p )
            {
                p.x = abs(p.x);

                if( p.y+p.x>1.0 )
                    return sqrt(dot2(p-float2(0.25,0.75))) - sqrt(2.0)/4.0;
                return sqrt(min(dot2(p-float2(0.00,1.00)),
                                dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
            }



            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                uv = (uv - 0.5) * 2;
                _shape = Remap(0, 1, -.25, 1, _shape);


                float heartSDF = sdfHeart(float2(uv.x, uv.y + 0.5) * (1+ abs(_shape))) + _shape;
                float borderSDF = sdfHeart(float2(uv.x, uv.y + 0.5) * (1 + abs(_shape))) + _border + _shape;


                float innerHeart = saturate(1 - borderSDF / fwidth(borderSDF));
                float outerHeart = saturate(1 - heartSDF/ fwidth(heartSDF));
                float outlineHeart = saturate(1 - (heartSDF - _outline) / fwidth(heartSDF));

                float3 border = (outerHeart - innerHeart) * _borderColor;
                float3 heart = innerHeart * _heartColor;
                float3 outline = (outlineHeart - outerHeart) * _outlineColor;

                float verticalMask = 1 - step(0, uv.y * 0.75 - 0.5 + (1-_health)) * innerHeart;
                float horizontalMask = 1 - step(0, uv.x * 0.75 - 0.5 + (1-_health)) * innerHeart;

                heart = lerp(_heartBgColor, heart, saturate(verticalMask * _verticalFill + horizontalMask * _horizontalFill));

                float3 color = border + heart + outline;
                return float4(color, outlineHeart);
            }
            ENDCG
        }
    }
}
