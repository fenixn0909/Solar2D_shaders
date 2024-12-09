
--[[
    https://godotshaders.com/shader/vertical-drops/
    FencerDevLog
    September 16, 2024

    Great for rain, snow, fireflies

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FG"
kernel.name = "verticleDrop"


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

uniform vec3 color = vec3(0.5, 0.7, .9); // : source_color 
uniform float speed = 1.1; //: hint_range(0.01, 10.0, 0.01)
uniform float density = 100.0; //: hint_range(1.0, 500.0, 1.0)
uniform float compression = 3.2; //: hint_range(0.1, 1.0, 0.01) 
uniform float trail_size = 350.0; //: hint_range(5.0, 100.0, 0.1) // Larger => Smaller
uniform float brightness = 100.5; //: hint_range(0.1, 10.0, 0.1)

float PI = 3.14159265359;


// -----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  P_COLOR vec4 COLOR;
  
  P_DEFAULT float TIME = CoronaTotalTime;
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  
  vec2 uv = -UV;
  float time = TIME * speed;
  uv.x *= density;
  vec2 duv = vec2(floor(uv.x), uv.y) * compression;
  float offset = sin(duv.x);
  float fall = cos(duv.x * 30.0);
  float trail = mix(100.0, trail_size, fall);
  float drop = fract(duv.y + time * fall + offset) * trail;
  drop = 1.0 / drop;
  drop = smoothstep(0.0, 1.0, drop * drop);
  drop = sin(drop * PI) * fall * brightness;
  float shape = sin(fract(uv.x) * PI);
  drop *= shape * shape;
  COLOR = vec4(color * drop, 0.0);
  //----------------------------------------------
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    
--]]


