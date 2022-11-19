Shader "Custom/ColorDirFlatPlus"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _Color1("Base Col", Color) = (0.5, 0.25, 0, 1)
        _Color2("Mid Col", Color) = (1, 0.5, 0.5, 1)
        _Color3("Light Col", Color) = (1, 0.5, 0, 1)
        _H("Position of Mid Color", Range(0.0, 1.0)) = 0.5

        [Toggle(SCALING)]_Scaling("Outline by Scale", Float) = 0
		_OutlineSize("Outline Size", Float) = 0.01
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _ID("Stencil ID", Int) = 1

        _GridCol ("Grid Color", Color) = (1, 1, 1, 1)
        _GridSize ("Grid Size", Float) = 3.0
        _Thickness ("Thickness", Range(0.0, 0.3)) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Stencil
        {
            Ref[_ID]
            Comp always
            Pass replace
            ZFail keep
        }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Flat

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _GridCol;
        fixed4 _Color1;
        fixed4 _Color2;
        fixed4 _Color3;
        float _GridSize;
        float _Thickness;
        float _H;

        struct SurfaceOutputCustom
        {
            fixed3 Albedo;
            float3 Normal;
            fixed3 Emission;
            half Specular;
            fixed Gloss;
            fixed Alpha;
        
            float2 uv;
        };

        float4 LightingFlat(SurfaceOutputCustom s, half3 lightDir, half3 viewDir, half atten) {

            float3 n = normalize(s.Normal);
            lightDir = normalize(lightDir);

            float diff = dot(n, lightDir);
            float dir = (1.0 + diff) * 0.5;

            float4 col = lerp(
                lerp(_Color1, _Color2, dir/_H),
                lerp(_Color2 * atten, _Color3, (dir - _H)/(1.0 - _H)),
                step(_H, dir)
            );

            s.uv -= 0.5;

            float2 fpos = frac(s.uv * _GridSize) - 0.5;

            float4 colGrid = 1.0;

            colGrid = 1.0 - smoothstep(
                _Thickness, 
                _Thickness + 0.01, 
                min(abs(fpos.x), abs(fpos.y))
            );

            col = lerp(col, colGrid * _GridCol, colGrid.r);

            return col;
        }

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            INTERNAL_DATA
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        //UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        //UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputCustom o)
        {
            o.uv = IN.uv_MainTex;
            o.Normal = WorldNormalVector(IN, o.Normal);
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
