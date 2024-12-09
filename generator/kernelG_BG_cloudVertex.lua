
--[[

  https://www.shadertoy.com/view/msfXD8

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "cloudVertex"


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

const lowp float speed = 0.25;

mat2 r2d(float a) 
{
  float c = cos(a), s = sin(a);
    return mat2(
        c, s, 
        -s, c 
    );
}

float noise(vec2 uv)
{
    return fract(sin(uv.x * 113. + uv.y * 412.) * 6339.);
}

vec3 noiseSmooth(vec2 uv)
{
    vec2 index = floor(uv);
    
    vec2 pq = fract(uv);
    pq = smoothstep(0., 1., pq);
     
    float topLeft = noise(index);
    float topRight = noise(index + vec2(1, 0.));
    float top = mix(topLeft, topRight, pq.x);
    
    float bottomLeft = noise(index + vec2(0, 1));
    float bottomRight = noise(index + vec2(1, 1));
    float bottom = mix(bottomLeft, bottomRight, pq.x);
    
    return vec3(mix(top, bottom, pq.y));
}

vec3 genCloud(vec2 uv, vec2 orig, float bias)
{
  
    vec3 col = noiseSmooth(uv * 4.);
    
    col += noiseSmooth(uv * 8.) * 0.5;
    col += noiseSmooth(uv * 16.) * 0.25;
    col += noiseSmooth(uv * 32.) * 0.125;
    col += noiseSmooth(uv * 64.) * 0.0625;
    
    col *= distance(orig, vec2(0.))*bias;  

  
    col *= smoothstep(0.2, .8, col);   
   
    return col;
}


// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = texCoord / iResolution;
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime * speed;
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  
    vec2 uv = (fragCoord - 0.5 * iResolution.xy)/iResolution.y;
    //vec4 sky = vec4(vec3(0.5, 0.7, 0.85) * ((1. - uv.y) + 1.5) / 2., 1.) / 2.1;
    vec4 sky = vec4(0,0,0,0);


    vec2 orig = uv;
    
    vec2 uv2 = uv;
    vec2 uv3 = uv;
        
    uv *= r2d(iTime - distance(uv, vec2(0.)));
    uv2 *= r2d(iTime/2. - distance(uv, vec2(0.))*1.2);
    uv3 *= r2d(iTime/3. - distance(uv, vec2(0.)));
    
    uv2 += 0.4;
    uv3 += 0.3;
    
    float l1 = fract((iTime) / 5.) + 1.;
    float l2 = fract((iTime + 0.6) / 2.) + 1.5;

        
    vec4 col = vec4(genCloud(uv, orig, 1.65), 0.);    
    col = mix(col, vec4(genCloud(uv2, orig, 3.8), 0.), 0.5);
    col = mix(col, vec4(genCloud(uv3, orig, 0.5), 0.), 0.3);
     
    col = mix(1. - (col / 5.), sky, 1. - col);    
        
    // Output to screen
    //fragColor = col;

  //----------------------------------------------
  //float alpha = when_gt( result.r, 0.5) *0.75;
  COLOR = col;
  //COLOR.a = alpha;
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


