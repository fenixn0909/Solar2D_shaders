
--[[
    https://godotshaders.com/shader/colorful-signal-effect/
    LoganB September 4, 2023
    A colorful signal effect for 2D games.
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FG"
kernel.name = "signalRipple"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",           default = 5, min = -30, max = 30, index = 0, },
  { name = "Size",           default = 0.8, min = 0, max = 20, index = 1, },
  { name = "Zoom",          default = 8., min = -150, max = 150, index = 2, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Size = CoronaVertexUserData.y;
float Zoom = CoronaVertexUserData.z;
//----------------------------------------------

uniform vec4 color_signal = vec4 (0.3, 0.1, 0.0, 0.2); // : hint_color 

// -----------------------------------------------

P_COLOR vec4 fragColor;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------
  
  float d = length((UV-0.5)*2.0);
  float t = pow(smoothstep(0.9,0.2,d),0.35);
  
  // For rainbow effect, keep this line :
  vec3 rainbow = 0.5 + 0.5*cos(TIME+UV.xyx+vec3(0,2,4));
  vec4 color = vec4(rainbow.rgb,1.0);
  
  // For idle color, delete "//" below :
  color = vec4(color_signal.rgb,1.0);

  d = sin(Zoom*d - Speed*TIME);
  d = abs(d);
  d = Size/d;
  color *= d*t;
  
  fragColor = vec4(color);
  
  //----------------------------------------------

  return CoronaColorScale( fragColor );
}
]]

return kernel

--[[
    
--]]


