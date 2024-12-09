
--[[
  Origin Author: QueenOfSquiggles
  https://godotshaders.com/shader/fnaf-faked-3d-displacement-shader/
  

  I’ve seen several posts on the godot subreddit asking how to create the fake 3D effect from the Five Nights At Freddy’s series. I was a bit curious about how to do this and did a bit of digging. (Sources linked at bottom)

  Simply, it works using a “Displacement Map”, which is basically a texture where each pixel is a greyscale value from 0.0 to 1.0 for how much to displace that pixel. I highly recommend using a CurveTexture which will let you manipulate the rate of distortion at the edges more easily.

  The `scroll` uniform allows you to scroll to the left or right. Setting up a system in the code lets you “look” left and right in the fake 3D space.

  This system seems to work with the source FNAF texture as well as some HDRIs downloaded from ambientcg. Feel free to remix if you feel like it could be improved! <3

  If you happen to use this to make something cool, I’d love to see it! (@OfSquiggles on twitter)

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "deform"
kernel.name = "fake3d"

--Test
kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name = "texDiffRatioX",
    default = 1,
    min = 0,
    max = 32,  
    index = 0,    
  },
  {
    name = "texDiffRatioY",
    default = 1,
    min = 0,
    max = 32,  
    index = 1,    
  },
  
}


kernel.fragment =
[[
vec2 texDiffRatio = vec2( CoronaVertexUserData.x, CoronaVertexUserData.y );

//----------------------------------------------

// the left/right look amount. Ideally clamp this externally to prevent viewing edges
float scroll = 0.0;

// keep positive to maintain pseudo3D effect.
uniform float displacement_scale = 1.0;

// easiest to just make this a curve texture, but making PNG gives a ton of control across the Y axis. Curve texture is just super smooth and doesn't have any issues with tearing.
//uniform sampler2D displacement_map : hint_black;


//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_UV vec2 uvTex = UV * texDiffRatio;

  P_COLOR vec4 COLOR;
  scroll = sin(CoronaTotalTime) * 0.1;
  //----------------------------------------------
  // Scale
  float _scale = 0.5;
  vec2 uv = (UV - 0.5) * _scale + 0.5;

  uv = uv + vec2(scroll, 0.0); // scroll the UV
  float displacement = texture2D(CoronaSampler1, uvTex).r; // pull amount from map
  displacement *= displacement_scale; // scale
  displacement *= (0.5 - uv.y); // transform based on distance from center horizontal
  COLOR = texture2D(CoronaSampler0, uv + vec2(0.0, displacement));// pull source image, displaced by scroll and vertical stretch.
  
  
  //COLOR = texture2D(CoronaSampler0, uv );// pull source image, displaced by scroll and vertical stretch.
  
  //----------------------------------------------
  
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


