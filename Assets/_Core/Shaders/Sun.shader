Shader "Puetsua/Sun"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Color1("Color1", Color) = (1,1,1,1)
        [HDR] _Color2("Color2", Color) = (1,1,1,1)

        _offsetX ("OffsetX",Float) = 0.0
        _offsetY ("OffsetY",Float) = 0.0      
        _octaves ("Octaves",Int) = 7
        _lacunarity("Lacunarity", Range( 1.0 , 5.0)) = 2
        _gain("Gain", Range( 0.0 , 1.0)) = 0.5
        _value("Value", Range( -2.0 , 2.0)) = 0.0
        _amplitude("Amplitude", Range( 0.0 , 5.0)) = 1.5
        _frequency("Frequency", Range( 0.0 , 6.0)) = 2.0
        _power("Power", Range( 0.1 , 5.0)) = 1.0
        _scale("Scale", Float) = 1.0  
    }

    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        Cull Back
        ZWrite On
        ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _octaves,_lacunarity,_gain,_value,_amplitude,_frequency, _offsetX, _offsetY, _power, _scale;
           
            float fbm( float2 p )
            {
                p = p * _scale + float2(_offsetX,_offsetY);
                for( int i = 0; i < _octaves; i++ )
                {
                    float2 i = floor( p * _frequency );
                    float2 f = frac( p * _frequency );      
                    float2 t = f * f * f * ( f * ( f * 6.0 - 15.0 ) + 10.0 );
                    float2 a = i + float2( 0.0, 0.0 );
                    float2 b = i + float2( 1.0, 0.0 );
                    float2 c = i + float2( 0.0, 1.0 );
                    float2 d = i + float2( 1.0, 1.0 );
                    a = -1.0 + 2.0 * frac( sin( float2( dot( a, float2( 127.1, 311.7 ) ),dot( a, float2( 269.5,183.3 ) ) ) ) * 43758.5453123 );
                    b = -1.0 + 2.0 * frac( sin( float2( dot( b, float2( 127.1, 311.7 ) ),dot( b, float2( 269.5,183.3 ) ) ) ) * 43758.5453123 );
                    c = -1.0 + 2.0 * frac( sin( float2( dot( c, float2( 127.1, 311.7 ) ),dot( c, float2( 269.5,183.3 ) ) ) ) * 43758.5453123 );
                    d = -1.0 + 2.0 * frac( sin( float2( dot( d, float2( 127.1, 311.7 ) ),dot( d, float2( 269.5,183.3 ) ) ) ) * 43758.5453123 );
                    float A = dot( a, f - float2( 0.0, 0.0 ) );
                    float B = dot( b, f - float2( 1.0, 0.0 ) );
                    float C = dot( c, f - float2( 0.0, 1.0 ) );
                    float D = dot( d, f - float2( 1.0, 1.0 ) );
                    float noise = ( lerp( lerp( A, B, t.x ), lerp( C, D, t.x ), t.y ) );              
                    _value += _amplitude * noise;
                    _frequency *= _lacunarity;
                    _amplitude *= _gain;
                }
                _value = clamp( _value, -1.0, 1.0 );
                return pow(_value * 0.5 + 0.5,_power);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            fixed4 _Color1;
            fixed4 _Color2;
            float _Noise;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 pixel = tex2D(_MainTex, i.uv);
                float val = (_Time.y*0.1+1)/2;
                float2 offset = {-val, 0};
                float2 temp = {i.uv.x + offset.x, i.uv.y + offset.y};
                float n = (fbm(temp) + 1) / 2;

                fixed4 color = lerp(_Color1, _Color2, (_SinTime.w+1)/2);

                pixel.rgb = dot(pixel.rgb, float3(0.3, 0.59, 0.11));
                n = n*0.5 + 0.5;

                pixel.rgb *= n * color;

                return pixel;
            }
            ENDCG
        }
    }
}
