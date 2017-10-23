
Shader "Unlit/Particles"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Height ("Height", Float) = 20.
		_Speed ("Speed", Float) = .2
		_Scale ("Scale", Vector) = (1,1,1,1)
		_Tornado ("Tornado", Float) = .1
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 front : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float3 _TargetTornado;
			float2 _Scale;
			float _Height, _Speed, _Tornado;

			float2x2 rot (float a) {
				float c=cos(a),s=sin(a);
				return float2x2(c,-s,s,c);
			}

			float3 displace (float3 p, float ratio) {
				p.xyz -= _TargetTornado;
				float d = length(p)*_Tornado + ratio;
				p.xz = mul(rot(d), p.xz);
				p.yz = mul(rot(d), p.yz);
				p.xyz += _TargetTornado;
				return p;
			}
			
			v2f vert (appdata v)
			{
				v2f o;

				float4 vertex = v.vertex;

				float3 seed = vertex;
				float rng = rand(seed.xz);
				float ratio = fmod(abs(_Time.y * _Speed + rng), 1.);

				float2 scale = _Scale * (.5+.5*rng);

				float unit = 0.01;
				float3 next = displace(vertex.xyz, ratio+unit);
				float3 prev = displace(vertex.xyz, ratio-unit);
				float3 front = normalize(next-prev);
				float3 right = cross(front, normalize(vertex));

				float2 uv = v.uv;
				vertex.xyz = displace(vertex.xyz, ratio);
				vertex.xyz += front * uv.y * scale.x + right * uv.x * scale.y;

				o.vertex = UnityObjectToClipPos(vertex);

				o.front = front;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				if (length(i.uv) > 1.) discard;
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb = i.front*.5+.5;
				return col;
			}
			ENDCG
		}
	}
}
