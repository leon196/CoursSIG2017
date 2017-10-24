Shader "Unlit/PokeballRain"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Height ("Height", Float) = 20.
		_Speed ("Speed", Float) = .2
		_Scale ("Scale", Float) = .2
		_BounceRange ("Bounce Range", Float) = 4.
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

			// attributes (infos from vertices)
			struct appdata
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			// varying (info from vertex shader to pixel shader)
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 position : SV_POSITION;
			};

			// uniforms
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Height, _Speed, _Scale, _BounceRange;
			
			v2f vert (appdata v)
			{
				v2f o;

				// give uv to fragment shader
				o.uv = v.uv;

				// random noise
				float3 seed = v.position;
				float rng = rand(seed.xz*20.);

				// animation ratio [0 -> 1]
				float ratio = fmod(abs(_Time.y * _Speed + rng), 1.);

				// decide when ratio hits ground
				float ratioGround = .9;

				// billboard scale
				float scale = _Scale;
				// fade scale from animation spawn and death
				scale *= smoothstep(0.,.01, ratio) * smoothstep(0.,.02, 1.-ratio);
				// random scale
				scale *= .5+.5*rng;

				// fall animation
				float fallRatio = min(ratioGround, ratio)/ratioGround;
				v.position.y = (1.-fallRatio) * _Height;

				// bounce animation
				float isBounce = step(ratioGround,ratio);
				float bounceRatio = smoothstep(ratioGround,1.,ratio);
				v.position.y += _BounceRange/2. * sin(bounceRatio*PI);
				v.position.x += _BounceRange * bounceRatio*(rand(seed.xz+1.)*2.-1.);
				v.position.z += _BounceRange * bounceRatio*(rand(seed.xz-1.)*2.-1.);

				// model matrix (world space) (transform component)
				v.position = mul(UNITY_MATRIX_M, v.position);
				
				// apply view and projection matrix (screen space)
				o.position = mul(UNITY_MATRIX_VP, v.position);
				
				// uv are used to scale quad in screen space
				float2 uv = v.uv;
				rotation2D(uv, _Time.y+rng*PI*20.);
				uv.x *= _ScreenParams.y/_ScreenParams.x;
				// random rotation with time

				// strech animation
				float stretchRatio = smoothstep(ratioGround-.025,ratioGround+.025,ratio);
				uv.x *= 1. + sin(stretchRatio * PI);
				uv.y *= 1. + .5*cos(stretchRatio * PI + PI/2.);

				// scale quad
				o.position.xy += uv * scale;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float dist = length(i.uv);

				// decide to write pixel or not
				if (dist > 1.) discard;

				float3 color = float3(1,1,1);

				// pokeball with maths
				// red & white
				color.rgb = lerp(float3(1,0,0), float3(1,1,1), step(0., i.uv.y));
				// belt
				color.rgb = lerp(color.rgb, float3(0,0,0), step(abs(i.uv.y), .05));
				// circles
				color.rgb = lerp(color.rgb, float3(0,0,0), step(.9, dist));
				color.rgb = lerp(color.rgb, float3(0,0,0), step(dist, .3));
				color.rgb = lerp(color.rgb, float3(1,1,1), step(dist, .2));
				color.rgb = lerp(color.rgb, float3(0,0,0), step(dist, .1));

				// volume effect
				color.rgb *= (1.-length(i.uv))*.75+.25;

				return fixed4(color, 1.);
			}
			ENDCG
		}
	}
}
