
Shader "Custom/GeometryShader1" {
	Properties {
		_MainTex ("Texture (RGB)", 2D) = "white" {}
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
			
			struct attibute
			{
				float4 position : POSITION;
				float3 normal	: NORMAL;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
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
				o.uv = v.texcoord;
				return o;
			}

			[maxvertexcount(3)]
			void geom (triangle attibute tri[3], inout TriangleStream<varying> triStream)
			{
				float3 position = (tri[0].position + tri[1].position + tri[2].position) / 3.;
				float3 direction = normalize(tri[0].normal + tri[1].normal + tri[2].normal);
				float3 perpendicular = cross(direction, normalize(position));

				varying pIn = (varying)0;

				// same data for all vertices
				pIn.normal = normalize(tri[0].normal); 
				pIn.color = float4(1,1,1,1);

				float3 a = tri[0].position;
				float3 b = tri[1].position;
				float3 c = tri[2].position;

				float3 center = (a+b+c)/3.;
				float noisy = noiseIQ(center*.2);
				float wave = fmod(_Time.y + noisy, 1.);

				// scale
				a = center + (a - center) * sin(wave*PI);
				b = center + (b - center) * sin(wave*PI);
				c = center + (c - center) * sin(wave*PI);

				// displace
				wave = smoothstep(.5,1.,wave);
				a += direction * wave * 5.;
				b += direction * wave * 5.;
				c += direction * wave * 5.;

				// rotate
				float dist = .2*wave*length(a+b+c)/3.;
				a = center + rotateY(a-center, dist);
				b = center + rotateY(b-center, dist);
				c = center + rotateY(c-center, dist);

				pIn.position = UnityObjectToClipPos(float4(a, 1.0));
				pIn.uv = tri[0].uv;
				triStream.Append(pIn);

				pIn.position = UnityObjectToClipPos(float4(b, 1.0));
				pIn.uv = tri[1].uv;
				triStream.Append(pIn);

				pIn.position = UnityObjectToClipPos(float4(c, 1.0));
				pIn.uv = tri[2].uv;
				triStream.Append(pIn);
			}

			float4 frag (varying i) : COLOR
			{
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	}
	FallBack "Unlit/Transparent"
}
