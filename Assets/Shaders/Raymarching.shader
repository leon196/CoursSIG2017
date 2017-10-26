Shader "Filters/Raymarching"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Texture ("Texture", 2D) = "white" {}
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
			
			sampler2D _MainTex, _Texture;
			float3 _CameraPosition, _CameraForward, _CameraRight, _CameraUp;
			float _Step, _Volume, _MinDist;

			float sdSphere (float3 p, float r) {
				return length(p) - r;
			}

			float sdCylinder (float2 p, float r) {
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

			// Martin Palko http://www.martinpalko.com/triplanar-mapping/
			float3 triplanar(float3 pos, float3 normal, sampler2D channel, float uvscale) {
			    float2 uvx = pos.yz*uvscale;
			    float2 uvy = pos.xz*uvscale;
			    float2 uvz = pos.xy*uvscale;
			    float3 texx = tex2D(channel,uvx).rgb;
			    float3 texy = tex2D(channel,uvy).rgb;
			    float3 texz = tex2D(channel,uvz).rgb;
			    float3 blends = abs(normal);
			    return texx*blends.x+texy*blends.y+texz*blends.z;
			}


			float map (float3 pos) {
				// pos.y += .1*noiseIQ(rotateY(pos*5., _Time.y));
				// pos.y -= .1*noiseIQ(rotateX(pos*10., _Time.y));
				float cellSize = .1;
				float crop = sdBox(pos, float3(1,1,1));

				float3 p = pos;
				rotation2D(p.xz, _Time.y);
				rotation2D(p.xy, _Time.y*.5);
				rotation2D(p.yz, _Time.y*.2);
				float box = sdBox(p, float3(1,1,1)*.5);

				// rotation2D(pos.xz, pos.y*.1);
				pos.y -= smoothstep(.1,1.2,length(pos))*.5;
				pos.y -= (pos.x+pos.z)*.2;
				// pos = normalize(pos)*(length(pos)+smoothstep(.1,1.,length(pos))*.5);
				pos.xz = fmod(abs(pos.xz), cellSize) - cellSize/2.;


				float cyl1 = sdCylinder(pos.xy, .01);
				float cyl2 = sdCylinder(pos.zy, .01);
				float scene = smin(cyl1, cyl2,.02);
				scene = max(crop, scene);

				scene = smin(scene, box, .1);

				return scene;
			}

			float3 getNormal (float3 pos) {
				float2 e = float2(0.001,0);
				return normalize(float3(map(pos+e.xyy)-map(pos-e.xyy),map(pos+e.yxy)-map(pos-e.yxy),map(pos+e.yyx)-map(pos-e.yyx)));
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
				float3 normal = getNormal(pos);
				// color = normal *.5 + .5;
				color = triplanar(pos, normal, _Texture, 1.);
				color *= shade;

				return fixed4(color, 1.);
			}
			ENDCG
		}
	}
}
