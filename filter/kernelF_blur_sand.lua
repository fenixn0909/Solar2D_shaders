

--[[
  Origin Author: arlez80
  https://godotshaders.com/author/arlez80/
  
  /*
    砂嵐エフェクト by あるる（きのもと 結衣）
    Screen Noise Effect Shader by Yui Kinomoto @arlez80

    MIT License
  */

--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur"
kernel.name = "sand"

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

uniform float seed = 81.0;
float power = 0.02; //: hint_range( 0.0, 1.0 ) 
uniform float speed = 0.1;

vec2 random( vec2 pos )
{ 
  return fract(
    sin(
      vec2(
        dot(pos, vec2(12.9898,78.233))
      , dot(pos, vec2(-148.998,-65.233))
      )
    ) * 43758.5453
  );
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    // Pixelate
    P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
    P_UV vec2 SCREEN_UV = UV_Pix;
    // Smooth
    //P_UV vec2 SCREEN_UV = texCoord;

    //Test
    power = abs(sin(CoronaTotalTime)) *0.2;
    float TIME = CoronaTotalTime;

    vec2 uv = SCREEN_UV + ( random( SCREEN_UV + vec2( seed - TIME * speed, TIME * speed ) ) - vec2( 0.5, 0.5 ) ) * power;
    P_COLOR vec4 COLOR = texture2D( CoronaSampler0, uv, 0.0 );


    return CoronaColorScale(COLOR);
}
]]
return kernel

--[[
  

--]]

