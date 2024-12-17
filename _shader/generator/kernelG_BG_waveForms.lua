
--[[
  
  Origin Author: pend00
  https://godotshaders.com/shader/waveforms/
  
  

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "waveForms"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Progress",          default = .5, min = 0, max = 1, index = 0, },
  { name = "Intensity",         default = .5, min = 0, max = 10, index = 1, },
  { name = "Sharpness",         default = .5, min = 0, max = 1, index = 2, },
  { name = "Edge",              default = .05, min = 0, max = .5, index = 3, },
} 


kernel.fragment =
[[

float Progress = CoronaVertexUserData.x;
float Intensity = CoronaVertexUserData.y; 
float Sharpness = CoronaVertexUserData.z;
float Edge = CoronaVertexUserData.w;

//----------------------------------------------

//uniform float Intensity = 2.8; // : hint_range(0.0, 2.0)How fast will the speech movement be
//uniform float Sharpness = .5; //: hint_range(0.0, 1.0)    Fuzzy edges on each line
//uniform float Edge = .05; // : hint_range(0.0, 0.5) Speach Intensity: How close to the edges should the animation beginn 

uniform int lines = 80; // Amount of lines the waveform is build up of
uniform float amplitude = .9;    // : hint_range(0.0, 1.0)    Height of the wave
uniform float frequency = 0.1;    // : hint_range(0.0, 0.5)    Set a lower value for a smoother wave
uniform float intensity = .75;   //: hint_range(0.0, 1.0)     Lower values creates gaps in the wave while higher make the wave more solid
uniform float line_size = .8;    // : hint_range(0.0, 1.0)    Thickness of the lines
uniform float fade = 0.1; // : hint_range(0.0, 0.5)           Blurres the top and bottom of the lines
uniform float rest_size = -.2; // : hint_range(-2., 2.)      The size of the lines when the line is not animating, i.e at value 0. Tweak if Fade is used.
uniform float Speed = .5; // Speed of wave animation

uniform vec4 color  = vec4(.8, 0.25, 0.5, 1.0); //: hint_color Color of wave

uniform bool dot_matrix = true; 
uniform int dot_matriz_size = 80;
uniform bool speech_sim = true; // Toggle to simulate speach. Will create a more erratic movement in the wave

//----------------------------------------------

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
    vec2(12.9898,78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    // Four corners in 2D of a tile
    float a = random(uv_index);
    float b = random(uv_index + vec2(1.0, 0.0));
    float c = random(uv_index + vec2(0.0, 1.0));
    float d = random(uv_index + vec2(1.0, 1.0));

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(a, b, blur.x) +
        (c - a) * blur.y * (1.0 - blur.x) +
        (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv) {
    int octaves = 4;
    float amp = 0.5;
    float freq = 4.;
    float value = 0.0;

    for(int i = 0; i < octaves; i++) {
    value += amp * noise(freq * uv - 0.5);
    amp *= 0.6;
    freq *= 2.;
    }
    return value;
}


//-----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    //----------------------------------------------
  
    // Some initialising
    float time = TIME * Speed;
    float progress = Progress * .5 + .5;
    vec4 c = vec4(vec3(0.0), 1.0);
    float f_columns = float(lines);
    
    // Make some distance to the edges before the animation starts
    float cutoff = smoothstep(0.0, Edge, (floor( ((UV.x) * (f_columns) ) + 0.5) / f_columns) );
    cutoff *= 1. - smoothstep(1.-Edge, 1.0, (floor( ((UV.x) * (f_columns) + 0.5) ) / f_columns) );

    // Speech simulation setup
    float ss = 1.0;
    if (speech_sim == true){
      ss = fbm(vec2(1.0, time * 1.3) * Intensity) * 1.5;
    }
    
    // Create the noise that controlls the animation
    float noise = fbm(vec2( floor(( (UV.x) * f_columns ) +0.5) * frequency, time) )   * ss * progress;
    noise *= cutoff; // Apply edge cutoff
    
    // Make wave values based on the noise
    float wave = smoothstep(1.-intensity, 1.0, noise) * amplitude;
    wave = wave + (rest_size * 0.2);
    
    // Create the lines
    float line = abs( sin(( f_columns * 3.1416 * UV.x) + 1.5) );
    line = smoothstep(1.-line_size, (1.-line_size) + (1.-Sharpness), line);
    
    // Simulate dot_matrix
    if (dot_matrix){
        float dm = abs( sin(( float(dot_matriz_size) * 3.1416 * UV.y) + 1.5) );
        dm = smoothstep(1.-line_size, (1.-line_size) + (1.-Sharpness), dm);
        line *= dm;
    }
    
    // Duplicate mask on top an bottom and apply to line
    float mask = 1.0 - smoothstep(wave, wave + fade, abs(UV.y - 0.5) * 2.);
    line *= mask;
    
    c = vec4(line) * color;
    
    COLOR = c;

  //----------------------------------------------
  //COLOR.a *= alpha;
  //COLOR.rgb *= COLOR.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


