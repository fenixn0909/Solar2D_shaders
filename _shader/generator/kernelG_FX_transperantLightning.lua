
--[[
  Transparent Lightning

  https://godotshaders.com/shader/energy-beams/
  Beider
  June 6, 2024

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "transperantLightning"

kernel.isTimeDependent = true

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


kernel.fragment =
[[

//----------------------------------------------

uniform int lightning_number = 5;
uniform vec2 amplitude = vec2(2.0,1.0);
uniform float offset = 0.45;
uniform float thickness = 0.02;
uniform float speed = 3.0;
uniform vec4 base_color = vec4(1.0, 1.0, 1.0, 1.0); // : source_color
uniform float glow_thickness = 0.08;
uniform vec4 glow_color = vec4(0.2, 0, 0.8, 0.0); // : source_color
uniform float alpha = 1.0; // : hint_range(0, 1)


//----------------------------------------------

//P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV );
P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;
const float PI = 3.14159265359;

//----------------------------------------------

// plot function 
float plot(vec2 st, float pct, float half_width){
  return  smoothstep( pct-half_width, pct, st.y) -
          smoothstep( pct, pct+half_width, st.y);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)),
              dot(uv, vec2(269.5,183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
                   dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
                   dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 n) {
    float total = 0.0, amp = 1.0;
    for (int i = 0; i < 7; i++) {
        total += noise(n) * amp;
        n += n;
        amp *= 0.5;
    }
    return total;
}

//----------------------------------------------



P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------

  vec2 uv = UV;
  vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
  
  vec2 t ;
  float y ;
  float pct ;
  float buffer; 
  // add more lightning
  for ( int i = 0; i < lightning_number; i++){
    t = uv * amplitude + vec2(float(i), -float(i)) - TIME*speed;
    y = fbm(t)*offset;
    pct = plot(uv, y, thickness);
    buffer = plot(uv, y, glow_thickness);
    color += pct*base_color;
    color += buffer*glow_color;
  }
  
  color.a *= alpha;
  COLOR = color;

  //COLOR.rgb *= color.a;
  //----------------------------------------------


  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


