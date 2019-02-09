Shader "Custom/NormalShow"
{
    SubShader
    {
    	Pass{

       		CGPROGRAM
        	#pragma vertex vert
        	#pragma fragment frag
        	#include "UnityCG.cginc"


	        struct v2f
	        {
	            float4 pos : SV_POSITION;
	            float3 worldNormal : TEXCOORD0;
	        };

	        v2f vert(appdata_base v)
	        {
	        	v2f o;
	        	float4x4  modelMatrixInverse = unity_WorldToObject;

	        	o.pos = UnityObjectToClipPos(v.vertex);
	        	o.worldNormal = normalize(mul(transpose(modelMatrixInverse),float4(v.normal,0.0)).xyz);

	        	return o;
	        }

	        fixed4 frag(v2f i): SV_Target
	        {
	        	return fixed4(i.worldNormal * 0.5 + 0.5,0.0);
	        }
        ENDCG
        }
 	}
    //FallBack "Diffuse"
}