Shader "Custom/Blinn-Phong"
{
    Properties
    {
        _Color("Object color", Color) = (0.1, 0.4, 0.1)
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
                float4 positionOS : POSITION;
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
            float _Shininess;
            CBUFFER_END

            Varyings Vert(Attributes input)
            {
                Varyings output;
                
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                
                return output;
            }

            float4 BlinnPhong(const Varyings i)
            {
                const Light mainLight = GetMainLight();

                // Ambient lighting
                const float3 ambient = 0.1 * mainLight.color;
                
                const float3 diffuse = saturate(dot(i.normalWS, mainLight.direction)) * mainLight.color;

                // Suunta fragmentista kameraan world spacessa
                const float3 viewDir = GetWorldSpaceNormalizeViewDir(i.positionWS);

                // Puolivälivektori
                const float3 halfDir = normalize(mainLight.direction + viewDir);

                // Specular lighting
                const float3 specular = pow(saturate(dot(i.normalWS, halfDir)), _Shininess) * mainLight.color;

                // Yhdistä valaistuksen osat ja laske väri
                return float4((ambient + diffuse + specular) * _Color, 1);
            }

            float4 Frag(const Varyings input) : SV_Target
            {
                return BlinnPhong(input);
            }

            ENDHLSL
        }

        Pass
        {
            Name "Depth"
            Tags { "LightMode" = "DepthOnly" }
            
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R
            
            HLSLPROGRAM
            
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
             // PITÄÄ OLLA RELATIVE PATH TIEDOSTOON!!!
             #include "Common/DepthOnly.hlsl"
             ENDHLSL
        }

        Pass
        {
            Name "Normals"
            Tags { "LightMode" = "DepthNormalsOnly" }
            
            Cull Back
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM
            
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag
        
            #include "Common/DepthNormal.hlsl"
            
            ENDHLSL
        }
    }
}