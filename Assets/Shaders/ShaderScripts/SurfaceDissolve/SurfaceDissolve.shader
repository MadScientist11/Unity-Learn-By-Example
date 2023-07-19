Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _LineColor ("LineColor", Color) = (1,0,0)
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

            float4 _Position;
            float4 _LineColor;
            float _Radius;

            struct MeshData
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            Interpolators vs(MeshData v)
            {
                Interpolators o;
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 fs(Interpolators interpolators) : SV_Target
            {
                float3 color = 1.;
                float dist = 1 - distance(interpolators.worldPos.xz, _Position.xz);
                float circle = InverseLerp(0 - _Radius, 1, dist);
                float circle2 = Lerp(0, 1, circle * circle * (3 - 2 * circle));

                //float3 blendNormal = saturate(pow(IN.worldNormal * 1.4, 4));
                half4 nSide1 = ValueNoiseFBM(interpolators.worldPos.xz * 5 + tt);
                //half4 nSide2 = tex2D(_NoiseTex, (IN.worldPos.xz + _Time.x) * _NScale);
                //half4 nTop = tex2D(_NoiseTex, (IN.worldPos.yz + _Time.x) * _NScale);

                //float3 noisetexture = nSide1;
                //noisetexture = lerp(noisetexture, nTop, blendNormal.x);
                //noisetexture = lerp(noisetexture, nSide2, blendNormal.y);
                float sphereNoise = LerpUnclamped(circle2, nSide1 * circle2, .2);

                float radiusCutoff = step(.5, sphereNoise);

                float Line = step(sphereNoise - 0.02, 0.5) * radiusCutoff; // line between two textures
                float3 colouredLine = Line * _LineColor; // color the line
                float disappearMask = 1-radiusCutoff.xxx + Line;
                clip(disappearMask-0.01);
                color = Lerp(1,_LineColor,Line);
                
                return float4(color, 1);
            }
            ENDCG
        }
    }
}