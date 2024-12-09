 
--[[
    https://forum.godotengine.org/t/how-to-write-a-bloom-shader/26070/2
    
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "bloom"


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
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.vertex =
[[

uniform sampler2D SCREEN_TEXTURE;

varying P_COLOR vec4 col0;
varying P_COLOR vec4 col1;
varying P_COLOR vec4 col2;
varying P_COLOR vec4 col3;

//----------------------------------------------
vec4 sample_glow_pixel( sampler2D tex, vec2 uv ) {
    float hdr_threshold = 0.1; // Exagerated, almost everything will glow
    return max(texture2DLod(tex, uv, 1.0) - hdr_threshold, vec4(0.0));
    //return max(texture2D(tex, uv) - hdr_threshold, vec4(0.0));
}
//----------------------------------------------



P_POSITION vec2 VertexKernel( P_POSITION vec2 POSITION )
{
    //P_POSITION vec2 VERTEX = POSITION;
    P_POSITION vec2 VERTEX = (POSITION+1)*.5;
    
    P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;
    vec2 ps = SCREEN_PIXEL_SIZE ;
    col0 = sample_glow_pixel(SCREEN_TEXTURE, VERTEX + vec2(-ps.x, 0));
    col1 = sample_glow_pixel(SCREEN_TEXTURE, VERTEX + vec2(ps.x, 0));
    col2 = sample_glow_pixel(SCREEN_TEXTURE, VERTEX + vec2(0, -ps.y));
    col3 = sample_glow_pixel(SCREEN_TEXTURE, VERTEX + vec2(0, ps.y));


    return POSITION;    
}
]]


kernel.fragment =
[[

uniform sampler2D SCREEN_TEXTURE;

P_DEFAULT float progress = CoronaVertexUserData.x;


varying P_COLOR vec4 col0;
varying P_COLOR vec4 col1;
varying P_COLOR vec4 col2;
varying P_COLOR vec4 col3;


float freq = 10;    // Frequency
float amp = 0.5;     // Amplitude 


//P_COLOR sampler2D CoronaSampler0;

//----------------------------------------------

//*
vec4 sample_glow_pixel( sampler2D tex, vec2 uv ) {
    float hdr_threshold = progress; // Exagerated, almost everything will glow
    //float hdr_threshold = 0.1; // Exagerated, almost everything will glow
    return max(texture2D(tex, uv, 0.0) - hdr_threshold, vec4(0.0));
}
//*/

//----------------------------------------------


// -----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;
    P_UV vec2 SCREEN_UV = UV;

    progress = abs(sin(CoronaTotalTime * freq)) * amp ;

    //----------------------------------------------

    vec2 ps = SCREEN_PIXEL_SIZE;
    // Get blurred color from pixels considered glowing
    vec4 col0 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, 0));
    vec4 col1 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, 0));
    vec4 col2 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, -ps.y));
    vec4 col3 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, ps.y));

    vec4 col = texture2D(SCREEN_TEXTURE, SCREEN_UV);
    vec4 glowing_col = 0.25 * (col0 + col1 + col2 + col3);

    COLOR = vec4(col.rgb + glowing_col.rgb, col.a);


    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;
    //COLOR = col0;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


