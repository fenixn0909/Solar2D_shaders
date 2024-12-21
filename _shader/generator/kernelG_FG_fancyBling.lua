
--[[
    Shader Art Coding Introduction
    https://www.shadertoy.com/view/mtyGWy
    https://youtu.be/f4s1h2YETNY

    Created by kishimisu in 2023-05-20

    #OVERHEAD: crank the var up too much will cause overhead!

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FG"
kernel.name = "fancyBling"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",                 default = 3, min = 0, max = 15, index = 0, },
  { name = "Scale",                 default = 1, min = 0, max = 8, index = 1, },
  { name = "Bright",                default = 1, min = 0.1, max = 10, index = 2, },
  { name = "Steps",--[[#OVERHEAD]]  default = 4, min = 1, max = 20, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Scale = CoronaVertexUserData.y;
float Bright = CoronaVertexUserData.z;
float Steps = CoronaVertexUserData.w;

//----------------------------------------------

vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );
}

// -----------------------------------------------

P_COLOR vec4 COLOR;
float iTime = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  vec2 ratio = vec2(1,1);
  vec2 uv = (UV * 2.0 - ratio.xy) / ratio.y * Scale;
  vec2 uv0 = uv;
  vec3 finalColor = vec3(0.0);
  
  for (float i = 0.0; i < Steps; i++) {
      uv = fract(uv * 1.5) - 0.5;

      float d = length(uv) * exp(-length(uv0));

      vec3 col = palette(length(uv0) + i*.4 + iTime*.4  * Speed);

      d = sin(d*8. + iTime)/8.;
      d = abs(d);

      d = pow( Bright * 0.01 / d, 1.2);

      finalColor += col * d;
  }

  float _cChk =  finalColor.r + finalColor.g + finalColor.b;
  //float _a = max(sign(_cChk - 0.5), 0.0)-0.2;
  float _a = max(sign(_cChk - 3), 0.0);
  
  COLOR = vec4( finalColor, _a );
  //COLOR = vec4( finalColor.rgb * COLOR.rgb, _a );

  //----------------------------------------------
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


