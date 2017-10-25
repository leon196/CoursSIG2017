Shader "Filters/Transition"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Blend ("Blend", Range(0,1)) = .5
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Utils.cginc"
			
			sampler2D _MainTex;
			sampler2D _Camera1, _Camera2;
			float _Blend;

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 uv = i.uv;

				// transition offsets
				// float offset = 0.;
				float offset = tex2D(_MainTex, uv).r;
				// float offset = rand(pixelize(uv, _ScreenParams.xy/16.));
				// float offset = rand(pixelize(uv.yy, _ScreenParams.xy/16.));
				// float offset = uv.x;
				// float offset = (uv.x + rand(pixelize(uv.yy, _ScreenParams.xy/16.)))/2.;

				// transition effect
				// float blend = _Blend;
				float blend = sin(_Time.y)*.5+.5;
				offset = smoothstep(.4,.6,offset+blend*2.-1.);
				blend = offset;
				fixed4 color = lerp(tex2D(_Camera1, uv), tex2D(_Camera2, uv), clamp(blend,0.,1.));

				// vignette effect
				color.rgb *= .75+.25*sin(uv.x*3.14159);
				color.rgb *= .75+.25*sin(uv.y*3.14159);

				return color;
			}
			ENDCG
		}
	}
}
