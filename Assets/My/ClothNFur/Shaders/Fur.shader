Shader "Custom/Fur"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _FurTex ("Fur Texture", 2D) = "white" {}
        _Shininess ("Shininess", Range(0.01, 300.0)) = 8.0
        _SpecularStrength ("Specular Strength", Range(0,1.5)) = 0.5

        _FurLength ("Fur Length", Range(0.001, 0.07)) = 0.027
        _FurDensity ("Fur Density", Range(0.01, 20)) = 0.11
        _FurThinness ("Fur Thinness", Range(0.01, 0.7)) = 0.1
        _FurAO ("Fur AO Strength", Range(0.0, 1)) = 0.25
        _FurShadowStrength ("Fur Shadow Strength", Range(0.0, 0.5)) = 0.3
        _FurSoftness ("Fur Softness", Range(0.5, 4.0)) = 1.5

        //_Force ("Force", Vector) = (0, 0, 0, 0)

        _RimLightPower("Rim Light Spread", Range(0.01, 8.0)) = 6.0

        _TransmissionSpread("Transmission Spread", Range(0.01, 10.0)) = 6.0
        _TransmissionRimPower("Transmission Rim Spread", Range(0.01, 10.0)) = 6.0
        _TransmissionStrength("Transmission Strength", Range(0.00, 3.0)) = 1.0

    }
    Category
    {
    	Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
    	Cull Off
    	Blend SrcAlpha OneMinusSrcAlpha


	    SubShader
	    {
	    	


			Pass
            {
                CGPROGRAM

                #define FURSTEP 0.00
                #pragma vertex vert_surface
                #pragma fragment frag_surface
                #include "FurBase.cginc"
                
                ENDCG
            }


            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.05
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.10
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.15
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.20
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.25
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.30
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.35
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.40
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.45
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.50
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.55
                #pragma vertex vert_fur
                #pragma fragment frag_fur
               #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.60
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.65
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }


            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.70
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.75
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.80
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.85
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.90
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 0.95
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

            Pass
            {
                CGPROGRAM

                #define FURSTEP 1.00
                #pragma vertex vert_fur
                #pragma fragment frag_fur
                #include "FurBase.cginc"
                
                ENDCG
            }

	    }

	    FallBack "Diffuse"
    }
}
