
--[[
  Origin Author: haruyou27
  https://godotshaders.com/author/haruyou27/
  
  Origin shader from

  https://www.shadertoy.com/view/XlfGRj

  A beautiful yet simple shader.

  Play with parameter to see all kinds of amazing thing this shader can do.

  I use low precision in the iterations to speed up the caculation at least twice as fast. 
  Not sure if it will cause any problem.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "scene"
kernel.name = "starnest"
-- kernel.isTimeDependent = true -- High Overhead!

kernel.vertexData =
{
  {
    name = "textureRatio",
    default = 1,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "paletteRowCols",
    default = 4,
    min = 1,
    max = 16,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
}



kernel.vertex =
[[
varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;

P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{ 
  slot_size = vec2( u_TexelSize.z, u_TexelSize.w ) * v_UserData.x; // multiply textureRatio to get matching UV of palette.
  sample_uv_offset = ( slot_size * 0.5 );

  //position.x += CoronaTotalTime * 0.1;

  return position;
}
]]

kernel.fragment =
[[

uniform P_DEFAULT vec4 u_resolution;


P_DEFAULT int iterations = 20;
P_DEFAULT float formuparam = 1.00;

P_DEFAULT int volsteps = 20;
P_DEFAULT float stepsize = 0.1;

P_DEFAULT float zoom = 0.800;
P_DEFAULT float tile = 0.5;
P_DEFAULT float speed = 0.001;

P_DEFAULT float brightness = 0.002;
P_DEFAULT float darkmatter = 0.100;
P_DEFAULT float distfading = 0.650;
P_DEFAULT float saturation = 0.750;


P_DEFAULT float SCurve (P_DEFAULT float value) {

    if (value < 0.5)
    {
        return value * value * value * value * value * 16.0; 
    }
    
    value -= 1.0;
    
    return value * value * value * value * value * 16.0 + 1.0;
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  vec2 iResolution = 1.0 / vec2(1.0,1.0);

  //get coords and direction
  //vec2 uv=FRAGCOORD.xy/iResolution.xy;
  vec2 uv=texCoord.xy/iResolution.xy;
  uv.y*=iResolution.y/iResolution.x;
  vec3 dir=vec3(uv*zoom,1.);
  float time=CoronaTotalTime*speed;

  vec3 from=vec3(1.0,0.5,0.5);
  from-=vec3(0.0,time,0.0);
  
  //volumetric rendering
  float s=0.1,fade=1.;
  vec3 v=vec3(0.);
  for (int r=0; r<volsteps; r++) {
    lowp vec3 p=from+s*dir*0.5;
    p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
    lowp float pa,a=pa=0.;
    for (int i=0; i<iterations; i++) { 
      p=abs(p)/dot(p,p)-formuparam; // the magic formula
      a+=abs(length(p)-pa); // absolute sum of average change
      pa=length(p);
    }
    lowp float dm=max(0.,darkmatter-a*a*.001); //dark matter
    a = pow(a, 2.3); // add contrast
    if (r>6) fade*=1.-dm; // dark matter, don't render near
    v+=fade;
    v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
    fade*=distfading; // distance fading
    s+=stepsize;
  }
    
  v=mix(vec3(length(v)),v,saturation); //color adjust
    
  vec4 C = vec4(v*.01,1.);
  
  C.r = pow(C.r, 0.35); 
  C.g = pow(C.g, 0.36); 
  C.b = pow(C.b, 0.38); 

  vec4 L = C;     
  
  P_COLOR vec4 finColor;

  finColor.r = mix(L.r, SCurve(C.r), 0.7); 
  finColor.g = mix(L.g, SCurve(C.g), 1.0); 
  finColor.b = mix(L.b, SCurve(C.b), 0.2); 
  finColor.a = 1;

  return CoronaColorScale(finColor);
}
]]

return kernel
