
--[[
  Origin Author: mackatap
  https://godotshaders.com/author/mackatap/
  
  A transition shader drawn from this* article by Timm[ie] Wong @DDRKirbyISQ. Permission was given by this individual for this post. The article explains more in depth and similar versions of this shader. Animating the shader parameter “progress” creates the transition effect. I have found that a tween using trans_cubic and ease_out looks pretty nice. Changing the final line from > to < will reverse the transition effect.
  
  *this: https://ddrkirby.com/articles/shader-based-transitions/shader-based-transitions.html

  tween.interpolate_property(mymaterial, “shader_param/progress”, 1, 0, 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT) 

  // Using texCoord for HQ, fragCoord for pixel
  // Using Texture or just colorPlane


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "diamond"

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
float diamondPixelSize = 0.3; //10f


float when_lt(float x, float y) {
  return max(sign(y - x), 0.0);
}



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  //FRAGCOORD Snippet
  P_UV vec2 texelOffset = ( u_TexelSize.zw * 0.5 );
  P_UV vec2 fragCoord = ( texelOffset + ( floor( texCoord / u_TexelSize.zw ) * u_TexelSize.zw ) );
  
  //Using texCoord for HQ, fragCoord for pixel
  float xFraction = fract(texCoord.x / diamondPixelSize);
  float yFraction = fract(texCoord.y / diamondPixelSize);
  
  progress = mod( CoronaTotalTime * 0.5, 1) ; //Reveal Scene

  float xDistance = abs(xFraction - 0.5);
  float yDistance = abs(yFraction - 0.5);

  P_COLOR vec4 texColor = vec4(1.,0,0,1);
  texColor.a *=  when_lt(xDistance + yDistance + texCoord.x + texCoord.y, progress * 4.0);
  texColor.rgb *= texColor.a;
  P_COLOR vec4 finColor = texture2D( CoronaSampler0, texCoord);

  return CoronaColorScale(texColor);
}
]]

return kernel

--[[

--]]


