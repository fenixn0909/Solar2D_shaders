
--[[
  Origin Author: camixes
  https://godotshaders.com/author/camixes/
  
  Message:
  this is my first shader!
  I was messing around with some trigonometry functions and some other functions and accidentally made this effect. 
  

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "spots"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "textureRatio",
    default = 1,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "paletteRowCols",
    default = 4,
    min = 1,
    max = 16,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
}


kernel.fragment =
[[

float Speed = 1.0; // movement speed

float Intensity = 2.0; // higher numbers add a second color
float Hardness = 500.0; // circle sizes
vec2 Scale = vec2(1.0,1.0); // scale
float RotationSpeed = 1.0; // rotation speed
vec3 Color = vec3(1.0,0.0,0.0); //attempt at color changing, doesn't really work, only barely noticeable when hardness is at 1f

// one thing that may happen is that the second color may match your theme for some reason, 
// but it should go back to being black when running the game.

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  float TIME = CoronaTotalTime;

  float coolEffect = pow(sin((sin(UV.x*(100.0)*Scale.x)*cos(UV.y*(100.0*Scale.y)))+(sin(UV.x+TIME*RotationSpeed)+cos(UV.y+TIME*RotationSpeed))+TIME*Speed)*Intensity,Hardness);

  vec4 offsetColor = vec4( Color.r, Color.g, Color.b, coolEffect);
  P_COLOR vec4 COLOR = offsetColor;
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[


--]]


