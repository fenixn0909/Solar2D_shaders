
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

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FG"
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
  //P_COLOR vec4 COLOR = texture2D( CoronaSampler0, fragCoord );
  P_COLOR vec4 fragColor;
  P_DEFAULT float iTime = CoronaTotalTime;
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  
  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
  vec2 uv0 = uv;
  vec3 finalColor = vec3(0.0);
  
  for (float i = 0.0; i < 4.0; i++) {
      uv = fract(uv * 1.5) - 0.5;

      float d = length(uv) * exp(-length(uv0));

      vec3 col = palette(length(uv0) + i*.4 + iTime*.4);

      d = sin(d*8. + iTime)/8.;
      d = abs(d);

      d = pow(0.01 / d, 1.2);

      finalColor += col * d;
  }

  float _cChk =  finalColor.r + finalColor.g + finalColor.b;
  //float _a = max(sign(_cChk - 0.5), 0.0)-0.2;
  float _a = max(sign(_cChk - 3), 0.0);
  
  //fragColor = vec4(finalColor, 1.0); // Black BG
  //fragColor = vec4( finalColor, 0 );
  fragColor = vec4( finalColor, _a );
  //fragColor = vec4( finalColor.rgb * COLOR.rgb, _a );

  //----------------------------------------------
  

  return CoronaColorScale( fragColor );
}
]]

return kernel

--[[

--]]


