Shader "Hidden/ShadowReceiver"
{
    Properties
    {
       
    }
    SubShader
    {
    	//ZWrite Off
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //要想有正确的衰减内置变量等，必须要有这句
            #pragma multi_compile_fwdbase

            
            #include "UnityCG.cginc"
            #include "autolight.cginc"
            #include "lighting.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                SHADOW_COORDS(1)    //宏表示为定义一个float4的采样坐标，放到编号为1的寄存器中
            };

            
            v2f vert (appdata_base v)
            {
                v2f o;
                //v.vertex.xyz += float3(0,0.0,0.0);
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)  //根据变换求解上面结构体中的float4坐标，unity5中采用的是屏幕空间阴影贴图
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed shadow = SHADOW_ATTENUATION(i); //根据贴图与纹理坐标对纹理采样得到shadow值。
                return shadow;
            }
            ENDCG
        }
    }
    FallBack "Specular"
}