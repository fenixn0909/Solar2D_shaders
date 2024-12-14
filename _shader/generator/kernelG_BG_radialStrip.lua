
--[[
  https://godotshaders.com/shader/rotating-radial-stripes/
  fruityfred
  November 8, 2024
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "radialStripe"

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

//----------------------------------------------

uniform vec2 center = vec2(0.5);
uniform int stripes = 24;
uniform float speed = 0.2; // : hint_range(0.0, 5.0, 0.1)
uniform int direction = 1; // : hint_range(-1, 1, 2)
uniform vec3 color_modifier = vec3(0.9);

//----------------------------------------------

P_COLOR vec4 COLOR = vec4(0.9, 0.6, 0.5, 1.0);
P_DEFAULT float TIME = CoronaTotalTime;

const float TAU =  6.283185307179586;

//----------------------------------------------


//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------

  // Fix aspect ratio issue.
  //vec2 uv_deriv = fwidthFine(UV);
  vec2 uv_deriv = abs(dFdx(UV)) + abs(dFdy(UV));
  float aspect_ratio = uv_deriv.y / uv_deriv.x;
  vec2 corrected_uv = UV * vec2(aspect_ratio, 1.0);
  vec2 corrected_center = center * vec2(aspect_ratio, 1.0);
  
  // Get the angle between the center of the effect and the UV.
  vec2 dir = corrected_center - corrected_uv;
  float angle = atan(dir.y, dir.x) - (TIME * speed * float(direction));
  // Check if the angle is in a stripe or not.
  if (mod(floor(angle / (TAU / float(stripes))), 2) == 0.0) {
    // If yes, apply the modifier to the pixel.
    COLOR.rgb *= color_modifier;
  }

  //----------------------------------------------


  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


