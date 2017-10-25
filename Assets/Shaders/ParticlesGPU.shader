
Shader "Unlit/ParticlesGPU"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PositionTexture ("Position Texture", 2D) = "white" {}
		_Scale ("Scale", Vector) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Utils.cginc"

			struct attribute
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float4 uv2 : TEXCOORD1;
			};

			struct varying
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 view : TEXCOORD2;
			};

			uniform sampler2D _MainTex, _PositionTexture;
			uniform float4 _MainTex_ST;
			uniform float2 _Scale;
			
			varying vert (attribute v)
			{
				varying o;

				float4 position = v.position;

				position.xyz = tex2Dlod(_PositionTexture, v.uv2).xyz;
				
				position = mul(UNITY_MATRIX_M, position);

				o.view = normalize(_WorldSpaceCameraPos - position);
				o.position = mul(UNITY_MATRIX_VP, position);
				o.position.xy += v.uv * _Scale.x;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (varying i) : SV_Target
			{
				if (length(i.uv) > 1.) discard;
				float3 color = float3(1,1,1);
				return fixed4(color,1);
			}
			ENDCG
		}
	}
}
