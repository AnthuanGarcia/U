Shader "Hidden/Pixelate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GridSize("Grid Size", Float) = 30.0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define ASPECT _ScreenParams.x / _ScreenParams.y

            sampler2D _MainTex;
            float _GridSize;

            fixed4 frag (v2f_img i) : COLOR
            {
                i.uv = 2.0*i.uv - 1.0;

                fixed2 grid = fixed2(_GridSize * ASPECT, _GridSize);
                fixed2 uvDot = (((floor(i.uv * _GridSize) + 0.5) / _GridSize) + 1.0) * 0.5;

                fixed4 col = tex2D(_MainTex, uvDot);

                return col;
            }
            ENDCG
        }
    }
}
