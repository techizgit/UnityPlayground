Shader "Custom/FoamCompute"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			struct waveSampler
			{
				float x;
				float z;
				float3 displacement;

			};

			StructuredBuffer<waveSampler> displacementSample;

			sampler2D _MainTex;
			float2 _uvOffset;


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				int _resolution = 768;
				fixed4 lastFrameFoam = tex2D(_MainTex, i.uv + _uvOffset);
				int x1 = floor(i.uv.x * (_resolution - 1)); int x2 = ceil(i.uv.x * (_resolution - 1));
				int z1 = floor(i.uv.y * (_resolution - 1)); int z2 = ceil(i.uv.y * (_resolution - 1));
				int index1 = x1 * _resolution + z1;
				int index2 = x1 * _resolution + z2;
				int index3 = x2 * _resolution + z1;
				int index4 = x2 * _resolution + z2;
				float dxdz = (displacementSample[index1].displacement.x - displacementSample[index2].displacement.x
							 + displacementSample[index3].displacement.x - displacementSample[index4].displacement.x) * 0.5 * 0.782;
				float dxdx = (displacementSample[index1].displacement.x - displacementSample[index3].displacement.x
							 + displacementSample[index2].displacement.x - displacementSample[index4].displacement.x) * 0.5 * 0.782;				
				float dzdx = (displacementSample[index1].displacement.z - displacementSample[index3].displacement.z
							 + displacementSample[index2].displacement.z - displacementSample[index4].displacement.z) * 0.5 * 0.782;
				float dzdz = (displacementSample[index1].displacement.z - displacementSample[index2].displacement.z
							 + displacementSample[index3].displacement.z - displacementSample[index4].displacement.z) * 0.5 * 0.782;

				float J = dxdx * dzdz - dxdz * dzdx;
				return saturate((-J - 0.02) * 2) + lastFrameFoam * 0.99 - 0.005;
			}
			ENDCG
		}
	}
}