
--[[
  Origin Author: alxl
  https://godotshaders.com/author/alxl/
  
  A fairly self-explanatory shader for animated stripes. 
  Shader params allow you to adjust the color, speed, and angle of the stripes, as well as the width of the stripes and the gaps between them.

  Increase divisions to get more stripes. 
  Increase stripe_bias to make the stripes thicker than the gaps between them. Note that angle is in radians
  


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "stripes"

kernel.isTimeDependent = true


kernel.vertexData =
{
  { name = "Speed",           default = 4.5, min = 0, max = 50, index = 0, },
  { name = "Angle",           default = 45, min = 0, max = 180, index = 1, },
  { name = "Divisions",       default = 8.0, min = 0, max = 100, index = 2, },
  { name = "Stripe_Bias",     default = 1.95, min = 1, max = 20, index = 3, },
} 

kernel.vertex =
[[
varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;

P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{ 
  slot_size = vec2( u_TexelSize.z, u_TexelSize.w ) * v_UserData.x; // multiply textureRatio to get matching UV of palette.
  sample_uv_offset = ( slot_size * 0.5 );
  return position;
}
]]

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Angle = CoronaVertexUserData.y;
float Divisions = CoronaVertexUserData.z;
float Stripe_Bias = CoronaVertexUserData.w;

//----------------------------------------------

float Radians = radians( Angle );

P_COLOR vec4 Col_Gap = vec4(0.25, 0.25, 0.25, .50); //: hint_color 
P_COLOR vec4 Col_Stripe = vec4(1.0, 0.75, 0.0, 1.0);//: hint_color 

//----------------------------------------------
P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  float w = cos(Radians) * texCoord.x + sin(Radians) * texCoord.y - Speed * 0.1 * TIME;
  
  if (floor(mod(w * Divisions, Stripe_Bias)) < 0.0001) {
    COLOR = Col_Gap;
  } else {
    COLOR = Col_Stripe;
  }
  
  return CoronaColorScale(COLOR);
}
]]

return kernel


