
--[[
    https://godotshaders.com/shader/animated-diamond-pattern/
    kcfresh53
    September 26, 2023


--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "diamondPattern"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",     default = 2, min = -15, max = 15, index = 0, },
  { name = "Rot",       default = 45, min = 0, max = 360, index = 1, },
  { name = "DistR",     default = .1, min = -2, max = 4, index = 2, },
  { name = "EdgeR",   default = 2, min = 1, max = 10, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Rot = CoronaVertexUserData.y;
float DistR = CoronaVertexUserData.z;
float EdgeR = CoronaVertexUserData.w;

//----------------------------------------------

P_COLOR vec4 Col_1 = vec4(1.0, 1.0, 1.0, 1.0);
P_COLOR vec4 Col_2 = vec4(.5, 0.75, 1.0, 1.0);

//----------------------------------------------

float TIME = CoronaTotalTime * Speed;
vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;
vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    vec2 FRAGCOORD = UV * iResolution;

    //----------------------------------------------
    float aspect = (1.0 / SCREEN_PIXEL_SIZE).y / (1.0 / SCREEN_PIXEL_SIZE).x;
    float value;

    vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).x;
    uv -= vec2(0.5, 0.5 * aspect);

    float rot = radians( Rot );
    float s = sin(rot);
    float c = cos(rot);

    float newX = uv.x * c - uv.y * s;
    float newY = uv.x * s + uv.y * c;

    uv = vec2(newX, newY);

    uv += vec2(0.5, 0.5 * aspect);
    uv.y += 0.5 * (1.0 - aspect);

    vec2 pos = 10.0 * uv;
    vec2 rep = fract(pos);
    float dist = 2.0 * min(min(rep.x, 1.0 - rep.x), min(rep.y, 1.0 - rep.y));
    float squareDist = length((floor(pos) + vec2(0.5)) - vec2(5.0));

    float edge = sin(TIME - squareDist * 0.5) * 0.5 + 0.5;
    edge = (TIME - squareDist * 0.5) * 0.5;
    edge = 2.0 * fract(edge * 0.5);

    value = fract(dist * 2.0);
    value = mix(value, 1.0 - value, step(1.0, edge));
    edge = pow(abs(1.0 - edge), EdgeR);
    value = smoothstep(edge - 0.05, edge, 0.95 * value);
    value += squareDist * DistR;

    //COLOR = mix(vec4(1.0, 1.0, 1.0, 1.0), vec4(0.5, 0.75, 1.0, 1.0), value);
    COLOR = mix( Col_1, Col_2, value );
    COLOR.a = 0.25 * clamp(value, 0.0, 1.0);

    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


