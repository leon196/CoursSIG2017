Shader "Unlit/VertexShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			// make fog work
			#pragma multi_compile_fog
			
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
				float3 view : TEXCOORD1;
				float3 vertexWorld : TEXCOORD2;
				float4 color : COLOR;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Audio;
			
			v2f vert (appdata v)
			{
				v2f o;
				float4 vertex = v.vertex;

				// local space
				vertex.x += sin(vertex.y*10.+_Time.y)*.1;

				// world space
				vertex = mul(UNITY_MATRIX_M, vertex);

				o.normal = mul(UNITY_MATRIX_M, v.normal);
				o.normal = normalize(o.normal);

				o.vertexWorld = vertex;
				o.view = normalize(vertex - _WorldSpaceCameraPos);

				// screen space
				o.vertex = mul(UNITY_MATRIX_VP, vertex);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				// normal color
				col.rgb = i.normal*.5+.5;

				// color from vertex distance
				float value = sin(length(i.vertexWorld)*10.);
				col *= smoothstep(0., .5, value);

				// basic phong shading
				col.rgb *= dot(i.normal, -i.view)*.5+.5;

				return col;
			}
			ENDCG
		}
	}
}
