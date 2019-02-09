Shader "Hidden/ShieldBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		// Horizontal
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float2 _BlurSize;
			float _Distance;


			float4 frag (v2f i) : SV_Target
			{
				_BlurSize.x /= max(_Distance,40) / 40;
				float s =  tex2D(_MainTex, i.uv).a * 0.38774;
				s += tex2D(_MainTex, i.uv + float2(_BlurSize.x * 2, 0)).a * 0.06136;
				s += tex2D(_MainTex, i.uv + float2(_BlurSize.x, 0)).a * 0.24477;
				s += tex2D(_MainTex, i.uv + float2(_BlurSize.x * -1, 0)).a * 0.24477;
				s += tex2D(_MainTex, i.uv + float2(_BlurSize.x * -2, 0)).a * 0.06136;
				return s;
			}
			ENDCG
		}

		// Vertical
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float2 _BlurSize;
			float _Distance;



			float4 frag (v2f i) : SV_Target
			{
				_BlurSize.y /=  max(_Distance,40) / 40;
				float s = tex2D(_MainTex, i.uv).a * 0.38774;
				s += tex2D(_MainTex, i.uv + float2(0, _BlurSize.y * 2)).a * 0.06136;
				s += tex2D(_MainTex, i.uv + float2(0, _BlurSize.y)).a * 0.24477;			
				s += tex2D(_MainTex, i.uv + float2(0, _BlurSize.y * -1)).a * 0.24477;
				s += tex2D(_MainTex, i.uv + float2(0, _BlurSize.y * -2)).a * 0.06136;
				return s;
			}
			ENDCG
		}
	}
}
