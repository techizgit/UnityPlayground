Shader "Hidden/OrthDepthSampling"
{
	Properties
	{
	}

	Category
	{
		Tags { "Queue" = "Geometry" }

		SubShader
		{
			Pass
			{
				Name "BASE"
				Tags { "LightMode" = "Always" }
				BlendOp Max

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "UnityCG.cginc"
		
				struct appdata_t {
					float4 vertex : POSITION;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					float height : TEXCOORD0;
				};

				v2f vert( appdata_t v )
				{
					v2f o;
					o.vertex = UnityObjectToClipPos( v.vertex );
					o.height = mul(unity_ObjectToWorld, v.vertex).y;

					return o;
				}

				float4 frag (v2f i) : SV_Target
				{
					return saturate((i.height+17)/25) ;
				}

				ENDCG
			}
		}
	}
}