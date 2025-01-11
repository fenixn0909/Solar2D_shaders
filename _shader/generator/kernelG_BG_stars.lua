
--[[
    https://www.shadertoy.com/view/lsfGWH
    

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "stars"

kernel.isTimeDependent = true



kernel.vertexData =
{
  { name = "Speed",     default = 3.5, min = 0, max = 15, index = 0, },
  { name = "Zoom",      default = 30, min = 1, max = 100, index = 1, },
  { name = "Prob",      default = 0.95, min = 0.01, max = 1, index = 2, },
  { name = "Blink",     default = 1, min = 0, max = 100, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Zoom = CoronaVertexUserData.y;
float Prob = CoronaVertexUserData.z;    // vec2(0,0.2): rise, vec2(1,-.1): left lines
float Blink = CoronaVertexUserData.w;
//----------------------------------------------

#define M_PI 3.1415926535897932384626433832795


//----------------------------------------------

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

//-----------------------------------------------
float iTime = CoronaTotalTime * Speed;
P_COLOR vec4 COLOR = vec4(0);
P_UV vec2 iResolution = 1 / CoronaTexelSize.zw;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

    P_UV vec2 fragCoord = texCoord * iResolution;

    //----------------------------------------------

    vec2 pos = floor(1.0 / Zoom * fragCoord.xy);
    pos.x += iTime * Blink * 0.000001;

    float color = 0.0;
    float starValue = rand(pos);
    
    if (starValue > Prob)
    {
        vec2 center = Zoom * pos + vec2(Zoom, Zoom) * 0.5;
        
        float t = 0.9 + 0.2 * sin(iTime + (starValue - Prob) / (1.0 - Prob) * 45.0);
                
        color = 1.0 - distance(fragCoord.xy, center) / (0.5 * Zoom);
        color = color * t / (abs(fragCoord.y - center.y)) * t / (abs(fragCoord.x - center.x));
    }
    else if (rand(fragCoord.xy / iResolution.xy) > 0.996)
    {
        float r = rand(fragCoord.xy);
        color = r * (0.25 * sin(iTime * (r * 5.0) + 720.0 * r) + 0.75);
    }
    
    COLOR = vec4(vec3(color), 1.0);
    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


