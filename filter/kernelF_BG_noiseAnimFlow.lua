
--[[
  
  Origin Author: nimitz
  https://www.shadertoy.com/view/MdlXRS

  Playing with different ways of animating noise. 
  In this version, the noise is made using a technique similar to "flow noise" (maybe it even qualifies as flow noise)
  

  // Noise animation - Flow
  // 2014 by nimitz (twitter: @stormoid)
  // https://www.shadertoy.com/view/MdlXRS
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
  // Contact the author for other licensing options


  //Somewhat inspired by the concepts behind "flow noise"
  //every octave of noise is modulated separately
  //with displacement using a rotated vector field

  //normalization is used to created "swirls"
  //usually not a good idea, depending on the type of noise
  //you are going for.

  //Sinus ridged fbm is used for better effect.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "BG"
kernel.name = "noiseAnimFlow"


kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name = "texWidth",
    default = 64,
    min = 1,
    max = 9999,
    index = 0,    
  },
  {
    name = "texHeight",
    default = 64,
    min = 1,
    max = 9999,  
    index = 1,    
  },
}


kernel.fragment =
[[
P_DEFAULT vec2 texSize = vec2( CoronaVertexUserData.x, CoronaVertexUserData.y );

//P_UV vec2 iResolution = vec2(1.);
//P_UV vec2 iResolution = vec2( 1, texSize.y / texSize.x);
P_UV vec2 iResolution = vec2( texSize.x, texSize.y);
//----------------------------------------------
  #define time CoronaTotalTime*0.1
  #define tau 6.2831853

  float intensive = 6.; // 2.  6: balanced 12: for flame world
  float detail = 3.; //7.  3 for toon

  //P_COLOR vec3 baseColor = vec3(.2,0.07,0.01); // Origin Lava 
  //P_COLOR vec3 baseColor = vec3(.35,0.11,0.04); // Flame vec3(.2,0.07,0.01)
  //P_COLOR vec3 baseColor = vec3(.27,0.53,0.81); // Ocean
  //P_COLOR vec3 baseColor = vec3(.97,0.83,0.11); // Golden Shine
  //P_COLOR vec3 baseColor = vec3(.37,0.33,0.06); // Golden Dark
  P_COLOR vec3 baseColor = vec3(.27,0.09,0.61); // Poison

  mat2 makem2(in float theta){float c = cos(theta);float s = sin(theta);return mat2(c,-s,s,c);}
  float noise( in vec2 x ){return texture2D( CoronaSampler0, x*.01).x;}
  mat2 m2 = mat2( 0.80,  0.60, -0.60,  0.80 );

  float grid(vec2 p)
  {
    float s = sin(p.x)*cos(p.y);
    return s;
  }

  float flow(in vec2 p)
  {
    float z= intensive;
    float rz = 0.;
    vec2 bp = p;
    for (float i= 1.;i < detail;i++ )
    {
      bp += time*1.5;
      vec2 gr = vec2(grid(p*3.-time*2.),grid(p*3.+4.-time*2.))*0.4;
      gr = normalize(gr)*0.4;
      gr *= makem2((p.x+p.y)*.3+time*10.);
      p += gr*0.5;
      
      rz+= (sin(noise(p)*8.)*0.5+0.5) /z;
      
      p = mix(bp,p,.5);
      z *= 1.7;
      p *= 2.5;
      p*=m2;
      bp *= 2.5;
      bp*=m2;
    }
    return rz;  
  }

  float spiral(vec2 p,float scl) 
  {
    float r = length(p);
    r = log(r);
    float a = atan(p.y, p.x);
    return abs(mod(scl*(r-2./scl*a),tau)-1.)*2.;
  }


// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = ( texCoord.xy / iResolution );
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;

  //scale = sin(CoronaTotalTime*3) * 1000;
  //amount = abs(sin(CoronaTotalTime*1)) * 3 + 1.5; // For Dot
  //amount = abs(sin(CoronaTotalTime*1)) *2  + 1; // For Line
  //saturation = abs(sin(CoronaTotalTime)) * 1 + .7;

  //----------------------------------------------
    float texRatio = iResolution.x/iResolution.y;
    //vec2 p = fragCoord.xy / iResolution.xy-0.5;
    //vec2 p = gl_FragCoord.xy / iResolution.xy - vec2(1.2, 1.2 );
    vec2 p = texCoord.xy - 0.5;
    p.x *= iResolution.x/iResolution.y;
    //p.y *= iResolution.y/iResolution.x;

    p*= 6.;
    float rz = flow(p);
    p /= exp(mod(time*3.,2.1));
    rz *= (6.-spiral(p,3.))*.9;
    vec3 col = baseColor/rz;
    col=pow(abs(col),vec3(1.01));
    COLOR = vec4(col,1.0);

  //----------------------------------------------
  //COLOR.a *= alpha;
  //COLOR.rgb *= COLOR.a;
  //COLOR.rgb = col2;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


