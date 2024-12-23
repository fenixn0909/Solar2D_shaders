
--[[
    https://godotshaders.com/shader/checkboard-pattern/
    FloodGate
    December 21, 2024


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "checkerboard"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "GridX",     default = 10, min = -20, max = 200, index = 0, },
  { name = "GridY",     default = 10, min = -20, max = 200, index = 1, },
  { name = "RatioX",    default = 1, min = -10, max = 100, index = 2, },
  { name = "RatioY",    default =  1.1, min = -10, max = 100, index = 3, },
} 


kernel.fragment =
[[
float GridX = CoronaVertexUserData.x;
float GridY = CoronaVertexUserData.y;
float RatioX = CoronaVertexUserData.z;
float RatioY = CoronaVertexUserData.w;

//----------------------------------------------

vec2 Grid_SizeUV = vec2( GridX, GridY ); // Size of the checkerboard squares
vec2 RatioUV = vec2( RatioX, RatioY ); // Default aspect ratio vector (to be updated by script)
vec4 Col_1 = vec4(0.8, 0.8, 0.8, 1.0); // Light gray
vec4 Col_2 = vec4(0.4, 0.4, 0.4, 1.0); // Dark gray


//-----------------------------------------------

P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------
  
    // Calculate the aspect ratio
    float aspect_ratio = RatioUV.x / RatioUV.y;

    // Adjust UV coordinates to preserve aspect ratio
    vec2 adjusted_uv = vec2(UV.x, UV.y * aspect_ratio);

    // Calculate the grid position based on the adjusted UV and grid size
    vec2 grid_pos = floor(adjusted_uv * Grid_SizeUV);

    // Use mod to alternate between Col_1 and Col_2
    float checker = mod(grid_pos.x + grid_pos.y, 2.0);

    // Assign the color based on the checker value
    COLOR = mix(Col_1, Col_2, checker);

    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


