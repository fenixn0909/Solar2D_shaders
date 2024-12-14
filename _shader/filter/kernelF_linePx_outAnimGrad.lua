
--[[
  Origin Author: 9exa
  https://godotshaders.com/shader/animated-and-gradient-outlines/
  
  It’s alot like hancan‘s (re)upload of the outline shader

  However the first one has alternating thickness

  Second one is a gradient between start_colour and end_color

  Third one is both!

  Most uniforms are pretty self explanatory, otherwise

  block_size <- size of segmentation for line width variation in animated outline



--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "linePx"
kernel.name = "outAnimGrad"

--Test
kernel.isTimeDependent = true

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
//----------------------------------------------
uniform float max_line_width = 4.0;
uniform float min_line_width = 1.0;
uniform float freq = 10.0;
uniform float block_size = 0.1;
uniform vec4 starting_colour = vec4(1,0,0,1);
uniform vec4 ending_colour = vec4(1);

const float pi = 3.1415;
const int ang_res = 16;
const int grad_res = 8;

float hash(vec2 p, float s) {
  return fract(35.1 * sin(dot(vec3(112.3, 459.2, 753.2), vec3(p, s))));
}

float noise(vec2 p, float s) {
  vec2 d = vec2(0, 1);
  vec2 b = floor(p);
  vec2 f = fract(p);
  return mix(
    mix(hash(b + d.xx, s), hash(b + d.yx, s), f.x),
    mix(hash(b + d.xy, s), hash(b + d.yy, s), f.x), f.y);
}

float getLineWidth(vec2 p, float s) {
  p /= block_size;
  float w = 0.0;
  float intensity = 1.0;
  for (int i = 0; i < 3; i++) {
    w = mix(w, noise(p, s), intensity);
    p /= 2.0;
    intensity /= 2.0;
  }
  
  return mix(max_line_width, min_line_width, w);
}

bool pixelInRange(sampler2D text, vec2 uv, vec2 dist) {
  float alpha = 0.0;
  for (int i = 0; i < ang_res; i++) {
    float angle = 2.0 * pi * float(i) / float(ang_res);
    vec2 disp = dist * vec2(cos(angle), sin(angle));
    if (texture2D(text, uv + disp).a > 0.0) return true;
  }
  return false;
}

float getClosestDistance(sampler2D text, vec2 uv, vec2 maxDist) {
  if (!pixelInRange(text, uv, maxDist)) return -1.0;
  
  float hi = 1.0; float lo = 0.0;
  
  for (int i = 1; i <= grad_res; i++) {
    float curr = (hi + lo) / 2.0;
    if (pixelInRange(text, uv, curr * maxDist)) {
      hi = curr;
    }
    else {
      lo = curr;
    }
  }
  return hi;
}

//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );

  P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
  P_DEFAULT float TIME = CoronaTotalTime;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------

    float timeStep = floor(freq * TIME);
    vec2 scaledDist = TEXTURE_PIXEL_SIZE;
    scaledDist *= getLineWidth(UV / TEXTURE_PIXEL_SIZE, timeStep);
    float w = getClosestDistance(CoronaSampler0, UV, scaledDist);
    
    if (( w > 0.0) && (texture2D(CoronaSampler0, UV).a < 0.2)) {
      //COLOR = mix(starting_colour, ending_colour, tanh(3.0*w));
      COLOR = mix(starting_colour, ending_colour, sin(3*w)); // sin, cos, tan: diff line result
    }
    else {
      COLOR = texture2D(CoronaSampler0, UV_Pix);
    }

  //----------------------------------------------
  

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


