--[[
  Original Author : nighteyes
  https://godotshaders.com/author/nighteyes/

  I could not find a good blur shader and just ended with learning the shader language. I used the post from Schorsch as a template https://godotforums.org/d/20506-a-good-blur-shader. He linked to a created shadertoy by him; so it might be that the license has to be changed?

  I’m not very familiar with the shading language but I thought I read that GLES2 does not support for loops. So I gues this will work in Vulkan and GLES3.

  Do note that this shader also blurs the alpha channel; something that is easily changed.

  Bugfix, edge blur was incorrect. Looked at Exuin’s Blur.

]]
--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur"
kernel.name = "box"
kernel.isTimeDependent = true

kernel.uniformData = 
{
    {
    name = "matAimC",
    default = {
      0.5, 0.2, 1.0, 1.0, -- Speed, Span
      1.0, 1.0, 1.0, 1.0, -- Tint
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    min = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    max = {
      10.0, 10.0, 10.0, 10.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    type="mat4",
    index = 0, -- u_UserData0
  },
  {
    name = "matToC",
    default = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    min = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    max = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    type="mat4",
    index = 1, -- u_UserData1
  },
}

kernel.fragment =
[[

int strength = 1; //: hint_range(1, 512) 
//----------------------------------------------
vec4 blur_size(sampler2D tex,vec2 fragCoord, vec2 pixelSize) {
    
    vec4 color = vec4(0.,0.,0.,0.);
    float strengthFloat = float(strength);  
    //float strengthFloat = strength;  

    vec2 pixel = fragCoord/pixelSize;
    int x_min = int(max(pixel.x-strengthFloat, 0));
    int x_max = int(min(int(pixel.x+strengthFloat), int(1./pixelSize.x)));
    int y_min = int(max(int(pixel.y-strengthFloat), 0));
    int y_max = int(min(int(pixel.y+strengthFloat), int(1./pixelSize.y)));

    int count =0;

    // Sum the pixels colors
    for(int x=x_min; x <= x_max; x++) {
        for(int y = y_min; y <= y_max; y++) {           
            color += texture2D(tex, vec2(float(x), float(y)) * pixelSize);
            count++;
        }
    }
    
    // Divide the color by the number of colors you summed up
    color /= float(count);
    
    return color;
}

//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  //Test
  strength = int( sin(CoronaTotalTime*5)*4 +3);

  P_COLOR vec4 COLOR;
  if (strength > 0){
    COLOR = blur_size(CoronaSampler0,texCoord,CoronaTexelSize.zw);
  }
  else{
    //Pixelization
    P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
    COLOR = texture2D( CoronaSampler0, UV_Pix );
  }

  return CoronaColorScale(COLOR);
}
]]

return kernel



--[[

--]]
