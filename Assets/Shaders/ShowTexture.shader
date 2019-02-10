Shader "Custom/ShowTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Volume ("Texture", 3D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		//Cull Off ZWrite Off ZTest Always

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
				float2 uv: TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD1;
				float4 modelPos : TEXCOORD2;
			};


			sampler2D _MainTex;
			sampler3D _Volume;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_WorldToObject,v.vertex);
				o.modelPos = v.vertex;
				o.uv = v.uv;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// tex = tex2D(_MainTex, i.uv);
				//i.modelPos.y *= 2;
				//i.modelPos = (i.modelPos + 1) * 0.5;
				fixed4 tex = tex3D(_Volume, i.modelPos.xzy );
				//return i.worldPos/50;
				return tex;
			}
			ENDCG
		}
	}
}
