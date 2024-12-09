
--[[
    Infinite custom texture scrolling with modifiers

    https://godotshaders.com/shader/infinite-scrolling-texture-with-angle-modifier/
    vaporvee
    May 29, 2024

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "BG"
kernel.name = "patternScroller"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
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


kernel.fragment =
[[

uniform sampler2D texture_to_scroll;


uniform float scroll_speed = .08;  // : hint_range(0, 2)
uniform float angle_degrees = 45.0; // : hint_range(0, 360)
uniform float repeat_x = 2;    // : hint_range(1, 20)
uniform float repeat_y = 2;    // : hint_range(1, 20)
uniform float row_offset = 1;   // : hint_range(0, 1)

//----------------------------------------------

vec2 round( vec2 value){
    return floor( value + vec2(0.5) );
}

//-----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed
P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;

//vec2 TEXTURE_SIZE = 1 / CoronaTexelSize.zw;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------
  
    float angle_rad = radians(angle_degrees);

    vec2 direction = vec2(cos(angle_rad), sin(angle_rad));

    vec2 offset_uv = UV - (TIME * scroll_speed * direction);

    float offset = fract(floor(offset_uv.y * repeat_y) * 0.5) > 0.0 ? (row_offset * 0.324) : 0.0;

    offset_uv.x += offset;

    vec2 scaled_uv = vec2(fract(offset_uv.x * repeat_x), 
              fract(offset_uv.y * repeat_y));

    //vec2 texelSize = vec2(1.0) / vec2(textureSize(texture_to_scroll, 0));
    vec2 texelSize = CoronaTexelSize.zw;
    vec2 snappedUV = round(scaled_uv / texelSize) * texelSize;

    COLOR = texture2D(texture_to_scroll, snappedUV);
    //----------------------------------------------
    //COLOR.a *= alpha;
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


