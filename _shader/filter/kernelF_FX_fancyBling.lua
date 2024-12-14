 
--[[
  Shader Art Coding Introduction
  https://www.shadertoy.com/view/mtyGWy
  https://youtu.be/f4s1h2YETNY
  
  Created by kishimisu in 2023-05-20

  /* This animation is the material of my first youtube tutorial about creative 
     coding, which is a video in which I try to introduce programmers to GLSL 
     and to the wonderful world of shaders, while also trying to share my recent 
     passion for this community.
                                         Video URL: https://youtu.be/f4s1h2YETNY
  */

  SHOULD MOVE to Generator

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "fancyBling"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.fragment =
[[


P_DEFAULT float resolutionX = CoronaVertexUserData.x;
P_DEFAULT float resolutionY = CoronaVertexUserData.y;
P_UV vec2 iResolution = vec2(resolutionX,resolutionY);
//----------------------------------------------

float _thiness = 28.0; // hint:(0.8)  The larger the thiner
float _freq = 3.4; // hint:(0.4)

//----------------------------------------------
//https://iquilezles.org/articles/palettes/
vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );
}

// -----------------------------------------------
//https://www.shadertoy.com/view/mtyGWy
P_COLOR vec4 FragmentKernel( P_UV vec2 fragCoord )
{
  //P_UV vec2 fragCoord = UV / iResolution;
  //P_UV vec2 uv = fragCoord / iResolution;
  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, fragCoord );
  P_COLOR vec4 fragColor;
  P_DEFAULT float iTime = CoronaTotalTime;
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  
  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
  vec2 uv0 = uv;
  vec3 finalColor = vec3(0.0);
  vec3 finalColor2 = vec3(0.0);
  
  for (float i = 0.0; i < 4.0; i++) {
      uv = fract(uv * 1.5) - 0.5;

      float d = length(uv) * exp(-length(uv0));

      vec3 col = palette(length(uv0) + i*.4 + iTime*_freq);

      d = sin(d*8. + iTime)/_thiness;
      d = abs(d);

      d = pow(0.01 / d, 1.2);

      finalColor += col * d;
  }

  //float _cChk =  finalColor.r + finalColor.g + finalColor.b;
  float _cChk =  COLOR.r + COLOR.g + COLOR.b;
  //float _a = max(sign(_cChk - 0.5), 0.0)-0.2;
  float _a = max(sign(_cChk - 0.5), 0.0);
  
  //finalColor.rgb = finalColor.rgb * _a;
  finalColor.rgb = finalColor.rgb * COLOR.a;


  finalColor2 = finalColor * COLOR.rgb;
  //fragColor = vec4( finalColor.rgb + COLOR.rgb, _a );
  //fragColor = (max( finalColor.rgb, COLOR.rgb), _a );
  fragColor.rgb = max( finalColor2.rgb, COLOR.rgb);
  //fragColor.r = max( finalColor.r, COLOR.r);
  //fragColor.g = max( finalColor.g, COLOR.g);
  //fragColor.b = max( finalColor.b, COLOR.b);
  //fragColor.a = _a;
  fragColor.a = COLOR.a;


  //----------------------------------------------
  

  return CoronaColorScale( fragColor );
}
]]

return kernel

--[[

--]]


