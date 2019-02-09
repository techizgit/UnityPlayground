Shader "Custom/ForceShield"
{
	Properties
	{

		_Tex1 ("R for Color, G for Dissolve", 2D) = "white" {}
		_SurfaceUVDistortion ("Surface UV Distortion", 2D) = "white" {}
		_Threshold("Dissolve Threshold", Range(0,1)) = 0.5
		_DissolveEdgeLength("Dissovle Edge Length", Range(0.001,0.03)) = 0.02
		_FaceEdgeLength("Face Edge Length", Range(0.00,0.05)) = 0.02
		_ShieldColorCenter1("Shield Center Color 1", Color) =(1,1,1,0)
		_ShieldColorCenter2("Shield Center Color 2", Color) =(1,1,1,0)
		_ShieldColorEdge1("Shield Center Edge 1", Color) =(1,1,1,0)
		_ShieldColorEdge2("Shield Center Edge 2", Color) =(1,1,1,0)
		_BlurAmt("Shield Blur Amount", Range(0,50)) = 30
	}
    SubShader
    {
    	Tags { "Queue" = "Transparent" "RenderType"="ForceShield"}

    	CGINCLUDE

    	#include "UnityCG.cginc"

    	sampler2D _GrabTexture;
    	sampler2D _Tex1;
    	sampler2D _SurfaceUVDistortion;
    	float4 _Tex1_ST;
    	float4 _SurfaceUVDistortion_ST;
    	float _Threshold;
    	float _DissolveEdgeLength;
    	float _FaceEdgeLength;
    	fixed4 _ShieldColorCenter1;
    	fixed4 _ShieldColorCenter2;
    	fixed4 _ShieldColorEdge1;
    	fixed4 _ShieldColorEdge2;
    	float _BlurWeight[49];
    	float _BlurAmt;
        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv1 : TEXCOORD0;
            float2 uv2 : TEXCOORD1;
            float2 uv3 : TEXCOORD2;
            float2 uv4 : TEXCOORD3;
            float4 worldPos : TEXCOORD4;
            float4 grabPos : TEXCOORD5;
            float bottomHeight : TEXCOORD6;
        };


        fixed4 Blur(float4 grabPos)
        {
        	float4 col = float4(0,0,0,0);
        	float2 uvOffset = 2.0 / _ScreenParams.xy;
        	for (int i = -3; i <= 3; ++i)
        	{
        		for (int j = -3; j <= 3; ++j) 
        		{
           			 col += tex2Dproj(_GrabTexture, grabPos + float4(uvOffset.x * i * _BlurAmt, uvOffset.y * j * _BlurAmt, 0.0f, 0.0f)) * _BlurWeight[j * 7 + i + 24];
        		}
   		 	}
   		 	return col;

        }


        v2f vert(appdata_full v)
        {
        	v2f o;

        	o.pos = UnityObjectToClipPos(v.vertex);
			o.uv1 = v.texcoord;
			o.uv2 = TRANSFORM_TEX(v.texcoord1, _Tex1);
			o.uv3 = v.texcoord2;
			o.uv4 = TRANSFORM_TEX(v.texcoord1, _SurfaceUVDistortion);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
			o.grabPos = ComputeGrabScreenPos(o.pos);
			o.bottomHeight = v.vertex.y;

        	return o;
        }

        fixed4 frag(v2f i): SV_Target
        {
        	float3 worldDx = ddx(i.worldPos);
        	float4 worldDy = ddy(i.worldPos);
        	float3 worldNormal = normalize(cross(worldDy, worldDx));

        	float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
        	float fresnel = saturate(1 - abs(dot(viewDir, worldNormal)));

        	float2 uvDistortion = UnpackNormal(tex2D(_SurfaceUVDistortion,i.uv4 + _Time.x * float2(0.83,-0.32) * 5)).xy;
        	float2 uvNew = i.uv2 + _Time.x * float2(4.5,6);





        	float dissolve = tex2D(_Tex1, i.uv1).g;


        	if (dissolve - _DissolveEdgeLength >  _Threshold)
        	{
        		return tex2Dproj(_GrabTexture, i.grabPos);
        	}
        	//return fixed4(i.uv2.x,i.uv2.y,0,0.5);
        	i.grabPos.xy += uvDistortion * 0.4;
        	fixed4 backgroundColor = Blur(i.grabPos);

        	float colorFactor = tex2D(_Tex1, uvNew + uvDistortion * 0.1).r;
        	fixed4 shieldColorCenter = lerp(_ShieldColorCenter1,_ShieldColorCenter2,colorFactor + (uvDistortion.x+uvDistortion.y) * 0.2);
        	fixed4 shieldColorEdge = lerp(_ShieldColorEdge1,_ShieldColorEdge2,colorFactor + (uvDistortion.x+uvDistortion.y) * 0.2);
        	fixed4 shieldColor = lerp(shieldColorCenter,shieldColorEdge,fresnel);
        	fixed4 col = lerp(backgroundColor,shieldColor,abs(colorFactor - 0.5) * 1.2);

        	float uvDist = min(min(i.uv3.y, 1 - i.uv3.x),(i.uv3.x - i.uv3.y)/1.414);

        	//if (dissolve - _DissolveEdgeLength >  _Threshold) return backgroundColor;
        	float4 dissolveEdgeColor = saturate(1 - abs((dissolve - _Threshold)/_DissolveEdgeLength));
        	col += dissolveEdgeColor;
        	col.a *= 1 - dissolveEdgeColor.r;
        	float4 faceEdgeColor = saturate(1-(uvDist/_FaceEdgeLength));
        	col += faceEdgeColor;
        	col.a *= 1 - faceEdgeColor.r;
        	col = saturate(col);
        	float bottomFac = 1- smoothstep(_FaceEdgeLength*0.3,_FaceEdgeLength*0.6,i.bottomHeight);
        	col += bottomFac;
        	col.a *= 1- bottomFac;
        	return col;
        }

    	ENDCG

    	GrabPass {}

    	Pass{

    		Cull Front
    		ZWrite Off
    		//Blend SrcAlpha OneMinusSrcAlpha


       		CGPROGRAM
        	#pragma vertex vert
        	#pragma fragment frag

        ENDCG
        }


        GrabPass {}

        Pass{

    		Cull Back
    		ZWrite Off
    		//Blend SrcAlpha OneMinusSrcAlpha


       		CGPROGRAM
        	#pragma vertex vert
        	#pragma fragment frag
        ENDCG
        }


 	}
}