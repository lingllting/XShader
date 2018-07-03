// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Valkyrie/Toon/ValkyrieToonCharacterBase" 
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}

		_MaskTex("Mask", 2D) = "black" {}
		_LightMaskTex("LightMask", 2D) = "black" {}
		_LightMaskParam("_LightMaskParam", Range(0.0,1.0)) = 0.7
		_LightMaskBackParam("_LightMaskBackParam", Range(0.0,1.0)) = 0.7
		_RampTex("Ramp", 2D) = "white"{}
		_RampBrightness("Ramp Brightness", Range(0.0,1)) = 1.0

		//_HighLightTex("HighLightTex", 2D) = "white" {}

		_HighLight("HighLight",range(0,1)) = 0.9		// 高光范围
		_HighLightColor("HighLight Color", Color) = (1,1,1,1)
		_HighLightStrength("HighLightStrength", range(0,1000)) = 100

		_BrightnessFactor("MinBrightness", range(0, 1)) = 0
		_BrightnessColor("Brightness Color", Color) = (1,1,1,1)

		_LightInfo("LightInfo", Vector) = (0.9, -1, 0.5, 0.005)
		_LightColor("LightColor",color) = (1,1,1,1)

		
		[Toggle]_HightlightDirectionSwitch("HightlightDirectionSwitch", float) = 1
		_HightlightDirection("HightlightDirection", range(-15, 15)) = 0
		_HightlightDirectionStrengthen("HightlightDirectionStrengthen", range(-90, 90)) = 0
		_HightlightDirectionBrightness("HightlightDirectionBrightness", range(0, 10)) = 0

		[Toggle]_ChangeColorSwitch("ChangeColorSwitch", range(0,1)) = 0
		_ChangeColorThreshold("ChangeColor Threshold", range(0,1)) = 0.05
		_OrigionColor1("Origion Color1",color) = (0,0,0,1)
		_TargetColor1("Target Color1",color) = (0,0,0,1)
		_OrigionColor2("Origion Color2",color) = (0,0,0,1)
		_TargetColor2("Target Color2",color) = (0,0,0,1)
		_OrigionColor3("Origion Color3",color) = (0,0,0,1)
		_TargetColor3("Target Color3",color) = (0,0,0,1)

		_Outline("Outline Thickness", range(0,10)) = 0.4
		_RampFactor("RampFactor", range(0,3)) = 2.5
		_RampFactor1("RampFactor1", range(0.1,20)) = 3
	}
		SubShader
		{
			//模型Base渲染 + 染色
			pass
			{

			Name "TOON"
				//平行光的的pass渲染
				Tags{ "LightMode" = "ForwardBase" "Queue" = "2010" }
				Cull Back
				//Lighting Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#pragma target 3.0 

				sampler2D _MainTex;
				sampler2D _MaskTex;
				sampler2D _LightMaskTex;

				sampler2D _RampTex;
				//sampler2D _HighLightTex;
				float _RampBrightness;

				uniform float4 _MainTex_ST;
				uniform float4 _Color;

				float _HighLight;
				float4 _HighLightColor;
				float _HighLightStrength;

				float _BrightnessFactor;
				//float4 _BrightnessColor;

				float _LightMaskParam;
				float _LightMaskBackParam;

				float4 _LightInfo;
				float4 _LightColor;

				float _HightlightDirectionSwitch;
				float _HightlightDirection;
				float _HightlightDirectionStrengthen;
				float _HightlightDirectionBrightness;

				float _ChangeColorSwitch;
				float _ChangeColorThreshold = 0.05;
				float4 _OrigionColor1;
				float4 _TargetColor1;
				float4 _OrigionColor2;
				float4 _TargetColor2;
				float4 _OrigionColor3;
				float4 _TargetColor3;

				float _RampFactor;
				float _RampFactor1;
				struct v2f
				{
					//裁减空间位置
					float4 pos:SV_POSITION;
					//世界空间位置
					float4 posW:TEXCOORD4;
					//顶点色
					float4 color:COLOR;
					//UV
					float2 uv : TEXCOORD0;
					//w值存储自定义光源的Lambert
					float4 lightDir:TEXCOORD1;
					//模型空间法线
					float3 normal:TEXCOORD2;
					//模型空间观察方向（朝向相机）
					float3 viewDir:TEXCOORD3;
					//世界空间光源方向（朝向光源）
					float4 lightDir1:TEXCOORD5;
					//世界空间法线
					float3 normalDir:TEXCOORD6;
				};

				// 如果color和origin的三个通道的值的差值都在一个阀值内则返回1,否则返回0
				fixed changeColor(half4 color, float4 origion)
				{
					fixed con = step(abs(origion.r - color.r), _ChangeColorThreshold);
					con = con + step(abs(origion.g - color.g), _ChangeColorThreshold);
					con = con + step(abs(origion.b - color.b), _ChangeColorThreshold);
					con = step(3, con);
					return con;
				}

				float3 RotationZ(float3 pointZ, float radius)
				{
					float radZ = radians(radius);

					float sinZ = sin(radZ);
					float cosZ = cos(radZ);

					return float3(
						pointZ.x * cosZ - pointZ.y * sinZ,
						pointZ.x * sinZ + pointZ.y * cosZ,
						pointZ.z);
				}

				float3 RotationY(float3 pointZ, float radius)
				{
					float radZ = radians(radius);

					float sinZ = sin(radZ);
					float cosZ = cos(radZ);

					return float3(
						pointZ.x * cosZ + pointZ.z * sinZ,
						pointZ.y,
						-pointZ.x * sinZ + pointZ.z * cosZ);
				}

				float4x4 Rotation(float4 rotation)
				{
					float radX = radians(rotation.x);
					float radY = radians(rotation.y);
					float radZ = radians(rotation.z);

					float sinX = sin(radX);
					float cosX = cos(radX);
					float sinY = sin(radY);
					float cosY = cos(radY);
					float sinZ = sin(radZ);
					float cosZ = cos(radZ);

					return float4x4(
						cosY * cosZ, -cosY * sinZ, sinY, 0,
						cosX * sinZ + sinX * sinY * cosZ, cosX * cosZ - sinX * sinY * sinZ, -sinX * cosY, 0,
						sinX * sinZ - cosX * sinY * cosZ, sinX * cosZ + cosX * sinY * sinZ, +cosX * cosY, 0,
						0, 0, 0, 1);
				}

				v2f vert(appdata_full v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.color = v.color;
					o.posW = mul(unity_ObjectToWorld,v.vertex);
					o.normal = v.normal;

					//float3 View = WorldSpaceViewDir(v.vertex);
					float3 View = WorldSpaceViewDir(o.posW);
					o.viewDir = mul((float3x3)unity_WorldToObject, View);

					//自定义光线方向转到模型空间
					float3 normDir = normalize(_LightInfo.xyz);
					normDir.xyz *= -1;
					float4 tempDir;
					tempDir.xyz = normDir;
					tempDir.w = 0;
					float3 dir = mul(unity_WorldToObject, tempDir).xyz;
					//???
					TANGENT_SPACE_ROTATION;
					o.lightDir.xyz = mul(rotation, dir);
					//自定义光线的lambert
					o.lightDir.w = dot(v.normal, dir);

					o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
					o.lightDir1 = normalize(_WorldSpaceLightPos0);
					return o;
				}

				half4 frag(v2f i) : COLOR
				{
					half LDotN = dot(i.lightDir1, i.normalDir)*0.5 + 0.5;
					half VDotN = dot(normalize(_WorldSpaceCameraPos - i.posW), i.normalDir);

					half4 texCol = tex2D(_MainTex,i.uv);

					//染色
					if (_ChangeColorSwitch == 1)
					{
						fixed con = changeColor(texCol, _OrigionColor1);
						texCol.rgb = lerp(texCol.rgb, texCol.rgb + _TargetColor1 - _OrigionColor1, con);
						con = changeColor(texCol, _OrigionColor2);
						texCol.rgb = lerp(texCol.rgb, texCol.rgb + _TargetColor2 - _OrigionColor2, con);
						con = changeColor(texCol, _OrigionColor3);
						texCol.rgb = lerp(texCol.rgb, texCol.rgb + _TargetColor3 - _OrigionColor3, con);
					}

					//采样ramp贴图
					float4 lightMask = tex2D(_LightMaskTex,i.uv);
					fixed4 mask = tex2D(_MaskTex, i.uv);

					half diff_misc = max(0, i.lightDir.w);

					float a = lerp(lightMask.r, diff_misc, _LightMaskParam);

					diff_misc = lerp(lightMask.r * diff_misc, diff_misc, a);
					half v = 0.625 + mask.r * 0.25 - 0.5 * mask.b;
					//half v = 0.5 + mask.r * 0.2 - 0.4 * mask.b;
					half2 rampUV = half2(diff_misc, v);
					half4 ramp = tex2D(_RampTex, rampUV);

					//Ramp贴图增强
					if (ramp.r + ramp.g + ramp.b != 3)
					{
						ramp.rgb = ramp.rgb*_RampBrightness;
					}
					ramp -= (1.0 - ramp) * (1.0 - mask.g);

					texCol.rgb *= ramp.rgb;
					texCol.rgb -= lerp(0, (1 - lightMask.rrr)*_LightMaskBackParam, max(0, -i.lightDir.w));
					texCol.rgb *= clamp(_LightColor.rgb * (1.0 - _BrightnessFactor) + _BrightnessFactor, 0, 1);
					texCol.rgb *= _Color;

					diff_misc *= 0.9;

					rampUV = half2(diff_misc * _RampFactor, 0.08);
					ramp = tex2D(_RampTex, rampUV);
					fixed4 specColor = float4(1, 1, 1, 1);
					if (ramp.r + ramp.g + ramp.b != 3)
						specColor *= 0;
					else
						specColor *= 0.6 * pow(diff_misc,floor(_RampFactor1)) *_HighLightStrength;
					

					texCol += lightMask.g * _HighLightColor * _HighLight * specColor ;

					if (_HightlightDirectionSwitch == 1)
					{
						if (dot(i.normal, normalize(RotationY(RotationZ(i.viewDir, _HightlightDirectionStrengthen), _HightlightDirection))) < -0.4)
							texCol *= _HightlightDirectionBrightness;
					}

					texCol *= i.color;

					//float4 highlight = tex2D(_HighLightTex, i.uv);
					//fixed4 specColor = tex2D(_RampTex, float2(diff_misc, 0.95));
					//texCol += highlight * specColor*0.4;

					return texCol;
				}
				ENDCG
			}
		}
	FallBack "Diffuse"
}