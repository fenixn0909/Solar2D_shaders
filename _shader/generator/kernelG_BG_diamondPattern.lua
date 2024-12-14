
--[[
    https://godotshaders.com/shader/animated-diamond-pattern/
    kcfresh53
    September 26, 2023

    ✳️ Need check on device!! issue: gl_FragCoord ✳️

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "diamondPattern"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "scrnPxW",
    default = 600,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "scrnPxH",
    default = 2000,
    min = 1,
    max = 9999,     
    index = 1,    -- v_UserData.y
  },
}


kernel.fragment =
[[


float scrnPxW = CoronaVertexUserData.x;
float scrnPxH = CoronaVertexUserData.y;

const float tweak = 1;
P_UV vec2 SCREEN_PIXEL_SIZE = tweak/vec2( scrnPxW, scrnPxH );

//----------------------------------------------

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed



P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    vec4 FRAGCOORD = gl_FragCoord;

    //----------------------------------------------

    float aspect = (1.0 / SCREEN_PIXEL_SIZE).y / (1.0 / SCREEN_PIXEL_SIZE).x;
    float value;

    vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).x;
    uv -= vec2(0.5, 0.5 * aspect);

    float rot = radians(45.0);
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
    edge = pow(abs(1.0 - edge), 2.0);
    value = smoothstep(edge - 0.05, edge, 0.95 * value);
    value += squareDist * 0.1;

    COLOR = mix(vec4(1.0, 1.0, 1.0, 1.0), vec4(0.5, 0.75, 1.0, 1.0), value);
    COLOR.a = 0.25 * clamp(value, 0.0, 1.0);

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


