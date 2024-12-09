
--[[
  
  Origin Author: 9Rituals
  https://godotshaders.com/shader/variable-blur-works-with-parallax-layers/

  Modified blur shader that can be used inside parallax background, just add a texture rect with the shader and ajust the values.

  You can add more than one layer of blur to make a 2D depth of field.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur" 
kernel.name = "variable"


kernel.isTimeDependent = true

kernel.vertexData =
{
  
}


kernel.fragment =
[[


//----------------------------------------------
  uniform float SAMPLES = 11.0;
  const float WIDTH = 0.04734573810584494679397346954847;

  vec2 blur_scale = vec2(1, 1); //1~5

  float gaussian(float x) {
      float x_squared = x*x;

      return WIDTH * exp((x_squared / (2.0 * SAMPLES)) * -1.0);
  }

// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 SCREEN_UV = texCoord;
  P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
  P_COLOR vec4 COLOR;
  //P_DEFAULT float iTime = CoronaTotalTime;

  // Fancy Dream
  //blur_scale.x = sin(CoronaTotalTime)*100;
  //blur_scale.y = cos(CoronaTotalTime*0.5)*100;

  // Regular
  blur_scale.x = sin(CoronaTotalTime)*5;
  blur_scale.y = cos(CoronaTotalTime*0.5)*5;
  
  //----------------------------------------------
    vec2 scale = TEXTURE_PIXEL_SIZE * blur_scale;
      
    float weight = 0.0;
    float total_weight = 0.0;
    vec4 color = vec4(0.0);
    
    for(int i=-int(SAMPLES)/2; i < int(SAMPLES)/2; ++i) {
      weight = gaussian(float(i));
      color.rgb += texture2D(CoronaSampler0, SCREEN_UV + scale * vec2(float(i))).rgb * weight;
      total_weight += weight;
    }
    
    COLOR.rgb = color.rgb / total_weight;
      
  //----------------------------------------------
  
  //COLOR.a = (COLOR.a+COLOR.g+COLOR.b)/3;

  //COLOR.rgb *= COLOR.a;
  //COLOR.a = lineOpacity * COLOR.r;
  //COLOR.rgb *= COLOR.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


