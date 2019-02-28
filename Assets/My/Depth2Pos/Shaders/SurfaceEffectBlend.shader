Shader "Custom/SurfaceEffectBlend"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_DetailTex("Texture", 2D) = "white" {}
		_Radius("Radius", float) = 50
		_SpinningSpeed("Spinning Speed", float) = 1
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
			sampler2D _DetailTex;
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



			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				float rawDepth = tex2D(_CameraDepthTexture, i.uv_depth);

				//float linearDepth = LinearEyeDepth(rawDepth);
				float linearDepth = i.vertex.w;
				float3 surfacePos = _WorldSpaceCameraPos + (linearDepth * i.interpolatedRay).xyz;
				half4 effectCol = half4(0, 0, 0, 0);
				float dist = distance(surfacePos.xz, _WorldSpaceEffectPos.xz);
				float s = 0; float c = 0;
				float angle = atan2((surfacePos.x - _WorldSpaceEffectPos.x),(surfacePos.z - _WorldSpaceEffectPos.z));
				angle += _Time.x * _SpinningSpeed;
				sincos(angle, s ,c);
				float2 surfaceUV = (float2(s * dist  , c * dist) / _Radius + 1) * 0.5;
				float effectFactor = tex2D(_DetailTex, float2(surfaceUV));
				if (dist < _Radius ) effectCol = lerp(_TintColor, float4(1,1,1,1) ,effectFactor) * effectFactor;
				return col + effectCol;
			}
			ENDCG
		}
	}
}
