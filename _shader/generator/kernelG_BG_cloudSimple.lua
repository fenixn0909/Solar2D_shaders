
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
  { name = "Speed",       default = 1.0, min = -50, max = 50, index = 0, },
  { name = "Brightness",  default = 0.85, min = 0.3, max = 1.5, index = 1, },
  { name = "Cover",       default = 0.1, min = -1.5, max = 0.8, index = 2, },
  { name = "Zoom",       default = 1.25, min = 0.25, max = 100, index = 3, },
} 

kernel.fragment =
[[

P_UV vec2 iResolution = vec2( 1, 1 );   // cloud width height
//----------------------------------------------

float Speed = CoronaVertexUserData.x;
float Brightness = CoronaVertexUserData.y;
float Cover = CoronaVertexUserData.z;
float Zoom = CoronaVertexUserData.w;  // Multiplier of UV, a higher number is for "Zooming out"

P_COLOR vec4 Col_Sky = vec4(0);
P_COLOR vec4 Col_Cloud = vec4(1.);

P_UV vec2 Direction = vec2( -1, 0);

// cloud shape: w/h freq, zoom-ish
const mat2 m2 = mat2(1.6,  1.2, -1.2,  1.6);      // Normal
//const mat2 m2 = mat2(-1.6,  -1.2, -1.2,  -1.6);  // Slice TR->BL
//const mat2 m2 = mat2( -1.6,  1.2, 1.2,  -1.6);  // Slice TL->BR
//const mat2 m2 = mat2( 1.6,  1.2, -1.2,  -1.6);  // Glare TL->BR
//const mat2 m2 = mat2( 1.6,  1.2, -10.2,  1.6);  // Wavy TL->BR
//const mat2 m2 = mat2( 1.6,  10.2, -3.2,  5.6);  // Hand Draw TL->BR
//const mat2 m2 = mat2( 1.6,  1.2, -100.2,  100.6);  // Wind TL->BR

//----------------------------------------------
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

//----------------------------------------------

P_COLOR vec4 COLOR = vec4(0.0);
P_DEFAULT float TIME = CoronaTotalTime;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  P_UV vec2 fragCoord = UV / iResolution;
  
  //----------------------------------------------
  
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;

    // layer1
    uv.x = uv.x*Zoom+(-TIME*(Speed* Direction.x));
    uv.y = uv.y*Zoom+(-TIME*(Speed* Direction).y);

    float n1 = fbm4(uv); // +TIME is for moving left, -TIME is for moving right
    

    COLOR = mix( Col_Sky, Col_Cloud, smoothstep(Cover, Brightness, n1));

  //----------------------------------------------
  //COLOR = vec4(col, 1.0);

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


