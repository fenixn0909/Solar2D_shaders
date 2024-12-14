
--[[

  Origin Author:   MilkyDeveloper 
  https://www.shadertoy.com/view/wllBWs

  😅 A very simple implementation of clouds without volumetrics or raymarching or any of that because this is meant to be used for a Minecraft Bedrock Shader. 
  Noise based on https://www.shadertoy.com/view/tlB3zK.

  // MIT License :D
  //noise function from iq: https://www.shadertoy.com/view/Msf3WH

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "cloudSimple" -- One Layer


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

float speed      = 1.0;
float brightness = 0.85; // hint: (0.4, 3.0) best 0.5~1.0
float cover      = 0.1; // The less the more cloud coverage


vec2 hash( vec2 p ) 
{
  p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
  return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p )
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

  vec2  i = floor( p + (p.x+p.y)*K1 );
    vec2  a = p - i + (i.x+i.y)*K2;
    float m = step(a.y,a.x); 
    vec2  o = vec2(m,1.0-m);
    vec2  b = a - o + K2;
  vec2  c = a - 1.0 + 2.0*K2;
    vec3  h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
  vec3  n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot( n, vec3(70.0) );
}

const mat2 m2 = mat2(1.6,  1.2, -1.2,  1.6);

float fbm4(vec2 p) {
    float amp = 0.5;
    float h = 0.0;
    for (int i = 0; i < 4; i++) {
        float n = noise(p);
        h += amp * n;
        amp *= 0.5;
        p = m2 * p ;
    }
    
  return  0.5 + 0.5*h;
}



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = texCoord / iResolution;
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;
    //vec3 sky = vec3(135./255., 206./255., 235./255.); // Just googled this lmao
    //vec3 col = vec3(0.0);
    vec4 sky = vec4( 0., 0., 0., 0.); // Just googled this lmao
    vec4 col = vec4(0.0);

    // layer1
    //vec3 cloudCol = vec3(1.);
    vec4 cloudCol = vec4(1.);
    uv += 10.0;

    

    float zoom = 1.25; // Multiplier of UV, a higher number is for "zooming out"

    float n1 = fbm4(uv*zoom+(iTime*(speed/30.))); // +iTime is for moving left, -iTime is for moving right
    col = mix( sky, cloudCol, smoothstep(cover, brightness, n1));

    // Output to screen
    //fragColor = vec4(col, 1.0);

  //----------------------------------------------
  //COLOR = vec4(col, 1.0);
  COLOR = col;
  //COLOR.a = alpha;
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


