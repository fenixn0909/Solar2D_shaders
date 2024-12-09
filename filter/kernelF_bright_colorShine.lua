
--[[
  Origin Author: 9exa
  https://godotshaders.com/shader/2d-shine-highlight/
  
  Found on reddit, thought I’d share it here too. Has 3 params:

  shine_color: A color (can be transparent!)
  shine_speed: How quickly it passes
  shine_size: how wide it is

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "bright"
kernel.name = "colorShine"

--Test
kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name = "texWidth",
    default = 64,
    min = 1,
    max = 9999,
    index = 0,    
  },
  {
    name = "texHeight",
    default = 64,
    min = 1,
    max = 9999,     
    index = 1,    
  },
  {
    name = "screenWidth",
    default = 64,
    min = 1,
    max = 9999,
    index = 2,    
  },
  {
    name = "screenHeight",
    default = 64,
    min = 1,
    max = 9999,     
    index = 3,    
  },
}


kernel.fragment =
[[
P_DEFAULT vec2 texSize = vec2( CoronaVertexUserData.x, CoronaVertexUserData.y );
P_DEFAULT float screenWidth = CoronaVertexUserData.z;
P_DEFAULT float screenHeight = CoronaVertexUserData.w;

//----------------------------------------------
uniform vec4 shine_color = vec4( 1., .8, 0, .5); //: hint_color 
uniform float shine_speed = 1.0; //: hint_range(0.0, 10.0, 0.1) 
uniform float shine_size  = 0.005; //: hint_range(0.01, 1.0, 0.01)

//----------------------------------------------
 
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  //P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );

  P_UV vec2 SCREEN_PIXEL_SIZE = 1 / vec2(screenWidth, screenHeight);
  P_UV vec2 SCREEN_UV = gl_FragCoord.xy * SCREEN_PIXEL_SIZE;

  P_COLOR vec4 COLOR;
  P_DEFAULT float TIME = CoronaTotalTime;

  //intensity = sin(CoronaTotalTime*1) * 10; 10 too round
  //intensity = sin(CoronaTotalTime*1) * 4;
  //intensity = 0;
  //----------------------------------------------
    
    COLOR = texture2D(CoronaSampler0, UV);
    float shine = step(1.0 - shine_size * 0.5, 0.5 + 0.5 * sin(UV.x - UV.y + TIME * shine_speed));
    COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, shine * shine_color.a);

  //----------------------------------------------
  COLOR.rgb *= COLOR.a;


  return CoronaColorScale(COLOR);
}

]]

return kernel


--[[

--]]





