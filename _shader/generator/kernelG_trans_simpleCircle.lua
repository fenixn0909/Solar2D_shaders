
--[[
  Origin Author: agurkas
  https://godotshaders.com/author/agurkas/
  
  This is a simple shader for a circle transition. It expects screen width and screen height in pixels and knowing those it always produces a perfect circle in the center of a rect.

  For the best result, have a script that sets the screen_width and screen_height uniforms  in _ready() of a script to the rect_size of a ColorRect. This way the screen_width and screen_height will always be automatically set to correct size.
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "simpleCircle"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "texWidth",
    default = 64,
    min = 1,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "texHeight",
    default = 64,
    min = 1,
    max = 9999,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
}


kernel.fragment =
[[

//render_mode unshaded;

float circle_size = 0.1 ; //: hint_range(0.0, 1.05)
//float texWidth = 256.0;
//float texHeight = 256.0;

P_DEFAULT float texWidth = CoronaVertexUserData.x;
P_DEFAULT float texHeight = CoronaVertexUserData.y;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  //Test
  circle_size = sin(CoronaTotalTime*1);

  float ratio = texWidth / texHeight;
  float dist = distance(vec2(0.5, 0.5), vec2(mix(0.5, texCoord.x, ratio), texCoord.y));
  P_COLOR vec4 COLOR = vec4(1,0,0,1);
  COLOR.a = step(circle_size, dist);
  COLOR.rgb *= COLOR.a;
  

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


