
--[[
    https://godotshaders.com/shader/topdown-game-2d-cloud-shader/
    Jams
    September 7, 2024

    ✳️ NOT WORKING! ✳️

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "FG"
kernel.name = "topdownCloud2D"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.fragment =
[[


uniform sampler2D Text_BG; //: repeat_enable, filter_nearest;
uniform sampler2D Texture_Noise; //: repeat_enable, filter_nearest;
uniform float density = 1.25; //: hint_range(0.0, 1.0)
uniform vec2 speed = vec2(1.02, 1.01);

//----------------------------------------------

  P_COLOR vec4 COLOR;
  P_DEFAULT float TIME = CoronaTotalTime;


// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //P_COLOR vec4 COLOR = texture2D( Text_BG, UV);
    //----------------------------------------------
    vec2 uv = UV + speed * TIME;
    float noise = texture2D( Texture_Noise, uv).r;
    float fog = clamp(noise * 2.0 - 1.0, 0.0, 1.0);
    COLOR.a *= fog * density;

    //----------------------------------------------
    // Transparent Filter
    COLOR.a = max(sign(0.2 - (COLOR.r + COLOR.g + COLOR.b)), 0.0);
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


