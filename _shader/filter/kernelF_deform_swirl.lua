
--[[
  Origin Author: casualgaragecoder
  https://godotshaders.com/author/casualgaragecoder/
  
  This simple shader allows swirling a sprite on itself. In its current state, it only works on stand-alone sprites. Don’t try to use an atlas with the rect selection.

  ratio : from 1 (unmodified) to 0 (totally folded)
  power : Speed of retraction. Determine at which pace the sprite will be disappearing to the center.
  min_speed : swirling speed at the border.
  max_speed : swirling speed near the center.

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "swirl"

--Test
kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  {
    name = "intensity",
    default = 0.65, 
    min = 0,
    max = 1,
    index = 0,  -- This corresponds to "CoronaVertexUserData.x"
  },
  {
    name = "size",
    default = 0.1, 
    min = 0,
    max = 1,
    index = 1,  -- This corresponds to "CoronaVertexUserData.y"
  },
  {
    name = "tilt",
    default = 0.2, 
    min = 0.0,
    max = 2.0,
    index = 2,  -- This corresponds to "CoronaVertexUserData.z"
  },
  {
    name = "speed",
    default = 1.0, 
    min = 0.1,
    max = 10.0,
    index = 3,  -- This corresponds to "CoronaVertexUserData.w"
  },
}


kernel.fragment =
[[


float ratio = 0.1; //: hint_range(0.0, 1.0) 
 
float power = 3.0;
 
float min_speed = 10.0;
 
float max_speed = 90.0;
 
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  vec2 uv = texCoord;
  
  uv *= 2.0;
  uv -= vec2(1.0);
  
  float len = length(uv);
  
  float rspeed = mix(max_speed, min_speed, len);
  
  //Test
  ratio = abs(sin(CoronaTotalTime * 0.5));

  float sinx = sin((1. - ratio) * rspeed);
  float cosx = cos((1. - ratio) * rspeed);
  
  vec2 trs = uv * mat2(vec2(cosx, sinx), vec2(-sinx, cosx));
  trs /= pow(ratio, power);
  
  trs += vec2(1.0);
  trs /= 2.;

  P_COLOR vec4 COLOR;
  if(trs.x > 1. || trs.x < 0. || trs.y > 1. || trs.y < 0.) {
      // Prevent sprite leaking.
      COLOR = vec4(0.);
  } else {
      vec4 col = texture2D(CoronaSampler0, trs);   
    COLOR = col;
  }

  return CoronaColorScale(COLOR);
}

]]

return kernel


--[[

--]]





