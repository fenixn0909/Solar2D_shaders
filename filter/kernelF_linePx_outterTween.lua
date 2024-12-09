--local object = display.newImage("image.png")

--object.fill.effect = "filter.custom.pixeloutline"
--object.fill.effect.intensity   = 0.0 to 10.0 -- how thick is it
--object.fill.effect.r, g, b   = 4 to 50 -- color

--So you will need to leave a 1px border around the image for the outline to work. 
--In this example there's no border on the bottom, so his feet aren't outlined.

--Add Pixelate?

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "linePx"
kernel.name = "outterTween"

kernel.vertexData  = {
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
    default = 0.5,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 0.1,
    min     = 0,
    max     = 4,
    index   = 3,
  },
}


kernel.fragment = 
[[



P_NORMAL float stroke = CoronaVertexUserData.w;

uniform P_DEFAULT float noiseSize = 100.0;

float sheetSize = 4; // int, 1~any
float tweenSpeed = 1;

varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;


float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float f_noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f*f*(3.0-2.0*f);

    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  // Test Pixelation
  P_UV vec2 uvPix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
  P_UV vec2 uvSpr = uvPix;

  P_COLOR vec4 v_lineColor = vec4( CoronaVertexUserData.x, CoronaVertexUserData.y, CoronaVertexUserData.z, 1);
  P_COLOR vec4 texColor = texture2D( CoronaSampler0, uvPix );

  // Noise Setup
  vec2 pos = vec2( texCoord * noiseSize );
  float uvGrid = 1 / sheetSize * noiseSize; // consistent noise for spriteSheet
  
  // Moving Noise
  float uvMoveY = CoronaTotalTime * 30;
  vec2 rndSeed = vec2(mod(pos.x,uvGrid), mod(pos.y + uvMoveY,uvGrid) ); 
  float vNoise = f_noise( rndSeed );

  // Noise Color1
  P_COLOR vec4 cNoiz1 = vec4(0.7, 0.8, 0.3, 1);
  cNoiz1.rgb *= vNoise;

  // Noise Color2
  P_COLOR vec4 cNoiz2 = vec4(1.5, 0.2, 0.0, 1);
  cNoiz2.rgb *= (0.6 -vNoise);

  // Tween Color
  P_COLOR vec4 cTween; 
  cTween.r = clamp( sin(CoronaTotalTime * 7 * tweenSpeed), -0.3, 0.2 );
  cTween.g = clamp( cos(CoronaTotalTime * 11 * tweenSpeed), -0.5, 0.7 );
  cTween.b = clamp( sin(CoronaTotalTime+240 * 9 * tweenSpeed), -0.2, 0.5 );

  if (texColor.a == 0.0)
  {
  P_NORMAL float w = stroke * CoronaTexelSize.z; //x
  P_NORMAL float h = stroke * CoronaTexelSize.w; //y
      if (texture2D(CoronaSampler0, texCoord + vec2(w, 0.0)).a != 0.0 ||
          texture2D(CoronaSampler0, texCoord + vec2(-w, 0.0)).a != 0.0 ||
          texture2D(CoronaSampler0, texCoord + vec2(0.0, h)).a != 0.0 ||
          texture2D(CoronaSampler0, texCoord + vec2(0.0,-h)).a != 0.0)
          {

            //vec3 mix(vec3 x, vec3 y, float a); return x*(1−a)+y*a
            //v_lineColor.rgb *= cNoiz1.rgb;
            //v_lineColor.rgb = mix(v_lineColor.rgb, cNoiz1.rgb, 0.5);
            v_lineColor.rgb += cNoiz1.rgb;
            v_lineColor.rgb += cNoiz2.rgb;
            v_lineColor.rgb += cTween.rgb;
            texColor.rgb = v_lineColor.rgb;
          }
  }
  //texColor *= cNoiz1;


  // Test Noise Color
  //texColor.rgb = vec3(vNoise);
  //texColor.rgb = vec3(cNoiz1);


  return CoronaColorScale(texColor);
}
]]
return kernel
-- graphics.defineEffect( kernel )