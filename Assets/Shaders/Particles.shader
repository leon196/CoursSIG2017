
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

			struct attribute
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct varying
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 view : TEXCOORD2;
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float3 _TargetTornado;
			uniform float2 _Scale;
			uniform float _Height, _Speed, _Tornado;

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
			
			varying vert (attribute v)
			{
				varying o;

				float4 position = v.position;
				position = mul(UNITY_MATRIX_M, position);

				float3 seed = position;
				float rng = rand(seed.xz);
				float ratio = fmod(abs(_Time.y * _Speed + rng), 1.);

				float2 scale = _Scale * (.5+.5*rng);

				float unit = 0.01;
				float3 next = displace(position.xyz, ratio+unit);
				float3 prev = displace(position.xyz, ratio-unit);
				float3 front = normalize(next-prev);
				float3 right = cross(front, normalize(position));

				float2 uv = v.uv;
				position.xyz = displace(position.xyz, ratio);
				position.xyz += front * uv.y * scale.x + right * uv.x * scale.y;

				o.view = normalize(_WorldSpaceCameraPos - position);
				o.position = mul(UNITY_MATRIX_VP, position);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = front;
				return o;
			}
			
			fixed4 frag (varying i) : SV_Target
			{
				if (length(i.uv) > 1.) discard;
				float3 color = float3(1,1,1);
				// color *= dot(i.normal, i.view)*.5+.5;
				color *= i.normal*.5+.5;
				return fixed4(color,1);
			}
			ENDCG
		}
	}
}
