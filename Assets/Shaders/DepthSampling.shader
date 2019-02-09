Shader "Custom/DepthSampling"
{
	Properties
	{
	}

	Category
	{

		SubShader
		{
			Pass
			{
				Name "BASE"
				Tags { "RenderType"="Opaque"  "Glowable" = "True"}
				//BlendOp Max

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
		
				struct appdata_t {
					float4 vertex : POSITION;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
				};

				v2f vert( appdata_t v )
				{
					v2f o;
					o.vertex = UnityObjectToClipPos( v.vertex );

					return o;
				}

				float frag (v2f i) : SV_Target
				{
					return i.vertex.w/30;
				}

				ENDCG
			}
		}
	}
}
