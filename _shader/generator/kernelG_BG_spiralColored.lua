
--[[
    Godot Shader Snippet
  
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "spiralColored"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Progress",  default = .5, min = 0, max = 1, index = 0, },
  { name = "Speed",     default = -4, min = -10, max = 10, index = 1, },
  { name = "Arm",       default = 1.6, min = -20, max = 20, index = 2, },
  { name = "Zoom",      default = -30, min = -300, max = 300, index = 3, },
} 


kernel.fragment =
[[

float Progress = CoronaVertexUserData.x;
float Speed = CoronaVertexUserData.y;
float Arm = CoronaVertexUserData.z;
float Zoom = CoronaVertexUserData.w;
//----------------------------------------------

P_COLOR vec4 color = vec4 (1, 0, 0, 1);// hint

//----------------------------------------------

float f_swirl(vec2 uv, float size, int arms)
{
    float angle = atan(-uv.y + 0.5, uv.x - 0.5) ;
    float len = length(uv - vec2(0.5, 0.5));

    return sin(len * size + angle * float(arms));
}

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
    mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
            vec2(cos(angle), sin(angle)));

    uv -= pivot;
    uv = uv * rotation;
    uv += pivot;
    return uv;
}

//----------------------------------------------

float TIME = CoronaTotalTime * Speed;

P_COLOR vec4 COLOR = vec4(color.rgb,color.a);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    int arm = int( Arm );
    //float swirl = f_swirl(UV, Zoom, arm);

    vec2 rotated_uv = rotate(UV, vec2(0.5), TIME);
    float swirl = f_swirl(rotated_uv, Zoom, arm);

    COLOR += vec4(vec3(swirl), 1.0); //Swirl
    //----------------------------------------------
    

    COLOR.a = Progress * 4;
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


