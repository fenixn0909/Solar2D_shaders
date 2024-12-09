--[[
  Origin Author: DrManatee
  https://godotshaders.com/author/DrManatee/

  A simple shader which adds animated dark static borders to the edge of the screen.

  Perfect for a horror game or TV screen effect.

  To put it into your game, simply place it onto a ColorRect that covers the screen.

  Variables:

  There are a few constants that can be customized in this script. If you want to change them overtime or at run-time, you can declare them within the fragment shader instead or change them to uniforms.

  UPDATE_INTERVAL: Pause between each time the static updates, in seconds.

  STATIC_GRANULARITY: Size of the individual static pixels. Choose a value between 0 and 1.

  EDGE_BLUR: Amount of blur on the dark border around the edge of the screen.

  BORDER_SIZE: Radial distance from the center where the border effect starts.

--]]

local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "animatedTV"
kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name    = "r",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
    },{
    name    = "g",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 1,
    },{
    name    = "b",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 1,
    min     = 0,
    max     = 4,
    index   = 3,
  },
}


kernel.fragment = 
[[
const float UPDATE_INTERVAL = .163;
const float STATIC_GRANULARITY = .005;
const float EDGE_BLUR = .5;
const float BORDER_SIZE = .3;

float generate_random_static (in float size, in float interval, in vec2 uv){
  float time_step = CoronaTotalTime - mod(CoronaTotalTime,interval);
  vec2 uv_step = uv - mod(uv, size);
  return fract(sin(dot(uv_step,vec2(12.0278*sin(time_step),15.0905)))*43758.5453);
}

vec2 get_polar_coords (vec2 center, vec2 uv){
  vec2 pos = uv-center;
  float r = length(pos);
  float theta = atan(pos.y,pos.x);
  return vec2(r,theta);
}

vec4 layer (in vec4 front_color, in vec4 back_color){
  return vec4(mix(back_color.rgb,front_color.rgb,front_color.a),front_color.a+back_color.a);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 COLOR;

  // Pixelate
  //P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
  //P_UV vec2 UV = UV_Pix;
  // Smooth
  P_UV vec2 UV = texCoord;

  // Smooth outline
  //P_UV vec2 uvOL = texCoord;

  //------------------------------------------------------------

  vec3 static_plot = vec3(generate_random_static(STATIC_GRANULARITY,UPDATE_INTERVAL,UV));
  
  vec2 c1 = vec2(0.5);
  vec2 pv1 = get_polar_coords(c1,UV);
  float func = BORDER_SIZE-.015*cos(4.0*pv1.y);
  float border_plot = smoothstep(func,func+EDGE_BLUR, pv1.x);
  vec4 border_color = vec4(vec3(0.0),1.0)*border_plot;
  COLOR = vec4(static_plot,.1);
  COLOR = layer(COLOR,border_color);

  //------------------------------------------------------------

  return CoronaColorScale( COLOR );
}
]]
return kernel
--[[



--]]