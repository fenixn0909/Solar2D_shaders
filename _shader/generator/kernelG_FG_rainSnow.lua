
--[[
    https://godotshaders.com/shader/rain-and-snow-with-parallax-scrolling-effect/
    Steampunkdemon July 9, 2023

--]]

local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FG"
kernel.name = "rainSnow"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "BaseSpd",     default = 0.5, min = -5, max = 5, index = 0, },
  { name = "Amount",      default = 500, min = 0, max = 1000, index = 1, },
  { name = "Slant",      default = 0.2, min = -10, max = 10, index = 2, },
  { name = "FarRainW",      default = 0.2, min = -1, max = 1, index = 3, },
} 

kernel.fragment =
[[

float BaseSpd = CoronaVertexUserData.x;
float Amount = CoronaVertexUserData.y;
float Slant = CoronaVertexUserData.z;    // vec2(0,0.2): rise, vec2(1,-.1): left lines
float FarRainW = CoronaVertexUserData.w;
//----------------------------------------------

//uniform float BaseSpd = 0.0; // : hint_range(0.1, 1.0) 
//uniform float Amount = 500.0; //500
//uniform float Slant = .2; // : hint_range(-1.0, 1.0) 
//uniform float FarRainW = .5; // : hint_range(0.1, 1.0) 


uniform float near_rain_length = 0.015; // : hint_range(0.01, 1.0) 
uniform float far_rain_length = 0.025; // : hint_range(0.01, 1.0) 
uniform float near_rain_width = 1.0; // : hint_range(0.1, 1.0) 
uniform float near_rain_transparency = 1.0; // : hint_range(0.1, 1.0) 
uniform float far_rain_transparency = 1.5; // : hint_range(0.1, 1.0) 
// Replace the below reference to source_color with hint_color if you are using a version of Godot before 4.
uniform vec4 rain_color = vec4(0.6, 0.7, 0.8, 1.0); // : source_color 

uniform float additional_rain_speed = 0.2; // : hint_range(0.1, 1.0) 

uniform vec4 color = vec4( .0, .05, .1, 0); // : hint_range(-1.0, 1.0) 


// -----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV );
    P_COLOR vec4 COLOR = color;

    P_DEFAULT float TIME = CoronaTotalTime;
    //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
    //----------------------------------------------

    // To control the rainfall from your program comment out the below line and add a new uniform above as:
    // uniform float time = 10000.0;
    // Then update the time uniform from your _physics_process function by adding delta. You can then pause the rainfall by not changing the time uniform.
    float time = 10000.0 + TIME;

    // Uncomment the following line if you are applying the shader to a TextureRect and using a version of Godot before 4.
    //  COLOR = texture(TEXTURE,UV);

    vec2 uv = vec2(0.0);
    float remainder = mod(UV.x - UV.y * Slant, 1.0 / Amount);
    uv.x = (UV.x - UV.y * Slant) - remainder;
    float rn = fract(sin(uv.x * Amount));
    uv.y = fract((UV.y + rn));


    vec4 rainC;
    // Blurred trail. Works well for rain:
    //rainC = mix(COLOR, rain_color, smoothstep(1.0 - (far_rain_length + (near_rain_length - far_rain_length) * rn), 1.0, fract(uv.y - time * (BaseSpd + additional_rain_speed * rn))) * (far_rain_transparency + (near_rain_transparency - far_rain_transparency) * rn) * step(remainder * Amount, FarRainW + (near_rain_width - FarRainW) * rn));

    // No trail. Works well for snow:
    rainC = mix(COLOR, rain_color, step(1.0 - (far_rain_length + (near_rain_length - far_rain_length) * rn), fract(uv.y - time * (BaseSpd + additional_rain_speed * rn))) * (far_rain_transparency + (near_rain_transparency - far_rain_transparency) * rn) * step(remainder * Amount, FarRainW + (near_rain_width - FarRainW) * rn));

    COLOR = rainC;
    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    
    void fragment() {
    
    }
--]]


