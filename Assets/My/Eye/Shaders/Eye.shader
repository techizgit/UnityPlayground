// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Eye"
{
	Properties
	{
		_IrisRadius("Iris Radius",Range(0.01,0.4)) = 0.225
		_IrisTex("Iris Texture", 2D) = "white" {}
		_IrisMask("Iris Mask", 2D) = "white" {}
		_ScleraTex("Sclera Texture", 2D) = "white" {}


		_IOR("IOR of Eye", Range(1,2)) = 1.333
		_Distortion("Distortion", Range(0,5)) = 3
		_PupilRadius("Pupil Radius", Range(0.01, 0.4)) = 0.3

		_Shininess("Specular Shininess", Range(1,100)) = 5
		_SpecularPower("Specular Power", Range(0,3)) = 1
	}

    SubShader
    {
    	Pass{
    		Tags {"LightMode"="ForwardBase"}
       		CGPROGRAM
        	#pragma vertex vert
        	#pragma fragment frag
        	#include "UnityCG.cginc"
        	#include "Lighting.cginc"

        	float _IrisRadius;
        	sampler2D _IrisTex;
        	sampler2D _ScleraTex;
        	sampler2D _IrisMask;
        	float _IOR;
        	float _Distortion;
        	float _Shininess;
        	float _SpecularPower;
        	float _PupilRadius;
        

	        struct v2f
	        {
	            float4 pos : SV_POSITION;
	            float2 uv : TEXCOORD0;
	            float3 worldPos : TEXCOORD1;
	            float3 objectNormal : TEXCOORD2;
	            float3 objectPos : TEXCOORD3;
	        };

	        v2f vert(appdata_full v)
	        {
	        	v2f o;

	        	o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.objectNormal = v.normal;
				o.objectPos = v.vertex;

	        	return o;
	        }

	        float2 remapUV(float2 uv)
	        {
	        	float lengthUV = length(uv);
	        	float2 uvNormalized = uv / lengthUV ;
	        	float newLength = 0;
	        	if (lengthUV  < _PupilRadius) 
	        	{
	        		newLength = lengthUV / _PupilRadius * 0.14;
	        	} else
	        	{
	        		newLength = (lengthUV - _PupilRadius) / (0.5 - _PupilRadius) * 0.36 + 0.14;
	        	}
	        	return uvNormalized * newLength;

	        }

	        fixed4 frag(v2f i): SV_Target
	        {
	        	float2 sUV = i.uv - float2(0.5, 0.5);



	        	float3 worldViewDir = normalize( _WorldSpaceCameraPos.xyz - i.worldPos);
	        	float3 objectViewDir = normalize(mul(unity_WorldToObject, worldViewDir));
	        	float3 objectNormal = i.objectNormal;


	        	float2 uvDirection = float2(objectViewDir.x, objectViewDir.z)/(objectViewDir.y  + 0.4);

	        	float cosUpN = clamp(dot(objectNormal, float3(0,1,0)),0,0.9999);
	        	float sinUpN = - sqrt(1 - cosUpN * cosUpN);
	        	float cosVN = dot(objectNormal,  objectViewDir);
	        	float sinVN = sqrt(1 - cosVN * cosVN);
	        	float sinRN = sinVN / _IOR;
	        	float cosRN = sqrt(1 - sinRN * sinRN);
	        	float sinRT = cosUpN * cosRN - sinUpN * sinRN;

	        	float2 sUVIris = sUV / _IrisRadius / 2;

	        	float d1 = sqrt(1 - sUVIris.x * sUVIris.x - sUVIris.y * sUVIris.y) - 0.86603;
	        	float d2 = sqrt(0.3025 - sUVIris.x * sUVIris.x - sUVIris.y * sUVIris.y) - 0.22913;

	        	float2 deltaUV = (d2 - d1) * (sinRN / cosUpN / sinRT) * uvDirection;


	        	float2 uvIris = remapUV(sUVIris  + deltaUV * _Distortion);
	        	float irisMask = tex2D(_IrisMask, uvIris + float2(0.5,0.5));
	         	if (length(uvIris) > 0.5) irisMask = 0;

	         	float4 col = lerp(tex2D(_ScleraTex, i.uv), tex2D(_IrisTex, uvIris + float2(0.5,0.5)), irisMask);

	         	float3 objectLightDirection =  - normalize(mul(unity_WorldToObject,_WorldSpaceLightPos0.xyz));
	         	float3 specularColor = pow(max(0.0, dot(reflect(objectLightDirection, objectNormal),objectViewDir)), _Shininess) * _SpecularPower * _LightColor0.rgb;

	         	if (length(sUV) > _IrisRadius) col = tex2D(_ScleraTex, i.uv);

	        	return col + float4(specularColor ,1);
	        }


        	ENDCG
        }



        Pass{
        	Blend One One
    		Tags {"LightMode"="ForwardAdd"}
       		CGPROGRAM
        	#pragma vertex vert
        	#pragma fragment frag
        	#include "UnityCG.cginc"
        	#include "Lighting.cginc"

        	float _Shininess;
        	float _SpecularPower;
        

	        struct v2f
	        {
	            float4 pos : SV_POSITION;
	            float3 worldPos : TEXCOORD1;
	            float3 objectNormal : TEXCOORD2;
	            float3 objectPos : TEXCOORD3;
	        };

	        v2f vert(appdata_full v)
	        {
	        	v2f o;

	        	o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.objectNormal = v.normal;
				o.objectPos = v.vertex;

	        	return o;
	        }

	        fixed4 frag(v2f i): SV_Target
	        {
	        	float3 worldViewDir = normalize( _WorldSpaceCameraPos.xyz - i.worldPos);
	        	float3 objectViewDir = normalize(mul(unity_WorldToObject, worldViewDir));
	        	float3 objectNormal = i.objectNormal;

	         	float3 objectLightDirection = - normalize(UnityWorldSpaceLightDir(i.worldPos));
	         	float3 specularColor = pow(max(0.0, dot(reflect(objectLightDirection, objectNormal),objectViewDir)), _Shininess) * _SpecularPower * _LightColor0.rgb;
	        	return float4(specularColor,1);
	        }


        	ENDCG
        }
 	}
    //FallBack "Diffuse"
}