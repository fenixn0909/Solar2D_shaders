

--[[
  https://godotshaders.com/shader/the-green-gameboy-look-4-x/
  rakzin
  November 27, 2024
--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "colorPalette4"

--Test
kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name    = "r",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
    },{
    name    = "g",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 1,
    },{
    name    = "b",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 1,
    min     = 0,
    max     = 32,
    index   = 3,
  },
}
kernel.fragment = [[

P_COLOR vec4 whiteColor = vec4(0.961, 0.980, 0.937, 1.0); // : source_color
P_COLOR vec4 lightGreyColor = vec4(0.549, 0.749, 0.039, 1.0); // : source_color
P_COLOR vec4 darkGreyColor = vec4(0.18, 0.451, 0.125, 1.0); // : source_color
P_COLOR vec4 blackColor = vec4(0.0, 0.247, 0.0, 1.0); // : source_color
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

//P_DEFAULT float PI = 3.14159265359;

// ----------------------------------------------------------------------------------------------------

float min4(float a, float b, float c, float d){
  return min(a, min(b, min(c, d)));
}

vec4 maxC4(vec4 a, vec4 b, vec4 c, vec4 d){
  return max(a, max(b, max(c, d)));
}

float when_eq(float x, float y) {
  return 1.0 - abs(sign(x - y));
}

// ----------------------------------------------------------------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;
// ----------------------------------------------------------------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_COLOR vec4 cW = whiteColor;
    P_COLOR vec4 cLG = lightGreyColor;
    P_COLOR vec4 cDG = darkGreyColor;
    P_COLOR vec4 cB = blackColor;
    
    
    // ----------------------------------------------------------------------------------------------------
    vec4 currentColor = texture2D(CoronaSampler0, UV);
    
    float blackDistance = distance(currentColor, vec4(vec3(0.0), 1.0));
    float whiteDistance = distance(currentColor, vec4(vec3(1.0), 1.0));
    float lightGrayDistance = distance(currentColor, vec4(vec3(0.666, 0.666, 0.666), 1.0));
    float darkGrayDistance = distance(currentColor, vec4(vec3(0.333, 0.333, 0.333), 1.0));
    
    cW *= when_eq( whiteDistance, min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance));
    cB *= when_eq( blackDistance, min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance));
    cDG *= when_eq( darkGrayDistance, min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance));
    cLG *= when_eq( lightGrayDistance, min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance));
    COLOR = min( maxC4(cW, cB, cLG, cDG), whiteColor );
    
    COLOR *= currentColor.a;
    
    // ----------------------------------------------------------------------------------------------------

    return CoronaColorScale( COLOR );
}
]]
return kernel

--[[
  
  
  

  void fragment(){
    vec4 currentColor = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    float blackDistance = distance(currentColor, vec4(vec3(0.0), 1.0));
    float whiteDistance = distance(currentColor, vec4(vec3(1.0), 1.0));
    float lightGrayDistance = distance(currentColor, vec4(vec3(0.666, 0.666, 0.666), 1.0));
    float darkGrayDistance = distance(currentColor, vec4(vec3(0.333, 0.333, 0.333), 1.0));
    
    if (
      whiteDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)
    )
    {
      COLOR = whiteColor;
    }
    else if (
      blackDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)
    )
    {
      COLOR = blackColor;
    }
    else if (
      darkGrayDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)
    )
    {
      COLOR = darkGreyColor;
    }
    else if (
      lightGrayDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)
    )
    {
      COLOR = lightGreyColor;
    }
    else{
      COLOR = whiteColor;
    }
  }

--]]

