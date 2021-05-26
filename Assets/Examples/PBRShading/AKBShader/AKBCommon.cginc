#ifndef AKBCOMMON_INCLUDED
#define AKBCOMMON_INCLUDED

//#define GAMMA_CORRECTION
//#define SCREEN_GAMMA_CORRECTION

#ifdef GAMMA_CORRECTION
#define GAMMA_TO_LINEAR(c) c.rgb = pow(c.rgb, 2.2);
#else
#define GAMMA_TO_LINEAR(c)
#endif 

#if defined(GAMMA_CORRECTION) && !defined(SCREEN_GAMMA_CORRECTION)
#define LINEAR_TO_GAMMA(c) c.rgb = pow(c.rgb, 0.454);
#else
#define LINEAR_TO_GAMMA(c) 
#endif 

#if defined(GLOBAL_COLOR)
half3 _GlobalColor;

#define SetGlobalColor(c) c.rgb *= _GlobalColor
#else
#define SetGlobalColor(c) c.rgb *= 1
#endif

#if defined(WHITE_INTENSITY)
half _WhiteIntensity;
#define SetWhiteIntenstiy(c) c.rgb = lerp(c.rgb, half3(1, 1, 1), _WhiteIntensity)
#else
#define SetWhiteIntenstiy(c) c.rgb = c.rgb
#endif

#if defined(CHANGE_SHADOW_COLOR)
half4 _ShadowColor;
#define ChangeShadowColor(c, atten) c = _LightColor0.rgb * lerp(_ShadowColor.rgb, 1, atten);
#else
#define ChangeShadowColor(c, atten) c.rgb = c.rgb
#endif

#endif // AKBCOMMON_INCLUDED
