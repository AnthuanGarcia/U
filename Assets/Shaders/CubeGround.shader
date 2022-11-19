Shader "Custom/CubeGround"
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

        //_MainTex ("Texture", 2D) = "white" {}
        //_GridTex ("Grid Texture", 2D) = "white" {}
        [Toggle(GRID)]_Grid("Show Grid", Float) = 0
        _GridCol ("Grid Color", Color) = (1, 1, 1, 1)
        _GridSize ("Grid Size", Float) = 3.0
        _Thickness ("Thickness", Range(0.0, 0.3)) = 0.05
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" 
        }

        Pass
        {
            Stencil
            {
                Ref[_ID]
                Comp always
                Pass replace
                ZFail keep
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature GRID

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 n : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 nWorld : NORMAL;
                float3 viewDir : TEXCOORD2;
                float3 lightDir : TEXCOORD3;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.nWorld = UnityObjectToWorldNormal(v.n);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.lightDir = WorldSpaceLightDir(v.vertex);

                o.uv = v.uv;

                return o;
            }

            //sampler2D _MainTex;
            //sampler2D _GridTex;
            fixed4 _GridCol;
            fixed4 _Color1;
            fixed4 _Color2;
            fixed4 _Color3;
            float _GridSize;
            float _Thickness;
            float _H;

            fixed4 frag (v2f i) : SV_Target
            {

                float3 n = normalize(i.nWorld);
                i.lightDir = normalize(i.lightDir);

                float diff = dot(n, i.lightDir);
                float dir = (1.0 + diff) * 0.5;

                float4 col = lerp(
                    lerp(_Color1, _Color2, dir/_H),
                    lerp(_Color2, _Color3, (dir - _H)/(1.0 - _H)),
                    step(_H, dir)
                );

                //fixed4 grid = (1.0 - tex2D(_GridTex, i.uv)) * step(0.999, n.y);

                //col = lerp(col, grid * _GridCol, grid.r);

            #ifdef GRID

                i.uv -= 0.5;

                float2 fpos = frac(i.uv * _GridSize) - 0.5;

                float4 colGrid = 1.0;

                colGrid = 1.0 - smoothstep(
                    _Thickness, 
                    _Thickness + 0.01, 
                    min(abs(fpos.x), abs(fpos.y))
                );

                col = lerp(col, colGrid * _GridCol, colGrid.r);
                
            #endif

                return col;
            }
            ENDCG

        }

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
}
