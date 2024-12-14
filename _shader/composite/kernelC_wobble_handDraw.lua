
--[[
  Origin Author: roughskin
  https://godotshaders.com/author/roughskin/

  Hi there,

  Here is a wobbly effect / hand painted animation for 2d sprites.

  Uniforms:

  flowMap: aka displacement map, adjust the movement of the sprite using normals.
  strenght: Force of the distortion from the displacement map.
  speed: Velocity of each frame.
  frames: How many frames should have the animation.
  Important note: It’s better to have a little transparent border in the image so that the effect can go outside the sprite. If not, the edges will be cut. (See screenshot with the normal logo vs logo with transparencies).

  Stay safe everyone!
--]]

--Or more generally for pixel i in a N wide texture the proper texture coordinate is
--(2i + 1)/(2N)



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "wobble"
kernel.name = "handDraw"

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

//sampler2D flowMap; // use CoronaSampler1,  Displacement map

float strength = 0.012;    //Force of the effect
float speed = 3;       //Speed of the effect
int frames = 30; //: hint_range(1, 9999)  Frames of the effect

//Returns a value between 0 and 1 depending of the frames -> exemple: frames = 4, frame 1 = 0.25
float clock(float time){
  float fframes = float(frames);
  return floor(mod(time * speed, fframes)) / fframes;
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  float c = clock(CoronaTotalTime*5); //Get clock frame
  
  vec4 offset = texture2D(CoronaSampler1, vec2(UV.x + c, UV.y + c) * 0.5) * strength; //Get offset 
  P_COLOR vec4 COLOR = texture2D(CoronaSampler0, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*strength); //We need to remove the displacement 
  
  return CoronaColorScale(COLOR);
}
]]

return kernel
