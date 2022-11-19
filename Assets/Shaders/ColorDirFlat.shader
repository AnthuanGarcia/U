Shader "Custom/ColorDirFlat"
{
    Properties
    {
        _Color1("Base Col", Color) = (0.5, 0.25, 0, 1)
        _Color2("Mid Col", Color) = (1, 0.5, 0.5, 1)
        _Color3("Light Col", Color) = (1, 0.5, 0, 1)
        _H("Position of Mid Color", Range(0.0, 1.0)) = 0.5

        [Toggle(SCALING)]_Scaling("Outline by Scale", Float) = 0
		_OutlineSize("Outline Size", Float) = 0.01
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _ID("Stencil ID", Int) = 1

        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Stencil
		{
			Ref[_ID]
			Comp always
			Pass replace
			ZFail keep
		}

        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Flat

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color1;
        fixed4 _Color2;
        fixed4 _Color3;
        fixed4 _GridColor;
        half _H;

        float4 LightingFlat(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {

            float3 n = normalize(s.Normal);
            lightDir = normalize(lightDir);

            float diff = dot(n, lightDir);
            float dir = (1.0 + diff) * 0.5;

            float4 col = lerp(
                lerp(_Color1, _Color2, dir/_H),
                lerp(_Color2, _Color3, (dir - _H)/(1.0 - _H)),
                step(_H, dir)
            );

            return float4(col.rgb, s.Alpha);

        }

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = 0.0;
        }
        ENDCG

        Pass
		{
			Cull Front
			ZWrite On
			ZTest ON

			Stencil
			{
				Ref[_ID]
				Comp notequal
				Fail keep
				Pass replace
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

            #pragma shader_feature SCALING

			#include "UnityCG.cginc"

			float _OutlineSize;
			float4 _OutlineColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;

            #ifdef SCALING

                float3 pos = v.vertex * (1.0 + _OutlineSize);

            #else

                float3 normal = normalize(v.normal) * _OutlineSize;
				float3 pos = v.vertex + normal;
            
            #endif

				o.vertex = UnityObjectToClipPos(pos);

				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				return _OutlineColor;
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
