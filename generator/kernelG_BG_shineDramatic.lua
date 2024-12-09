
--[[
  
  

  Origin Author: Emil
  https://www.shadertoy.com/view/3d3XWr

  template for glowy shiny thingy

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG" 
kernel.name = "shineDramatic"


kernel.isTimeDependent = true

kernel.vertexData =
{
  
}


kernel.fragment =
[[
P_UV vec2 iResolution = vec2(1. ,1.);

//P_COLOR vec4 color_mod = vec4( 1.2, 0.6, 6.9, 1);
P_COLOR vec4 color_mod = vec4( 1.7, 1.2, .9, 1);
//P_COLOR vec4 color_mod = vec4( 1, 1, 1, 1);

//----------------------------------------------
  #define PI 3.141592653

// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = ( texCoord.xy / iResolution );
  //P_UV vec2 fragCoord = abs(dFdx(texCoord)) + abs(dFdy(texCoord));


  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;

  #ifdef isTween
    lineOpacity += sin(CoronaTotalTime*.25)* 0.5;
    width += sin(CoronaTotalTime*.25)* 1;
    //opacityScanline += abs(sin(CoronaTotalTime)) * .5  ; //50
  #endif
  //----------------------------------------------
    float newTime = iTime*1.0;
        
    // uvs from -1 to 1 in Y height
    //vec2 uv = (fragCoord-iResolution.xy*0.5)/iResolution.y;
    // Better Result!
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    float radial = atan(uv.x, uv.y)/(PI*2.);
    
    float shine1 = abs(fract((radial + newTime*0.12)*2.)-0.5)*2.0;
    float shine2 = abs(fract((radial + newTime*-0.06)*5.)-0.5)*2.0;
    float shine3 = abs(fract((radial + newTime*0.001)*11.)-0.5)*2.0;
    
    float shines = 0.0;
    shines += shine1*0.13;
    shines += shine2*0.23;
    shines += shine3*0.33;
    shines = smoothstep(0.2, 0.5, shines);
    
    float luv = length(uv);
    
    shines =  shines * (0.12/luv);
    
    shines = clamp(shines, 0.0, 1.0)*smoothstep(0.03,0.25, luv);
    //shines *= 1.6;
    shines *= smoothstep(1.0, 0.0, luv);
    shines = clamp(shines, 0.0, 1.0);
    
    // Glow Core
    COLOR = vec4(mix(shines,1.0,smoothstep(0.4, 0.0, luv)));
    
    // Empty Core
    //COLOR = vec4(shines);
      
  //----------------------------------------------
  
  // Color Mod
  COLOR.rgb *= color_mod.rgb;
  // Shrink Radius
  //COLOR.rgb *= COLOR.a;


  //COLOR.a = (COLOR.a+COLOR.g+COLOR.b)/3;
  //COLOR.a = lineOpacity * COLOR.r;
  //COLOR.rgb *= COLOR.a;


  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


