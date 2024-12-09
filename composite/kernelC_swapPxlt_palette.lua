
--[[
  USAGE:
  
  For Art Part:
    Method A, from scratch:
    Open your graphic editor, mine is Aseprite.
    1.Create a 4x4 pixels blank palette, make sure it's SQUARE(Range: from 2x2 to 16x16).
    the index format in 4x4 will be:
        0,  1,  2,  3,
        4,  5,  6,  7,
        8,  9, 10, 11,
       12, 13, 14, 15,
    
    2.At index[0], this will be the background color, leave the value of "Blue and Alpha Channels to 0". (Alpha to 1 if you're using background for ur art)
    3.For index[1]~index[15], assign the value of "Blue Channel form 1 to 15 that matching the index".
    4.In index[1]~index[15], tweak the value of "R and G Channel as you like" (mainly for the readibility of creating art)
    5.Save it as "moldPalette.png".
    6.Make art with the palette, "make sure file size is SQUARE", save it as "moldSprite.png".  (Tip: set the color mode to index, so you won't get error by accidently changed the Blue Channel)
    7.Load moldPalette, change the colors as you need, save it as "swapPalette.png".
    
    Method B, from exist image:
    1.Create "temporaryPallete":
      Open the image you have created in Aseprite, click the "Option icon" above the palette, then choose "New palette from sprite". 
      Click the "Option icon", choose "save the palette" and save it as "temporaryPallete.png". 
      (if you are not using Aseprite, see if your graphic editor had the similiar function. if not, make the palette manually)
    2.Create "swapPallete":
      open temporaryPalette, set the sprite canvas to squre(4x4 or 6x6..etc).
      keep the RGBA of TopLeft pixel all 0, arrange the other colors in order you like.
      save the it as "swapPalette.png".
      
    3.Create "moldPalette":
      Open swapPalette, Run Method A form operation 2.~6.
  
  In Lua file:
  1.require ("kernel_composite_pixelate_paletteSwap')
  2.local _textureRatio = "width/height of swapPalette.png" / "width/height of moldSprite.png".
    if your palette size if 4x4 and sprite size is 32x32, then _textureRatio = 4/32
  3.local _paletteRowCols = "width/height of swapPalette.png"
    if your palette size if 4x4, then _paletteRowCols = 4

  4.Load the shader
  local _optImg = {
      type="composite",
      paint1={ type="image", filename= "moldSprite.png" },
      paint2={ type="image", filename= "swapPalette.png" }
  }
  spr.fill = _optImg
  spr.fill.effect = "composite.pixelate.paletteSwap"
  spr.fill.effect.textureRatio = _textureRatio
  spr.fill.effect.paletteRowCols = _paletteRowCols
  
  DONE!

--]]

--Or more generally for pixel i in a N wide texture the proper texture coordinate is
--(2i + 1)/(2N)



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "swapPxlt"
kernel.name = "palette"

kernel.vertexData =
{
  {
    name = "texDiffRatioX",
    default = 1,
    min = 0,
    max = 32,  
    index = 0,    
  },
  {
    name = "texDiffRatioY",
    default = 1,
    min = 0,
    max = 32,  
    index = 1,    
  },
  {
    name = "paletteRowCols",
    default = 4,
    min = 1,
    max = 16,     
    index = 2,    -- CoronaVertexUserData.z
  },
}



kernel.vertex =
[[
vec2 texDiffRatio = vec2( CoronaVertexUserData.x, CoronaVertexUserData.y );


varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;



P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{ 
  slot_size = vec2( u_TexelSize.z, u_TexelSize.w ) * texDiffRatio; // multiply textureRatio to get matching UV of palette.
  sample_uv_offset = ( slot_size * 0.5 );
  return position;
}
]]

kernel.fragment =
[[
varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;

const P_COLOR float TICK_COLOR = 0.0039;      // TICK_COLOR > 1/255, so you can get interger from floor( keyRGB / TICK_COLOR )
P_DEFAULT float paletteRowCols = CoronaVertexUserData.z;
P_DEFAULT float tickUV = 1 / paletteRowCols;


P_UV vec2 getSwapUV(P_DEFAULT float keyRGB)
{
  P_DEFAULT float indColor = floor( keyRGB / TICK_COLOR);     // Swap Color Index: will be integer from 0~255.

  P_DEFAULT float indX = indColor - floor( indColor / paletteRowCols) * paletteRowCols; 
  P_DEFAULT float indY = floor( indColor / paletteRowCols);        
  
  P_DEFAULT float uSwap = ( indX + 0.5 ) * tickUV ;                // Get the color from central point to matching the color you assigned in palette
  P_DEFAULT float vSwap = ( indY + 0.5 ) * tickUV ; 
  
  return vec2(uSwap,vSwap);
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  // Get Image Color
  P_UV vec2 uv_offset = ( sample_uv_offset + ( floor( texCoord / slot_size ) * slot_size )   );
  P_COLOR vec4 texColor = texture2D( u_FillSampler0, uv_offset ); 

  // Get Palette Color
  P_UV vec2 uv_swap = getSwapUV( texColor.b ); // Pick one of r,g,b as key according to your image 
  P_COLOR vec4 swapColor = texture2D( u_FillSampler1, uv_swap );

  // Swap color
  texColor = swapColor;       

  return CoronaColorScale(texColor);
}
]]

return kernel
-- graphics.defineEffect( kernel )