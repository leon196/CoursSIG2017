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
			
			sampler2D _MainTex;
			sampler2D _Camera1, _Camera2;
			float _Blend;

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 uv = i.uv;

				// transition effect
				float offset = tex2D(_MainTex, uv).r;
				offset += _Blend;
				// offset = smoothstep(.4,.6,offset);
				float ratio = offset * sin(_Blend*3.14159);
				ratio = smoothstep(.2,.8,ratio);
				fixed4 color = lerp(tex2D(_Camera1, uv), tex2D(_Camera2, uv), ratio);

				// vignette effect
				color.rgb *= .75+.25*sin(uv.x*3.14159);
				color.rgb *= .75+.25*sin(uv.y*3.14159);

				return color;
			}
			ENDCG
		}
	}
}
