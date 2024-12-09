
--[[
    https://godotshaders.com/shader/screen-shake/
    Near
    November 26, 2023

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "wobble"
kernel.name = "shake"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = 'strength',
    default = 0.0,
    min = 0,
    max = 10,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  
}


kernel.fragment =
[[

float strength = CoronaVertexUserData.x;
uniform vec2 FactorA  = vec2(100.0,100.0);
uniform vec2 FactorB  = vec2(1.0,1.0);
uniform vec2 magnitude = vec2(0.01,0.01);

//----------------------------------------------

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{


    //----------------------------------------------

    vec2 uv = UV;
    uv -= 0.5;
    uv *= 1.0 - 2.0 * magnitude.x;
    uv += 0.5;
    vec2 dt = vec2(0.0, 0.0);
    dt.x = sin(TIME * FactorA.x + FactorB.x) * magnitude.x;
    dt.y = cos(TIME * FactorA.y + FactorB.y) * magnitude.y;
    COLOR = texture2D( CoronaSampler0,uv + (dt* strength));

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


