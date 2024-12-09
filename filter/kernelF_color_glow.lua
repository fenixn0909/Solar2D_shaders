
--[[

  Origin Author: Rosace
  https://godotshaders.com/shader/glow-effect-2d/
  
  This shader allows you to make a part of a sprite glow without having to make a light mask

  you have source colors these are the colors of the pixels you want to glow

  the threshold value is a sensivity

  the intensity is the strength of the glow

  and the opacity allows to see the original sprite under it

  oh and of course the glow color you want

   

  if you’re new with Godot you’ll need a worldenvironment node with “glow” checked for this to work.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "glow"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "vd_resolution",
    default = 5000,
    min = 1,
    max = 9999,
    index = 1, 
  },
}


kernel.fragment =
[[
P_DEFAULT float progress = CoronaVertexUserData.x;
vec4 colorBG = vec4(0,0,0,0);
P_DEFAULT float vd_resolution = CoronaVertexUserData.y;

//----------------------------------------------
P_COLOR vec4 color1 = vec4(0,0,0,1); // color wants to glow
P_COLOR vec4 color2 = vec4(0,1,1,1); // color wants to glow
P_COLOR vec4 glow_color = vec4(0,1,0,1); //: source_color

P_DEFAULT float threshold = 0.5;
P_DEFAULT float intensity = 1;
P_DEFAULT float opacity = 1;



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  threshold = sin(CoronaTotalTime*37);
  intensity = sin(CoronaTotalTime*5)*10;
  //opacity = sin(CoronaTotalTime*10);

  glow_color.r = sin(CoronaTotalTime*5);
  glow_color.g = cos(CoronaTotalTime*3);
  glow_color.b = cos(CoronaTotalTime*7);

  //progress = abs(sin(CoronaTotalTime));
  //progress *= pRate;
  //progress = pRate - progress; // Inversion

  //----------------------------------------------
  
  // Get the pixel color from the texture
  vec4 pixel_color = texture2D(CoronaSampler0, UV);
  
  // Calculate the distance between the pixel color and the first source color
  float distance = length(pixel_color - color1);
  
  // Calculate the distance between the pixel color and the second source color
  float distance_second = length(pixel_color - color2);
  
  // Create a new variable to store the modified glow color
  vec4 modified_glow_color = glow_color;
  
  // Set the alpha value of the modified glow color to the specified opacity
  modified_glow_color.a = opacity;
  
  // If the distance to either source color is below the threshold, set the output color to a blend of the pixel color and the modified glow color
  if (distance < threshold || distance_second < threshold) {
    COLOR = mix(pixel_color, modified_glow_color * intensity, modified_glow_color.a);
  }
  // Otherwise, set the output color to the pixel color
  else {
    COLOR = pixel_color;
  }

  //----------------------------------------------
  
  
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


