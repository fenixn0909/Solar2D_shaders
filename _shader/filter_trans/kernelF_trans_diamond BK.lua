
--[[
  Origin Author: mackatap
  https://godotshaders.com/author/mackatap/
  
  A transition shader drawn from this article by Timm[ie] Wong @DDRKirbyISQ. Permission was given by this individual for this post. The article explains more in depth and similar versions of this shader. Animating the shader parameter “progress” creates the transition effect. I have found that a tween using trans_cubic and ease_out looks pretty nice. Changing the final line from > to < will reverse the transition effect.

  tween.interpolate_property(mymaterial, “shader_param/progress”, 1, 0, 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT) 

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "diamondBK"

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

// Ranges from 0 to 1 over the course of the transition.
// We use this to actually animate the shader.
float progress; //: hint_range(0, 1)

// Size of each diamond, in pixels.
float diamondPixelSize = 0.01; //10f


float when_lt(float x, float y) {
  return max(sign(y - x), 0.0);
}



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  //FRAGCOORD Snippet
  P_UV vec2 sample_uv_offset = ( u_TexelSize.zw * 0.5 );
  P_UV vec2 uv_frag = ( sample_uv_offset + ( floor( texCoord / u_TexelSize.zw ) * u_TexelSize.zw ) );
  P_COLOR vec4 texColor = texture2D( CoronaSampler0, texCoord);

  progress = mod( CoronaTotalTime * 0.25, 1) ;

  float xFraction = fract(uv_frag.x / diamondPixelSize);
  float yFraction = fract(uv_frag.y / diamondPixelSize);
  float xDistance = abs(xFraction - 0.5);
  float yDistance = abs(yFraction - 0.5);
  if (xDistance + yDistance + texCoord.x + texCoord.y > progress * 4) {
    discard;
  }

  return CoronaColorScale(texColor);
}
]]

return kernel

--[[

--]]


