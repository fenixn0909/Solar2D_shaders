--[[
  Origin Author: flotos
  https://godotshaders.com/author/flotos/
  
  Animate your backgrounds tree, or grass, with X, Y movement and global wind waves.

--]]



local kernel = {}

kernel.language = "glsl"

kernel.category = "filter"
kernel.group = "wobble"
kernel.name = "foliage"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "x",
    default = 1,
    min = 0,
    max = 4,
    index = 0, -- v_UserData.x
  },
  {
    name = "y",
    default = 1,
    min = 0,
    max = 4,
    index = 1, -- v_UserData.y
  },
}


kernel.fragment =
[[

float x_intensity = 3.0;
float y_intensity = 0.5;
float offset = 0.0;
float speed = 2.0; //: hint_range(0, 20) 
float wave_frequency = 20;//: hint_range(0, 100) 
float wave_length = 200.0;//: hint_range(50, 800) 



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{   
    P_UV vec2 UV = texCoord;
    P_DEFAULT float TIME = CoronaTotalTime;
    
    vec2 real_uv = vec2(UV.x, UV.y);
    
    vec2 vecToBottom = vec2(1, 1) - UV.y; 
    float distToBottom = length(vecToBottom);
    
    float final_speed = TIME * (speed / 4.0) + offset;
    
    float time_var = (cos(final_speed) * cos(final_speed * 4.0) * cos(final_speed * 2.0))/(200.0);
    float time_var2 = (cos(final_speed) * cos(final_speed * 6.0) * cos(final_speed * 2.0))/(200.0);
    
    float wave_from_x = (cos(real_uv.x * 100.0)/1000.0);
    float wave_large_from_x = cos(TIME + (real_uv.x * wave_frequency))/wave_length;
    
    float wave_from_y = (cos(real_uv.y * 99000.0)/90000.0);
    
    float new_x = real_uv.x + time_var * (distToBottom * x_intensity) + wave_from_x + (wave_large_from_x);
    float new_y = real_uv.y + time_var2 * (distToBottom * y_intensity);
    
    vec2 new_uv1 = vec2(new_x, new_y);
    vec4 new_texture = texture2D( CoronaSampler0, new_uv1);
    
    /*
    P_COLOR vec4 COLOR;
    if(new_texture.rgb != vec3(1,1,1)){
        COLOR.rgba = new_texture.rgba;
    }
    */

    
  
    return CoronaColorScale( new_texture );
}
]]

return kernel

--[[


--]]
