#pragma target 3.0

#include "Lighting.cginc"
#include "UnityCG.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _FurTex;
float4 _FurTex_ST;
float _Shininess;
float _SpecularStrength;

float _FurLength;
float _FurDensity;
float _FurThinness;
float _FurAO;
float _FurShadowStrength;
float _FurSoftness;
float4 _Force;

float _RimLightPower;
float _TransmissionSpread;
float _TransmissionRimPower;
float _TransmissionStrength;



struct v2f
{
    float4 pos: SV_POSITION;
    float2 uv1: TEXCOORD0;
    float2 uv2: TEXCOORD1;
    float3 worldNormal: TEXCOORD2;
    float3 worldPos: TEXCOORD3;
    float2 uvDir: TEXCOORD4;
    float3 worldFurTangent: TEXCOORD5;
};


v2f vert_surface(appdata_base v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv1 = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv2 = TRANSFORM_TEX(v.texcoord, _FurTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    return o;
}

fixed4 frag_surface(v2f i): SV_Target
{
    
    float3 worldNormal = normalize(i.worldNormal);
    float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    float3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    float3 worldHalf = normalize(worldView + worldLight);
    
    fixed3 albedo = tex2D(_MainTex, i.uv1).rgb;
    fixed3 ambient = unity_AmbientSky.xyz * albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
    fixed3 specular = _LightColor0.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess) * _SpecularStrength;

    fixed3 color = (ambient + diffuse) * (1 - _FurAO);
    
    return fixed4(color, 1.0);
}

v2f vert_fur(appdata_tan v)
{
	v2f o;
	o.uv1 = TRANSFORM_TEX(v.texcoord, _MainTex);
	o.uv2 = TRANSFORM_TEX(v.texcoord, _FurTex);
	o.worldNormal = UnityObjectToWorldNormal(v.normal);

	float3 pos = v.vertex.xyz + v.normal * _FurLength * FURSTEP;
	pos += clamp(mul(unity_WorldToObject, _Force).xyz, -1, 1) * pow(FURSTEP, _FurSoftness) * _FurLength; 

	float3 lastPos = v.vertex.xyz + v.normal * _FurLength * (FURSTEP - 0.05);
	lastPos += clamp(mul(unity_WorldToObject, _Force).xyz, -2, 2) * pow(FURSTEP - 0.05, _FurSoftness) * _FurLength; 

	o.worldFurTangent = normalize(mul(unity_ObjectToWorld, pos - lastPos));


	o.pos = UnityObjectToClipPos(float4(pos, 1));
	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

	TANGENT_SPACE_ROTATION;

	float3 worldLightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));
	float3 tanLightDir = normalize(mul(rotation, worldLightDir));
	o.uvDir = -tanLightDir.xz;

	return o;
}

fixed4 frag_fur(v2f i): SV_Target
{
	float3 worldNormal = normalize(i.worldNormal);
    float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    float3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    float3 worldHalf = normalize(worldView + worldLight);

    fixed3 albedo = tex2D(_MainTex, i.uv1).rgb;
    float rim = 1.0 - saturate(dot(worldView, worldNormal));
    float rimColor = pow(rim, _RimLightPower);

    fixed3 ambient = (unity_AmbientSky.xyz + rimColor * 0.3) * albedo;

    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));

    fixed3 noise = tex2Dlod(_FurTex, float4(i.uv2 * _FurDensity,0,0)).rgb;
	fixed alpha = clamp(noise - (FURSTEP * FURSTEP) * _FurThinness, 0, 1);

	fixed3 noise_D = tex2Dlod(_FurTex, float4((i.uv2 + i.uvDir * 0.001) * _FurDensity,0,0)).rgb;
	fixed alpha_D = clamp(noise_D - (FURSTEP * FURSTEP) * _FurThinness, 0, 1);

	diffuse *= 1 - (smoothstep(0, 0.1, alpha - alpha_D)) * _FurShadowStrength; 

	fixed3 transmission = pow(saturate(dot(-worldView, worldLight)), _TransmissionSpread) * pow(rim, _TransmissionRimPower) * _LightColor0.rgb * _TransmissionStrength;
	diffuse += transmission;

	float TdotH = dot(i.worldFurTangent, worldHalf);
	fixed3 specular = _LightColor0.rgb * pow(saturate(sqrt(1 - TdotH * TdotH)), _Shininess)  * _SpecularStrength * smoothstep(-0.2,1, dot(worldNormal, worldLight));

	fixed3 color = (ambient + diffuse + specular) * (1 - (pow(1 - FURSTEP, 3)) * _FurAO);

	return fixed4(color, alpha);
}