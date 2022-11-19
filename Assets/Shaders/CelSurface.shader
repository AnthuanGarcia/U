Shader "Custom/CelSurface"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _Col1 ("Base Color", Color) = (1, 1, 1, 1)
        _Col2 ("Dir Color", Color) = (1, 1, 1, 1)
        _Intensity ("Diffuse Intensity", Float) = 0.125
        _AA("Band Smoothing", Float) = 4.0
		_Glossiness("Shininess", Float) = 64.0
		_Fresnel("Fresnel/Rim Amount", Range(0, 1)) = 0.5
        _Ramp("Ramp Light", 2D) = "white" {}
        [Toggle(SCALING)]_Scaling("Outline by Scale", Float) = 0
		_OutlineSize("Outline Size", Float) = 0.01
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _ID("Stencil ID", Int) = 1
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

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Cel
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _Ramp;
        float4 _Col1;
        float4 _Col2;
        float _Intensity;
        float _AA;
        float _Glossiness;
        float _Fresnel;

        float4 LightingCel(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {

            float3 n = normalize(s.Normal);
            lightDir = normalize(lightDir);
            viewDir = normalize(viewDir);

            float diff = dot(n, lightDir);
            float diffuse = max(diff, 0.0);

            //float delta = fwidth(diffuse) * _AA;
            //float diffSmooth = smoothstep(0, delta, diffuse);
            float diffSmooth = tex2D(_Ramp, float2(diff * 0.5 + 0.5, 0.5));

            float3 hv = normalize(lightDir + viewDir);
            float spec = pow(max(dot(n, hv), 0.0), _Glossiness);

            float specSmooth = smoothstep(0.0, 0.1*_AA, spec);

            float rim = 1.0 - dot(n, viewDir);
            rim *= sqrt(diffuse);

            const float fresnelSize = 1.0 - _Fresnel;
            float rimSmooth = smoothstep(fresnelSize, fresnelSize*1.1, rim);

            float dirCol = (1.0 + diff) * 0.5;
            float3 baseCol = lerp(_Col1.rgb, _Col2.rgb, dirCol * atten);
            //baseCol.a = s.Alpha;

            s.Albedo = baseCol;
            float3 col = baseCol + diffSmooth*_Intensity + (rimSmooth + specSmooth) * atten;

            return fixed4(col, s.Alpha);

        }

        sampler2D _MainTex;

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
