Shader "Hidden/RenderDepth"
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
				//BlendOp Max

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "UnityCG.cginc"

				sampler2D _CameraDepthTexture;
		
				struct appdata_t {
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					float4 grabPos : TEXCOORD0;
				};

				v2f vert( appdata_t v )
				{
					v2f o;
					o.vertex = UnityObjectToClipPos( v.vertex );
					o.grabPos = ComputeGrabScreenPos(o.vertex);

					return o;
				}

				float frag (v2f i) : SV_Target
				{
					return LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.grabPos))/30;
				}

				ENDCG
			}
		}
	}
}
