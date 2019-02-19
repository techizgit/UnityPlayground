Shader "Custom/OceanWater"
{
	Properties
	{
		[HideInInspector] _ReflectionTex ("", 2D) = "white" {}
		[HideInInspector] _ReflectionBlockTex ("", 2D) = "white" {}
		[HideInInspector] _HeightMap ("", 2D) = "black" {}
		[HideInInspector] _ShadowMask ("", 2D) = "white" {}



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

		Tags { "RenderType"="Transparent" "RenderQueue"="Transparent" "LightMode"="ForwardBase" }

		//Grab background color for refractive
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

	            samplerCUBE _Skybox;
	            sampler2D _FoamTex;
	            sampler2D _NormalTex;
	            sampler2D _WaterBackground;
	            sampler2D _CameraDepthTexture;
	            sampler2D _ReflectionTex;
	            sampler2D _ReflectionBlockTex;
	            sampler2D _HeightMap;
	            sampler2D _ShadowMask;
	            sampler2D _FoamMap;

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

				int _resolution;

				float2 _ShallowMaskOffset;

				//Sample wave displacement from a matrix passed from compute shader
				struct waveSampler
				{
					float x;
					float z;
					float3 displacement;
				};

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
	            };

	            StructuredBuffer<waveSampler> displacementSample;

	            //Calculate single gerstner wave bitangent
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

	            //Calculate single gerstner wave tangent
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


	            //Adding waves with different directions together
	            void CalculateGerstnerBT(float Amp, float Stp, float Dir, float Lth ,float attenuationFac,float3 vert,out float3 dB, out float3 dT)
	            {
	            	dB = 0; dT = 0;
	            	Stp *= 0.3;
	            	attenuationFac  = attenuationFac + (1 - attenuationFac)*sqrt(2/Lth);
	            	Amp = Amp * attenuationFac * Lth / 40 ;
	            	Stp =  (1-step(Amp,0)) * Stp;
	            	float Pi = 3.1415926f; float g = 9.8f;
	            	float Dx;float Dz;
	            	sincos(Dir / 360  * 2 * Pi , Dz, Dx);
	            	float w =  2 * Pi / Lth;
	            	float psi = _S * 2 * Pi / 20 / sqrt(Lth);
	
					dB += SingleWaveB(w,Amp,Stp,Dir,vert,psi,1,1,3.5);
	            	dB += SingleWaveB(w,Amp*1.00,Stp,Dir+17,vert,psi,0.9,1,4);
	            	dB += SingleWaveB(w,Amp*0.95,Stp,Dir+46,vert,psi,1.1,0.9,4.5);
	            	dB += SingleWaveB(w,Amp*0.85,Stp,Dir+65,vert,psi,0.8,1.2,5);
	            	dB += SingleWaveB(w,Amp*0.75,Stp,Dir+133,vert,psi,1.4,0.8,5.5);
	            	dB += SingleWaveB(w,Amp*0.65,Stp,Dir+96,vert,psi,0.7,0.65,6);

	            	dT += SingleWaveT(w,Amp,Stp,Dir,vert,psi,1,1,3.5);
	            	dT += SingleWaveT(w,Amp*1.00,Stp,Dir+17,vert,psi,0.9,1,4);
	            	dT += SingleWaveT(w,Amp*0.95,Stp,Dir+46,vert,psi,1.1,0.9,4.5);
	            	dT += SingleWaveT(w,Amp*0.85,Stp,Dir+65,vert,psi,0.8,1.2,5);
	            	dT += SingleWaveT(w,Amp*0.75,Stp,Dir+133,vert,psi,1.4,0.8,5.5);
	            	dT += SingleWaveT(w,Amp*0.65,Stp,Dir+96,vert,psi,0.7,0.65,6);
	            }


	            //Adding waves with different wave length together
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


	            	binormal = normalize(binormal);
	            	tangent = normalize(tangent);

	            	         	
	            }

	            //Calculating fresnel factor
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

	            //Fake Sub-suraface scattering calculation
	            float4 CalculateSSSColor(float3 lightDirection, float3 worldNormal, float3 viewDir,float waveHeight, float shadowFactor){
	            	float lightStrength = sqrt(saturate(lightDirection.y));
	            	float SSSFactor = pow(saturate(dot(viewDir ,lightDirection) )+saturate(dot(worldNormal ,-lightDirection)) ,_DirectTranslucencyPow) * shadowFactor * lightStrength * _EmissionStrength;
	            	return _DirectionalScatteringColor * (SSSFactor + waveHeight * 0.6);
	            }

	            //Calculate refractive color
	            float4 CalculateRefractiveColor(float3 worldPos, float4 grabPos, float3 worldNormal, float3 viewDir,float3 lightDirection,float landHeight,float waveHeight,float shadowFactor)
	            {
	            	//USING DEPTH TEXTURE(.W) BUT NOT ACTUAL RAYLENGTH IN WATER, NEED TO FIX
	           		float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, grabPos));
	            	float surfaceDepth = grabPos.w;
	            	float viewWaterDepthNoDistortion = backgroundDepth - surfaceDepth;

	            	float4 distortedUV = grabPos;
	            	float2 uvOffset = worldNormal.xz * _RefractionStrength;

	            	//Distortion near water surface should be attenuated
					uvOffset *= saturate(viewWaterDepthNoDistortion);


					distortedUV.xy = AlignWithGrabTexel(distortedUV.xy + uvOffset);

					//Resample depth to avoid false distortion above water
	            	backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, distortedUV));

	            	surfaceDepth = grabPos.w;
	            	float viewWaterDepth = backgroundDepth - surfaceDepth;

					float tmp = step(viewWaterDepth,0);
	            	distortedUV.xy = tmp * AlignWithGrabTexel(grabPos.xy) + (1 - tmp) * distortedUV.xy;
	            	viewWaterDepth = tmp * viewWaterDepthNoDistortion + (1 - tmp) * viewWaterDepth;
	            	            	           	
	            	float4 transparentColor =  tex2Dproj(_WaterBackground , distortedUV);
	            	float shallowWaterFactor = 0;

					shallowWaterFactor = saturate(pow(landHeight,_WaterDepthChangeFactor)) ;

					float4 scatteredColor = _DeepColor  + _ShallowColor * shallowWaterFactor * (shadowFactor + 1) * 0.5;

					float viewWaterDepthFactor = pow(saturate(viewWaterDepth / _WaterClarity), _WaterClarityAttenuationFactor);
					float4 emissionSSSColor = CalculateSSSColor(lightDirection, worldNormal,  viewDir, waveHeight, shadowFactor);

	            	return lerp(transparentColor , scatteredColor, viewWaterDepthFactor) + emissionSSSColor;
	            }

	            //Calculate reflective color
	            float4 CalculateReflectiveColor(float3 worldPos, float4 grabPos, float3 worldNormal, float3 viewDir, out float4 distortedUV)
	            {
	            	float2 uvOffset = worldNormal.xz * _ReflectionDistortionStrength;

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

					//Read displacement data from compute buffer
					int x = round(input.uv.x * (_resolution - 1));
					int z = round(input.uv.y * (_resolution - 1));
					int index =  x * _resolution + z;
					float3 disPos = displacementSample[index].displacement;

					input.vertex.xyz = mul(unity_WorldToObject, float4(worldPos + disPos, 1));
					worldPos = worldPos + disPos;
					output.uv = input.uv;
    				output.pos = UnityObjectToClipPos(input.vertex);

    				output.worldPos = worldPos;
    				output.grabPos = ComputeGrabScreenPos(output.pos);
	                return output;
	            }

	            float4 frag(vertexOutput input) : SV_Target
	            {
	            	float3 viewDir = normalize(input.worldPos - _WorldSpaceCameraPos.xyz);

	            	//Sampling landheight from height map
	            	float landHeight = tex2D(_HeightMap, float2(input.worldPos.x/1200+0.25, input.worldPos.z/1200+0.25));
	            	float attenuationFac = 1;

	            	//Attenuate waves above shallow water
					attenuationFac = saturate(pow((1.0 - landHeight),_ShoreWaveAttenuation));
	            	float3 bitangent = float3(0,0,0);
	            	float3 tangent = float3(0,0,0);

	            	CalculateWaveBT(input.worldPos, bitangent, tangent, attenuationFac);

	            	//Calculating normal, using BTN matrix
	            	float3 worldNormal = normalize(cross(tangent, bitangent));
	            	float3x3 M = {bitangent,tangent,worldNormal};
	            	M = transpose(M);
	            	float3 tangentNormal = lerp(UnpackNormal(tex2D(_NormalTex, float2(input.worldPos.x / 50.0 * _NormalTex_ST.x,input.worldPos.z / 50.0 * _NormalTex_ST.y) + float2(0.94,0.34)*_Time.x*_NormalSpeed)),
	            								UnpackNormal(tex2D(_NormalTex, float2(input.worldPos.x / 50.0 * _NormalTex_ST.x,input.worldPos.z / 50.0 * _NormalTex_ST.y) + float2(-0.85,-0.53)*_Time.x*_NormalSpeed)),0.5);
	            	tangentNormal = normalize(tangentNormal) ;
	            	float3 mappedWorldNormal = normalize(mul(M, tangentNormal));

	            	float waveHeight = saturate(input.worldPos.y/_waveMaxHeight) ;
	            	float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

					float3 specularColor = pow(max(0.0, dot(reflect(lightDirection, mappedWorldNormal),viewDir)), _Shininess);

					//This reflective distorted UV is calculated in CalculateReflectiveColor() with "out" keyword
					float4 reflectiveDistortedUV;
					float3 reflectedColor = CalculateReflectiveColor(input.worldPos, input.grabPos, mappedWorldNormal,viewDir,reflectiveDistortedUV);

					reflectiveDistortedUV.x = input.grabPos.x;

					//Fake surface shadow sampled from another render texture
					float shadowFactor = tex2Dproj(_ShadowMask, UNITY_PROJ_COORD(reflectiveDistortedUV));

					//Blocking false specular
					float blockFactor = saturate(1-tex2Dproj(_ReflectionBlockTex, UNITY_PROJ_COORD(reflectiveDistortedUV)).r);

					float F = CalculateFresnel (-viewDir, mappedWorldNormal);
					float4 refractiveColor = CalculateRefractiveColor(input.worldPos, input.grabPos, mappedWorldNormal,viewDir,lightDirection,landHeight,waveHeight,shadowFactor);

					float4 col = float4(lerp(refractiveColor ,reflectedColor ,F),1) + float4(specularColor,1) * shadowFactor * blockFactor;
	                return col;
	            }
	            ENDCG
		}
	}

	FallBack "Specular"
}
