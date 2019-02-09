Shader "Custom/Flat"
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
	            float4 worldPos :  TEXCOORD0;
	        };

	        v2f vert(appdata_base v)
	        {
	        	v2f o; 
	        	//float4x4  modelMatrixInverse = unity_WorldToObject;

	        	o.pos = UnityObjectToClipPos(v.vertex);
	        	o.worldPos = mul(unity_ObjectToWorld, v.vertex);

	        	return o;
	        }

	        fixed4 frag(v2f i): SV_Target
	        {
	        	float3 worldDx = ddx(i.worldPos);
	        	float3 worldDy = ddy(i.worldPos);
	        	float3 worldNormal = normalize(cross(worldDy, worldDx));
	        	return fixed4(worldNormal * 0.5 + 0.5,1.0);
	        }
        ENDCG
        }
 	}
    //FallBack "Diffuse"
}
