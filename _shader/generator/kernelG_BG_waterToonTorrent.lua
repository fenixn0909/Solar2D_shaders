
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
  { name = "Speed",       default = 1.2, min = -10, max = 10, index = 0, },
  { name = "Distortion",  default = 0.5, min = 0, max = 20, index = 1, },
  { name = "Scale",       default = 0.5, min = 0, max = 5, index = 2, },
  { name = "Layers",      default = 3.0, min = 0, max = 8, index = 3, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Distortion = CoronaVertexUserData.y;
float Scale = CoronaVertexUserData.z;
float Layers = CoronaVertexUserData.w;

P_UV vec2 iResolution = vec2( 1, 1 );
//----------------------------------------------

uniform vec3 direction = vec3(1,1,0);


vec2 Ratio = vec2(1, 0.5);  // Range.y: zooming
//uniform float Scale = 0.5;
//uniform float Speed = 1.0;
//uniform float Distortion = 0.5;
//uniform float Layers = 2.;
uniform float shades = 3.;
uniform int steps = 6;

uniform float alpha = .75;

uniform vec3 tint = vec3(.459,.765,1.);
//uniform vec3 tint = vec3( .959, 1.465, 1. );
//uniform vec3 tint = vec3(.259,.565,.8);
//uniform vec3 tint = vec3( -1, -5, 0); // Use for overlay

//----------------------------------------------

P_DEFAULT float TIME = CoronaTotalTime;


//----------------------------------------------


float gyroid (vec3 seed) { return dot(sin(seed),cos(seed.yzx)); }

float fbm (vec3 seed)
{
    float result = 0., a = .5;
    for (int i = 0; i < steps; ++i, a /= 2.) {
        seed += direction * TIME*Speed*.01/a;
        seed.z += result*Distortion;
        result += gyroid(seed/a)*a;
    }
    return result;
}
//----------------------------------------------


// -----------------------------------------------

P_COLOR vec4 COLOR;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
    //----------------------------------------------

    vec2 p = (2.*UV-Ratio)/Ratio.y;
    float shape = fbm(vec3(p*Scale, 0.));
    float gradient = fract(shape*Layers);
    //float shade = round(pow(gradient, 4.)*shades)/shades;
    float shade = floor(pow(gradient, 4.)*shades)/shades + float(0.5);

    vec3 color = mix(tint*mix(.6,.8,gradient), vec3(1), shade);
    COLOR = vec4(color, alpha);
    //COLOR = vec4(color, COLOR.r);
    COLOR.rgb *= COLOR.a;
    //----------------------------------------------

    // Tween Alpha
    //P_DEFAULT float alpha2 = abs(sin(TIME)) -0.15;
    //COLOR.a = alpha2;

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
  uniform float Scale = 0.5;
  uniform float Speed = 1.0;
  uniform vec3 direction = vec3(1,1,0);
  uniform float Distortion = 0.5;
  uniform float Layers = 2.;
  uniform float shades = 3.;
  uniform int steps = 6;

  uniform vec3 tint = vec3(.459,.765,1.);

  float gyroid (vec3 seed) { return dot(sin(seed),cos(seed.yzx)); }

  float fbm (vec3 seed)
  {
      float result = 0., a = .5;
      for (int i = 0; i < steps; ++i, a /= 2.) {
          seed += direction * TIME*Speed*.01/a;
          seed.z += result*Distortion;
          result += gyroid(seed/a)*a;
      }
      return result;
  }

  void fragment()
  {
      vec2 p = (2.*UV-R)/R.y;
      float shape = fbm(vec3(p*Scale, 0.));
      float gradient = fract(shape*Layers);
      float shade = round(pow(gradient, 4.)*shades)/shades;
      vec3 color = mix(tint*mix(.6,.8,gradient), vec3(1), shade);
      COLOR = vec4(color,1.0);
  }

--]]


