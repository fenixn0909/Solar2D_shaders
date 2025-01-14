
--[[
    Origin Author: roughskin
    https://godotshaders.com/author/roughskin/
    
    #VARIATION: Goto the tag and tweak them for different patterns
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "wobble"
kernel.name = "twitch"

kernel.isTimeDependent = true


kernel.vertexData =
{
  { name = "Speed",     default = 1, min = 0, max = 100, index = 0, },
  { name = "Strength",  default =  .03, min = 0, max = .1, index = 1, },
  { name = "Frames",    default = 10, min = 0, max = 100, index = 2, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Strength = CoronaVertexUserData.y;
float Frames = int( CoronaVertexUserData.z );    // vec2(0,0.2): rise, vec2(1,-.1): left lines

//sampler2D flowMap; // use CoronaSampler1,  Displacement map

//----------------------------------------------

//Returns a value between 0 and 1 depending of the frames -> exemple: frames = 4, frame 1 = 0.25
float clock(float time){
  return floor(mod(time, Frames)) / Frames;
}

float rand (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    float tmClock = clock( CoronaTotalTime * Speed ); //Get clock frame

    //Random Offset
    vec2 randSeed = UV + CoronaTotalTime;
    P_RANDOM float offRnd = rand(randSeed) - 0.5;


    //Best if offset translate around circle
    float timeMult = 10000 * tmClock * Speed;
    float degree = CoronaTotalTime * timeMult; 
    float AM = 1.1;
    
    //=== #VARIATION Pattern 1
    float offX = sin(radians(degree)) * AM + offRnd;
    float offY = cos(radians(degree)) * AM + offRnd;
    
    //=== #VARIATION Pattern 2
    //float offX = offRnd * AM;
    //float offY = offRnd * AM;
    
    //=== #VARIATION Pattern 3
    //float offX = sin(radians(degree)) * offRnd ;
    //float offY = cos(radians(degree)) * offRnd * AM;

    vec4 offset = texture2D(CoronaSampler1, vec2(UV.x + offX, UV.y + offY)) * Strength; //Get offset 
    P_COLOR vec4 COLOR = texture2D(CoronaSampler0, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*Strength); //We need to remove the displacement 
    //----------------------------------------------

    return CoronaColorScale(COLOR);
}
]]

return kernel
