Shader "Filters/Raymarching"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Step ("Step", Float) = 32.
		_Volume ("Volume", Float) = 0.01
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
			
			sampler2D _MainTex;
			float3 _CameraPosition, _CameraForward, _CameraRight, _CameraUp;
			float _Step, _Volume;

			float map (float3 pos) {
				return length(pos) - 1.;
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

				float3 color = float3(0,0,0);

				for (float i = 0.; i < _Step; ++i) {
					float dist = map(pos);
					if (dist < _Volume) {
						color = float3(1,1,1) * (1.-i/_Step);
						break;
					}
					pos += ray * dist;
				}

				return fixed4(color, 1.);
			}
			ENDCG
		}
	}
}
