Shader "Unlit/Skybox"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Panorama1 ("Panorama", CUBE) = "white" {}
		_Panorama2 ("Panorama", CUBE) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Utils.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 vertexWorld : TEXCOORD2;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 view : TEXCOORD1;
			};

			sampler2D _MainTex;
			samplerCUBE _Panorama1, _Panorama2;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				v.vertex = mul(UNITY_MATRIX_M, v.vertex);
				o.view = normalize(v.vertex - _WorldSpaceCameraPos);
				o.vertexWorld = v.vertex;
				o.vertex = mul(UNITY_MATRIX_VP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = normalize(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				color.rgb = i.view*.5+.5;
				float scale = 10.;
				float2 uv1 = sin(length(i.uv)*scale);
				float2 uv2 = sin((dot(i.view, i.normal)*scale));
				float2 uv = lerp(uv2, uv1, abs(dot(i.view, float3(0,0,1))));
				uv.x = atan2(i.vertexWorld.y, i.vertexWorld.x);
				uv.y += abs(sin(uv.x*2.+ _Time.y))*2.;
				uv.y -= noiseIQ(rotateY(rotateX(i.view*4., _Time.y),_Time.y*.5))*2.;
				float lod = 8.*length(i.uv);
				uv = floor(uv*lod)/lod;
				color.rgb = hsv2rgb(float3(fmod(uv.y+_Time.y, 1.), 1., 1.));
				// color.rgb = float3(1,1,1) * abs(uv.x) / 3.14159;
				// col.rg = sin(i.vertexWorld.x*.01);

				float4 pano1 = texCUBE(_Panorama1, i.view);
				float4 pano2 = texCUBE(_Panorama2, i.view);

				// color = pano2;
				color = lerp(color, pano2, step(sin(_Time.y),dot(i.view, i.normal)+uv.y));

				return color;
			}
			ENDCG
		}
	}
}
