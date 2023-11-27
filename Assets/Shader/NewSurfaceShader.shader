Shader "Custom/NewSurfaceShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1) 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        Pass
        {
            Name"OmaPass"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL; //Vertexin normaali
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1; //Vertexin normaali maailman koordinaateissa
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            CBUFFER_END


            Varyings Vert(const Attributes input)
            {
                Varyings output;

                //output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(input.positionOS, 1))));
                output.positionHCS = TransformObjectToHClip(input.positionOS);

                //output.positionWS = mul(UNITY_MATRIX_M, input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);

                output.normalWS = TransformObjectToWorldNormal(input.normalOS); //Vertexin normaalin muuntaminen maailman koordinaatteihin
    
                return output;
            }

            half Lambertian(float3 lightDir, float3 normal)
            {
                return max(0, dot(normal, lightDir)); //Lambertian heijastusmallin laskenta
            }

            float4 Frag(const Varyings input) : SV_TARGET
            {
                float3 lightDir = normalize(float3(1, 1, 1)); //Valon suunta
                float3 normal = normalize(input.normalWS); //Vertexin normalisointi

                float lambertian = Lambertian(lightDir, normal); //Diffuusin valaistuksen laskenta

                return _Color * lambertian; //Lopullinen värifragmentille
            }

            ENDHLSL
        }
    }
}
