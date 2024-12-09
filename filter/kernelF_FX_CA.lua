--[[
      https://godotshaders.com/shader/just-chromatic-aberration/
      jecovier
      April 23, 2022
  This is a little shader to create a chromatic aberration without any other effect, 
  you can control de X and Y displacement of  each color (RGB) individually.

  Chromatic Aberration -> CA


--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "CA"

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
    max     = 4,
    index   = 3,
  },
}


kernel.fragment = 
[[


uniform vec2 r_displacement = vec2(-3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 2.0);
uniform vec2 b_displacement = vec2(3.0, 0.0);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  // Pixelate
  P_UV vec2 uv_pix = (CoronaTexelSize.zw * 0.5) + ( floor( UV / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
  P_UV vec2 SCREEN_UV = uv_pix;
  // Smooth
  //P_UV vec2 SCREEN_UV = UV;

  float r = texture2D(CoronaSampler0, SCREEN_UV + vec2(CoronaTexelSize.zw * r_displacement), 0.0).r;
  float g = texture2D(CoronaSampler0, SCREEN_UV + vec2(CoronaTexelSize.zw * g_displacement), 0.0).g;
  float b = texture2D(CoronaSampler0, SCREEN_UV + vec2(CoronaTexelSize.zw * b_displacement), 0.0).b;
  float a = texture2D(CoronaSampler0, SCREEN_UV).a;
    
  P_COLOR vec4 COLOR = vec4(r, g, b, a);
  //COLOR.rgb *= COLOR.a;
  

  return CoronaColorScale( COLOR );
}
]]
return kernel
--[[



--]]