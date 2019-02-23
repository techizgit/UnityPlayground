Shader "Custom/SSS"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Thickness ("Thickness", 2D) = "white" {}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #include "UnityCG.cginc"
        #pragma vertex vert
	    #pragma fragment frag

		struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        v2f vert(appdata_base v)
        {
        	v2f o;
        	o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
        	return o;
        }

        fixed4 frag(v2f i): SV_Target
        {
        	return 1;
        }



        ENDCG
    }
    FallBack "Diffuse"
}
