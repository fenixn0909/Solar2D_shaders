
--[[
    Origin Author: snesmocha
    https://godotshaders.com/author/snesmocha/

    tutorial followed from here:
    https://www.youtube.com/watch?v=BZp8DwPdj4s


    Find and go #VARIATION and tweak them for different patterns

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "kaleidoScope"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",                     default = 0.5, min = -5, max = 5, index = 0, },
  { name = "IdealDist",                 default = 2, min = -10, max = 10, index = 1, },
  { name = "Steps",   --[[#OVERHEAD!]]  default = 100, min = 50, max = 150, index = 2, },
  { name = "Vivid",                     default = 10, min = 0, max = 15, index = 3, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float IdealDist = CoronaVertexUserData.y; 
float Steps = CoronaVertexUserData.z;
float Vivid = CoronaVertexUserData.w;

//----------------------------------------------

P_COLOR vec4 Col_Tint = vec4( 1.0, .7, .2, 1.0);

//----------------------------------------------
mat2 rot(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(vec2(c,s),vec2(-s,c));
}

const float pi = 1.0 * acos(-1.0);
const float pi2 = pi*2.0;

vec2 pmod(vec2 p, float r) {
    float a = atan(p.x, p.y) + pi/r;
    float n = pi2 / r;
    a = floor(a/n)*n;
    return p*rot(-a);
}

float box( vec3 p, vec3 b ) {
    vec3 d = abs(p) - b;
    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float ifsBox(vec3 p, float time) {
    for (int i=0; i<5; i++) {
        p = abs(p) - 1.0;
        p.xy *= rot(time * 0.3);
        p.xz *= rot(time * 0.1);
    }
    p.xz *= rot(time);
    return box(p, vec3(0.4,0.8,0.3));
}

float map(vec3 p, vec3 cPos, float time) {
    vec3 p1 = p;
    p1.x = mod(p1.x-5., 10.) - 5.;
    p1.y = mod(p1.y-5., 10.) - 5.;
    p1.z = mod(p1.z, 16.)-8.;
    p1.xy = pmod(p1.xy, 5.0);
    return ifsBox(p1, time);
}


//----------------------------------------------

float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //float ideal_dist = IdealDist*100;
    int steps = int( Steps );

    //----------------------------------------------
    vec2 p = UV;

    vec3 cPos = vec3(0.0, 0.0, -3.0 * TIME * Speed);
    // vec3 cPos = vec3(0.3*sin(TIME*0.8), 0.4*cos(TIME*0.3), -6.0 * TIME);
    vec3 cDir = normalize(vec3(0.0, 0.0, -1.0));
    vec3 cUp  = vec3(sin( TIME * Speed ), 1.0, 0.0);
    vec3 cSide = cross(cDir, cUp);

    vec3 ray = normalize(cSide * (p.x - 0.5) + cUp * (p.y - 0.5) + cDir);

    // Phantom Mode https://www.shadertoy.com/view/MtScWW by aiekick
    float acc = 0.0;
    float acc2 = 0.0;
    float t = 0.0;
    for (int i = 0; i < steps; i++) {
      vec3 pos = cPos + ray * t;
      float dist = map(pos * (IdealDist), cPos, TIME* Speed);
      dist = max(abs(dist), 0.02);
      float a = exp(-dist*3.0);
      if (mod(length(pos)+24.0*TIME* Speed, 30.0) < 3.0) {
          a *= 2.0;
          acc2 += a;
      }
      acc += a;
      t += dist * 0.5;
    }

    // Plain Color          #VARIATION
    //vec3 col = vec3(acc * 0.01, acc * 0.011 + acc2*0.002, acc * 0.012+ acc2*0.005);
    
    // Tween Color by UV    #VARIATION
    vec3 col = vec3(acc * 0.01 * UV.x, acc * 0.011 * UV.y + acc2*0.002 , acc * 0.012+ acc2*0.005 * (UV.x + UV.y) );
    col *= abs(sin(TIME)) + .75;
    

    vec4 COLOR = vec4( col, 1.0 - t * 0.03);
    COLOR.rgb *= Vivid * .1;

    //----------------------------------------------
    // Tint Color  #VARIATION
    COLOR *= Col_Tint;

    return CoronaColorScale( COLOR );
}

]]

return kernel


--[[


--]]





