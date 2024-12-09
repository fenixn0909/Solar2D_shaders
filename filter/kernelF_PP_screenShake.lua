
--[[
  
  Origin Author:  flyingrub
  https://www.shadertoy.com/view/wsBXWW

  SHAKE ME Screenshake me! https://www.shadertoy.com/view/wsBXWW

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "PP" 
kernel.name = "screenShake"


kernel.isTimeDependent = true

kernel.vertexData =
{
  
}


kernel.fragment =
[[
P_UV vec2 iResolution = vec2(1. ,1.);

//----------------------------------------------
  const float amount = 0.1; // .2
  const float rotationAmount = .1; // 0.1, too larger will cause nauseous 
  const float speed = .05; // .1


  vec2 rotate2D(vec2 _uv, float _angle){
      _uv =  mat2(cos(_angle),-sin(_angle),
                  sin(_angle),cos(_angle)) * _uv;
      return _uv;
  }

  vec3 random3(vec3 c) {
    float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
    vec3 r;
    r.z = fract(512.0*j);
    j *= .125;
    r.x = fract(512.0*j);
    j *= .125;
    r.y = fract(512.0*j);
    return r;
  }
  const float F3 =  0.3333333;
  const float G3 =  0.1666667;

  float simplex3d(vec3 p) {
     vec3 s = floor(p + dot(p, vec3(F3)));
     vec3 x = p - s + dot(s, vec3(G3));
     
     vec3 e = step(vec3(0.0), x - x.yzx);
     vec3 i1 = e*(1.0 - e.zxy);
     vec3 i2 = 1.0 - e.zxy*(1.0 - e);
      
     vec3 x1 = x - i1 + G3;
     vec3 x2 = x - i2 + 2.0*G3;
     vec3 x3 = x - 1.0 + 3.0*G3;
     
     vec4 w, d;
     
     w.x = dot(x, x);
     w.y = dot(x1, x1);
     w.z = dot(x2, x2);
     w.w = dot(x3, x3);
     
     w = max(0.6 - w, 0.0);
     
     d.x = dot(random3(s)-.5, x);
     d.y = dot(random3(s + i1)-.5, x1);
     d.z = dot(random3(s + i2)-.5, x2);
     d.w = dot(random3(s + 1.0)-.5, x3);
     
     w *= w;
     w *= w;
     d *= w;
     
     return dot(d, vec4(52.0));
  }


// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = ( texCoord.xy / iResolution );
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;

  //----------------------------------------------
    vec2 uv = fragCoord/iResolution.xy;
    uv = uv*2.-1.;
      vec3 p3 = vec3(0,0, iTime*speed)*8.0+8.0;
      vec3 noise = vec3(simplex3d(p3),simplex3d(p3+10.),simplex3d(p3+20.));
      uv = rotate2D(uv, noise.z*rotationAmount*.1);
    uv = (uv+1.)/2.;
    COLOR = vec4(texture2D( CoronaSampler0, uv+noise.xy*amount*0.1 ).rgb, 1.0);

  //----------------------------------------------
  //COLOR.a = (COLOR.a+COLOR.g+COLOR.b)/3;
  //COLOR.a *= alpha;
  //COLOR.rgb *= COLOR.a;
  
  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


