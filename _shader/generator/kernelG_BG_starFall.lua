
--[[
  
    Origin Author: Xor
    https://www.shadertoy.com/view/ctXGRn

    -- Volume: overhead if crank it up too much
    
    Settings:
    -- Fire Flies: {-2, 40, -0.15, -0.05}

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "starFall"

kernel.isTimeDependent = true



kernel.vertexData =
{
  { name = "Speed",     default = -1, min = -50, max = 50, index = 0, },
  { name = "Volume",      default = 20, min = 1, max = 45, index = 1, },
  { name = "LenX",      default = 0, min = -.7, max = 1, index = 2, },
  { name = "LenY",      default = 0.2, min = -.7, max = 1, index = 3, },
} 

kernel.fragment =
[[

uniform vec4 u_resolution;


float Speed = CoronaVertexUserData.x;
float Volume = CoronaVertexUserData.y;
float LenX = CoronaVertexUserData.z;    // vec2(0,0.2): rise, vec2(1,-.1): left lines
float LenY = CoronaVertexUserData.w;
//----------------------------------------------

int when_gt(float x, float y) { //greater than return 1
  return int(max(sign(x - y), 0.0));
}

//-----------------------------------------------
float iTime = CoronaTotalTime * Speed;
P_COLOR vec4 COLOR = vec4(0,0,0,0);
P_UV vec2 iResolution = vec2( 1, 1);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
    {
    
    //----------------------------------------------

    COLOR *= 0.;
    
    //Line dimensions (box) and position relative to line
    vec2 b = vec2( LenX, LenY), p; 
    int ip = 0 + when_gt( LenY, LenX ); // keep rainbow color after direction changed

    //Rotation matrix
    mat2 R;
    //Iterate 20 times
    for(float i=.9; i++<Volume;
        //Add attenuation
        COLOR += 1e-3/length(clamp(p=R                          //Using rotated boxes
        *(fract((UV/iResolution.y*i*.1+iTime*b)*R)-.5),-b,b)-p)
        *(cos(p[ip]/.1+vec4(0,1,2,3))+1.) )                       //My favorite color palette
        R=mat2(cos(i+vec4(0,33,11,0))                           //Rotate for each iteration
    );                         

    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


