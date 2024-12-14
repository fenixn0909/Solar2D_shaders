--[[
  Origin Author: Kamots
  https://godotshaders.com/author/Kamots/

  A fragment shader that computes a flat-top hexagon mask. 
  The mask can hide or display, using selectable alpha values, any or all of: 
  the hexagon shape, an outline of the hexagon shape, the border area outside the hexagon shape.

  There are four shader parameters:

  Border Alpha: The border is the area “outside” the hexagon. This alpha value defaults to 0.0, making the border area invisible.
  Tile Alpha: The tile is the hexagon area occupying the center of the texture. This alpha value defaults to 1.0, making the hex tile fully visible. 
  (The TileAlpha is multiplied by the original alpha of the pixel, so all alpha information in the original texture is also preserved in the hex masking.)
  Outline Size: The outline is the edges of the tile area, expressed in UV units. The outline size defaults to 0.0, producing no outline
  Outline Alpha: The alpha value for the outline portion of the hex mask.

--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "hexBorder"

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

// 2D Hexagon Masking Shader
//shader_type canvas_item;

// Firt quadrant hexagon edge constants
const float X1 = 0.25;
const float Y1 = 0.06698729810778;
const float M  = -1.73205080756888;

// Border = Everything outside the hexagon
// Tile = Everything inside the hexagon
// Outline = Edges of the hexagon (size in UV units)
uniform float BorderAlpha = 1.0;  //: hint_range( 0.0, 1.0 )
uniform float TileAlpha = 0.5;    //: hint_range( 0.0, 1.0 )
uniform float OutlineSize = 0.05;  //: hint_range( 0.0, 0.5 )
uniform float OutlineAlpha = 1.0; //: hint_range( 0.0, 1.0 )

P_COLOR vec4 colorOL = vec4( 1, 0, 0, 1.0);
P_COLOR vec4 colorTile = vec4( 0.2, 0.2, 0.1, 1);

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 COLOR;

  // Pixelate
  P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
  P_UV vec2 UV = UV_Pix;
  // Smooth
  //P_UV vec2 UV = texCoord;

  // Smooth outline
  P_UV vec2 uvOL = texCoord;

  //------------------------------------------------------------

  // Pull in the texture
  COLOR = texture2D( CoronaSampler0, UV );
  // Need a copy for original alpha values
  vec4 color = texture2D( CoronaSampler0, UV );
  // Set everything to the BorderAlpha
  //COLOR.a = color.a * BorderAlpha;
  // Map current point to first quadrant
  float x0 = min( uvOL.x, 1.0 - uvOL.x );
  float y0 = min( uvOL.y, 1.0 - uvOL.y );
  // Compute line through UV.x,UV.y orthogonal to hex edge
  float m = M;
  float m0 = -1.0 / m;
  float b0 = y0 - m0 * x0;
  // Find x,y = intersection of hex edge and orthognoal through UV.x,UV.y
  float x = ( 0.5 - b0 ) / ( m0 - m );
  float y = m0 * x + b0;
  // Are we inside the hex?
  if ( x0 >= x && y0 >= Y1 ) {
    float d = distance( vec2( x, y ), vec2( x0, y0 ) );
    // Are we inside the outline?
    if ( d < OutlineSize || y0 - Y1 < OutlineSize )
    {
      colorOL.rgb *= colorOL.a;
      COLOR.rgb = colorOL.rgb;

    }
    else
    {
      colorTile.rgb *= 1-COLOR.a;
      COLOR = mix( COLOR, colorTile, 1-COLOR.a);
    }
  }

  //------------------------------------------------------------

  return CoronaColorScale( COLOR );
}
]]
return kernel
--[[



--]]