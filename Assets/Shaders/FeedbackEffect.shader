Shader "Hidden/FeedbackEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			
			sampler2D _MainTex, _Camera1;

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 uv = i.uv;
				float2 offset = normalize(uv-.5);
				uv -= offset * .01;
				fixed4 buffer = tex2D(_MainTex, uv);
				fixed4 camera = tex2D(_Camera1, i.uv);
				fixed4 color = lerp(buffer, camera, .1);
				return color;
			}
			ENDCG
		}
	}
}
