
--[[
  
    Origin Author:  flyingrub
    https://www.shadertoy.com/view/3djSzh

    Play with the parameters defined at the begining

    Find and go #VARIATION and tweak them for different patterns
  

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG" 
kernel.name = "polygonRepeat"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",           default = -.4, min = -3, max = 3, index = 0, },
  { name = "Repeat",           default = 0.45, min = -2, max = 2, index = 1, },
  { name = "Rot_Speed",          default = 1.8, min = -10, max = 10, index = 2, },
  { name = "Sides",          default = 10, min = 0, max = 15, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Repeat = CoronaVertexUserData.y;
float Rot_Speed = CoronaVertexUserData.z;
float Sides = CoronaVertexUserData.w;
//----------------------------------------------

P_UV vec2 iResolution = 1.0 / CoronaTexelSize.zw;
P_UV vec2 SCREEN_PIXEL_SIZE = iResolution * CoronaTexelSize.zw;

//----------------------------------------------
  
// Tween Alpha    #VARIATION
#define isTween

#define PI 3.14159265359
#define TAU 6.28318530718
#define pixel_width 50.*Repeat*3./max(iResolution.y,iResolution.x)

vec3 lineColor = vec3(1, .2, 0);
float lineOpacity = 0.5;
float width = 0.5;

//----------------------------------------------

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
    float r = TAU/float(floor(Sides));

    return cos(floor(.5+a/r)*r-a)*length(_uv);
}

// From https://www.shadertoy.com/view/tsBGDD
float smoothmodulo(float a) {
    return abs( mod(a, 2.) - 1.);
}

// -----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float iTime = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    #ifdef isTween
    lineOpacity += abs(sin(iTime*1.25))* 0.5;
    width += abs(sin(iTime*1.25))* 1;
    #endif
    //----------------------------------------------

    vec2 R = SCREEN_PIXEL_SIZE;     // Ratio
    vec2 U = ( 2.* UV - R ) / R.y;
    U = rotate(U,iTime * Rot_Speed);
    U *= Repeat*50.;
    float c = stroke(smoothmodulo(polygonSDF(U)+iTime*10.*Speed),1.);

    COLOR = vec4(vec3(c),1.);   

    // Apply Color
    COLOR.rgb = lineColor*c;
    COLOR.a = lineOpacity;

    //----------------------------------------------
    // Alpha Stripes    #VARIATION
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


