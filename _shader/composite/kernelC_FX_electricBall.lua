
--[[
    https://godotshaders.com/shader/electric-ball-canvas-item/
    Grandpa_Pit
    July 9, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "FX"
kernel.name = "electricBall"


kernel.isTimeDependent = true


kernel.vertexData =
{
  { name = "Speed",     default = 0, min = -1, max = 1, index = 0, },
  { name = "Brightness",  default =  6, min = 1, max = 10, index = 1, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Brightness = CoronaVertexUserData.y;

vec4 Col_Light = vec4( .5, 1., 0.3, 1.);

//----------------------------------------------

float PI = 3.14159265359;

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //----------------------------------------------

    vec2 cc_uv = UV - vec2(.5); 
    float angle = atan(cc_uv.y, cc_uv.x) / PI + 1.;
    float p = sqrt(dot(cc_uv, cc_uv)); 
    vec2 puv = vec2(p, angle * .5);
    vec2 uv = puv * 2.;
    float time = TIME * Speed;
    vec4 old_colo = Col_Light;
    COLOR = vec4(.0);
    for(int i = 1; i <= 5; i++){
        float intensive = .1 + .07 * float(i);
        vec2 offset = (texture2D(CoronaSampler0, vec2(time*.35*(.5+fract(sin(float(i)*55.))), angle)).rg - vec2(.5)) * intensive; 
        vec2 uuv = uv + offset;
        float dist = abs(uuv.x - .5);
        float rand_speed = .2 + .05 * fract(cos(float(i)*1144.));
        float gone = smoothstep(.1 + 0.05 * (float(i) - .5), 1.0, texture2D(CoronaSampler1, uv + vec2(time*rand_speed)).s);
        COLOR += gone * old_colo / dist * .01 * texture2D(CoronaSampler1, uuv + vec2(time)).s;
    }
    vec4 light = old_colo * smoothstep(1.0, -2.0, abs(uv.x - .5) * 2.0) * texture2D(CoronaSampler1, uv).a; 
    COLOR += light * Brightness; 

    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    
--]]


