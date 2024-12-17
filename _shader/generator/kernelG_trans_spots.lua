
--[[
    Origin Author: camixes
    https://godotshaders.com/author/camixes/

    Find and go #VARIATION and tweak them for different patterns

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "spots"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",           default = 1.0, min = -10, max = 10, index = 0, },
  { name = "Intensity",       default = 2, min = -20, max = 20, index = 1, },
  { name = "Hardness",        default = 500, min = -1000, max = 1000, index = 2, },
  { name = "RotationSpeed",   default = 1.0, min = -100, max = 100, index = 3, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Intensity = CoronaVertexUserData.y;
float Hardness = CoronaVertexUserData.z;
float RotationSpeed = CoronaVertexUserData.w;
//----------------------------------------------
vec2 Scale = vec2(1.0,1.0); // scale
vec3 Col_Dot = vec3( 1.0, 0.0, 0.0 ); //attempt at color changing, doesn't really work, only barely noticeable when hardness is at 1f

// one thing that may happen is that the second color may match your theme for some reason, 
// but it should go back to being black when running the game.
//----------------------------------------------

float TIME = CoronaTotalTime;
P_COLOR vec4 COLOR;
  
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    float coolEffect = pow(sin((sin(UV.x*(100.0)*Scale.x)*cos(UV.y*(100.0*Scale.y)))+(sin(UV.x+TIME*RotationSpeed)+cos(UV.y+TIME*RotationSpeed))+TIME*Speed)*Intensity,Hardness);
    vec4 offsetColor = vec4(coolEffect+Col_Dot.r,coolEffect+Col_Dot.g,coolEffect+Col_Dot.b, coolEffect);
    COLOR = offsetColor;
    
    //----------------------------------------------
    // Single Color   #VARIATION
    //COLOR = vec4( Col_Dot.r, Col_Dot.g, Col_Dot.b, coolEffect);
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[


--]]


