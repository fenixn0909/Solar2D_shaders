
--[[
    Transparent noise border
    https://godotshaders.com/shader/transparent-noise-border/
    rainlizard
    February 26, 2024
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "FX"
kernel.name = "noiseBorder" 

kernel.isTimeDependent = true

kernel.textureWrap = 'repeat'

kernel.vertexData =
{
  { name = "Radius",     default = 0.516459, min = 0, max = 1, index = 0, },
  { name = "EffectCon",  default =  .4309, min = 0, max = 1, index = 1, },
  { name = "BurnSpeed",      default = 0.3076, min = 0, max = 1, index = 2, },
  { name = "Shape",      default = 0.5, min = 0, max = 1, index = 3, },
} 


kernel.fragment =
[[

float Radius = CoronaVertexUserData.x;
float EffectCon = CoronaVertexUserData.y;
float BurnSpeed = CoronaVertexUserData.z;    // vec2(0,0.2): rise, vec2(1,-.1): left lines
float Shape = CoronaVertexUserData.w;
//----------------------------------------------

uniform sampler2D TEXTURE;
// uniform sampler2D textureNoise; // CoronaSampler1


//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{


    //----------------------------------------------

    vec2 centerDistVec = vec2(0.5) - UV;
        
    float distToCircleEdge = length(centerDistVec) * Radius;
    float distToSquareEdge = 0.5*(0.5 - min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
    float distToEdge = mix(distToCircleEdge,distToSquareEdge,Shape);

    float gradient = smoothstep(0.5, 0.5 - Radius, distToEdge);

    vec2 direction = vec2(0, 1) * BurnSpeed;
    //float noiseValue = texture2D(textureNoise, UV + direction * TIME).r;
    float noiseValue = texture2D(CoronaSampler1, UV + direction * TIME).r;

    float opacity = step(Radius, mix(gradient, noiseValue, EffectCon) - distToEdge);

    COLOR = texture2D(TEXTURE, UV) * vec4(1.0, 1.0, 1.0, opacity);

    //----------------------------------------------
    
    // Restrict to texture alpha
    //COLOR.a = alpha;
    COLOR.rgb *= COLOR.a;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


