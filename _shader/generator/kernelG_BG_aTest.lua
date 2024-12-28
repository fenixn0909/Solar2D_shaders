
--[[
    
    Test

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "aTest"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Progress",    default = .5, min = 0, max = 1, index = 0, },
  { name = "Prog_Factor",     default = .5, min = -1.5, max = 1.5, index = 1, },
  { name = "SkewY",     default = .5, min = -10, max = 10, index = 2, },
  { name = "OffsetX",    default =  .75, min = -10, max = 10, index = 3, },
} 


kernel.fragment =
[[
float Progress = CoronaVertexUserData.x;
float Prog_Factor = CoronaVertexUserData.y;
float SkewY = CoronaVertexUserData.z;
float OffsetX = CoronaVertexUserData.w;

//----------------------------------------------

vec4 Col_1 = vec4(0.8, 0.8, 0.8, 1.0); // Light gray
vec4 Col_2 = vec4(0.4, 0.4, 0.4, 1.0); // Dark gray


//-----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------
  
    //COLOR = vec4( step( 0.5, UV.x * UV.x ) );
    //COLOR = vec4( step( 0.1, abs( UV.x - UV.y ) ) );
    //COLOR = vec4( step( 0.1, abs( UV.x - UV.y ) ) );
    
    //COLOR = vec4( smoothstep( -0, 1, UV.x/UV.y  ) );
    //COLOR = vec4( smoothstep( 1, -1.5, abs( UV.x - UV.y )  ) );
    
    //COLOR = vec4( smoothstep( 0, Progress, abs( UV.x - UV.y )  ) );
    
    float progress = (Progress - Prog_Factor) * 2.5;
    COLOR = vec4( smoothstep( Prog_Factor, progress, abs( OffsetX - UV.x - UV.y*SkewY  )  ) );


    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


