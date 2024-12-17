
--[[

    https://www.shadertoy.com/view/4tdSWr

    

    Find and go #VARIATION and tweak them for different patterns

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "cloud2D"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",       default = .25, min = -20, max = 20, index = 0, },
  { name = "Brightness",  default = 0.85, min = -2, max = 2, index = 1, },
  { name = "Cover",       default = 0.1, min = -10, max = 10, index = 2, },
  { name = "Zoom",       default =  1.1, min = 0, max = 50, index = 3, },
} 


kernel.fragment =
[[
float Speed = CoronaVertexUserData.x;
float Brightness = CoronaVertexUserData.y;
float Cover = CoronaVertexUserData.z;
float Zoom = CoronaVertexUserData.w;

P_UV vec2 iResolution = vec2(1,1);
//----------------------------------------------

const float Darkness = .5;
const float Cloudalpha = 8;
const float Skytint = .5;

P_COLOR const vec3 Col_Sky1 = vec3(0.2, 0.4, 0.6);
P_COLOR const vec3 Col_Sky2 = vec3(0.4, 0.7, 1.0);

// No Sky Color
//const vec3 Col_Sky1 = vec3(0.0, 0.0, 0.0);
//const vec3 Col_Sky2 = vec3(0.0, 0.0, 0.0);

const mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );

//----------------------------------------------
vec2 hash( vec2 p ) {
    p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}


const float K1 = 0.366025404; // (sqrt(3)-1)/2;
const float K2 = 0.211324865; // (3-sqrt(3))/6;

float noise( in vec2 p ) {
    vec2 i = floor(p + (p.x+p.y)*K1); 
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0); //vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0*K2;
    vec3 h = max(0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
    vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot(n, vec3(70.0));  
}

float fbm(vec2 n) {
    float total = 0.0, amplitude = 0.1;
    for (int i = 0; i < 7; i++) {
        total += noise(n) * amplitude;
        n = m * n;
        amplitude *= 0.4;
    }
    return total;
}

float when_gt(float x, float y) { //greater than return 1
    return max(sign(x - y), 0.0);
}

// -----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------
  
    vec2 p = UV;
    vec2 uv = UV;    

    // Tweaking Shape  #VARIATION
    //TIME = CoronaTotalTime + 100;
    //uv.x = uv.x*TIME* 100;
    //uv.y = uv.y*TIME* 1.5;

    float time = TIME * Speed;
    float q = fbm(uv * Zoom * 0.5);

    //ridged noise shape
    float r = 0.0;
    uv *= Zoom;
    uv -= q - time;
    float weight = 0.8;
    for (int i=0; i<8; i++){
    r += abs(weight*noise( uv ));
        uv = m*uv + time;
    weight *= 0.7;
    }

    //noise shape
    float f = 0.0;
    uv = p*vec2(iResolution.x/iResolution.y,1.0);
    uv *= Zoom;
    uv -= q - time;
    weight = 0.7;
    for (int i=0; i<8; i++){
    f += weight*noise( uv );
        uv = m*uv + time;
    weight *= 0.6;
    }

    f *= r + f;

    //noise colour
    float c = 0.0;
    time = TIME * Speed * 2.0;
    uv = p*vec2(iResolution.x/iResolution.y,1.0);
    uv *= Zoom*2.0;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++){
    c += weight*noise( uv );
        uv = m*uv + time;
    weight *= 0.6;
    }

    //noise ridge colour
    float c1 = 0.0;
    time = TIME * Speed * 3.0;
    uv = p*vec2(iResolution.x/iResolution.y,1.0);
    uv *= Zoom*3.0;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++){
    c1 += abs(weight*noise( uv ));
        uv = m*uv + time;
    weight *= 0.6;
    }

    c += c1;

    vec3 Col_Sky = mix(Col_Sky2, Col_Sky1, p.y);
    vec3 cloudcolour = vec3(1.1, 1.1, 0.2) * clamp((Darkness + Brightness*c), 0.0, 1.0);

    // No Sky Color
    //vec3 Col_Sky = vec3(0,0,0);
    //vec3 cloudcolour = vec3(1.1, 1.1, 0.9) * clamp((Darkness + Brightness*c), 0.0, 1.0);


    f = Cover + Cloudalpha*f*r;

    vec3 result = mix(Col_Sky, clamp(Skytint * Col_Sky + cloudcolour, 0.0, 1.0), clamp(f + c, 0.0, 1.0));
    
    COLOR = vec4( result, 1.0);

    //----------------------------------------------

    // Rid Off Darker Color  #VARIATION
    float alpha = when_gt( result.r, 0.5) *0.95;
    COLOR = vec4( result, alpha );
    // Cloud Only < Need "Rid Off Darker Color" ON >      #VARIATION
    //COLOR.rgb *= COLOR.a;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


