Shader "Custom/CloudBlending"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_CloudTex("Cloud Texture", 2D) = "white" {}

	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _CloudTex;
			sampler2D_float _CameraDepthTexture;



			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 ray : TEXCOORD1;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv_depth : TEXCOORD1;
				float4 interpolatedRay : TEXCOORD2;
			};

			float4 _MainTex_TexelSize;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv.xy;
				o.uv_depth = v.uv.xy;

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					o.uv.y = 1 - o.uv.y;
				#endif				

				o.interpolatedRay = v.ray;

				return o;
			}



			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				float4 cloud = tex2D(_CloudTex, i.uv);
				float d = Linear01Depth(tex2D(_CameraDepthTexture, i.uv_depth));
				if (cloud.a > 0.96) cloud.a = 1;
				if (d == 1) 
				{
					return lerp(col, cloud, 1 - cloud.a);
				} else
				{
					return col;
				}
			}
			ENDCG
		}
	}
}
