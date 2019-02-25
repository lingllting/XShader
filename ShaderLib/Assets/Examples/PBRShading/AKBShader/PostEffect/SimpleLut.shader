Shader "Hidden/AKB/SimpleLut" 
{
	Properties 
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader 
	{
		Pass
		{
			ZTest Always Cull Off ZWrite Off

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _LutParams;
			sampler2D _LutTex;

			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			half3 ApplyLut2d(sampler2D tex, half3 uvw, half3 scaleOffset)
			{
				// Strip format where `height = sqrt(width)`
				uvw.z *= scaleOffset.z;
				half shift = floor(uvw.z);
				uvw.xy = uvw.xy * scaleOffset.z * scaleOffset.xy + scaleOffset.xy * 0.5;
				uvw.x += shift * scaleOffset.y;
				uvw.xyz = lerp(tex2D(tex, uvw.xy).rgb, tex2D(tex, uvw.xy + half2(scaleOffset.y, 0)).rgb, uvw.z - shift);
				return uvw;
			}

			fixed4 frag(v2f i) : SV_Target 
			{
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				half3 col = ApplyLut2d(_LutTex, mainTex.rgb, _LutParams.xyz);
				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
