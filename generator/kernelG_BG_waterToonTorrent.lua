
--[[

  https://godotshaders.com/shader/water-toon-torrent-shader/
  pawn_games

  
  Shader adapted from the link below to GDScript:
  https://www.shadertoy.com/view/mtfBRr

  I don’t get any credit, just posting here because it’s really beautiful.

  Credits go to https://twitter.com/leondenise.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "waterToonTorrent"


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
P_UV vec2 iResolution = vec2(resolutionX,resolutionY);
//----------------------------------------------

uniform vec2 R = vec2(.8, .1);  // R.y: change shape, the smaller the more
uniform float scale = 0.5;
uniform float speed = 1.0;
uniform vec3 direction = vec3(1,1,0);
uniform float distortion = 0.5;
uniform float layers = 2.;
uniform float shades = 3.;
uniform int steps = 6;

uniform float alpha = 0.05;

//uniform vec3 tint = vec3(.459,.765,1.);
//uniform vec3 tint = vec3(.259,.565,.8);
uniform vec3 tint = vec3( -1, -5, 0); // Use for overlay

//----------------------------------------------

P_DEFAULT float TIME = CoronaTotalTime;


//----------------------------------------------


float gyroid (vec3 seed) { return dot(sin(seed),cos(seed.yzx)); }

float fbm (vec3 seed)
{
    float result = 0., a = .5;
    for (int i = 0; i < steps; ++i, a /= 2.) {
        seed += direction * TIME*speed*.01/a;
        seed.z += result*distortion;
        result += gyroid(seed/a)*a;
    }
    return result;
}
//----------------------------------------------


// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  //P_UV vec2 fragCoord = texCoord / iResolution;
  P_COLOR vec4 COLOR;
  //P_DEFAULT float iTime = CoronaTotalTime;
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  
  vec2 p = (2.*UV-R)/R.y;
  float shape = fbm(vec3(p*scale, 0.));
  float gradient = fract(shape*layers);
  //float shade = round(pow(gradient, 4.)*shades)/shades;
  float shade = floor(pow(gradient, 4.)*shades)/shades + float(0.5);
  
  vec3 color = mix(tint*mix(.6,.8,gradient), vec3(1), shade);
  COLOR = vec4(color,1.0);
  COLOR.a = alpha;
  
  //----------------------------------------------
  
  // Tween Alpha
  P_DEFAULT float alpha2 = abs(sin(CoronaTotalTime)) -0.15;
  COLOR.a = alpha2;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

  //Original shadertoy source: https://www.shadertoy.com/view/mtfBRr
  //Credits to Leon Denise
  //https://leon196.github.io/
  //(@leondenise): https://twitter.com/leondenise
  shader_type canvas_item;

  uniform vec2 R = vec2(.8, .6);
  uniform float scale = 0.5;
  uniform float speed = 1.0;
  uniform vec3 direction = vec3(1,1,0);
  uniform float distortion = 0.5;
  uniform float layers = 2.;
  uniform float shades = 3.;
  uniform int steps = 6;

  uniform vec3 tint = vec3(.459,.765,1.);

  float gyroid (vec3 seed) { return dot(sin(seed),cos(seed.yzx)); }

  float fbm (vec3 seed)
  {
      float result = 0., a = .5;
      for (int i = 0; i < steps; ++i, a /= 2.) {
          seed += direction * TIME*speed*.01/a;
          seed.z += result*distortion;
          result += gyroid(seed/a)*a;
      }
      return result;
  }

  void fragment()
  {
      vec2 p = (2.*UV-R)/R.y;
      float shape = fbm(vec3(p*scale, 0.));
      float gradient = fract(shape*layers);
      float shade = round(pow(gradient, 4.)*shades)/shades;
      vec3 color = mix(tint*mix(.6,.8,gradient), vec3(1), shade);
      COLOR = vec4(color,1.0);
  }

--]]


