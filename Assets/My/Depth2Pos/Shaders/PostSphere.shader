Shader "Custom/PostSphere"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Radius("Radius", float) = 50
		_TintColor("Tint Color", Color) = (1, 1, 1, 0)

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
			sampler2D_float _CameraDepthTexture;
			float4 _WorldSpaceEffectPos;
			float _Radius;
			float _SpinningSpeed;
			float4 _TintColor;



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

			float CalculateLerp(float dist, float2 uv)
			{
				float lerpFac = (dist / _Radius) * (dist / _Radius);
				uv.y = uv.y / _ScreenParams.x * _ScreenParams.y;
				uv *= 500;
				if (abs(1 - frac(uv.x)) < 0.5 && abs(1 - frac(uv.y)) < 0.5) lerpFac = 1;
				return lerpFac;
			}



			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				float rawDepth = tex2D(_CameraDepthTexture, i.uv_depth);
				float linearDepth = LinearEyeDepth(rawDepth);
				float3 surfacePos = _WorldSpaceCameraPos + (linearDepth * i.interpolatedRay).xyz;
				half4 effectCol = col;
				float dist = distance(surfacePos, _WorldSpaceEffectPos);

				if (dist < _Radius ) effectCol = float4(1,0.3,0.3,1);
				float lerpFac = CalculateLerp(dist, i.uv);
				return lerp(col, effectCol, lerpFac );
			}
			ENDCG
		}
	}
}
