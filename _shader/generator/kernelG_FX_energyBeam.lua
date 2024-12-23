
--[[
    https://godotshaders.com/shader/energy-beams/
    pend00
    July 2, 202
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "energyBeam2"

kernel.isTimeDependent = true



kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "setting1",
        paramName = {
            'Progress','Speed','Energy','Frequency',
            'Beams','Beam_Diff','Edge_Size','Roughness',
            'Thickness','Outline_Thick','Glow', 'Outline_Glow',
            'Offset_Y','Noise','','',
        },
        default = {
            1.,1.,12.,10.,
            3.,0.,.05,3.,
            .006,.03,0.,0.,
            0.,1,0,0,
        },
        min = {
            0., 0., -20., 0.,
            1., 0., 0., .5,
            0., 0., -0.2, -2.,
            -1., -20., -10., -10.,
        },
        max = {
            10., 10., 20., 100.,
            10., 10., 2., 10.,
            0.05, 0.1, 5., 2.,
            1., 20., 10., 10.,
        },
    },
    {
        index = 1, 
        type = "mat4",  -- vec4 x 4
        name = "setting2",
        paramName = {
            'Beam_R','Beam_G','Beam_B','Beam_A',
            'Outline_R','Outline_G','Outline_B','Outline_A',
            '','','','',
            '','','','',
        },
        default = {
            0.91, 1.0, 1.0, 1.0,
            0.5, 1.0, 0.96, 1.0,       
            0., 0., 0., 0.,
            0., 0., 0., 0.,
        },
        min = {
            0., 0., 0., 0.,
            0., 0., 0., 0.,
            0., 0., 0., 0.,
            0., 0., 0., 0.,
        },
        max = {
            1., 1., 1., 1.,
            1., 1., 1., 1.,
            1., 1., 1., 1.,
            1., 1., 1., 1.,
        },
    },
}

-- u_UserData0[0].x; //
-- u_UserData0[0].y; //
-- u_UserData0[0].z; //
-- u_UserData0[0].w; //

-- kernel.vertexData =
-- {
--   { name = "Beams",     default = 3, min = 0, max = 30, index = 0, },
--   { name = "Noise",        default = 1, min = -10, max = 10, index = 1, },
--   { name = "Energy",      default = 12, min = -25, max = 150, index = 2, },
--   { name = "Frequency",      default = 12, min = 0, max = 75, index = 3, },
-- } 

kernel.fragment =
[[

//float Beams = CoronaVertexUserData.x;
//float Noise = CoronaVertexUserData.y;
//float Energy = CoronaVertexUserData.z;
//float Frequency = CoronaVertexUserData.w;

uniform mat4 u_UserData0;
uniform mat4 u_UserData1;

//----------------------------------------------

// u_UserData0

float Progress  = u_UserData0[0].x;  //1.0; // : hint_range(0.0, 1.0)
float Speed     = u_UserData0[0].y;  //1.0; // Animation Speed
float Energy    = u_UserData0[0].z;  //3.0; // How much the beams will travel up and down
float Frequency = u_UserData0[0].w;  //10.0; 

float Beams     = u_UserData0[1].x;  //.0;
float Beam_Diff = u_UserData0[1].y;  //.0; // : hint_range(0.0, 1.0)The thickness difference between the main beam and the other, if there are more than one beam. The closer to 1 the smaller the thickness difference.
float Edge_Size = u_UserData0[1].z;  //0.05; //  : hint_range(0.0, 0.5)  How close to the edge should the beam be still before the animatino starts
float Roughness = u_UserData0[1].w;  //3; 

float Thickness     = u_UserData0[2].x;  //.006; // : hint_range(0.0, 0.1) Thickness of the main beam
float Outline_Thick = u_UserData0[2].y;  //0.03; // : hint_range(0.0, 0.1) Thickness of the outline color
float Glow          = u_UserData0[2].z;  //0.0; // : hint_range(0.0, 3.0) Use together with WorldEnvironment's Glow feature
float Outline_Glow  = u_UserData0[2].w;  //0.0; // : hint_range(0.0, 3.0)

float Offset_Y  = u_UserData0[3].x;  //0.0; //  : hint_range (-0.5, 0.5)  Position of the beam
vec2 NoiseUV    = vec2( u_UserData0[3].y ); // If the object (for example the ColorRect or Sprite node) is compressed use this to compensate for the noise texture being compressed.

int I_Beams = int(Beams); // How many beams the energy field should have
int I_Roughness = int(Roughness); // : hint_range(1, 10) How compact the noise texture will be
int I_Frequency = int(Frequency); // Amount of "ripples" in the beams


// u_UserData1

float Beam_R = u_UserData1[0].r;
float Beam_G = u_UserData1[0].g;
float Beam_B = u_UserData1[0].b;
float Beam_A = u_UserData1[0].a;

float Outline_R = u_UserData1[1].r;
float Outline_G = u_UserData1[1].g;
float Outline_B = u_UserData1[1].b;
float Outline_A = u_UserData1[1].a;

//vec4 Col_Beam = vec4(0.91, 1.0, 1.0, 1.0); // : hint_color
//vec4 Col_Outline = vec4(0.5, 1.0, 0.96, 1.0); // : hint_color

//vec4 Col_Beam = vec4( Beam_R, Beam_G, Beam_B, Beam_A ); // : hint_color
//vec4 Col_Outline = vec4( Outline_R, Outline_G, Outline_B, Outline_A); // : hint_color

vec4 Col_Beam = u_UserData1[0];
vec4 Col_Outline = u_UserData1[1];



//----------------------------------------------

//P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV );
P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;
const float PI = 3.14159265359;

//----------------------------------------------

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            43758.5453123);
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

float fbm(vec2 uv, float time) {
    int octaves = I_Roughness;
    float amp = 0.01 * Energy * Progress;
    float freq = float(I_Frequency);
  float value = 0.0;
  
    for(int i = 0; i < octaves; i++) {
        value += amp * noise(freq * vec2(uv.x, uv.y + time));
        amp *= 0.5;
        freq *= 2.0;
    }
    return value;
}

vec4 difference(vec4 base, vec4 blend){
  return abs(base - blend);
}

vec4 bolt(vec2 uv, float time, float i)
{
  // Setup the beam locking to the edges.
  float falloff = smoothstep(0.0, Edge_Size, uv.x) * smoothstep(0.0, Edge_Size, 1.0 - uv.x);
  
  // Use Fractal Brownian Motion to create a "cloud texture" and use Difference blend mode to make the beam
  vec4 clouds = vec4(fbm((uv + vec2(i) ) * NoiseUV, time * Speed)) * falloff;
  vec4 diff_clouds = difference(clouds, vec4(uv.y - 0.5 + Offset_Y + (uv.y * falloff * 0.02 * Energy * Progress)));
  
  // Create a new noise to mask the beams on low "Progress" values. To make a "turn-off" effect more visually interesting.
  vec4 clouds2 = vec4(fbm((uv * 2.0) * NoiseUV, time * 1.)) * 5.0;
  diff_clouds += smoothstep(0.0, 0.8, clouds2) * 0.1 * (1.-Progress);
  
  // Set thickness of the beams. First beam is the Thickness size and all following beams are sized with beam_difference
  float thickness2 =  1. - ( Thickness / (min(i + Beam_Diff, 1.0) + (1.0-Beam_Diff))) * Progress ;
  vec4 beam = clamp(smoothstep(thickness2, thickness2 + 0.005 * Progress, 1.0 - diff_clouds), vec4(0.0), vec4(1.0));
  
  //Set the beam outlines
  vec4 beam_outline;
  float outline = thickness2 - (Outline_Thick * Progress);
  beam_outline = clamp(smoothstep(outline, outline + 0.04, 1.0 - diff_clouds), 0.0, 1.0);
  beam_outline = clamp(beam_outline - beam, 0.0, 1.0);
  
  // Merge the beam and the outline and return to the fragment function
  return (beam * (Col_Beam + vec4(Glow, Glow, Glow, 0.))) + (beam_outline * (Col_Outline + vec4(Outline_Glow, Outline_Glow, Outline_Glow, 0.)));
}

//----------------------------------------------



P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------

  vec4 beam = vec4(0.0);
  
  for (int i = 0; i < I_Beams; i++){
    beam = max(beam, bolt(UV, TIME, float(i)));
  }
  
  COLOR = beam;

  //----------------------------------------------


  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


