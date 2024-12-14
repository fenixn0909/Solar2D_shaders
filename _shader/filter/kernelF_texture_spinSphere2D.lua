
--[[
  Origin Author: alxl
  https://godotshaders.com/author/alxl/
  
  A simple shader that makes a 2D canvas item look like a spinning sphere. 
  Make sure to set the “Repeat” import flag for your texture!

  In the first example (the animation below), 
  I used a sprite with a 2D image supplied by Solar System Scope to create a spinning Earth.

  In the second example, I used two more sprites, both with a 2D cloud texture also provided by Solar System Scope. 
  One has the as_shadow shader param set to true, which creates dark, somewhat transparent shapes on the Earth. 
  The non-shadow cloud sprite is scaled slightly larger than the other two sprites, so that the clouds float off the surface of the planet. 
  As an aside, simply adding a radial gradient behind the planet to create an atmospheric glow can really sell the effect.

  Note that the textures I used have an aspect ratio of 2:1. As such, the aspect_ratio shader param is set to 2.0. 
  Additionally, I had to set the sprite scales to match the aspect ratio (e.g. scale = Vector2(0.5, 1.0)) to prevent an oval-like shape.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "texture"
kernel.name = "spinSphere2D"
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

uniform P_DEFAULT vec4 u_resolution;

const P_DEFAULT float PI = 3.141593;

P_DEFAULT float aspect_ratio = 3.0;
P_DEFAULT float rotation_speed = 0.3;
bool as_shadow = false;



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV float px = 2.0 * (texCoord.x - 0.5);
  P_UV float py = 2.0 * (texCoord.y - 0.5);
  
  P_COLOR vec4 finColor;

  if (px * px + py * py > 1.0) {
    // Outside of "sphere"
    finColor.a = 0.0;
  } else {
    px = asin(px / sqrt(1.0 - py * py)) * 2.0 / PI;
    py = asin(py) * 2.0 / PI;
    
    finColor = texture2D(CoronaSampler0, vec2(
      0.5 * (px + 1.0) / aspect_ratio - CoronaTotalTime * rotation_speed,
      0.5 * (py + 1.0)));
    if (as_shadow) {
      finColor.rgb = vec3(0.0, 0.0, 0.0);
      finColor.a *= 0.9;
    }
  }

  return CoronaColorScale(finColor);
}
]]

return kernel


--[[


void fragment() {
  
}

--]]

