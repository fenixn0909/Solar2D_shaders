--[[
    https://godotshaders.com/author/nighteyes/
    Original Author : nighteyes
    
    #OVERHEAD: crank the var up too much will cause overhead!

]]
--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur"
kernel.name = "box"
kernel.isTimeDependent = true


kernel.vertexData =
{
  { name = "Progress",                  default = .5, min = 0, max = 1, index = 0, },
  { name = "Strength", --[[#OVERHEAD]]  default = 15, min = 0, max = 25, index = 1, },
} 

kernel.fragment =
[[

//----------------------------------------------

P_COLOR float Progress = CoronaVertexUserData.x;
P_COLOR float Strength = CoronaVertexUserData.y;

//----------------------------------------------
vec4 blur_size(sampler2D tex,vec2 fragCoord, vec2 pixelSize) {
    
    vec4 color = vec4(0.,0.,0.,0.);
    float strengthFloat = float( Progress * Strength );  
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


  P_COLOR vec4 COLOR;
  if (Progress > 0){
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
