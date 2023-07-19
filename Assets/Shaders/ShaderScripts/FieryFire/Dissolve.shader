Shader "Unlit/Dissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {



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
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 vertexObject : TEXCOORD2;

                float4 vertex : SV_POSITION;
            };

            Interpolators vs(MeshData v)
            {
                Interpolators o;
                o.uv = v.uv;
                o.vertexObject = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                return o;
            }

            float4 _Position;
            float _Radius;

            float4 fs(Interpolators interpolators) : SV_Target
            {
                float2 uv = interpolators.uv;
                float3 color = 1.;
                float3 vPos = interpolators.vertexObject * float3(1,1,-1);
                float3 n = normalize(interpolators.normal);
                float3 temp = pow(abs(n), 8);
                float3 mask = temp / dot(temp, float3(1, 1, 1));
                float2 p = lerp(float2(vPos.x, vPos.z), float2(vPos.y, vPos.z), mask.x);
                float2 triplanarUV = lerp(p, float2(vPos.x, vPos.y+1), mask.z);

                float dist = 1 - distance(triplanarUV, _Position.xz);
                float circle = InverseLerp(0 - _Radius, 1, dist);
                float circle2 = Lerp(0, 1, circle * circle * (3 - 2 * circle));
                
                half4 nSide1 = ValueNoiseFBM(triplanarUV * 5 + tt);
                float sphereNoise = LerpUnclamped(circle2, nSide1 * circle2, .2);
                
                float radiusCutoff = step(.5, sphereNoise);
                
                float Line = step(sphereNoise - 0.02, 0.5) * radiusCutoff; // line between two textures
                float3 colouredLine = Line * float3(1,0,0); // color the line
                float disappearMask = 1 - radiusCutoff.xxx + Line;
                clip(disappearMask - 0.01);
                color = Lerp(1, float3(1,0,0), Line);


                return float4(color, 1);
                return float4(mask, 1);
                return float4(triplanarUV,0, 1);
                return float4(vPos.xz,0, 1);
            }
            ENDCG
        }
    }
}