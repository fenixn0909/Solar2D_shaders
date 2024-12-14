
--[[
  Origin Author: lurgx
  https://godotshaders.com/author/lurgx/

  // HSV to RBG from https://www.rapidtables.com/convert/color/hsv-to-rgb.html
  // Rotation matrix from https://en.wikipedia.org/wiki/Rotation_matrix
  
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "rainbowOver"
kernel.isTimeDependent = true



kernel.fragment =
[[

const float PI = 3.1415926535;

float strength = 0.5; //: hint_range(0., 1.) 
float speed = 2.5;    //: hint_range(0., 10.) 
float angle = 45.;     //: hint_range(0., 360.)


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 finColor = texture2D(CoronaSampler0, texCoord);

  float hue = texCoord.x * cos(radians(angle)) - texCoord.y * sin(radians(angle));
  hue = fract(hue + fract(CoronaTotalTime  * speed));
  float x = 1. - abs(mod(hue / (1./ 6.), 2.) - 1.);
  vec3 rainbow;
  if(hue < 1./6.){
    rainbow = vec3(1., x, 0.);
  } else if (hue < 1./3.) {
    rainbow = vec3(x, 1., 0);
  } else if (hue < 0.5) {
    rainbow = vec3(0, 1., x);
  } else if (hue < 2./3.) {
    rainbow = vec3(0., x, 1.);
  } else if (hue < 5./6.) {
    rainbow = vec3(x, 0., 1.);
  } else {
    rainbow = vec3(1., 0., x);
  }
  rainbow.rgb *= finColor.a;

  vec4 color = texture2D(CoronaSampler0, texCoord);
  finColor = mix(color, vec4(rainbow, color.a), strength);

  return finColor;
}
]]

return kernel



--[[



--]]