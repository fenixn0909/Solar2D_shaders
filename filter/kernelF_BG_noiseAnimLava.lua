
--[[
  
  Origin Author: nimitz
  https://www.shadertoy.com/view/lslXRS

  Playing with different ways of animating noise. 
  In this version, the noise is made using the ideas behind "flow noise", 
  I'm not quite sure it qualifies though, but it looks decent enough.

  // Noise animation - Lava
  // by nimitz (twitter: @stormoid)
  // https://www.shadertoy.com/view/lslXRS
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
  // Contact the author for other licensing options

  //Somewhat inspired by the concepts behind "flow noise"
  //every octave of noise is modulated separately
  //with displacement using a rotated vector field

  //This is a more standard use of the flow noise
  //unlike my normalized vector field version (https://www.shadertoy.com/view/MdlXRS)
  //the noise octaves are actually displaced to create a directional flow

  //Sinus ridged fbm is used for better effect.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "BG"
kernel.name = "noiseAnimLava"


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
  float scale = 8.;

  //P_COLOR vec3 baseColor = vec3(.2,0.07,0.01); // Origin Lava 
  //P_COLOR vec3 baseColor = vec3(.35,0.11,0.04); // Flame vec3(.2,0.07,0.01)
  P_COLOR vec3 baseColor = vec3(.27,0.53,0.81); // Ocean
  //P_COLOR vec3 baseColor = vec3(.97,0.83,0.11); // Golden Shine
  //P_COLOR vec3 baseColor = vec3(.37,0.33,0.06); // Golden Dark
  //P_COLOR vec3 baseColor = vec3(.27,0.09,0.61); // Poison

  float hash21(in vec2 n){ return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453); }
  mat2 makem2(in float theta){float c = cos(theta);float s = sin(theta);return mat2(c,-s,s,c);}
  float noise( in vec2 x ){return texture2D(CoronaSampler0, x*.01).x;}

  vec2 gradn(vec2 p)
  {
    float ep = .09;
    float gradx = noise(vec2(p.x+ep,p.y))-noise(vec2(p.x-ep,p.y));
    float grady = noise(vec2(p.x,p.y+ep))-noise(vec2(p.x,p.y-ep));
    return vec2(gradx,grady);
  }

  float flow(in vec2 p)
  {
    float z=2.;
    float rz = 0.;
    vec2 bp = p;
    for (float i= 1.;i < 7.;i++ )
    {
      //primary flow speed
      p += time*.6;
      
      //secondary flow speed (speed of the perceived flow)
      bp += time*1.9;
      
      //displacement field (try changing time multiplier)
      vec2 gr = gradn(i*p*.34+time*1.);
      
      //rotation of the displacement field
      gr*=makem2(time*6.-(0.05*p.x+0.03*p.y)*40.);
      
      //displace the system
      p += gr*.5;
      
      //add noise octave
      rz+= (sin(noise(p)*7.)*0.5+0.5)/z;
      
      //blend factor (blending displaced system with base system)
      //you could call this advection factor (.5 being low, .95 being high)
      p = mix(bp,p,.77);
      
      //intensity scaling
      z *= 1.4;
      //octave scaling
      p *= 2.;
      bp *= 1.9;
    }
    return rz;  
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
  
    //vec2 p = fragCoord.xy / iResolution.xy-0.5;
    vec2 p = gl_FragCoord.xy / iResolution.xy-1;
    p.x *= iResolution.x/iResolution.y;
    p*= scale;
    float rz = flow(p);
    
    vec3 col = baseColor/rz;
    col=pow(col,vec3(1.4));
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


