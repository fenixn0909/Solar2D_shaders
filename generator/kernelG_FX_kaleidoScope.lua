
--[[
  Origin Author: snesmocha
  https://godotshaders.com/author/snesmocha/
  
  tutorial followed from here:
  https://www.youtube.com/watch?v=BZp8DwPdj4s

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "kaleidoScope"

kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  {
    name = "intensity",
    default = 0.65, 
    min = 0,
    max = 1,
    index = 0,  -- This corresponds to "CoronaVertexUserData.x"
  },
  {
    name = "size",
    default = 0.1, 
    min = 0,
    max = 1,
    index = 1,  -- This corresponds to "CoronaVertexUserData.y"
  },
  {
    name = "tilt",
    default = 0.2, 
    min = 0.0,
    max = 2.0,
    index = 2,  -- This corresponds to "CoronaVertexUserData.z"
  },
  {
    name = "speed",
    default = 1.0, 
    min = 0.1,
    max = 10.0,
    index = 3,  -- This corresponds to "CoronaVertexUserData.w"
  },
}


kernel.fragment =
[[

float IdealDist = 100.0;

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




P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  vec2 p = texCoord;
  float TIME = CoronaTotalTime;

  vec3 cPos = vec3(0.0,0.0, -3.0 * TIME);
  // vec3 cPos = vec3(0.3*sin(TIME*0.8), 0.4*cos(TIME*0.3), -6.0 * TIME);
  vec3 cDir = normalize(vec3(0.0, 0.0, -1.0));
  vec3 cUp  = vec3(sin(TIME), 1.0, 0.0);
  vec3 cSide = cross(cDir, cUp);

  vec3 ray = normalize(cSide * (p.x - 0.5) + cUp * (p.y - 0.5) + cDir);

  // Phantom Mode https://www.shadertoy.com/view/MtScWW by aiekick
  float acc = 0.0;
  float acc2 = 0.0;
  float t = 0.0;
  for (int i = 0; i < 99; i++) {
      vec3 pos = cPos + ray * t;
      float dist = map(pos * (IdealDist / 100.0), cPos, TIME);
      dist = max(abs(dist), 0.02);
      float a = exp(-dist*3.0);
      if (mod(length(pos)+24.0*TIME, 30.0) < 3.0) {
          a *= 2.0;
          acc2 += a;
      }
      acc += a;
      t += dist * 0.5;
  }

  vec3 col = vec3(acc * 0.01, acc * 0.011 + acc2*0.002, acc * 0.012+ acc2*0.005);
  vec4 COLOR = vec4(col, 1.0 - t * 0.03);
    
  return CoronaColorScale( COLOR );
}

]]

return kernel


--[[


void fragment(){
    vec2 p = UV;

    vec3 cPos = vec3(0.0,0.0, -3.0 * TIME);
    // vec3 cPos = vec3(0.3*sin(TIME*0.8), 0.4*cos(TIME*0.3), -6.0 * TIME);
    vec3 cDir = normalize(vec3(0.0, 0.0, -1.0));
    vec3 cUp  = vec3(sin(TIME), 1.0, 0.0);
    vec3 cSide = cross(cDir, cUp);

    vec3 ray = normalize(cSide * (p.x - 0.5) + cUp * (p.y - 0.5) + cDir);

    // Phantom Mode https://www.shadertoy.com/view/MtScWW by aiekick
    float acc = 0.0;
    float acc2 = 0.0;
    float t = 0.0;
    for (int i = 0; i < 99; i++) {
        vec3 pos = cPos + ray * t;
        float dist = map(pos * (IdealDist / 100.0), cPos, TIME);
        dist = max(abs(dist), 0.02);
        float a = exp(-dist*3.0);
        if (mod(length(pos)+24.0*TIME, 30.0) < 3.0) {
            a *= 2.0;
            acc2 += a;
        }
        acc += a;
        t += dist * 0.5;
    }

    vec3 col = vec3(acc * 0.01, acc * 0.011 + acc2*0.002, acc * 0.012+ acc2*0.005);
    COLOR = vec4(col, 1.0 - t * 0.03);
}

--]]





