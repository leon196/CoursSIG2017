
Shader "Unlit/ParticlesPosition"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SpawnTexture ("Spawn", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Utils.cginc"

			sampler2D _MainTex;
			sampler2D _SpawnTexture;
			float3 _Target;
			float _Radius;
			
			float4 frag (v2f_img i) : SV_Target
			{
				float4 position = tex2D(_MainTex, i.uv);
				float4 spawn = tex2D(_SpawnTexture, i.uv);
				
				float fade = 1.-smoothstep(0.,_Radius,length(_Target-position));

				// position.y += sin(noiseIQ(position.xyz)) * fade;
				position.xyz = _Target + rotateY(position-_Target, length(position-_Target)*.01 * fade);
				position.xyz = _Target + rotateZ(position-_Target, length(position-_Target)*.005 * fade);
				position.xyz -= normalize(_Target-position) * fade;

				position = lerp(position, spawn, step(fade,.1) * step(fmod(_Time.y+rand(i.uv),1.),0.01));

				return position;
			}
			ENDCG
		}
	}
}
