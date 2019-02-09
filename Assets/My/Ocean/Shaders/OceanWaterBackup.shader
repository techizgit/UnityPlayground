// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/OceanWater"
{
	Properties
	{
		[HideInInspector] _ReflectionTex ("", 2D) = "white" {}
		[HideInInspector] _ReflectionBlockTex ("", 2D) = "white" {}
		[HideInInspector] _HeightMap ("", 2D) = "black" {}
		[HideInInspector] _ShadowMask ("", 2D) = "white" {}

		[Header(Wave 2)]
		_A1("Amplitude 1", Range(0,1)) = 0.5
		_Stp1("Steep 1", Range(0,1)) = 0.5
		_D1("Direction 1", Range(0,360)) = 0

		[Header(Wave 3)]
		_A2("Amplitude 2", Range(0,1)) = 0.5
		_Stp2("Steep 2", Range(0,1)) = 0.5
		_D2("Direction 2", Range(0,360)) = 0

		[Header(Wave 5)]
		_A3("Amplitude 3", Range(0,1)) = 0.5
		_Stp3("Steep 3", Range(0,1)) = 0.5
		_D3("Direction 3", Range(0,360)) = 0

		[Header(Wave 8)]
		_A4("Amplitude 4", Range(0,1)) = 0.5
		_Stp4("Steep 4", Range(0,1)) = 0.5
		_D4("Direction 4", Range(0,360)) = 0

		[Header(Wave 13)]
		_A5("Amplitude 5", Range(0,1)) = 0.5
		_Stp5("Steep 5", Range(0,1)) = 0.5
		_D5("Direction 5", Range(0,360)) = 0

		[Header(Wave 21)]
		_A6("Amplitude 6", Range(0,1)) = 0.5
		_Stp6("Steep 6", Range(0,1)) = 0.5
		_D6("Direction 6", Range(0,360)) = 0

		[Header(Wave 34)]
		_A7("Amplitude 7", Range(0,1)) = 0.5
		_Stp7("Steep 7", Range(0,1)) = 0.5
		_D7("Direction 7", Range(0,360)) = 0

		[Header(Wave 55)]
		_A8("Amplitude 8", Range(0,1)) = 0.5
		_Stp8("Steep 8", Range(0,1)) = 0.5
		_D8("Direction 8", Range(0,360)) = 0

		[Header(Wave 89)]
		_A9("Amplitude 9", Range(0,1)) = 0.5
		_Stp9("Steep 9", Range(0,1)) = 0.5
		_D9("Direction 9", Range(0,360)) = 0

		[Header(Wave 144)]
		_A10("Amplitude 10", Range(0,1)) = 0.5
		_Stp10("Steep 10", Range(0,1)) = 0.5
		_D10("Direction 10", Range(0,360)) = 0

		[Header(Wave 233)]
		_A11("Amplitude 11", Range(0,1)) = 0.5
		_Stp11("Steep 11", Range(0,1)) = 0.5
		_D11("Direction 11", Range(0,360)) = 0

		[Header(Wave 377)]
		_A12("Amplitude 12", Range(0,1)) = 0.5
		_Stp12("Steep 12", Range(0,1)) = 0.5
		_D12("Direction 12", Range(0,360)) = 0



		[Header(Wave Parameters)]
		_S("Speed", float) = 10.0
		_ShoreWaveAttenuation("Shore Waves Attenuation",Range(0.1,15)) = 1.0

		[Header(Textures)]
		_FoamTex ("Foam Texture", 2D) = "white" {} 
		_NormalTex ("Normal Map", 2D) = "white" {}
		_ShallowMaskOffset("Shallow Mask Offset",Vector) = (-0.1,0.2,0,0)
		_Skybox("Skybox", Cube) = "" {}
		_NormalSpeed("Normal Moving Speed", Float) = 1.0

		_HeightMapTransform("Height Map Divide Scale XZ",Vector) = (640,640,0.3,0.3)


		[Header(Scattering Color)]
		_DeepColor("Deep Color", Color) = (0.04,0.125,0.62,1.0)
		_ShallowColor("Shallow Color", Color) = (0.275,0.855,1.0,1.0)


		[Header(Refractive Distortion)]
		_RefractionStrength("Refractive Distortion Strength",Float) = 1.0
		_WaterClarity("Water Clarity",Range(4,30)) = 12.0
		_WaterClarityAttenuationFactor("Water Clarity Attenuation Factor",Range(0.1,3)) = 1.0
		_WaterDepthChangeFactor("Water Depth Change Factor",Range(0.1,2)) = 1.0

		[Header(Fake SSS)]
		_DirectTranslucencyPow("Direct Translucency Power",Range(0.1,3)) = 1.5
		_EmissionStrength("Directional Scattering Strength",Range(0.1,2)) = 1.0
		_DirectionalScatteringColor("Directional Scattering Color", Color) = (0.00,0.65,0.34,1.0)
		_waveMaxHeight("Wave Height Factor For Scattering", Float) = 5.0

		[Header(Reflective)]
		[Toggle(_USE_SKYBOX)] _UseSkybox ("Use Skybox ONLY", Float) = 0
		_AirRefractiveIndex("Air Refractive Index", Float) = 1.0
		_WaterRefractiveIndex("Water Refractive Index", Float) = 1.333
		_FresnelPower("Fresnel Power", Range(0.1,50)) = 5
		_ReflectionDistortionStrength("Reflective Distortion Strength",Float) = 1.0


		[Header(Specular)]
		_SunAnglePow("Sunlight Angle Strength", Range(0.1,2)) = 1
		_Shininess("Shininess",Range(50,800)) = 400

	}

	SubShader
	{

		//Zwrite Off
		Tags { "RenderType"="Transparent" "RenderQueue"="Transparent" "LightMode"="ForwardBase" }
		GrabPass { "_WaterBackground" }
		Pass{
	            CGPROGRAM
	            #pragma shader_feature _USE_SKYBOX
	            #pragma vertex vert
	            #pragma fragment frag
	            #pragma multi_compile_fwdbase
	            #include "UnityCG.cginc"
	            #include "autolight.cginc"
	            #include "lighting.cginc"

	            // Properties
	            samplerCUBE _Skybox;
	            sampler2D _FoamTex;
	            sampler2D _NormalTex;
	            sampler2D _WaterBackground;
	            sampler2D _CameraDepthTexture;
	            sampler2D _ReflectionTex;
	            sampler2D _ReflectionBlockTex;
	            sampler2D _HeightMap;
	            sampler2D _ShadowMask;

	            float4 _FoamTex_ST;
	            float4 _NormalTex_ST;

				float _S;
				float _A1,_A2,_A3,_A4,_A5,_A6,_A7,_A8,_A9,_A10,_A11,_A12;
				float _Stp1,_Stp2,_Stp3,_Stp4,_Stp5,_Stp6,_Stp7,_Stp8,_Stp9,_Stp10,_Stp11,_Stp12;
				float _D1,_D2,_D3,_D4,_D5,_D6,_D7,_D8,_D9,_D10,_D11,_D12;

				float4 _DeepColor;
				float4 _ShallowColor;
				float4 _DirectionalScatteringColor;

				float4 _CameraDepthTexture_TexelSize;
				float4 _HeightMapTransform;

				float _Shininess;
				float _SunAnglePow;
				float _NormalSpeed;
				float _ShoreWaveAttenuation;
				float _AirRefractiveIndex;
				float _WaterRefractiveIndex;
				float _FresnelPower;
				float _RefractionStrength;
				float _WaterClarity;
				float _WaterDepthChangeFactor;
				float _WaterClarityAttenuationFactor;
				float _DirectTranslucencyPow;
				float _EmissionStrength;
				float _waveMaxHeight;
				float _ReflectionDistortionStrength;

				float2 _ShallowMaskOffset;

	            struct vertexInput
	            {
	                float4 vertex : POSITION;
	                float3 normal : NORMAL;
	                float3 uv : TEXCOORD0;
	               

	            };

	            struct vertexOutput
	            {
	                float4 pos : SV_POSITION;
	                float2 uv : TEXCOORD0;
	                float3 worldPos : TEXCOORD1;
	                float4 grabPos : TEXCOORD2;
//	                float3 worldNormal : TEXCOORD3;
//	                float3 worldTangent : TEXCOORD4;
//	                float3 worldBitangent : TEXCOORD5;
	            };

	            float3 SingleWaveDisplacement(float w, float Amp, float Stp, float Dir, float3 vert, float psi, float xScale, float zScale, float timeScale)
	            {
	            	float Dz, Dx;
	            	float Pi = 3.1415926f;
	            	sincos(Dir / 360  * 2 * Pi , Dz, Dx);
	            	float phase = w * Dx * vert.x * xScale + w * Dz * vert.z * zScale + psi * _Time.x * timeScale;
	            	float sinp;float cosp;
	            	sincos(phase, sinp, cosp);
	            	float3 disp = float3(0,0,0);
	            	disp.x = Stp / w * Dx * cosp;
	            	disp.z = Stp / w * Dz * cosp;
	            	disp.y = Amp * sinp;
	            	return disp;
	            }

	            void CalculateGerstner(float Amp, float Stp, float Dir, float Lth ,float attenuationFac,float3 vert,out float3 dDisp)
	            {
	            	dDisp = float3(0,0,0);
	            	Stp *= 0.3;
	            	//if (Lth <= 8) attenuationFac = 1;
	            	attenuationFac  = attenuationFac + (1 - attenuationFac)*sqrt(2/Lth);
	            	Amp = Amp * attenuationFac * Lth / 40;
	            	Stp =  (1-step(Amp,0)) * Stp;
	            	float Pi = 3.1415926f;
	            	float Dx;float Dz;
	            	sincos(Dir / 360  * 2 * Pi , Dz, Dx);

					float w = 2 * Pi / Lth;
	            	float psi = _S * 2 * Pi / 20 / sqrt(Lth);

	            	dDisp += SingleWaveDisplacement(w,Amp,Stp,Dir,vert,psi,1,1,3.5);
	            	dDisp += SingleWaveDisplacement(w,Amp*1.00,Stp,Dir+27,vert,psi,0.9,1,4);
	            	dDisp += SingleWaveDisplacement(w,Amp*0.95,Stp,Dir+62,vert,psi,1.1,0.9,4.5);
	            	dDisp += SingleWaveDisplacement(w,Amp*0.85,Stp,Dir+98,vert,psi,0.8,1.2,5);
	            	dDisp += SingleWaveDisplacement(w,Amp*0.75,Stp,Dir+104,vert,psi,1.4,0.8,5.5);
	            	dDisp += SingleWaveDisplacement(w,Amp*0.65,Stp,Dir+160,vert,psi,0.7,0.65,6);


	            }


	            float3 VerticesDisplacement(float3 vert)
	            {
	            	float landHeight = tex2Dlod(_HeightMap, float4(vert.x/_HeightMapTransform.x +_HeightMapTransform.z/100, vert.z/_HeightMapTransform.y+_HeightMapTransform.w/100,0,0));
	            	float attenuationFac = 1;    
					attenuationFac = saturate(pow((1.0 - landHeight),_ShoreWaveAttenuation));


	            	float3 displace = float3(0, 0, 0); float3 dDisp = float3(0,0,0);

	            	CalculateGerstner(_A1,_Stp1,_D1,2,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A2,_Stp2,_D2,3,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A3,_Stp3,_D3,5,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A4,_Stp4,_D4,8,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A5,_Stp5,_D5,13,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A6,_Stp6,_D6,21,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A7,_Stp7,_D7,34,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A8,_Stp8,_D8,55,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A9,_Stp9,_D9,89,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A10,_Stp10,_D10,144,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A11,_Stp11,_D11,233,attenuationFac,vert,dDisp);
	            	displace += dDisp;
	            	CalculateGerstner(_A12,_Stp12,_D12,377,attenuationFac,vert,dDisp);
	            	displace += dDisp;

	            	return displace;
	           
	            }

	            float3 SingleWaveB(float w, float Amp, float Stp, float Dir, float3 vert, float psi, float xScale, float zScale, float timeScale)
	            {
	            	float Dz, Dx;
	            	float Pi = 3.1415926f;
	            	sincos(Dir / 360  * 2 * Pi , Dz, Dx);
	            	float phase = w * Dx * vert.x * xScale + w * Dz * vert.z * zScale + psi * _Time.x * timeScale;
	            	float sinp;float cosp;
	            	sincos(phase, sinp, cosp);
	            	float3 dB = float3(0,0,0);
	            	dB.x = -Stp * Dx * Dx * sinp;
	            	dB.z = -Stp * Dx * Dz * sinp;
	            	dB.y = Amp * Dx * w * cosp;
	            	return dB;
	            }

	            float3 SingleWaveT(float w, float Amp, float Stp, float Dir, float3 vert, float psi, float xScale, float zScale, float timeScale)
	            {
	            	float Dz, Dx;
	            	float Pi = 3.1415926f;
	            	sincos(Dir / 360  * 2 * Pi , Dz, Dx);
	            	float phase = w * Dx * vert.x * xScale + w * Dz * vert.z * zScale + psi * _Time.x * timeScale;
	            	float sinp;float cosp;
	            	sincos(phase, sinp, cosp);
	            	float3 dT = float3(0,0,0);
	            	dT.x = -Stp * Dx * Dz * sinp;
	            	dT.z = -Stp * Dz * Dz * sinp;
	            	dT.y = Amp * Dz * w * cosp;
	            	return dT;
	            }



	            void CalculateGerstnerBT(float Amp, float Stp, float Dir, float Lth ,float attenuationFac,float3 vert,out float3 dB, out float3 dT)
	            {
	            	dB = 0; dT = 0;
	            	Stp *= 0.3;
	            	//if (Lth <= 8) attenuationFac = 1;
	            	attenuationFac  = attenuationFac + (1 - attenuationFac)*sqrt(2/Lth);
	            	Amp = Amp * attenuationFac * Lth / 40 ;
	            	Stp =  (1-step(Amp,0)) * Stp;
	            	float Pi = 3.1415926f; float g = 9.8f;
	            	float Dx;float Dz;
	            	sincos(Dir / 360  * 2 * Pi , Dz, Dx);
	            	float w =  2 * Pi / Lth;
	            	float psi = _S * 2 * Pi / 20 / sqrt(Lth);
	
					dB += SingleWaveB(w,Amp,Stp,Dir,vert,psi,1,1,3.5);
	            	dB += SingleWaveB(w,Amp*1.00,Stp,Dir+27,vert,psi,0.9,1,4);
	            	dB += SingleWaveB(w,Amp*0.95,Stp,Dir+62,vert,psi,1.1,0.9,4.5);
	            	dB += SingleWaveB(w,Amp*0.85,Stp,Dir+98,vert,psi,0.8,1.2,5);
	            	dB += SingleWaveB(w,Amp*0.75,Stp,Dir+104,vert,psi,1.4,0.8,5.5);
	            	dB += SingleWaveB(w,Amp*0.65,Stp,Dir+160,vert,psi,0.7,0.65,6);

	            	dT += SingleWaveT(w,Amp,Stp,Dir,vert,psi,1,1,3.5);
	            	dT += SingleWaveT(w,Amp*1.00,Stp,Dir+27,vert,psi,0.9,1,4);
	            	dT += SingleWaveT(w,Amp*0.95,Stp,Dir+62,vert,psi,1.1,0.9,4.5);
	            	dT += SingleWaveT(w,Amp*0.85,Stp,Dir+98,vert,psi,0.8,1.2,5);
	            	dT += SingleWaveT(w,Amp*0.75,Stp,Dir+104,vert,psi,1.4,0.8,5.5);
	            	dT += SingleWaveT(w,Amp*0.65,Stp,Dir+160,vert,psi,0.7,0.65,6);
	            }

	            void CalculateWaveBT(float3 vert, out float3 binormal, out float3 tangent, float attenuationFac)
	            {

	            	binormal = float3(1,0,0);
	            	tangent = float3(0,0,1);
	            	float3 dB;float3 dT;

	            	CalculateGerstnerBT(_A1,_Stp1,_D1,2,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A2,_Stp2,_D2,3,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A3,_Stp3,_D3,5,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A4,_Stp4,_D4,8,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A5,_Stp5,_D5,13,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A6,_Stp6,_D6,21,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A7,_Stp7,_D7,34,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A8,_Stp8,_D8,55,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A9,_Stp9,_D9,89,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A10,_Stp10,_D10,144,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A11,_Stp11,_D11,233,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	CalculateGerstnerBT(_A12,_Stp12,_D12,377,attenuationFac, vert, dB, dT);
	            	binormal.x += dB.x; binormal.z += dB.z; binormal.y += dB.y;
	            	tangent.x += dT.x; tangent.z += dT.z; tangent.y += dT.y;

	            	//binormal = saturate(binormal); tangent = saturate(tangent);

	            	binormal = normalize(binormal);
	            	tangent = normalize(tangent);


	            	         	
	            }

	            float CalculateFresnel (float3 I, float3 N)
	            {
	            	float R_0 = (_AirRefractiveIndex - _WaterRefractiveIndex) / (_AirRefractiveIndex + _WaterRefractiveIndex);
	            	R_0 *= R_0;
	            	return  R_0 + (1.0 - R_0) * pow((1.0 - saturate(dot(I, N))), _FresnelPower);
	            }

	            float2 AlignWithGrabTexel (float2 uv)
	            {
	            	return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs( _CameraDepthTexture_TexelSize.xy);
	            }

	            float4 CalculateSSSColor(float3 lightDirection, float3 worldNormal, float3 viewDir,float waveHeight, float shadowFactor){
	            	float lightStrength = sqrt(saturate(lightDirection.y));
	            	//blockFactor = 1;
	            	float SSSFactor = pow(saturate(dot(viewDir ,lightDirection) )+saturate(dot(worldNormal ,-lightDirection)) ,_DirectTranslucencyPow) * shadowFactor * lightStrength * _EmissionStrength;
	            	return _DirectionalScatteringColor * (SSSFactor + waveHeight * 0.6);
	            }


	            float4 CalculateRefractiveColor(float3 worldPos, float4 grabPos, float3 worldNormal, float3 viewDir,float3 lightDirection,float landHeight,float waveHeight,float shadowFactor)
	            {
	           		float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, grabPos));
	            	//float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(grabPos.z);
	            	float surfaceDepth = grabPos.w;
	            	float viewWaterDepthNoDistortion = backgroundDepth - surfaceDepth;


	            	float4 distortedUV = grabPos;
	            	float2 uvOffset = worldNormal.xz * _RefractionStrength;
					//uvOffset.y *= 1 -  abs(viewDir.y) ;
					uvOffset *= saturate(viewWaterDepthNoDistortion);
					distortedUV.xy = AlignWithGrabTexel(distortedUV.xy + uvOffset);
	            	backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, distortedUV));

	            	surfaceDepth = grabPos.w;
	            	float viewWaterDepth = backgroundDepth - surfaceDepth;


//	            	if (viewWaterDepth < 0){
//	            		distortedUV.xy = AlignWithGrabTexel(grabPos.xy);
//	            		viewWaterDepth = viewWaterDepthNoDistortion;
//	            	}

					float tmp = step(viewWaterDepth,0);
	            	distortedUV.xy = tmp * AlignWithGrabTexel(grabPos.xy) + (1-tmp) * distortedUV.xy;
	            	viewWaterDepth = tmp * viewWaterDepthNoDistortion + (1-tmp) * viewWaterDepth;
	            	            	           	
	            	float4 transparentColor =  tex2Dproj(_WaterBackground , distortedUV);
	            	float shallowWaterFactor = 0;

					//float landHeight = tex2D(_HeightMap, float2(worldPos.x/_HeightMapTransform.x +_HeightMapTransform.z/100, worldPos.z/_HeightMapTransform.y+_HeightMapTransform.w/100));
					shallowWaterFactor = saturate(pow(landHeight,_WaterDepthChangeFactor)) ;
					//float4 ScatteredColor = lerp(_DeepColor, _ShallowColor, ShallowWaterFactor);
					float4 ScatteredColor = _DeepColor  + _ShallowColor * shallowWaterFactor * (shadowFactor+1)*0.5;

					float viewWaterDepthFactor = pow(saturate(viewWaterDepth/_WaterClarity),_WaterClarityAttenuationFactor);
					float4 emissionSSSColor = CalculateSSSColor(lightDirection, worldNormal,  viewDir, waveHeight, shadowFactor);

	            	return lerp(transparentColor , ScatteredColor, viewWaterDepthFactor) + emissionSSSColor;
	            }




	            float4 CalculateReflectiveColor(float3 worldPos, float4 grabPos, float3 worldNormal, float3 viewDir, out float4 distortedUV)
	            {
	            	float2 uvOffset = worldNormal.xz * _ReflectionDistortionStrength;
	            	//uvOffset.x = 0;
	            	uvOffset.y -= worldPos.y;
	            	distortedUV = grabPos; distortedUV.xy += uvOffset;
	            	#if _USE_SKYBOX	
	            		return texCUBE(_Skybox, reflect(viewDir,worldNormal));
	            	#endif
	            	float4 skyColor = texCUBE(_Skybox, reflect(viewDir,worldNormal));
	            	return lerp(tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(distortedUV)),skyColor,0.65);


	            }


	            vertexOutput vert(vertexInput input)
	            {
	                vertexOutput output;

					float3 worldPos = mul(unity_ObjectToWorld, input.vertex);
					float3 disPos = VerticesDisplacement(worldPos);
					input.vertex.xyz = mul(unity_WorldToObject, float4(worldPos + disPos, 1));
					worldPos = worldPos + disPos;
					output.uv = input.uv;
    				output.pos = UnityObjectToClipPos(input.vertex);

//    				float attenuationFac = 1;
//	            	float landHeight = tex2Dlod(_HeightMap, float4(worldPos.x/_HeightMapTransform.x +_HeightMapTransform.z/100, worldPos.z/_HeightMapTransform.y+_HeightMapTransform.w/100,0,0));
//	            	attenuationFac = saturate(pow((1.0 - landHeight),_ShoreWaveAttenuation));
//    				CalculateWaveBT(worldPos, output.worldBitangent, output.worldTangent, attenuationFac);
//    				output.worldNormal = normalize(cross(output.worldTangent, output.worldBitangent));

    				output.worldPos = worldPos;
    				output.grabPos = ComputeGrabScreenPos(output.pos);
	                return output;
	            }





	            float4 frag(vertexOutput input) : SV_Target
	            {
	            	float3 viewDir = normalize(input.worldPos - _WorldSpaceCameraPos.xyz);
	            	float landHeight = tex2D(_HeightMap, float2(input.worldPos.x/_HeightMapTransform.x +_HeightMapTransform.z/100, input.worldPos.z/_HeightMapTransform.y+_HeightMapTransform.w/100));

	            	float attenuationFac = 1;
					attenuationFac = saturate(pow((1.0 - landHeight),_ShoreWaveAttenuation));
	            	float3 bitangent = float3(0,0,0);
	            	float3 tangent = float3(0,0,0);
	            	CalculateWaveBT(input.worldPos, bitangent, tangent, attenuationFac);
	            	float3 worldNormal = normalize(cross(tangent, bitangent));
	            	float3x3 M = {bitangent,tangent,worldNormal};

	            	//float3x3 M = {input.worldBitangent, input.worldTangent, input.worldNormal};
	            	M = transpose(M);

	            	float3 tangentNormal = lerp(UnpackNormal(tex2D(_NormalTex, float2(input.worldPos.x / 50.0 * _NormalTex_ST.x,input.worldPos.z / 50.0 * _NormalTex_ST.y) + float2(0.94,0.34)*_Time.x*_NormalSpeed)),
	            								UnpackNormal(tex2D(_NormalTex, float2(input.worldPos.x / 50.0 * _NormalTex_ST.x,input.worldPos.z / 50.0 * _NormalTex_ST.y) + float2(-0.85,-0.53)*_Time.x*_NormalSpeed)),0.5);

	            	tangentNormal = normalize(tangentNormal) ;
	            	float3 mappedWorldNormal = normalize(mul(M, tangentNormal));
	            	float waveHeight = saturate(input.worldPos.y/_waveMaxHeight) ;
	            	float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);


	            	//float scatterViewFactor = saturate(dot(viewDir , lightDirection));
					//float scatterFactor = pow(waveHeight,_WaveHeightPow)  + (1-waveHeight)*pow(scatterViewFactor,_ScatterAnglePow);



					float3 specularColor = pow(max(0.0, dot(reflect(lightDirection, mappedWorldNormal),viewDir)), _Shininess);
					//float3 specularColor = pow(max(0.0, dot(mappedWorldNormal,normalize(- viewDir + lightDirection))), _Shininess);
					float4 reflectiveDistortedUV;
					float3 reflectedColor = CalculateReflectiveColor(input.worldPos, input.grabPos, mappedWorldNormal,viewDir,reflectiveDistortedUV);
					//reflectiveDistortedUV.x = 0;

					reflectiveDistortedUV.x = input.grabPos.x;
					float shadowFactor = tex2Dproj(_ShadowMask, UNITY_PROJ_COORD(reflectiveDistortedUV));
					//shadowFactor = saturate(pow(shadowFactor,0.5));
					float blockFactor = saturate(1-tex2Dproj(_ReflectionBlockTex, UNITY_PROJ_COORD(reflectiveDistortedUV)).r);

					float F = CalculateFresnel (-viewDir, mappedWorldNormal);
					float4 refractiveColor = CalculateRefractiveColor(input.worldPos, input.grabPos, mappedWorldNormal,viewDir,lightDirection,landHeight,waveHeight,shadowFactor);
					//float4 emissionSSSColor = CalculateSSSColor(lightDirection, mappedWorldNormal,  viewDir, waveHeight, shadowFactor, F);




					float4 col = float4(lerp(refractiveColor ,reflectedColor ,F),1) + float4(specularColor,1) * shadowFactor * blockFactor;

					//if (tex2D(_HeightMap, float2(input.worldPos.x/500, input.worldPos.z/500)).r<0.2) col = float4(1,0,0,1);
					//return tex2D(_HeightMap, float2(input.worldPos.x/_HeightMapTransform.x +_HeightMapTransform.z/100, input.worldPos.z/_HeightMapTransform.y+_HeightMapTransform.w/100))/2;

	                //float foamFactor = saturate(pow((1-worldNormal.y)*1.5,2)* 5 * tex2D(_FoamTex, float2(input.worldPos.x / 50.0 * _FoamTex_ST.x,input.worldPos.z / 50.0 * _FoamTex_ST.y)).a);
	                //float4 foamColor = float4(0.7,0.7,0.7,0);

	                //return blockFactor;
	                return col ;
	            }
	            ENDCG
		}
	}

	FallBack "Specular"
}
