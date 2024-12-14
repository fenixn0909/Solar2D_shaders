
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

kernel.vertexData =
{
  {
    name = 'intensity',
    default = 0.0,
    min = 0,
    max = 10,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  
}


kernel.fragment =
[[

uniform sampler2D TEXTURE;
// uniform sampler2D textureNoise; // CoronaSampler1


uniform float radius = 0.516459;   //: hint_range(0.0, 1.0) 
uniform float effectControl = .4309;    //: hint_range(0.0, 1.0) 
uniform float burnSpeed = 0.3076;    //: hint_range(0.0, 1.0) 
uniform float shape = .50;  //: hint_range(0.0, 1.0) 


//----------------------------------------------

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{


    //----------------------------------------------

    vec2 centerDistVec = vec2(0.5) - UV;
        
    float distToCircleEdge = length(centerDistVec) * radius;
    float distToSquareEdge = 0.5*(0.5 - min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
    float distToEdge = mix(distToCircleEdge,distToSquareEdge,shape);

    float gradient = smoothstep(0.5, 0.5 - radius, distToEdge);

    vec2 direction = vec2(0, 1) * burnSpeed;
    //float noiseValue = texture2D(textureNoise, UV + direction * TIME).r;
    float noiseValue = texture2D(CoronaSampler1, UV + direction * TIME).r;

    float opacity = step(radius, mix(gradient, noiseValue, effectControl) - distToEdge);

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


