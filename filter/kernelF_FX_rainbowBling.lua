 
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
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "rainbowBling"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "offX",
    default = 0.0,
    min = -0.5,
    max = 0.5,
    index = 0, 
  },
  {
    name = "offY",
    default = 0.0,
    min = -0.5,
    max = 0.5,
    index = 1, 
  },
  {
    name = "density",
    default = 20,
    min = 1,
    max = 99,
    index = 2, 
  },
  {
    name = "speed",
    default = 17,
    min = -360,
    max = 360,
    index = 3, 
  },
}


kernel.fragment =
[[

P_UV vec2 offset_ = vec2( CoronaVertexUserData.x ,CoronaVertexUserData.y);
P_UV vec2 iResolution = vec2( 1, 1);
float desity_ = CoronaVertexUserData.z;
float speed_ = CoronaVertexUserData.w; // Minus -> inward


//----------------------------------------------

float _brightness = 0.03; //hint: (0.005, 0.1)

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
  P_COLOR vec4 fragColor = texture2D( CoronaSampler0, fragCoord );
  
  P_DEFAULT float iTime = CoronaTotalTime * speed_;
  

  //----------------------------------------------
  
  P_COLOR vec4 mixColor;

  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
  
  uv -= offset_;


  vec2 uv0 = uv;
  uv = fract(uv * 2.) - .5;


  vec3 colP2 = vec3(0.0);
  
  float d = length(uv);
  
  vec3 colP = palette( length(uv0) + iTime);
  
  d = sin(d*desity_ - iTime)/desity_;
  d = abs(d);
  d = _brightness / d;
  
  colP *= d;


  float _a = max(sign( fragColor.r + fragColor.g + fragColor.b - 0.0), 0.0);
  
  colP.rgb = colP.rgb * fragColor.a;
  colP2 = (colP.rgb + 0.8) * fragColor.rgb;

  mixColor.rgb = max( colP2.rgb, fragColor.rgb);
  mixColor.a = fragColor.a;

  //----------------------------------------------
  //mixColor = vec4( fragCoord.x, fragCoord.y, 1., 1);


  return CoronaColorScale( mixColor );
}
]]

return kernel

--[[

--]]


