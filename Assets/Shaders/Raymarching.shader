Shader "Filters/Raymarching"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Step ("Step", Float) = 32.
		_Volume ("Volume", Float) = 0.01
		_MinDist ("Min Dist", Float) = 0.1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Utils.cginc"
			
			sampler2D _MainTex;
			float3 _CameraPosition, _CameraForward, _CameraRight, _CameraUp;
			float _Step, _Volume, _MinDist;

			float sdSphere (float3 p, float r) {
				return length(p) - r;
			}

			float sdBox( float3 p, float3 b )
			{
			  float3 d = abs(p) - b;
			  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
			}

			float smin (float a, float b, float r) {
				float h = clamp(.5+.5*(b-a)/r,0.,1.);
				return lerp(b,a,h)-r*h*(1.-h);
			}

			float map (float3 pos) {
				// pos.y += .1*noiseIQ(rotateY(pos*5., _Time.y));
				// pos.y -= .1*noiseIQ(rotateX(pos*10., _Time.y));
				float box = sdBox(pos, float3(1,1,1));
				float ground = abs(pos.y) - .1;
				pos.y -= 2.;
				pos.x += sin(_Time.y);
				float sph = sdSphere(pos, 1);
				return smin(box, sph, .5);
			}

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 uv = i.uv * 2. - 1.;
				uv.x *= _ScreenParams.x/_ScreenParams.y;

				float3 eye = _CameraPosition;
				float3 ray = _CameraForward + _CameraRight * uv.x + _CameraUp * uv.y;
				// float3 eye = float3(0,0,-2.);
				// float3 ray = float3(uv, 1.);
				ray = normalize(ray);
				float3 pos = eye;

				float3 color = float3(1,1,1);
				float shade = 0.;

				for (float i = 0.; i < _Step; ++i) {
					float dist = map(pos);
					if (dist < _Volume) {
						shade += 1./_Step;
					}
					if (shade >= 1.) {
						break;
					}
					dist = dist * (.9 + .1 * rand(uv));
					dist = max(_MinDist, dist);
					pos += ray * dist;
				}

				color *= shade;

				return fixed4(color, 1.);
			}
			ENDCG
		}
	}
}
