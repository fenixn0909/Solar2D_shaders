
--[[
  Inspire from TY Code Monkey
  https://www.youtube.com/watch?v=auglNRLM944

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "dissolveMistOG" --With Outline Glow

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "colorFadeR",
    default = 1,
    min = 0,
    max = 1,     
    index =0,    
  },
  {
    name = "colorFadeG",
    default = 1,
    min = 0,
    max = 1,     
    index = 1,    
  },
  {
    name = "colorFadeB",
    default = 1,
    min = 0,
    max = 1,     
    index = 2,    
  },
  {
    name = "slider", --The smaller the larger
    default = 0.5,
    min = 0,
    max = 1,
    index = 3,    
  },
}


kernel.fragment =
[[

uniform P_DEFAULT float strokeSize = 0.125; // best 0.125~0.3  :hint (0 ,1) GT 1 then color overlay one sprite 
uniform P_DEFAULT float texNoiseScaler = 0.8; 
uniform P_DEFAULT float noiseSize = 100.0;

float sheetSize = 4; // int, 1~any

P_COLOR vec4 colorFade = vec4( CoronaVertexUserData.x, CoronaVertexUserData.y, CoronaVertexUserData.z, 1);
P_DEFAULT float slider = CoronaVertexUserData.w;


float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float f_noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Test Make Square
    //i = vec2(1,1);

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

  //P_UV vec2 uvSpr = texCoord;

  P_UV vec2 uvNoise = texCoord * texNoiseScaler;
  P_COLOR vec4 colorSpr = texture2D(CoronaSampler0, uvSpr);

  vec2 pos = vec2( texCoord * noiseSize );
  float uvGrid = 1 / sheetSize * noiseSize; // consistent noise for spriteSheet
  
  // Moving Noise
  float uvMoveY = CoronaTotalTime * 30;
  vec2 rndSeed = vec2(mod(pos.x,uvGrid), mod(pos.y + uvMoveY,uvGrid) ); 
  float vNoise = f_noise( rndSeed );
  
  slider = sin(CoronaTotalTime);

  // Color Outline
  float aInner = step(vNoise, slider );
  float aOutter = step(vNoise, slider+strokeSize );
  float aOutLine = aOutter - aInner;

  colorFade.rgb *= aOutLine;
  colorSpr.a *= aOutter;


  // Fade 
  colorSpr.rgb += colorFade.rgb;
  colorSpr.rgb *= colorSpr.a;

  // Test Shield Damaged
  //colorSpr.rgb += colorFade.rgb * colorSpr.a;

  // Test Noise Color
  //colorSpr.rgb = vec3(vNoise);

  return CoronaColorScale(colorSpr);
}
]]

return kernel

--[[

--]]
