
--[[
  
  ( Pumping Molten Core )

  Origin Author: abelu
  https://www.shadertoy.com/view/3lB3R3

  An exercise in simplex noise animation

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG" 
kernel.name = "colorNoise"


kernel.isTimeDependent = true

kernel.vertexData =
{
  
}


kernel.fragment =
[[
P_UV vec2 iResolution = vec2(1. ,1.);


//----------------------------------------------
  #define PI 3.14159265359

  float speed = 1.2; // 2.


  vec3 mod289(vec3 x) { 
    return x - floor(x * (1.0 / 289.0)) * 289.0; 
  }

  vec2 mod289(vec2 x) { 
    return x - floor(x * (1.0 / 289.0)) * 289.0; 
  }

  vec3 permute(vec3 x) { 
    return mod289(((x*34.0)+1.0)*x); 
  }

  float snoise(vec2 v) {
    // Precompute values for skewed triangular grid
    const vec4 C = vec4(0.211324865405187,
                        // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,
                        // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,
                        // -1.0 + 2.0 * C.x
                        0.024390243902439);
                        // 1.0 / 41.0

    // First corner (x0)
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    // Other two corners (x1, x2)
    vec2 i1 = vec2(0.0);
    i1 = (x0.x > x0.y)? vec2(1.0, 0.0):vec2(0.0, 1.0);
    vec2 x1 = x0.xy + C.xx - i1;
    vec2 x2 = x0.xy + C.zz;

    // Do some permutations to avoid
    // truncation effects in permutation
    i = mod289(i);
    vec3 p = permute(
            permute( i.y + vec3(0.0, i1.y, 1.0))
                + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(
                        dot(x0,x0),
                        dot(x1,x1),
                        dot(x2,x2)
                        ), 0.0);

    m = m*m ;
    m = m*m ;

    // Gradients:
    //  41 pts uniformly over a line, mapped onto a diamond
    //  The ring size 17*17 = 289 is close to a multiple
    //      of 41 (41*7 = 287)

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);

    // Compute final noise value at P
    vec3 g = vec3(0.0);
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * vec2(x1.x,x2.x) + h.yz * vec2(x1.y,x2.y);
    return 130.0 * dot(m, g);
  }

  float lines(in vec2 st, float b) {
    float scale = 5.;
    st *= scale;

    return smoothstep(
      0.,
      .5 + b * .5,
      abs((sin(st.x * PI) + b * 1.9)) * .35
    );
  }

  vec2 rotate2d(in vec2 st, in float a) {
    return st * mat2(cos(a), -sin(a),
                     sin(a), cos(a));
  }


// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = ( texCoord.xy / iResolution );
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;

  #ifdef isTween
    lineOpacity += sin(CoronaTotalTime*.25)* 0.5;
    width += sin(CoronaTotalTime*.25)* 1;
    //opacityScanline += abs(sin(CoronaTotalTime)) * .5  ; //50
  #endif
  //----------------------------------------------
    vec2 st = fragCoord;
    vec2 ps = st - vec2(.5);
    st *= 12.;

    float noise = snoise(st) * .43 + .48;
    float len = 1. - smoothstep(.0, .6 + .5 * sin(iTime * speed), length(ps));
    float pattern = lines(vec2(noise) * len, .3);

    COLOR = vec4(
      vec3(
        pattern, 
        noise * len, 
        len
      ), 
    1.);
      
  //----------------------------------------------
  
  COLOR.a = (COLOR.a+COLOR.g+COLOR.b)/3;

  COLOR.rgb *= COLOR.a;
  //COLOR.a = lineOpacity * COLOR.r;
  //COLOR.rgb *= COLOR.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


