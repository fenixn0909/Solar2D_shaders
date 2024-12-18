 
--[[
    https://godotshaders.com/shader/discrete-ocean/
    Moraguma
    September 30, 2024

    Smoke-ish is color alpha < 1 

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "discreteOcean"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Amp",        default = 0.05, min = 0, max = .05, index = 0, },
  { name = "Size",       default = 1, min = 0, max = 10, index = 1, },
  { name = "Speed",      default = 1.0, min = -15, max = 15, index = 2, },
  { name = "Waves",      default = 10, min = 1, max = 50, index = 3, },
} 

kernel.fragment =
[[

float Amp = CoronaVertexUserData.x;
float Size = CoronaVertexUserData.y;
float Speed = CoronaVertexUserData.z;
float Waves = CoronaVertexUserData.w;

//----------------------------------------------

P_COLOR vec4 bottom_color = vec4( .8, 1.0, 1.2, 0.8); 
P_COLOR vec4 top_color = vec4( 0.0, 0.0, 0.0, 0.9); 

const float PI = 3.14159265359;

//----------------------------------------------

float rand(float n){return fract(sin(n) * 43758.5453123);}

float noise(float p){
    float fl = floor(p);
  float fc = fract(p);
    return mix(rand(fl), rand(fl + 1.0), fc);
}

float fmod(float x, float y) {
    return x - floor(x / y) * y;
}

vec4 lerp(vec4 a, vec4 b, float w) {
    return a + w * (b - a);
}

//-----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------

    float t = float(Waves);
    float effective_wave_amp = min(Amp, 0.5 / t);
    float d = fmod(UV.y, 1.0 / t);
    float i = floor(UV.y * t);
    float vi = floor(UV.y * t + t * effective_wave_amp);
    float s = effective_wave_amp * sin((UV.x + TIME * max(1.0 / t, noise(vi)) * Speed * vi / t) * 2.0 * PI * Size);
    
    if (d < s) i--;
    if (d > s + 1.0 / t) i++;
    i = clamp(i, 0.0, t - 1.0);
    
    COLOR = lerp(top_color, bottom_color, i / (t - 1.0));

    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


