--[[
    https://godotshaders.com/shader/ripple-effect/
    samuelmq2
    December 11, 2022
--]]



local kernel = {}

kernel.language = "glsl"

kernel.category = "filter"
kernel.group = "ripple"
kernel.name = "square"

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
vec3 Col_Line = vec3( 1.0, 0.0, 0.0); //: source_color; 
float Num_Cells = 25.0; //: hint_range(2.0, 20.0, 1.0)
float Speed = 1.0; //: hint_range(0.1,2.0, 0.01)
float Smoothness = 1.0; //: hint_range(0.5, 2.0, 0.01)
float Angle = 90.0; //: hint_range(0.0, 360.0)
//----------------------------------------------

const float PI = 3.141516;
//----------------------------------------------

float when_gt(float x, float y) { //greater than return 1
  return max(sign(x - y), 0.0);
}


float rectanglef (vec2 uv, float width, float height, float feather){
    vec2 uv_cartesian = uv * 2.0 - 1.0; 
    vec2 uv_reflected = abs(uv_cartesian); 
    float dfx = smoothstep(width,width+feather,uv_reflected.x);
    float dfy = smoothstep(height,height+feather,uv_reflected.y); 
    return max(dfx,dfy); 
}

vec2 rotation ( vec2 uv, vec2 center, float ang){
    mat2 rotation = mat2(
          vec2(cos(ang), -sin(ang)), 
          vec2(sin(ang), cos(ang))
          );
    uv -= center; 
    uv *= rotation; 
    uv += center; 
    return uv;         
}

//----------------------------------------------

P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{   
    
    float alpha = texture2D( CoronaSampler0, UV ).a;
    //----------------------------------------------

    vec2 igrid = floor(UV * Num_Cells)/Num_Cells;

    igrid = rotation(igrid, vec2(0.5), Angle * PI/180.0); 
    igrid.x += 2.0 - mod(TIME*Speed,4.0); 
    vec2 fgrid = fract(UV * Num_Cells); 
    float rect_mask = rectanglef(igrid, 0.001,2.0,Smoothness); 
    float grid_mask = 1.0 - rectanglef(fgrid,rect_mask,rect_mask,0.0); 
    float outline_mask = 1.0 - rectanglef(fgrid,rect_mask+0.1,rect_mask+0.1,0.0) - grid_mask; 
    vec3 outline = outline_mask * Col_Line; 
    //vec3 tex = texture(TEXTURE,UV).rgb; 
    P_COLOR vec3 texColor = texture2D( CoronaSampler0, UV ).rgb;
    vec3 mixColor = mix(texColor,outline,outline_mask); 
    P_COLOR vec4 COLOR = vec4(mixColor,outline_mask + grid_mask); 
    COLOR.rgb *= COLOR.a;
    
    //----------------------------------------------
    // Totally Cut RGBA Outside of Texture
    COLOR *= when_gt( alpha, 0 );


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[


--]]
