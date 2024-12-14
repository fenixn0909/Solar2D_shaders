
--[[
    https://godotshaders.com/shader/noise-offset-wiggle/
    nuzcraft
    October 26, 2023

    ✳️ Great for Wind / Water Flow ✳️

]]

local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "wobble"
kernel.name = "noiseOffset"

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

uniform sampler2D SCREEN_TEXTURE; 
uniform sampler2D NOISE_TEXTURE; 

uniform float strength = 1.4;       //: hint_range(0.0, 5, 0.1) 
uniform float uv_scaling = 1.0;     //: hint_range (0.0, 1.0, 0.05) 
uniform vec2 movement_direction = vec2(0, 1); // 
uniform float movement_speed = 0.5; //: hint_range (0.0, 0.5, 0.01) 

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed
P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;

P_COLOR vec4 FragmentKernel( P_UV vec2 SCREEN_UV )
{

    //----------------------------------------------
    vec2 uv = SCREEN_UV;
    vec4 screen_texture = texture2D(SCREEN_TEXTURE, uv);
    vec2 movement_factor = movement_direction * movement_speed * TIME;
    float noise_value = texture2D(NOISE_TEXTURE, uv*uv_scaling + movement_factor).r - 0.5;
    uv += noise_value * SCREEN_PIXEL_SIZE * strength;
    COLOR = texture2D(SCREEN_TEXTURE, uv);
  

    //----------------------------------------------

    return CoronaColorScale(COLOR);
}
]]

return kernel

