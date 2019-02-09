Shader "Custom/UVShow"
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
	            float2 uv : TEXCOORD0;
	        };

	        v2f vert(appdata_full v)
	        {
	        	v2f o;

	        	o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;

	        	return o;
	        }

	        fixed4 frag(v2f i): SV_Target
	        {
	        	return fixed4(i.uv.x,i.uv.y,0,0);
	        }
        ENDCG
        }
 	}
    //FallBack "Diffuse"
}