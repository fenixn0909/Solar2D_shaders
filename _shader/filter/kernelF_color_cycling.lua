
--[[
    https://godotshaders.com/shader/color-cycling-hit-effect/
    rasmus
    May 18, 2023
--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "cycling"

kernel.vertexData =
{
  { name = "Speed",         default = 15, min = 0, max = 30, index = 0, },
  { name = "Frame_Cur",     default = 0, min = 0, max = 100, index = 1, },
  { name = "Mix_Ratio",     default = .42, min = 0, max = 1, index = 2, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Frame_Cur = CoronaVertexUserData.y;
float Mix_Ratio = CoronaVertexUserData.z;
//-----------------------------------------------

uniform sampler2D TEXTURE;

int iFrame_Cur = int(Frame_Cur);

const vec3 colors[6] = vec3[] (
    vec3(1.0, 0.0, 0.0), // Red
    vec3(0.5, 0.0, 0.0), // Dark red
    vec3(0.0, 0.0, 0.0), // Black
    vec3(0.0, 1.0, 1.0), // Blue
    vec3(0.0, 0.8, 0.5), // Dark blue
    vec3(1.0, 1.0, 0.0)  // Black
);

//-----------------------------------------------

int modi( int a, int b ){ return (a)-((a)/(b))*(b); }

//-----------------------------------------------

float TIME = CoronaTotalTime;

P_COLOR vec4 COLOR = vec4(0);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //float mixR = Mix_Ratio;
    float mixR = abs(sin( TIME * Speed )) * Mix_Ratio;
    //-----------------------------------------------

    float brightness = dot(COLOR.rgb, vec3(0.2126, 0.7152, 0.0722));

    // Calculate the starting frame based on brightness
    int offset = 0;
    if (brightness > 0.75) {
        offset = 2;
    } else if (brightness > 0.25) {
        offset = 1;
    }

    // Get the color, wrapping around at the end of the array
    int color_index = modi( iFrame_Cur + offset, colors.length() );
    vec3 color = colors[color_index];

    // Apply the color to the sprite
    COLOR = texture2D( TEXTURE, UV);
    color *= COLOR.a;
    COLOR = vec4(mix(COLOR.rgb, color, mixR), COLOR.a);

    //-----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]


return kernel




--[[



--]]





