
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
  { name = "Speed",         default = 6, min = 0, max = 20, index = 0, },
  { name = "Zoom",          default = 40, min = 0, max = 200, index = 1, },
  { name = "Brightness",    default = .95, min = .5, max = 2, index = 2, },
  { name = "Scale",         default = 1, min = -8, max = 8, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Zoom = CoronaVertexUserData.y;
float Brightness = CoronaVertexUserData.z;
float Scale = CoronaVertexUserData.w;

//----------------------------------------------
//----------------------------------------------

#ifdef GL_ES
precision mediump float;
#endif
#define RADIANS 0.017453292519943295


//----------------------------------------------
float cosRange(float degrees, float range, float minimum) {
    return (((1.0 + cos(degrees * RADIANS)) * 0.5) * range) + minimum;
}

//----------------------------------------------

P_UV vec2 iResolution = vec2( 1, 1 );
P_DEFAULT float iTime = CoronaTotalTime;
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_UV vec2 fragCoord = UV / iResolution;
    
    //----------------------------------------------

    float time = iTime * Speed;
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p  = (2.0*fragCoord.xy-iResolution.xy)/max(iResolution.x,iResolution.y);
    float ct = cosRange(time*5.0, 3.0, 1.1);
    float xBoost = cosRange(time*0.2, 5.0, 5.0);
    float yBoost = cosRange(time*0.1, 10.0, 5.0);

    float fScale = cosRange(time * 15.5, 1.25, 0.5) * Scale ;

    for(int i=1;i<Zoom;i++) {
        float _i = float(i);
        vec2 newp=p;
        newp.x+=0.25/_i*sin(_i*p.y+time*cos(ct)*0.5/20.0+0.005*_i)*fScale+xBoost;       
        newp.y+=0.25/_i*sin(_i*p.x+time*ct*0.3/40.0+0.03*float(i+15))*fScale+yBoost;
        p=newp;
    }

    vec3 col=vec3(0.5*sin(3.0*p.x)+0.5,0.5*sin(3.0*p.y)+0.5,sin(p.x+p.y));
    col *= Brightness;
      
    // Add border
    float vigAmt = 5.0;
    float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
    float extrusion = (col.x + col.y + col.z) / 4.0;
    extrusion *= 1.5;
    extrusion *= vignette;

    //----------------------------------------------
    COLOR = vec4(col, extrusion);

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


