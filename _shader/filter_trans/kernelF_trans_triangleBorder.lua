
--[[
    https://godotshaders.com/shader/triangle-border/
    isaacryu
    November 30, 2024

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "triangleBorder"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[
float progress = CoronaVertexUserData.x;
vec4 colorBG = vec4(0,0,0,0);
//----------------------------------------------

uniform vec4 block_color = vec4( .7, 0.0, 0.0, 1.0 ); // : source_color; // Solid block color
uniform float block_width = 0.5; // : hint_range(0.0, 1.0); // Block width (0 to 1, relative to the canvas)
uniform float triangle_size_pixels = 100; // : hint_range(1.0, 100.0); // Frequency of the triangle pattern along the border
uniform float wave_offset = 1; // : hint_range(0.0, 1.0); // Offset for the wave period (0 to 1, relative to the period)

// block_width => progress

//----------------------------------------------

//P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);
P_COLOR vec4 COLOR;

P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    //progress = abs(sin(CoronaTotalTime));
    //----------------------------------------------

    float triangle_size_uv = triangle_size_pixels * SCREEN_PIXEL_SIZE.y;
    
    // Check if the pixel is inside the solid block area
    if (UV.x < progress) {
        // Set the pixel to the block color
        COLOR = block_color;
    } else {
        // Calculate the triangle pattern along the right edge
        float distance_from_edge = UV.x - progress;
        
        // Calculate the Y position within the triangle pattern cycle
        float vertical_cycle = mod(UV.y + wave_offset * triangle_size_uv, triangle_size_uv);
        
        // Map the vertical position to the triangle's shape
        float triangle_base = abs(triangle_size_uv / 2.0 - vertical_cycle); // Creates a triangular wave

        // Check if the fragment is within the triangle area
        if (distance_from_edge < triangle_base) {
            COLOR = block_color; // Color inside the triangle border
        } else {
            discard; // Transparent outside the triangle
        }
    }
    //----------------------------------------------

    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


