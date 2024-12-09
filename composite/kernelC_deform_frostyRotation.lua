
--[[
    https://godotshaders.com/shader/frosty-rotative-deformation/
    CasualGarageCoder
    December 6, 2022
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "deform"
kernel.name = "frostyRotation" 

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = 'intensity',
    default = 0.0,
    min = 0,
    max = 10,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  
}


kernel.fragment =
[[

uniform sampler2D TEXTURE;
uniform sampler2D noise;


//----------------------------------------------

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //P_UV vec2 SCREEN_UV = gl_FragCoord.xy * CoronaTexelSize.zw;
    P_UV vec2 SCREEN_UV = UV;

    //----------------------------------------------

    float angle = TIME;
    vec2 dist = vec2(.5) - UV;
    float s = sin(angle);
    float c = cos(angle);
    mat2 m = mat2(vec2(c, -s), vec2(s, c));
    dist *= m;
    vec4 coord = texture2D(CoronaSampler1, dist);
    coord.x -= .0;
    coord.y -= .0;
    vec4 lens_color = texture2D(CoronaSampler0, UV + coord.xy);
    COLOR = lens_color;

    //----------------------------------------------
    
    // Restrict to texture alpha
    //COLOR.a = alpha;
    COLOR.rgb *= COLOR.a;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


