
--[[
  Origin Author: mackatap
  https://godotshaders.com/shader/diamond-based-screen-transition/
  
  A transition shader drawn from this* article by Timm[ie] Wong @DDRKirbyISQ. Permission was given by this individual for this post. The article explains more in depth and similar versions of this shader. Animating the shader parameter “progress” creates the transition effect. I have found that a tween using trans_cubic and ease_out looks pretty nice. Changing the final line from > to < will reverse the transition effect.
  
  *this: https://ddrkirby.com/articles/shader-based-transitions/shader-based-transitions.html

  tween.interpolate_property(mymaterial, “shader_param/progress”, 1, 0, 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT) 

  // Using texCoord for HQ, fragCoord for pixel
  // Using Texture or just plain color
  

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "diamond"

kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "pixelSize",
    default = 25,
    min = 5,
    max = 250,
    index = 1, 
  },
}


kernel.fragment =
[[

float progress = CoronaVertexUserData.x;
float diamondPixelSize = CoronaVertexUserData.y;

P_COLOR vec4 Col_Plain = vec4( 1.0, 0.0, 0.0, 1.0);

//----------------------------------------------

float when_lt(float x, float y) { return max(sign(y - x), 0.0); }

//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;
    P_UV vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
    P_UV vec2 FRAGCOORD = UV * iResolution;

    P_COLOR vec4 COLOR = Col_Plain;
    //----------------------------------------------

    float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
    float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
    float xDistance = abs(xFraction - 0.5);
    float yDistance = abs(yFraction - 0.5);

    COLOR.a *=  when_lt(xDistance + yDistance + UV.x + UV.y, progress * 4.0);
    COLOR.rgb *= COLOR.a;

    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


