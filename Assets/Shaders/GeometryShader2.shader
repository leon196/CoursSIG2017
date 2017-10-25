
Shader "Custom/GeometryShader2" {
	Properties {
		_MainTex ("Texture (RGB)", 2D) = "white" {}

		_ArrowScale ("Arrow Scale", Float) = 1.0
		_ArrowWidth ("Arrow Width", Float) = 0.1
		_ArrowLength ("Arrow Length", Float) = 1
		_ArrowHeadWidth ("Arrow Head Width", Float) = 0.1
		_ArrowHeadLength ("Arrow Head Length", Float) = 1
	}
	SubShader { 
		Tags { "RenderType"="Opaque" }
		Cull Off
		Pass {
			LOD 200

			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Utils.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _ArrowScale, _ArrowWidth, _ArrowLength, _ArrowHeadWidth, _ArrowHeadLength;
			
			struct attibute
			{
				float4 position : POSITION;
				float3 normal	: NORMAL;
				float4 color : COLOR;
			};

			struct varying {
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			attibute vert (appdata_full v)
			{
				attibute o = (attibute)0;
				o.position = v.vertex;
				o.normal = v.normal;
				o.color = v.color;
				return o;
			}

			[maxvertexcount(7)]
			void geom (triangle attibute tri[3], inout TriangleStream<varying> triStream)
			{
				float3 position = (tri[0].position + tri[1].position + tri[2].position) / 3.;
				float3 direction = (tri[0].normal + tri[1].normal + tri[2].normal) / 3.;
				
				float3 perpendicular = (cross(direction, normalize(position)));

				float3 a = position - perpendicular * _ArrowWidth * _ArrowScale;
				float3 b = position + perpendicular * _ArrowWidth * _ArrowScale;
				float3 c = a + direction * _ArrowLength * _ArrowScale;
				float3 d = b + direction * _ArrowLength * _ArrowScale;

				float3 e = position + (- perpendicular * _ArrowHeadWidth + _ArrowLength * direction) * _ArrowScale;
				float3 f = position + (perpendicular * _ArrowHeadWidth + _ArrowLength * direction) * _ArrowScale;
				float3 g = position + (direction * _ArrowHeadLength + _ArrowLength * direction + _ArrowHeadLength * direction) * _ArrowScale;

				varying pIn = (varying)0;

				// same data for all vertices
				pIn.normal = direction; 
				pIn.color = float4(1,1,1,1);
				
				pIn.uv = float2(1.0, 0.0); 
				pIn.position = UnityObjectToClipPos(float4(a, 1.0));
				triStream.Append(pIn);

				pIn.uv = float2(0.0, 0.0); 
				pIn.position = UnityObjectToClipPos(float4(b, 1.0));
				triStream.Append(pIn);

				pIn.uv = float2(1.0, 1.0); 
				pIn.position = UnityObjectToClipPos(float4(c, 1.0));
				triStream.Append(pIn);

				pIn.uv = float2(0.0, 1.0); 
				pIn.position = UnityObjectToClipPos(float4(d, 1.0));
				triStream.Append(pIn);

				triStream.RestartStrip();
				pIn.position = UnityObjectToClipPos(float4(e, 1.0));
				triStream.Append(pIn);
				pIn.position = UnityObjectToClipPos(float4(f, 1.0));
				triStream.Append(pIn);
				pIn.position = UnityObjectToClipPos(float4(g, 1.0));
				triStream.Append(pIn);
			}

			float4 frag (varying i) : COLOR
			{
				return float4(i.normal*.5+.5, 1.) * i.uv.y;
			}
			ENDCG
		}
	}
	FallBack "Unlit/Transparent"
}
