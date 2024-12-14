
--[[
  undulatingBurnOut
  Origin Author: pthrasher
  https://github.com/gl-transitions/gl-transitions/blob/master/transitions/undulatingBurnOut.glsl

  adapted by gre from https://gist.github.com/pthrasher/8e6226b215548ba12734
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "rippleBurnOut"


kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
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

uniform float smoothness = 0.03;
uniform vec2 center = vec2(0.5);
uniform vec3 color = vec3(0.0);

const float M_PI = 3.14159265358979323846;

float quadraticInOut(float t) {
  float p = 2.0 * t * t;
  return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

float getGradient(float r, float dist) {
  float d = r - dist;
  return mix(
    smoothstep(-smoothness, 0.0, r - dist * (1.0 + smoothness)),
    -1.0 - step(0.005, d),
    step(-0.005, d) * step(d, 0.01)
  );
}

float getWave(vec2 p){
  vec2 _p = p - center; // offset from center
  float rads = atan(_p.y, _p.x);
  float degs = degrees(rads) + 180.0;
  vec2 range = vec2(0.0, M_PI * 30.0);
  vec2 domain = vec2(0.0, 360.0);
  float ratio = (M_PI * 30.0) / 360.0;
  degs = degs * ratio;
  float x = progress;
  float magnitude = mix(0.02, 0.09, smoothstep(0.0, 1.0, x));
  float offset = mix(40.0, 30.0, smoothstep(0.0, 1.0, x));
  float ease_degs = quadraticInOut(sin(degs));
  float deg_wave_pos = (ease_degs * magnitude) * sin(x * offset);
  return x + deg_wave_pos;
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime*1));
  //progress = 0;
  //----------------------------------------------

  float dist = distance(center, p);
  float m = getGradient(getWave(p), dist);
  //return mix(mix(cFrom, cTo, m), mix(cFrom, vec4(color, 1.0), 0.75), step(m, -2.0));
  
  vec4 cFrom = texture2D( CoronaSampler0, p);
  vec4 cTo = colorBG;
  COLOR = mix(mix(cFrom, cTo, m), mix(cFrom, vec4(color, 1.0), 0.75), step(m, -2.0));


  //----------------------------------------------
  //COLOR.rgb *= COLOR.a;
  
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


