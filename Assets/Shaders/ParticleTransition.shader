Shader "Unlit/ParticleTransition"
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
			
			#include "UnityCG.cginc"
			#include "Utils.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex, _Camera1;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;

				// screen distribution
				o.vertex.xzyw = v.vertex.xyzw;
				o.vertex.xy = o.vertex.xy * 2. - 1.;

				// animation
				float rng = rand(o.vertex.xy);
				float ratio = fmod(_Time.y + rng * 10., 1.);
				float scale = 0.1;
				scale *= 1.-smoothstep(.8,1.,ratio);
				v.uv.x += noiseIQ(v.uv.xxy+v.vertex*10.);
				v.uv.y += noiseIQ(v.uv.xxy+10.+v.vertex*3.);

				o.uv = o.vertex.xy + v.uv * scale;
				o.uv.y = -o.uv.y;

				// animation
				o.vertex.x += ratio*.1;
				o.vertex.y -= sin(ratio * PI)*.1;

				// show quad
				o.vertex.xy += v.uv * scale;
				o.vertex.z = 0.01;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_Camera1, i.uv*.5+.5);
				return col;
			}
			ENDCG
		}
	}
}
