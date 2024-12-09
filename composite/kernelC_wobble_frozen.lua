
--[[
    
--]]




local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "wobble"
kernel.name = "frozen" -- Or Liquid?

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

float strength = 0.05;    //Force of the effect
float speed = 1;       //Speed of the effect
int frames = 10; //: hint_range(1, 9999)  Frames of the effect

//Returns a value between 0 and 1 depending of the frames -> exemple: frames = 4, frame 1 = 0.25
float clock(float time){
  float fframes = float(frames);
  return floor(mod(time * speed, fframes)) / fframes;
}

float rand (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  float c = clock(CoronaTotalTime); //Get clock frame
  
  //Random Offset
  //vec2 randSeed = vec2(0.001,0.001) * sin(CoronaTotalTime)*0.1;
  vec2 randSeed = vec2(0.001,0.001) - 0.25;
  //P_RANDOM float c = rand(randSeed) -0.5; //Get random frame
  P_RANDOM float offRnd = rand(randSeed);


  //Best if offset translate around circle
  float speed2 = 500;
  float degree = CoronaTotalTime*speed2; //mod( CoronaTotalTime*speed2, 360.0 );
  float AM = 0.01;
  float offX = sin(radians(degree)) * AM + offRnd;
  float offY = cos(radians(degree)) * AM + offRnd;

  vec4 offset = texture2D(CoronaSampler1, vec2(UV.x + offX, UV.y + offY)) * strength; //Get offset 
  //vec4 offset = texture2D(CoronaSampler1, vec2(UV.x + c, UV.y + c)) * strength; //Get offset 
  //COLOR = texture2D(CoronaSampler0, vec2(UV.x,UV.y) + normal.xy); //Apply offset
  //P_COLOR vec4 COLOR = texture2D(CoronaSampler0, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*strength); //We need to remove the displacement 
  P_COLOR vec4 COLOR = texture2D(CoronaSampler0, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*strength); //We need to remove the displacement 
  
  //Test
  //float c2 = clock(CoronaTotalTime);
  //COLOR = vec4( c2, c2, c2, 1);

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[
  void fragment(){
    float c = clock(TIME);
    COLOR = vec4( c, c, c, 1);
  }
--]]
