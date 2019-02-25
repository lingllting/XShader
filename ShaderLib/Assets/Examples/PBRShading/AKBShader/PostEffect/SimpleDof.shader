Shader "Hidden/AKB/SimpleDof"
{
	Properties
	{
		_MainTex("Base", 2D) = "" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		// Pass 0: Final DOF
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f {
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _TapLowBackground;
			sampler2D _COC;

			v2f vert (appdata_img v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy;
				return o;
			}

			half4 frag(v2f i) : SV_Target {
				half4 tapHigh = tex2D(_MainTex, i.uv.xy);
				half coc = tex2D(_COC, i.uv.xy).r;

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0) i.uv.xy = i.uv.xy * half2(1, -1) + half2(0, 1);
				#endif

				half4 tapLow = tex2D(_TapLowBackground, i.uv.xy);
				tapHigh = lerp(tapHigh, tapLow, coc);
				return tapHigh;
			}

			ENDCG
		}

		// Pass 1: COC
		Pass
		{
			ColorMask R

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"	

			struct v2f {
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			sampler2D_float _CameraDepthTexture;
			half4 _CurveParams;

			v2f vert(appdata_img v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy;
				return o;
			}

			half4 frag(v2f i) : SV_Target {
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.xy);
				d = Linear01Depth(d);
				half coc = 0.0;

				half focalDistance01 = _CurveParams.w + _CurveParams.z;

				if (d > focalDistance01)
					coc = (d - focalDistance01);

				coc = saturate(coc * _CurveParams.y);
				return coc;
			}
			ENDCG
		}
		
		// Pass 2: Blur
		Pass 
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"	

			half4 offsets;
			sampler2D _MainTex;
			sampler2D _COC;

			struct v2f {
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half4 uv01 : TEXCOORD1;
				half4 uv23 : TEXCOORD2;
				half4 uv45 : TEXCOORD3;
			};

			v2f vert(appdata_img v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy;
				o.uv01 = v.texcoord.xyxy + offsets.xyxy * half4(1, 1, -1, -1);
				o.uv23 = v.texcoord.xyxy + offsets.xyxy * half4(1, 1, -1, -1) * 2.0;
				o.uv45 = v.texcoord.xyxy + offsets.xyxy * half4(1, 1, -1, -1) * 3.0;

				return o;
			}

			half4 frag(v2f i) : SV_Target{
				half4 blurredColor = half4 (0, 0, 0, 0);

				half4 sampleA = tex2D(_MainTex, i.uv.xy);
				half4 sampleB = tex2D(_MainTex, i.uv01.xy);
				half4 sampleC = tex2D(_MainTex, i.uv01.zw);
				half4 sampleD = tex2D(_MainTex, i.uv23.xy);
				half4 sampleE = tex2D(_MainTex, i.uv23.zw);

				half alphaA = tex2D(_COC, i.uv.xy).r;
				half alphaB = tex2D(_COC, i.uv01.xy).r;
				half alphaC = tex2D(_COC, i.uv01.zw).r;
				half alphaD = tex2D(_COC, i.uv23.xy).r;
				half alphaE = tex2D(_COC, i.uv23.zw).r;

				half sum = alphaA + dot(half4 (0.75, 0.75, 0.5, 0.5), half4 (alphaB, alphaC, alphaD, alphaE));

				sampleA.rgb = sampleA.rgb * alphaA;
				sampleB.rgb = sampleB.rgb * alphaB * 0.75;
				sampleC.rgb = sampleC.rgb * alphaC * 0.75;
				sampleD.rgb = sampleD.rgb * alphaD * 0.5;
				sampleE.rgb = sampleE.rgb * alphaE * 0.5;

				blurredColor += sampleA;
				blurredColor += sampleB;
				blurredColor += sampleC;
				blurredColor += sampleD;
				blurredColor += sampleE;

				blurredColor /= sum;
				half4 color = blurredColor;
				color.a = alphaA;
				return color;
			}
			ENDCG
		}
	}
}
