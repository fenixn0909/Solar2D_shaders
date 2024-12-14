
--[[
    Simple noise overlay
    https://godotshaders.com/shader/simple-noise-overlay/
    MacNaab
    May 28, 2022
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "FX"
kernel.name = "noiseOverlay" 

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
//uniform sampler2D noise; //CoronaSampler1

uniform vec2 direction = vec2(1, 0);
uniform float speed = 0.1;

//----------------------------------------------
vec4 overlay(vec4 base, vec4 blend){
    vec4 limit = step(0.5, base);
    return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------

    // image texture
    vec4 base = texture2D(TEXTURE, UV);
    // noise texture
    vec4 blend = texture2D(CoronaSampler1, UV + ( direction * speed * TIME));
    
    COLOR = overlay(base, blend);
    //----------------------------------------------
    
    // Restrict to texture alpha
    //COLOR.a = alpha;
    //COLOR.rgb *= COLOR.a;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


