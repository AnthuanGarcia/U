Shader "Custom/ColorDirection"
{
    Properties
    {
        _Color1("Base Col", Color) = (0.5, 0.25, 0, 1)
        _Color2("Mid Col", Color) = (1, 0.5, 0.5, 1)
        _Color3("Light Col", Color) = (1, 0.5, 0, 1)
        _H("Position of Mid Color", Range(0.0, 1.0)) = 0.5
        _RimColor("Rim Color", Color) = (0.5, 0.5, 0.5, 1)
        _RimPow("Rim intensity", Range(0.0, 12.0)) = 2.0
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.0
        _Alpha("Transparency", Range(0.0, 1.0)) = 1.0
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #pragma surface surf Standard
  
        struct Input {
            float2 uv_MainTex;
            float3 viewDir;
            float3 worldNormal;
        };
        
        sampler2D _MainTex;
        fixed4 _RimColor;
        fixed4 _Color1;
        fixed4 _Color2;
        fixed4 _Color3;
        half _H;
        half _Metallic;
        half _Smoothness;
        half _RimPow;
        half _Alpha;

        void surf(Input IN, inout SurfaceOutputStandard o) {

            half rim = clamp(1.0 - dot(IN.viewDir, IN.worldNormal), 0.0, 1.0);
            rim = pow(rim, _RimPow);

            float dir = (dot(_WorldSpaceLightPos0.xyz, IN.worldNormal) * 0.5) + 0.5;

            float4 baseCol = lerp(
                lerp(_Color1, _Color2, dir/_H),
                lerp(_Color2, _Color3, (dir - _H)/(1.0 - _H)),
                step(_H, dir)
            );

            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * baseCol;
            o.Emission = (_RimColor.rgb * rim) * _RimColor.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Alpha = _Alpha;

        }
        ENDCG
    }

    FallBack "Diffuse"
}
