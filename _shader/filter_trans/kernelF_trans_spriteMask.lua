
--[[
    Origin Author: agurkas
    https://godotshaders.com/author/agurkas/

    This is a simple shader for a circle transition. It expects screen width and screen height in pixels and knowing those it always produces a perfect circle in the center of a rect.

    For the best result, have a script that sets the screen_width and screen_height uniforms  in _ready() of a script to the rect_size of a ColorRect. This way the screen_width and screen_height will always be automatically set to correct size.

    !! Make sure sprite pixels are all INISED the borders, NOT Connected !!

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "spriteMask"


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
P_DEFAULT float progress = CoronaVertexUserData.x;
//----------------------------------------------

float screen_width = 320.0;
float screen_height = 320.0;

//----------------------------------------------
vec2 scale(vec2 uv, float x, float y)
{
    mat2 scale = mat2(vec2(x, 0.0), vec2(0.0, y));

    uv -= 0.5;
    uv = uv * scale;
    uv += 0.5;
    return uv;
}

float when_neq(float x, float y) {
    return abs(sign(x - y));
}

float when_gt(float x, float y) { //great than
    return 1.0 - max(sign(x - y), 0.0);
}

//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  //float v_sizeMask = abs(sin(CoronaTotalTime*5)*10);
  //float v_sizeMask = mod(CoronaTotalTime*5, 10000)*0.01 * CoronaTotalTime*15;
  //float v_sizeMask = 1-progress * 15;
  float v_sizeMask = progress*10 * progress*10; // the larger the smaller
  
  if ( v_sizeMask > 30) {v_sizeMask = 100000;}

  // Scale
  vec2 uvScale = (texCoord - 0.5) * v_sizeMask + 0.5;


  //Test
  vec2 uvMask = uvScale;
  //vec2 uvMask = scale(texCoord, v_sizeMask, v_sizeMask);
  //uvMask *= progress;

  P_COLOR vec4 texColor = texture2D( CoronaSampler0, uvMask );
  //texColor.a = 1-texColor.a;
  P_COLOR vec4 COLOR = vec4(1,0,0,1);
  //P_COLOR vec4 COLOR = texColor;

  //----------------------------------------------

  //If texColor.a != 1, get alpha = 0
  //COLOR.rgb *= when_neq( texColor.a, 1 );
  
  //If texColor.a > 0, get alpha = 0
  COLOR.a = when_gt( texColor.a, 0 );
  //COLOR.rgb *= when_gt( texColor.a, 0 );
  //COLOR.rgb *= when_gt( texColor.a, 0 );
  
  //float ratio = screen_width / screen_height;
  //float dist = distance(vec2(0.5, 0.5), vec2(mix(0.5, texCoord.x, ratio), texCoord.y));
  
  //COLOR.a = 1-progress;
  COLOR.rgb *= COLOR.a;
  
  //----------------------------------------------

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


