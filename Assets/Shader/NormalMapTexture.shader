Shader "Custom/NormalMapTexture"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Shininess ("Shininess", Range(1, 512)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NormalMap_ST;
            float _Shininess;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };

            Varyings Vert (Attributes input)
            {
                Varyings output;

                const VertexPositionInputs position_inputs = GetVertexPositionInputs(input.positionOS);
                const VertexNormalInputs normal_inputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionHCS = position_inputs.positionCS;
                output.normalWS = normal_inputs.normalWS;
                output.tangentWS = normal_inputs.tangentWS;
                output.bitangentWS = normal_inputs.bitangentWS;
                output.positionWS = position_inputs.positionWS;

                
                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;

                return output;
            }

            float4 Frag (Varyings input) : SV_Target
            {
                const float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
                const float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, TRANSFORM_TEX(input.uv, _NormalMap)));
                const float3x3 TangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);

                const float3 normalWS = TransformTangentToWorld(normalTS, TangentToWorld, true);
                
                input.normalWS = normalWS;

                return texColor;
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