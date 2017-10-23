// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/CelShading"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutlineThin ("Outline Thin", Float) = .1
		_OutlineColor ("Outline Color", Color) = (1,1,1,1)
		_TresholdSegments ("Treshold Segments", Float) = 8.
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		// outline pass
		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _OutlineThin, _OutlineColor;
			
			v2f vert (appdata v)
			{
				v2f o;

				o.normal = normalize(v.normal);
				v.vertex.xyz += o.normal * _OutlineThin;

				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}

		// treshold pass
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _TresholdSegments;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = normalize(v.normal);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= dot(i.normal, float3(0,1,0));
				col = floor(col*+_TresholdSegments)/+_TresholdSegments;
				return col;
			}
			ENDCG
		}
	}
}
