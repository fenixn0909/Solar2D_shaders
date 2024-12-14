
--[[
    https://godotshaders.com/shader/topdown-game-2d-cloud-shader/
    Jams
    September 7, 2024

    ✳️ use ShapeTexture to clamp the clouds ✳️

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
    name = "density",
    default = 0.5,
    min = 0,
    max = 3,
    index = 0, 
  },
  {
    name = "speedX",
    default = .1,
    min = -10,
    max = 10,
    index = 1, 
  },
  {
    name = "speedY",
    default = .05,
    min = -10,
    max = 10,
    index = 2, 
  },
}


kernel.fragment =
[[
uniform sampler2D ShapeTexture; //: repeat_enable, filter_nearest;

float density = CoronaVertexUserData.x;
float speedX = CoronaVertexUserData.y;
float speedY = CoronaVertexUserData.z;

//uniform float density = 1.25; //: hint_range(0.0, 1.0)
//uniform vec2 speed = vec2(1.02, 1.01);

//----------------------------------------------

  P_COLOR vec4 COLOR;
  P_DEFAULT float TIME = CoronaTotalTime;


// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    P_COLOR vec4 COLOR = texture2D( ShapeTexture, UV);
    //----------------------------------------------
    vec2 uv = UV + vec2( speedX, speedY) * TIME;
    
    float noise = texture2D( CoronaSampler1, uv).r;
    float fog = clamp(noise * 2.0 - 1.0, 0.0, 1.0);
    COLOR.a *= fog * density;
    COLOR.rgb += fog * density;
    
    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


