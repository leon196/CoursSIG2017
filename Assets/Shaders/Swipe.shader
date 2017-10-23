Shader "Unlit/Swipe"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		LOD 100

		GrabPass { "_BackgroundTexture" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 grabPos : TEXCOORD1;
			};

			sampler2D _MainTex, _BackgroundTexture;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 uv = i.grabPos;
				uv.x += sin(uv.y*10.)*.2;
				uv.y += sin(uv.x*20.)*.1;
				fixed4 col = tex2Dproj(_BackgroundTexture, uv);
				col.rgb *= .5+.5*sin(i.uv.x*3.14159);
				col.rgb *= .5+.5*sin(i.uv.y*3.14159);
				return col;
			}
			ENDCG
		}
	}
}
