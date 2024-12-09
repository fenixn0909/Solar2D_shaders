
--[[
    https://godotshaders.com/shader/colorful-signal-effect/
    LoganB September 4, 2023
    A colorful signal effect for 2D games.
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FG"
kernel.name = "signalRipple"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "speed",
    default = 5,
    min = -99,
    max = 99,
    index = 0, 
  },
}


kernel.fragment =
[[

//----------------------------------------------

uniform vec4 color_signal = vec4 (0.3, 0.1, 0.0, 0.2); // : hint_color 
uniform float size = 0.8; //: hint_range(0.0, 1.0, 0.01) 
uniform float zoom = 8.0; //: Incre => More Ripple & Thiner.  hint_range(0.0, 20, 1)
//uniform float speed = 5.0; //: hint_range(-10.0, 10.0, 1.0) 
float speed = CoronaVertexUserData.x; //: hint_range(-10.0, 10.0, 1.0) 


// -----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  P_COLOR vec4 fragColor;
  //P_COLOR vec2 UV = fragCoord;
  P_DEFAULT float TIME = CoronaTotalTime;
  //----------------------------------------------
  
  float d = length((UV-0.5)*2.0);
  float t = pow(smoothstep(0.9,0.2,d),0.35);
  
  // For rainbow effect, keep this line :
  vec3 rainbow = 0.5 + 0.5*cos(TIME+UV.xyx+vec3(0,2,4));
  vec4 color = vec4(rainbow.rgb,1.0);
  
  // For idle color, delete "//" below :
  color = vec4(color_signal.rgb,1.0);

  d = sin(zoom*d - speed*TIME);
  d = abs(d);
  d = size/d;
  color *= d*t;
  

  fragColor = vec4(color);

  
  //----------------------------------------------
  //fragColor = vec4( 1., 0., 0., 1.);

  //return CoronaColorScale( color );
  return CoronaColorScale( fragColor );
}
]]

return kernel

--[[
    
--]]


