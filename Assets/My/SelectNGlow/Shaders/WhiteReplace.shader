Shader "Hidden/WhiteReplace"
{
	SubShader
	{
		Tags
		{
		"RenderType"="Opaque"
		"Glowable" = "True"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float _GlowFactor;

			fixed4 frag (v2f i) : SV_Target
			{
				//return 1;
				return _GlowFactor;
			}
			ENDCG
		}
	}
}