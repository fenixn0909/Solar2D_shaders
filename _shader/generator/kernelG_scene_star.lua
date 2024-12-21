--[[
    Origin Author: gerardogc2378
    https://godotshaders.com/author/gerardogc2378/
    gerardogc2378
    August 12, 2021
    Hi, if you like stars just like me then you can enjoy this shader. 
    I played with an Android device and works really fine with a GLES2 project.

--]]


local kernel = {}

kernel.language = "glsl"

kernel.category = "generator"
kernel.group = "scene"
kernel.name = "star"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "x",
    default = 1,
    min = 0,
    max = 4,
    index = 0, -- v_UserData.x
  },
  {
    name = "y",
    default = 1,
    min = 0,
    max = 4,
    index = 1, -- v_UserData.y
  },
}


kernel.fragment =
[[
uniform vec4 Col_BG = vec4(0,0,0.2,1); //: hint_color;

//----------------------------------------------
float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

//----------------------------------------------

float TIME = CoronaTotalTime;
P_COLOR vec4 COLOR = vec4(0);

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_UV vec2 SCREEN_UV = texCoord;
    P_UV vec2 texelOffset = ( CoronaTexelSize.zw * 0.5 );
    P_UV vec2 FRAGCOORD = ( texelOffset + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw ) );
    //----------------------------------------------

    float size = 100.0;
    float prob = 0.9;
    vec2 pos = floor(1.0 / size * FRAGCOORD.xy);
    float color = 0.0;
    float starValue = rand(pos);

    if (starValue > prob)
    {
        vec2 center = size * pos + vec2(size, size) * 0.5;
        float t = 0.9 + 0.2 * sin(TIME * 8.0 + (starValue - prob) / (1.0 - prob) * 45.0);
        color = 1.0 - distance(FRAGCOORD.xy, center) / (0.5 * size);
        color = color * t / (abs(FRAGCOORD.y - center.y)) * t / (abs(FRAGCOORD.x - center.x));
    }
    else if (rand(SCREEN_UV.xy / 20.0) > 0.995)
    {
        float r = rand(SCREEN_UV.xy);
        color = r * (0.85 * sin(TIME * (r * 5.0) + 720.0 * r) + 0.95);
    }
    COLOR = vec4(vec3(color),1.0) + Col_BG;
    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[


--]]
