
--[[
  
  Origin Author: Xor
  https://www.shadertoy.com/view/ctXGRn

  /*
      "Shooting Stars" by @XorDev

      I got hit with inspiration for the concept of shooting stars.
      This is what I came up with.
      
      Tweet: twitter.com/XorDev/status/1604218610737680385
      Twigl: t.co/i7nkUWIpD8
      <300 chars playlist: shadertoy.com/playlist/fXlGDN
  */

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "starFall"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.fragment =
[[
P_DEFAULT float resolutionX = CoronaVertexUserData.x;
P_DEFAULT float resolutionY = CoronaVertexUserData.y;
P_UV vec2 iResolution = vec2(resolutionX,resolutionY);
//----------------------------------------------
  
// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = texCoord / iResolution;
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;

  //----------------------------------------------
  
    COLOR *= 0.;
        
    //Line dimensions (box) and position relative to line
    vec2 b = vec2(0,0.25), p; // vec2(0,0.2): rise, vec2(1,-.1): left lines
    //Rotation matrix
    mat2 R;
    //Iterate 20 times
    for(float i=.9; i++<20.;
        //Add attenuation
        COLOR += 1e-3/length(clamp(p=R
        //Using rotated boxes
        *(fract((texCoord/iResolution.y*i*.1+iTime*b)*R)-.5),-b,b)-p)
        //My favorite color palette
        *(cos(p.y/.1+vec4(0,1,2,3))+1.) )
        //Rotate for each iteration
        R=mat2(cos(i+vec4(0,33,11,0)));

  //----------------------------------------------
  //COLOR.a *= alpha;
  //COLOR.rgb *= COLOR.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


