
--[[
    https://godotshaders.com/shader/discrete-clouds/
    Moraguma
    October 14, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "BG"
kernel.name = "discreteClouds"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.fragment =
[[
P_DEFAULT float resolutionX = CoronaVertexUserData.x;
P_DEFAULT float resolutionY = CoronaVertexUserData.y;

//----------------------------------------------

uniform vec4 bottom_color   = vec4( 1.0, .95, .75, 1.0 ); //: source_color
uniform vec4 top_color      = vec4( 0.0, 0.2, 0.3 ,1.0 ); //: source_color

uniform int layer_count = 7; //: hint_range(2, 80, 1)
uniform float time_scale = .2; //: hint_range(0.0, 1.0)     Speed
uniform float base_intensity = .5; //: hint_range(0.0, 1.0) Bubble Fading, lower the sooner
uniform float size = .91; //: hint_range(0.00001, 0.5, 1.0) Lower the smaller + longer


P_DEFAULT float TIME = CoronaTotalTime;

//----------------------------------------------

vec4 lerp(vec4 a, vec4 b, float w) {
    return a + w * (b - a);
}

float fmod(float x, float y) {
    return x - floor(x / y) * y;
}

float rand(float n){return fract(sin(n) * 43758.5453123);}

bool cloud_layer(float x, float y, float h) {
    return y - sqrt((1.0 - pow(y - h, 2.0))) * base_intensity * texture2D(CoronaSampler0, vec2(fmod(x / size + rand(h), 1.0), fmod(y / size - TIME * time_scale, 1.0))).r < h;
}

// -----------------------------------------------
P_COLOR vec4 COLOR;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  
  //----------------------------------------------
  float y = 1.0 - UV.y;

    for (int i = 0; i < layer_count; i++) {
        float h = float(i) / float(layer_count - 1);
        if (cloud_layer(UV.x, y, h)) {
            COLOR = lerp(bottom_color, top_color, h);
            break;
        }
    }

  //----------------------------------------------
  
  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


