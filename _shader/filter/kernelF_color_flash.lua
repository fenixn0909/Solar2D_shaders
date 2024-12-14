
--[[
  Origin Author: lurgx
  https://godotshaders.com/author/lurgx/

  Flash for Sprite node or Animated Sprite

  A flash that can be used to hit the player or to announce that he is low on health can also be used on a large boss to announce that he is about to die.

  It’s my second shader I’m learning little by little

  I hope to improve it a bit later

  Greetings to all!
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "flash"
kernel.isTimeDependent = true



kernel.vertex =
[[
P_DEFAULT float u_time = 1.0;
P_DEFAULT float side = 0.9;
P_DEFAULT float up = 0.1;
bool move = true;

P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{ 
  P_POSITION vec2 vertex = position;
  if (move == true){
    vertex += vec2(cos(CoronaTotalTime*u_time)*side,cos(CoronaTotalTime*u_time)*up);
  }
  return position;
  //return vertex;
}
]]

kernel.fragment =
[[

bool shine = true;
P_DEFAULT float u_time = 1.0; //: hint_range (0.,10.)
P_COLOR vec4 color = vec4(1.0, 0, 0, 1);//: hint_color;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 finColor;
  if (shine == true){
    finColor = texture2D(CoronaSampler0, texCoord);
    finColor.rgb += vec3(color.r,color.g,color.b)*(abs(cos(CoronaTotalTime*u_time))) * finColor.a;    
  }

  return finColor;
}
]]

return kernel

