
--[[
    https://godotshaders.com/shader/invert-color-ddd/
    SpeedyShaderZZZ
    August 5, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "inverting"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[
//P_DEFAULT float progress = CoronaVertexUserData.x;
//----------------------------------------------

float frequency = 20;

//----------------------------------------------
P_DEFAULT float TIME = CoronaTotalTime;
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    // Shifting
    float phase = sign(sin( TIME * frequency ));


    //----------------------------------------------
    vec4 tex_color = texture2D( CoronaSampler0, UV );
    // Dark Blink
    //tex_color.rgb = vec3(1.0)*phase - tex_color.rgb;
    // White Blink
    //tex_color.rgb = vec3(1.0) - tex_color.rgb*phase;
    // Normal Blink
    if( phase < 0 ){    tex_color.rgb = vec3(1.0) - tex_color.rgb;   }
    

    COLOR.rgb = tex_color.rgb;

    //----------------------------------------------
    COLOR.a = tex_color.a;
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


