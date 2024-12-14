 
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



-- kernel.vertexData =
-- {
--   {
--     -- hint_range( 0.5, 1.5, 2) >1: Higher, <1: Reverse
--     name = "offset",    
--     default = 1.5,
--     min = -5,
--     max = 5,
--     index = 0, 
--   },
-- }


kernel.fragment =
[[
//----------------------------------------------

uniform vec4 bottom_color = vec4( 0.3, 0.6, 0.8, .3); //: source_color;
uniform vec4 top_color = vec4( 0.0, 0.0, 0.0, 0.5); //: source_color;

uniform float wave_amp =  0.5; //: hint_range(0.0, 0.5);
uniform float wave_size =  1.0; //: hint_range(1.0, 10.0);
uniform float wave_time_mul =  1.0; //: hint_range(0.1, 2.0);

uniform int total_phases = 10; //: hint_range(2, 600, 1);



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


//----------------------------------------------

//-----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------

    float t = float(total_phases);
        float effective_wave_amp = min(wave_amp, 0.5 / t);
        float d = fmod(UV.y, 1.0 / t);
        float i = floor(UV.y * t);
        float vi = floor(UV.y * t + t * effective_wave_amp);
        float s = effective_wave_amp * sin((UV.x + TIME * max(1.0 / t, noise(vi)) * wave_time_mul * vi / t) * 2.0 * PI * wave_size);
        
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


