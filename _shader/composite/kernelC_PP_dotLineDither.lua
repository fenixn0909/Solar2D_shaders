
--[[
  
  Origin Author:  flyingrub
  https://www.shadertoy.com/view/tdBSRc

  fork of https://www.shadertoy.com/view/4sBBDK
  

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "PP" --Postprocess
kernel.name = "dotLineDither"


kernel.isTimeDependent = true

kernel.vertexData =
{
    { name = "Angle",       default = 97.2, min = 0., max = 360, index = 0, },
    { name = "Scale",       default = 9.5, min = 0., max = 15, index = 1, },
    { name = "Amount",      default = 5, min = 1, max = 10, index = 2, },
    { name = "Saturation",  default = .8, min = -10, max = 10, index = 3, },
} 


kernel.fragment =
[[

float Angle = CoronaVertexUserData.x;
float Scale = CoronaVertexUserData.y;
float Amount = CoronaVertexUserData.z;      //const   dot: 1~5, line 1~2.5
float Saturation = CoronaVertexUserData.w;  

//----------------------------------------------

#define LINE
//#define DOT
//#define DITHER

const bool Is_GreyScale = false;


//----------------------------------------------

float greyScale(in vec3 col) {
    return dot(col, vec3(0.2126, 0.7152, 0.0722));
}

mat2 rotate2d(float angle){
    return mat2(cos(angle), -sin(angle), sin(angle),cos(angle));
}

// -----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float iTime = CoronaTotalTime;
P_UV vec2 iResolution = 1.0 / CoronaTexelSize.zw;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_UV vec2 fragCoord = UV * iResolution;

    //----------------------------------------------
  
    P_UV vec2 uv = UV;
    
    P_COLOR vec4 col_tex = texture2D(CoronaSampler0, uv); 
    P_COLOR vec3 col = texture2D(CoronaSampler0, uv).rgb; 
    if (Is_GreyScale) col = vec3(greyScale(col));
    
    uv *= iResolution.xy;

    P_UV vec2 p = rotate2d(Angle) * uv * Scale; 
    
    P_UV float pattern;
    #ifdef LINE
    pattern = sin( p.x ) * Amount;
    col = col * 10. * Saturation - 5. + pattern;
    #endif

    #ifdef DOT
    pattern = sin( p.x ) * sin( p.y ) * Amount;
    col = col * 10. * Saturation - 5. + pattern;
    #endif
    
    #ifdef DITHER
    pattern = texture2D(CoronaSampler1, UV * 0.25).r * 2 /5.;
    col = step(pattern, col*Saturation/1.2); 
    
    #endif
  
    
    COLOR = vec4( col, col_tex.a );

    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


