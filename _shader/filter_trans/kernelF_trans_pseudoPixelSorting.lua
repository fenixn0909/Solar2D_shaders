
--[[
    https://godotshaders.com/shader/pseudo-pixel-sorting-v2/
    Ahopness
    October 15, 2023
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "pseudoPixelSorting"


kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 0,
    max = 2,
    index = 0, 
  },
}


kernel.fragment =
[[

float progress = CoronaVertexUserData.x;
//----------------------------------------------

uniform sampler2D SCREEN_TEXTURE;
uniform float mask_softness = 1.4; // negative values result in mask being inverted
uniform float mask_threshold = .3;


//----------------------------------------------


P_COLOR vec4 COLOR;
vec4 FRAGCOORD = gl_FragCoord;
P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    
    //----------------------------------------------

    vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy;
    vec4 tex = texture2D(SCREEN_TEXTURE, uv);
    
    // Masking
    float f = mask_softness / 2.0;
    float a = mask_threshold - f;
    float b = mask_threshold + f;
    float average = (tex.x + tex.y + tex.z) / 3.0;
    float mask = smoothstep(a, b, average);
    
    // Pseudo Pixel Sorting
    float sort_threshold = 1.0 - clamp(progress / 2.6, 0.0, 1.0);
    vec2 sort_uv = vec2(uv.x, sort_threshold);
    
    // Curved melting transition
    vec2 transition_uv = uv;
    float turbulance = fract(sin(dot(vec2(transition_uv.x), vec2(12.9, 78.2)))* 437.5);
    transition_uv.y += pow(progress, 2.0 + (progress * 2.0)) * mask * turbulance;
    COLOR = texture2D(SCREEN_TEXTURE, transition_uv);
    
    // Draw pixel sorting effect behind the melting transition
    if(transition_uv.y > 1.){
        COLOR = texture2D(SCREEN_TEXTURE, sort_uv);
    }else{
        COLOR = texture2D(SCREEN_TEXTURE, uv);
    }
    //----------------------------------------------

    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


