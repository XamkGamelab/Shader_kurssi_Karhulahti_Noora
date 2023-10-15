Shader "Custom/Blinn-Phong"
{
    Properties
    {
        _Color("Object color", Color) = (1, 1, 1, 1)
        _Shininess ("Object shininess", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/lighting.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _Shininess;
            CBUFFER_END

            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(input.positionOS, 1))));
                output.positionWS = mul(UNITY_MATRIX_M, input.positionOS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                
                return output;
            }

            float4 BlinnPhong(Varyings i)
            {
                Light mainLight = GetMainLight();

                // Ambient lighting
                float3 ambient = 0.1 * mainLight.color;
                
                float3 diffuse = saturate(dot(i.normalWS, mainLight.direction)) * mainLight.color;

                // Suunta fragmentista kameraan world spacessa
                float3 viewDir = GetWorldSpaceNormalizeViewDir(i.positionWS);

                // Puolivälivektori
                float3 halfDir = normalize(mainLight.direction + viewDir);

                // Specular lighting
                float3 specular = pow(saturate(dot(i.normalWS, halfDir)), _Shininess) * mainLight.color;

                // Yhdistä valaistuksen osat ja laske väri
                return float4((ambient + diffuse + specular) * _Color, 1);
            }

            float4 Frag(const Varyings input) : SV_Target
            {
                return BlinnPhong(input);
            }

            ENDHLSL
        }
    }
}