
--[[
  Origin Author: Zeh Fernando
  https://gl-transitions.com/editor/DoomScreenTransition
  License: MIT


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "doomScreen"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[
P_DEFAULT float progress = CoronaVertexUserData.x;
vec4 colorBG = vec4(0,0,0,0);
//----------------------------------------------

// Transition parameters --------

// Number of total bars/columns
uniform int bars = 128; // 

// Multiplier for speed ratio. 0 = no variation when going down, higher = some elements go much faster
uniform float amplitude = 1; // 

// Further variations in speed. 0 = no noise, 1 = super noisy (ignore frequency)
uniform float noise = 0.2; //

// Speed variation horizontally. the bigger the value, the shorter the waves
uniform float frequency = 1; //

// How much the bars seem to "run" from the middle of the screen first (sticking to the sides). 0 = no drip, 1 = curved drip
uniform float dripScale = .5; // 

uniform float speedScale = 0.5; // 


// The code proper --------

float rand(int num) {
  return fract(mod(float(num) * 67123.313, 12.0) * sin(float(num) * 10.3) * cos(float(num)));
}

float wave(int num) {
  float fn = float(num) * frequency * 0.1 * float(bars);
  return cos(fn * 0.5) * cos(fn * 0.13) * sin((fn+10.0) * 0.3) / 2.0 + 0.5;
}

float drip(int num) {
  return sin(float(num) / float(bars - 1) * 3.141592) * dripScale;
}

float pos(int num) {
  return (noise == 0.0 ? wave(num) : mix(wave(num), rand(num), noise)) + (dripScale == 0.0 ? 0.0 : drip(num));
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime*0.5));
  //progress = 0.5;
  //----------------------------------------------

  int bar = int(UV.x * (float(bars)));
  float scale = speedScale + pos(bar) * amplitude;
  float phase = progress * scale;
  float posY = UV.y;
  vec2 p;
  vec4 c;

  //if (phase + posY < 1.0) {  //Upward
  //p = vec2(UV.x, UV.y + mix(0.0, vec2(1.0).y, phase));  //Upward
  //p = vec2(UV.x, UV.y + mix(vec2(1.0).y, 0.0, 1- phase)); equal to upper line

  if (posY - phase > 0.0) {
    p = vec2(UV.x, UV.y - mix(0.0, vec2(1.0).y, phase));
    //c = getFromColor(p);
    c = texture2D( CoronaSampler0, p ); // Drop Bar
    //c = colorBG; // CurtainFall
  } else {
    //p = UV.xy / vec2(1.0).xy;
    //c = getToColor(p);
    //c = colorBG; // Drop Bar
    //c = texture2D( CoronaSampler0, p ); // CurtainFall
  }

  // Finally, apply the color
  //return c;
  COLOR = c;
  //COLOR.rgb *= COLOR.a;

  //----------------------------------------------

  
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


