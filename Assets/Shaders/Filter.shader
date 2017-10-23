// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Filter/Filter"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Scale ("Scale", Float) = 1.
		_Slider ("Slider", Range(0,1)) = 0.5
		_Position ("Position", Vector) = (0,0,0,0)
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct attribute
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct varying
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			varying vert (attribute v)
			{
				varying o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float _Scale, _Slider;
			float3 _Position;

			fixed4 frag (varying i) : SV_Target
			{
				float2 uv = i.uv;

				// viewport space
				// uv = uv*2.-1.;
				// uv.x *= _ScreenParams.x/_ScreenParams.y;

				// polar coordinates effect
				// float a = atan2(uv.y,uv.x);
				// float r = length(uv);
				// uv = float2(a,r+a/4.);
				// uv = fmod(abs(uv), 1.);

				// wave effect
				// uv.x += sin(uv.y*_Scale + _Time.y)*_Slider;

				// pixel effect
				uv = floor(uv*_Scale)/_Scale;

				fixed4 col = tex2D(_MainTex, uv);

				// treshold effect
				// col = floor(col*_Scale)/_Scale;

				// vignette effect
				// col.rgb *= sin(uv.x*3.14159);
				// col.rgb *= sin(uv.y*3.14159);

				return col;
			}
			ENDCG
		}
	}
}
