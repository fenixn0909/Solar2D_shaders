
--[[
    https://godotshaders.com/shader/2d-spinning-sphere/ks_disco
    alxl
    December 13, 2021

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "sphere"
kernel.name = "spine2D"

kernel.isTimeDependent = true

kernel.textureWrap = 'repeat'

kernel.vertexData =
{
  { name = "Rot_Speed",  default = 0.3, min = -15, max = 15, index = 0, },
  { name = "Aspect_Ratio",  default = 2, min = -15, max = 15, index = 1, },
} 



kernel.fragment =
[[

float Rot_Speed = CoronaVertexUserData.x;
float Aspect_Ratio = CoronaVertexUserData.y;
float RotZ = CoronaVertexUserData.z;
float RotW = CoronaVertexUserData.w;
//-----------------------------------------------
uniform sampler2D TEXTURE;

bool As_Shadow = false;

const float PI = 3.14159265359;

//-----------------------------------------------
float TIME = CoronaTotalTime;
P_COLOR vec4 COLOR = vec4(0);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    float px = 2.0 * (UV.x - 0.5);
    float py = 2.0 * (UV.y - 0.5);
    
    if (px * px + py * py > 1.0) {
        // Outside of "sphere"
        COLOR.a = 0.0;
    } else {
        px = asin(px / sqrt(1.0 - py * py)) * 2.0 / PI;
        py = asin(py) * 2.0 / PI;
        
        COLOR = texture2D(TEXTURE, vec2(
            0.5 * (px + 1.0) / Aspect_Ratio - TIME * Rot_Speed,
            0.5 * (py + 1.0)));
        
        if (As_Shadow) {
            COLOR.rgb = vec3(0.0, 0.0, 0.0);
            COLOR.a *= 0.9;
        }
    }

    //-----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]


return kernel




--[[



--]]





