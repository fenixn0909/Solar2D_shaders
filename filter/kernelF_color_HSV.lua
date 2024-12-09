

--[[
  Origin Author: al1-ce
  https://godotshaders.com/shader/hsv-adjustment/
  
  Just a simple hsv ajustment shader

--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "HSV"

kernel.vertexData =
{
  {
    name = "intensity",
    default = 0,
    min = 0,
    max = 1,
    index = 0, -- v_UserData.x
  },
}

kernel.isTimeDependent = true


kernel.fragment =
[[
P_COLOR float tweener;
//----------------------------------------------
float h = 1; //: hint_range(0,1) = 1;
float s = 1; //: hint_range(0,1) = 1;
float v = 1; //: hint_range(0,1) = 1;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}



//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  //P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
  P_COLOR vec4 COLOR;

  h = sin(CoronaTotalTime*7 * 0.2);
  s = sin(CoronaTotalTime*3 * 0.2);
  v = abs(sin(CoronaTotalTime*5 * 0.2))+0.75;
  //----------------------------------------------
  vec4 col = texture2D(CoronaSampler0, UV);
    
  col.rgb = hsv2rgb(rgb2hsv(col.rgb) * vec3(h, s, v));
  
  COLOR = col;
  
  //----------------------------------------------

  return CoronaColorScale( COLOR );
}
]]

return kernel