Shader "Custom/MultiTexture"
{
    Properties
    {
        _MainTex1 ("Texture 1", 2D) = "white" {}
        _MainTex2 ("Texture 2", 2D) = "black" {}
        _Blend ("Blend texture", 2D) = "grey"
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        Pass
        {
            CGPROGRAM
            
            #include "UnityCG.cginc"

            #pragma vertex Vert
            #pragma fragment Frag

            //the texture that's used to blend between the colors
			sampler2D _Blend;
			float4 _Blend_ST;

			//the colors to blend between
			sampler2D _MainTex1;
			float4 _MainTex1_ST;

			sampler2D _MainTex2;
			float4 _MainTex2_ST;

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings Vert (Attributes input)
            {
                Varyings output;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.uv = input.uv;
                return output;
            }

            float4 Frag (Varyings input) : SV_Target
            {
            	const float2 main_uv = TRANSFORM_TEX(input.uv, _MainTex1);
				const float2 secondary_uv = TRANSFORM_TEX(input.uv, _MainTex2);
				const float2 blend_uv = TRANSFORM_TEX(input.uv, _Blend);

				//read colors from textures
				fixed4 main_color = tex2D(_MainTex1, main_uv);
				fixed4 secondary_color = tex2D(_MainTex2, secondary_uv);
				fixed4 blend_color = tex2D(_Blend, blend_uv);

				//take the red value of the color from the blend texture
				fixed blend_value = blend_color.r;

				//interpolate between the colors
				fixed4 col = lerp(main_color, secondary_color, blend_value);
				return col;
            }
            ENDCG
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