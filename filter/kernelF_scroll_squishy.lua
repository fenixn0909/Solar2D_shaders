
-- Need: display.setDefault( "textureWrapX", "repeat" )

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "scroll"
kernel.name = "squishy"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "speedX",
    default = 0.1,
    min = -10,
    max = 10,
    index = 0, -- v_UserData.x
  },
  {
    name = "speedY",
    default = 0.1,
    min = -10,
    max = 10,
    index = 1, -- v_UserData.y
  },
}

kernel.vertex =
[[
#define SPEED 0.1



uniform P_COLOR mat4 u_UserData0; 
uniform P_COLOR mat4 u_UserData1; 

//P_DEFAULT float speed = 0.1;

const P_DEFAULT float scale = 16.0;
const P_DEFAULT float speed = 7.0;


P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{

    P_UV vec2 offset = vec2(CoronaTotalTime * speed, 0.0);
    //P_UV vec2 movedPixel = (pixel - offset) / scale;
    //P_UV vec2 uv = (floor(movedPixel) + 0.5);
    
    /*
    if (pixel.x > iResolution.x / 2.0)
        uv += 1.0 - clamp((1.0 - fract(movedPixel)) * scale, 0.0, 1.0);

    color = texture(iChannel0, uv / iChannelResolution[0].xy);

    if (pixel.x > iResolution.x / 2.0 - 1.0 && pixel.x < iResolution.x / 2.0) color = vec4(0.0);
    */

    //P_DEFAULT float timer = mod( CoronaTotalTime, 360000);
    //position.x = 1000.0 * timer;
    //P_DEFAULT float timer = mod( CoronaTotalTime, 360000);
    //position.x += 10.0 * timer;
    
    //if (position.x > 100.0) { position.x = 000.0; }

    return position;
}
]]


kernel.fragment =
[[
uniform P_DEFAULT vec4 u_resolution;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  //P_UV vec2 uv = texCoord;
  //uv.x = texCoord.x * 1.0 + pow(abs(sin(3.14 * texCoord.x/2.0)),2.0);

  //P_COLOR vec4 texColor = texture2D( u_FillSampler0, uv + CoronaTotalTime * 0.08 ); 

  //Diagonal Stretch Wavy
  //P_DEFAULT float offX = texCoord.x * 1.0 + pow(abs(sin(3.14 * texCoord.x/2.0)),2.0);
  //P_DEFAULT float offY = texCoord.x * 1.0 + pow(abs(sin(3.14 * texCoord.x/2.0)),2.0);


  //Water
  //P_DEFAULT float offX = texCoord.x * 1.0 + pow(abs(sin(3.14 * texCoord.x/2.0)),2.0);
  //P_DEFAULT float offY = texCoord.y * 1.0 + pow(abs(sin(3.14 * texCoord.y/2.0)),2.0);
  
  //BulgeX
  //P_DEFAULT float offX = texCoord.x * 1.0 + pow(abs(cos(3.14 * texCoord.x/2.0)),2.0);
  //P_DEFAULT float offY = texCoord.y * 1.0 + pow(abs(sin(3.14 * texCoord.y/2.0)),2.0);
  
  //BulgeY
  //P_DEFAULT float offX = texCoord.x * 1.0 + pow(abs(sin(3.14 * texCoord.x/2.0)),2.0);
  //P_DEFAULT float offY = texCoord.y * 1.0 + pow(abs(cos(3.14 * texCoord.y/2.0)),2.0);
  
  //Bulge Diagonal
  //P_DEFAULT float offX = texCoord.y * 1.0 + pow(abs(sin(3.14 * texCoord.y/2.0)),2.0);
  //P_DEFAULT float offY = texCoord.y * 1.0 + pow(abs(cos(3.14 * texCoord.y/2.0)),2.0);
  
  //Bulge Diagonal  Larger the rate for texCoord, Wider the view of texture
  P_DEFAULT float offX = texCoord.x * 1.0 + pow(abs(sin(3.14 * texCoord.x/3.0)),2.0);
  P_DEFAULT float offY = texCoord.y * 1.0 + pow(abs(cos(3.14 * texCoord.y/2.0)),2.0);
  
  P_UV vec2 uRes = u_resolution.xy;


  P_UV vec2 uv_offset = vec2( texCoord.x + offX, texCoord.y + offY );
  P_COLOR vec4 texColor = texture2D( u_FillSampler0, uv_offset + CoronaTotalTime * 0.08 ); 

  return CoronaColorScale(texColor);
}
]]



return kernel