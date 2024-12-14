--[[
  2D Sprite “Cartridge Tilting Glitch”

  Origin Author: sashatouille
  https://godotshaders.com/author/sashatouille/


  A small shader that can be attached to a sprite. 
  This shader will allow you to simulate the graphical glitches that we could see on the old consoles when we touched the cartridge in the middle of a game!
  Works event better with a sprite sheet animated sprite (see screenshots).

  

--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "glitchVHS"
kernel.isTimeDependent = true


kernel.vertexData   = {
  {
    name    = "r",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
    },{
    name    = "g",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 1,
    },{
    name    = "b",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 1,
    min     = 0,
    max     = 4,
    index   = 3,
  },
}
kernel.fragment = 
[[
uniform float range = 0.075; //: hint_range(0.0, 0.1, 0.005)
uniform float noiseQuality = 250.0; //: hint_range(0.0, 300.0, 0.1)
uniform float noiseIntensity = 0.0188; //: hint_range(-0.6, 0.6, 0.0010)
uniform float offsetIntensity = .03; //: hint_range(-0.1, 0.1, 0.001)
uniform float colorOffsetIntensity  = 3.3; //: hint_range(0.0, 5.0, 0.001)

const float saturation = 0.2;

//----------------------------------------------

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float UVY, float offset)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, UVY) * offset;
    x -= smoothstep(pos, edge1, UVY) * offset;
    return x;
}

//----------------------------------------------

P_DEFAULT float TIME = CoronaTotalTime;
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
    //----------------------------------------------

  vec2 uv = UV;
    for (float i = 0.0; i < 0.71; i += 0.1313)
    {
        float d = mod(TIME * i, 1.7);
        float o = sin(1.0 - tan(TIME * 0.24 * i));
        o *= offsetIntensity;
        uv.x += verticalBar(d, UV.y, o);
    }
    
    float UVY = uv.y;
    UVY *= noiseQuality;
    UVY = float(int(UVY)) * (1.0 / noiseQuality);
    float noise = rand(vec2(TIME * 0.00001, UVY));
    uv.x += noise * noiseIntensity;

    vec2 offsetR = vec2(0.009 * sin(TIME), 0.0) * colorOffsetIntensity;
    vec2 offsetG = vec2(0.0073 * (cos(TIME * 0.97)), 0.0) * colorOffsetIntensity;
    
    float r = texture2D( CoronaSampler0, uv + offsetR).r;
    float g = texture2D( CoronaSampler0, uv + offsetG).g;
    float b = texture2D( CoronaSampler0, uv).b;
    float a = texture2D( CoronaSampler0, uv).a;
    vec4 tex = vec4(r, g, b, a);
    COLOR = tex;
    //----------------------------------------------

    return CoronaColorScale(COLOR);
}

]]
return kernel

--[[



--]]