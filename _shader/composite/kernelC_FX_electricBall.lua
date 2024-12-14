
--[[

    https://godotshaders.com/shader/electric-ball-canvas-item/
    Grandpa_Pit
    July 9, 2024


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "FX"
kernel.name = "electricBall"


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


//----------------------------------------------

//render_mode blend_add;



uniform float brightness = 2.5;
uniform float time_scale = 3.0;
float PI = 3.14159265359;

//P_COLOR vec4 COLOR;
P_COLOR vec4 COLOR = vec4( .5, 1., 0.3, 1.);
P_DEFAULT float TIME = CoronaTotalTime;


// -----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //P_DEFAULT float alpha = abs(sin(CoronaTotalTime));
    //P_DEFAULT float dt = abs(sin(CoronaTotalTime));
    //----------------------------------------------

    vec2 cc_uv = UV - vec2(.5); 
      float angle = atan(cc_uv.y, cc_uv.x) / PI + 1.;
      float p = sqrt(dot(cc_uv, cc_uv)); 
      vec2 puv = vec2(p, angle * .5);
      vec2 uv = puv * 2.;
      float time = TIME * time_scale;
      vec4 old_colo = COLOR;
      COLOR = vec4(.0);
      for(int i = 1; i <= 5; i++){
        float intensive = .1 + .07 * float(i);
        vec2 offset = (texture2D(CoronaSampler0, vec2(time*.35*(.5+fract(sin(float(i)*55.))), angle)).rg - vec2(.5)) * intensive; 
        vec2 uuv = uv + offset;
        float dist = abs(uuv.x - .5);
        float rand_speed = .2 + .05 * fract(cos(float(i)*1144.));
        float gone = smoothstep(.1 + 0.05 * (float(i) - .5), 1.0, texture2D(CoronaSampler1, uv + vec2(time*rand_speed)).s);
        COLOR += gone * old_colo / dist * .01 * texture2D(CoronaSampler1, uuv + vec2(time)).s;
      }
      vec4 light = old_colo * smoothstep(1.0, -2.0, abs(uv.x - .5) * 2.0) * texture2D(CoronaSampler1, uv).a; 
      COLOR += light * brightness; 

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    
--]]


