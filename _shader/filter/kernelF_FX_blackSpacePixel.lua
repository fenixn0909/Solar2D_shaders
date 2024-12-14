 
--[[
  https://godotshaders.com/shader/screentone-black-spaced-pixels/
  Exuin
  January 24, 2021
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "blackSpacePixel"


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
}


kernel.fragment =
[[

P_COLOR vec3 color_light = vec3( 0.5, 0.5, 1.0);
P_COLOR vec3 color_dark = vec3( 0.0, 0.0, 0.3);

//----------------------------------------------

//float a[5] = float[](3.4, 4.2, 5.0, 5.2, 1.1);

int modi( int a, int b ){ return (a)-((a)/(b))*(b); }

bool is_white(float average, ivec2 pixel_pos){
    
    bool pixel_bools[16] = bool[](
        modi((pixel_pos.x),4) == 0&&modi((pixel_pos.y+3),4) == 0,
        modi((pixel_pos.x+2),4) == 0&&modi((pixel_pos.y+1),4) == 0,
        modi((pixel_pos.x+2),4) == 0&&modi((pixel_pos.y+3),4) == 0,
        modi((pixel_pos.x),4) == 0&&modi((pixel_pos.y+1),4) == 0,
        modi((pixel_pos.x+1),4) == 0&&modi((pixel_pos.y+2),4) == 0,
        modi((pixel_pos.x+3),4) == 0&&modi((pixel_pos.y),4) == 0,
        modi((pixel_pos.x+3),4) == 0&&modi((pixel_pos.y+2),4) == 0,
        modi((pixel_pos.x+1),4) == 0&&modi((pixel_pos.y),4) == 0,
        modi((pixel_pos.x+1),4) == 0&&modi((pixel_pos.y+3),4) == 0,
        modi((pixel_pos.x+3),4) == 0&&modi((pixel_pos.y+1),4) == 0,
        modi((pixel_pos.x+3),4) == 0&&modi((pixel_pos.y+3),4) == 0,
        modi((pixel_pos.x+1),4) == 0&&modi((pixel_pos.y+1),4) == 0,
        modi((pixel_pos.x),4) == 0&&modi((pixel_pos.y+2),4) == 0,
        modi((pixel_pos.x+2),4) == 0&&modi((pixel_pos.y),4) == 0,
        modi((pixel_pos.x+2),4) == 0&&modi((pixel_pos.y+2),4) == 0,
        true
    );

    bool result = false;
    int max_i = int(average*17.0);
    for (int i = 0; i < max_i; i++){
        result = result||pixel_bools[i];
    }
    return result;
}


// -----------------------------------------------
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------
  
    vec4 cur_pixel = texture2D(CoronaSampler0, UV);
    ivec2 pixel_pos = ivec2(UV / CoronaTexelSize.zw);
      float average = (cur_pixel.r + cur_pixel.g + cur_pixel.b) / 3.0;
    if(is_white(average, pixel_pos)){
        //COLOR = vec4( color_light, cur_pixel.a); // Solid Color
        COLOR = vec4( cur_pixel.rgb, cur_pixel.a);
    } else {
        COLOR = vec4( color_dark, cur_pixel.a ); // Solid Color
        //COLOR = vec4( cur_pixel.rgb, cur_pixel.a);

    }
  //----------------------------------------------
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    

--]]


