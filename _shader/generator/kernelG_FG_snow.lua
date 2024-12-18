
--[[
    https://godotshaders.com/shader/let-it-snow/
    gerardogc2378
    September 8, 2023

    #OVERHEAD: crank the var up too much will cause overhead!

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FG"
kernel.name = "snow"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",                     default = 2.5, min = -10, max = 10, index = 0, },
  { name = "Motion",                    default = 7.5, min = 0, max = 50, index = 1, },
  { name = "Layers", --[[#OVERHEAD!]]   default = 27, min = 0, max = 50, index = 2, },
  { name = "Size",                      default = 20, min = 0, max = 20, index = 3, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Motion = CoronaVertexUserData.y; 
float Layers = CoronaVertexUserData.z;
float Size = CoronaVertexUserData.w;

//----------------------------------------------
  
P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    int layers = int( Layers );
    float size = Size * 0.01;
    float speed = Speed * -1;
    //----------------------------------------------
  
    mat3 p = mat3(vec3(13.323122,23.5112,21.71123), vec3(21.1212,28.7312,11.9312), vec3(21.8112,14.7212,61.3934));
    vec2 uv = UV;
    vec3 acc = vec3(0.1, 0.1, 0.4);
    float dof = 5.0 * sin(TIME * .1);
    for (int i = 0; i < layers; i++) {
        float fi = float(i);
        vec2 q = uv * (1.0 + fi * .5);
        q += vec2(q.y * (Motion * mod(fi * 7.238917, 1.0) - Motion * 0.5), speed * TIME / (1.0 + fi * 0.5 * 0.03));
        vec3 n = vec3(floor(q), 31.189 + fi);
        vec3 m = floor(n) * 0.00001 + fract(n);
        vec3 mp = (31415.9 + m) / fract(p * m);
        vec3 r = fract(mp);
        vec2 s = abs(mod(q, 1.0) - 0.5 + 0.9 * r.xy - 0.45);
        s += 0.01 * abs(2.0 * fract(10.0 * q.yx) - 1.0); 
        float d = 0.6 * max(s.x - s.y, s.x + s.y) + max(s.x, s.y) - 0.01;
        float edge = size + 0.05 * min(0.5 * abs(fi - 5.0 - dof), 1.0);
        acc += vec3(smoothstep(edge, -edge, d) * (r.x / (1.0 + 0.02 * fi * 0.5)));
    }
    COLOR = vec4(vec3(acc), 1.0);
    //----------------------------------------------
    // Transparent Filter
    COLOR.a = max(sign(0.2 - (COLOR.r + COLOR.g + COLOR.b)), 0.0);
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


