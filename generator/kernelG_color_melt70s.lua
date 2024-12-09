
--[[

  Origin Author:  tomorrowevening
  https://www.shadertoy.com/view/XsX3zl

  THE COLORS MAN, THE COLORS.
  Inspired by @WAHa_06x36's sine puke

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "color"
kernel.name = "melt70s"


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

#ifdef GL_ES
precision mediump float;
#endif
#define RADIANS 0.017453292519943295

// Variation:   The larger the slower
const int zoom = 40; //40  Good: 70 50 30 20 10 Great: 60 Soft: 40
const float brightness = 0.975;
float fScale = 10.25; //1.25

float cosRange(float degrees, float range, float minimum) {
    return (((1.0 + cos(degrees * RADIANS)) * 0.5) * range) + minimum;
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = texCoord / iResolution;
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  
    float time = iTime * 1.25;
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p  = (2.0*fragCoord.xy-iResolution.xy)/max(iResolution.x,iResolution.y);
    float ct = cosRange(time*5.0, 3.0, 1.1);
    float xBoost = cosRange(time*0.2, 5.0, 5.0);
    float yBoost = cosRange(time*0.1, 10.0, 5.0);

    fScale = cosRange(time * 15.5, 1.25, 0.5);

    for(int i=1;i<zoom;i++) {
        float _i = float(i);
        vec2 newp=p;
        newp.x+=0.25/_i*sin(_i*p.y+time*cos(ct)*0.5/20.0+0.005*_i)*fScale+xBoost;       
        newp.y+=0.25/_i*sin(_i*p.x+time*ct*0.3/40.0+0.03*float(i+15))*fScale+yBoost;
        p=newp;
    }

    vec3 col=vec3(0.5*sin(3.0*p.x)+0.5,0.5*sin(3.0*p.y)+0.5,sin(p.x+p.y));
    col *= brightness;
      
    // Add border
    float vigAmt = 5.0;
    float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
    float extrusion = (col.x + col.y + col.z) / 4.0;
    extrusion *= 1.5;
    extrusion *= vignette;
      
    //fragColor = vec4(col, extrusion);

  //----------------------------------------------
  COLOR = vec4(col, extrusion);
  //COLOR.a = alpha;
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


