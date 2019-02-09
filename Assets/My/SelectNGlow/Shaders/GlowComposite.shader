Shader "Hidden/GlowComposite"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

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
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
			};

			float2 _MainTex_TexelSize;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv0 = v.uv;
				o.uv1 = v.uv;

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					o.uv1.y = 1 - o.uv1.y;
				#endif

				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _GlowPrePassTex;
			sampler2D _GlowBlurredTex;

			float _Intensity;
			float2 _ObjPoint;


			float noiseSampler(float3 xyz, float res)
			{
				xyz *= res;
				float3 xyz0 = floor(fmod(xyz,res)) * float3(1,200,1000);
				float3 xyz1 = floor(fmod(xyz + float3(1,1,1),res))  * float3(1,200,1000);

				float3 f = frac(xyz); f = f*f*(3.0-2.0*f);
				float4 v = float4(xyz0.x + xyz0.y + xyz0.z , xyz1.x  + xyz0.y + xyz0.z,
								xyz0.x   + xyz1.y + xyz0.z, xyz1.x  + xyz1.y + xyz0.z);
				float4 rand = frac(sin(v/res*6.2832)*1000.0);
				float r0 = lerp(lerp(rand.x,rand.y,f.x),lerp(rand.z,rand.w,f.x),f.y);

				rand = frac(sin((v - xyz0.z + xyz1.z)/res*6.2832)*1000.0);
				float r1 = lerp(lerp(rand.x,rand.y,f.x),lerp(rand.z,rand.w,f.x),f.y);
				return lerp(r0,r1,f.z);



			}


			fixed4 frag (v2f i) : SV_Target
			{
				
				fixed4 col = tex2D(_MainTex, i.uv0);

				float2 uvTemp = i.uv1 + _MainTex_TexelSize.xy * float2(-1, -1);
				fixed4 glow = abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				//fixed4 glow = max(0, tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				uvTemp = i.uv1 + _MainTex_TexelSize.xy * float2(-1, 0);
				glow += abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				uvTemp = i.uv1 + _MainTex_TexelSize.xy * float2(-1, 1);
				glow += abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				uvTemp = i.uv1 + _MainTex_TexelSize.xy * float2(0, -1);
				glow += abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				uvTemp = i.uv1 + _MainTex_TexelSize.xy * float2(0, 0);
				glow += abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				uvTemp = i.uv1 + _MainTex_TexelSize.xy * float2(0, 1);
				glow += abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				uvTemp = i.uv1 + _MainTex_TexelSize.xy * float2(1, -1);
				glow += abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				uvTemp = i.uv1 + _MainTex_TexelSize.xy * float2(1, 0);
				glow += abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				uvTemp = i.uv1 + _MainTex_TexelSize.xy * float2(1, 1);
				glow += abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				glow /= 9;

				//glow = abs(tex2D(_GlowBlurredTex, uvTemp) - tex2D(_GlowPrePassTex,uvTemp));
				//_ObjPoint = float2(0.5,0.5);
				float2 uvP = i.uv0; uvP.x = uvP.x * _ScreenParams.x / _ScreenParams.y;
				//_ObjPoint.x = _ObjPoint.x * _ScreenParams.x / _ScreenParams.y;
				float x = atan2(uvP.y - _ObjPoint.y, uvP.x - _ObjPoint.x)/6.2832 + 0.5;
				float y = length(float2(uvP.y - _ObjPoint.y, uvP.x - _ObjPoint.x));

				//float n = noiseSampler(float3(x + _Time.x, y/4 -_Time.x, 0),32);

				float n = noiseSampler(float3(x,y*0.75 - _Time.x * 3, _Time.x * 0.15),16) * 0.5;
				n += noiseSampler(float3(x,y*0.75 - _Time.x * 3, _Time.x * 0.15),32) * 0.25;
				n += noiseSampler(float3(x,y*0.75 - _Time.x * 3, _Time.x * 0.15),64) * 0.125;
				n += noiseSampler(float3(x,y*0.75 - _Time.x * 3, _Time.x * 0.15),128) * 0.0625;
				n = smoothstep(0.1,0.9,n);
				return col +  glow * _Intensity * float4(n,1-n,n,0);
			}
			ENDCG
		}
	}
}
