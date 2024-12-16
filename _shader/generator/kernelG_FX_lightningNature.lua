
--[[
    https://godotshaders.com/shader/lightning/
    FencerDevLog
    November 26, 2023
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "lightningNature"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "amp_start",
    default = 0.5,
    min = -1,
    max = 1,
    index = 0,    
  },
  {
    name = "amp_coeff",
    default = 0.5,
    min = -.75,
    max = .75,     
    index = 1,    
  },
  {
    name = "freq_coeff",
    default = 2.0,
    min = 0,
    max = 30,     
    index = 2,    
  },
  {
    name = "speed",
    default = .5,
    min = 0,
    max = 50,     
    index = 3,    
  },
}


kernel.fragment =
[[

//----------------------------------------------


float amp_start = CoronaVertexUserData.x;
float amp_coeff = CoronaVertexUserData.y;
float freq_coeff = CoronaVertexUserData.z;
float speed = CoronaVertexUserData.w;

int octave_count = 10; //: hint_range(1, 20)
vec3 effect_color = vec3(0.2, 0.3, 0.8); //: source_color 


//----------------------------------------------

float hash12(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)),
              dot(uv, vec2(269.5,183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
                   dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
                   dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 uv, int octaves) {
    float value = 0.0;
    float amplitude = amp_start;
    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(uv);
        uv *= freq_coeff;
        amplitude *= amp_coeff;
    }
    return value;
}

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //----------------------------------------------

    vec2 uv = 2.0 * UV - 1.0;
    uv += 2.0 * fbm(uv + TIME * speed, octave_count) - 1.0;
    float dist = abs(uv.x);
    vec3 color = effect_color * mix(0.0, 0.05, hash12(vec2(TIME))) / dist;
    COLOR = vec4(color, 1.0);

    float _cChk =  COLOR.r + COLOR.g + COLOR.b;
    float _a = max(sign(_cChk - 0.8), 0.0);
    //----------------------------------------------
    COLOR.a = _a;
    COLOR.rgb *= _a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


