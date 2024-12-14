
--[[
  
  Origin Author:  flyingrub
  https://www.shadertoy.com/view/3djSzh

  Play with the parameters defined at the begining

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG" 
kernel.name = "polygonRepeat"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "texWidth",
    default = 4,
    min = 1,
    max = 9999,
    index = 0,    
  },
  {
    name = "texHeight",
    default = 4,
    min = 1,
    max = 9999,     
    index = 1,    
  },
}


kernel.fragment =
[[
P_UV vec2 iResolution = vec2(1. ,1.);
P_UV vec2 texSize = vec2( CoronaVertexUserData.x, CoronaVertexUserData.y );


//----------------------------------------------
  #define isTween

  #define PI 3.14159265359
  #define TAU 6.28318530718
  #define pixel_width 50.*repeat*3./max(texSize.y,texSize.x)

  #define repeat 0.5 // .05 incr for more
  #define speed 0.5 // .1
  #define sides 16  // 16: parachute 32: nearly circle, 64: perfect circle?
  
  #define rotation_speed 0.2 // .1

  vec3 lineColor = vec3(1, .2, 0);

  float width = 0.5; // 1.   #define width 0.5 // 1.
  float lineOpacity = 0.5;


  float stroke(float d, float size) {
    return smoothstep(pixel_width,0.0,abs(d-size)-width/2.);
  }

  vec2 rotate(vec2 _uv, float _angle){
      _uv =  mat2(cos(_angle),-sin(_angle),
                  sin(_angle),cos(_angle)) * _uv;
      return _uv;
  }

  float polygonSDF(vec2 _uv) {
    // Angle and radius from the current pixel
    float a = atan(_uv.x,_uv.y)+PI;
    float r = TAU/float(floor(sides));

    return cos(floor(.5+a/r)*r-a)*length(_uv);
  }

  // From https://www.shadertoy.com/view/tsBGDD
  float smoothmodulo(float a) {
    return abs( mod(a, 2.) - 1.);
  }


// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = ( texCoord.xy / iResolution );
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;

  #ifdef isTween
    lineOpacity += sin(CoronaTotalTime*.25)* 0.5;
    width += sin(CoronaTotalTime*.25)* 1;
    //opacityScanline += abs(sin(CoronaTotalTime)) * .5  ; //50
  #endif
  //----------------------------------------------
    vec2 R = iResolution.xy;
    //vec2 R = texSize.xy;
    vec2 U = ( 2.* fragCoord - R ) / R.y;
    U = rotate(U,iTime*rotation_speed);
    U *= repeat*50.;
    float c = stroke(smoothmodulo(polygonSDF(U)+iTime*10.*speed),1.);

    //COLOR = vec4(vec3(c),1.);   

    // Apply Color
    COLOR.rgb = lineColor*c;
      
  //----------------------------------------------
  COLOR.a = c;
  COLOR.rgb *= COLOR.a;
  COLOR.a = lineOpacity * COLOR.r;
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


