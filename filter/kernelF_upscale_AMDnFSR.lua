--[[
  Origin Author: threethan
  https://godotshaders.com/author/threethan/
  
  The upscaling pass of AMDs FSR. (Internally called EASU).

  It does not include the sharpen pass, but still is a huge improvement over bilinear. 
  I’ve also ported over the sharpen pass, but Godot doesn’t really have a good way to do multi-pass post processing so it’s basically one or the other. 
  Godot 4 includes a more proper implementation, but this world in GLES 2 and GLES 3 on Godot 3.X.

  Should give significant gains over native res on desktop, but very heavy on mobile.

  To use, create a viewport at a lower resolution than the window size. 
  Then, pass that viewport texture to a texturerect that is larger than the viewport texture. 
  If you have the right setupo, you should be able to select filter for the viewport texture and get bilinear filtering Then, apply this shader to the texturerect. 
  (This shader will behave identically whether or not filter is enabled on the viewport texture)



    /* EASU stage
    *
    * SOURCE: https://www.shadertoy.com/view/stXSWB
    *
    * This takes a reduced resolution source, and scales it up while preserving detail.
    *
    * Updates:
    *   stretch definition fixed. Thanks nehon for the bug report!
    */

--]]



local kernel = {}

kernel.language = "glsl"

kernel.category = "filter"
kernel.group = "upscale"
kernel.name = "AMDnFSR"


kernel.vertexData =
{
  {
    name = "x",
    default = 1,
    min = 0,
    max = 4,
    index = 0, -- v_UserData.x
  },
  {
    name = "y",
    default = 1,
    min = 0,
    max = 4,
    index = 1, -- v_UserData.y
  },
}


kernel.fragment =
[[

/**** EASU ****/
void FsrEasuCon(
    out vec4 con0,
    out vec4 con1,
    out vec4 con2,
    out vec4 con3,
    // This the rendered image resolution being upscaled
    vec2 inputViewportInPixels,
    // This is the resolution of the resource containing the input image (useful for dynamic resolution)
    vec2 inputSizeInPixels,
    // This is the display resolution which the input image gets upscaled to
    vec2 outputSizeInPixels
)
{
    // Output integer position to a pixel position in viewport.
    con0 = vec4(
        inputViewportInPixels.x/outputSizeInPixels.x,
        inputViewportInPixels.y/outputSizeInPixels.y,
        .5*inputViewportInPixels.x/outputSizeInPixels.x-.5,
        .5*inputViewportInPixels.y/outputSizeInPixels.y-.5
    );
    // Viewport pixel position to normalized image space.
    // This is used to get upper-left of 'F' tap.
    con1 = vec4(1,1,1,-1)/inputSizeInPixels.xyxy;
    // Centers of gather4, first offset from upper-left of 'F'.
    //      +---+---+
    //      |   |   |
    //      +--(0)--+
    //      | b | c |
    //  +---F---+---+---+
    //  | e | f | g | h |
    //  +--(1)--+--(2)--+
    //  | i | j | k | l |
    //  +---+---+---+---+
    //      | n | o |
    //      +--(3)--+
    //      |   |   |
    //      +---+---+
    // These are from (0) instead of 'F'.
    con2 = vec4(-1,2,1,2)/inputSizeInPixels.xyxy;
    con3 = vec4(0,4,0,0)/inputSizeInPixels.xyxy;
}

// Filtering for a given tap for the scalar.
void FsrEasuTapF(
    inout vec3 aC, // Accumulated color, with negative lobe.
    inout float aW, // Accumulated weight.
    vec2 off, // Pixel offset from resolve position to tap.
    vec2 dir, // Gradient direction.
    vec2 len, // Length.
    float lob, // Negative lobe strength.
    float clp, // Clipping point.
    vec3 c
)
{
    // Tap color.
    // Rotate offset by direction.
    vec2 v = vec2(dot(off, dir), dot(off,vec2(-dir.y,dir.x)));
    // Anisotropy.
    v *= len;
    // Compute distance^2.
    float d2 = min(dot(v,v),clp);
    // Limit to the window as at corner, 2 taps can easily be outside.
    // Approximation of lancos2 without sin() or rcp(), or sqrt() to get x.
    //  (25/16 * (2/5 * x^2 - 1)^2 - (25/16 - 1)) * (1/4 * x^2 - 1)^2
    //  |_______________________________________|   |_______________|
    //                   base                             window
    // The general form of the 'base' is,
    //  (a*(b*x^2-1)^2-(a-1))
    // Where 'a=1/(2*b-b^2)' and 'b' moves around the negative lobe.
    float wB = .4 * d2 - 1.;
    float wA = lob * d2 -1.;
    wB *= wB;
    wA *= wA;
    wB = 1.5625*wB-.5625;
    float w=  wB * wA;
    // Do weighted average.
    aC += c*w;
    aW += w;
}

//------------------------------------------------------------------------------------------------------------------------------
// Accumulate direction and length.
void FsrEasuSetF(
    inout vec2 dir,
    inout float len,
    float w,
    float lA,float lB,float lC,float lD,float lE
)
{
    // Direction is the '+' diff.
    //    a
    //  b c d
    //    e
    // Then takes magnitude from abs average of both sides of 'c'.
    // Length converts gradient reversal to 0, smoothly to non-reversal at 1, shaped, then adding horz and vert terms.
    float lenX = max(abs(lD - lC), abs(lC - lB));
    float dirX = lD - lB;
    dir.x += dirX * w;
    lenX = clamp(abs(dirX)/lenX,0.,1.);
    lenX *= lenX;
    len += lenX * w;
    // Repeat for the y axis.
    float lenY = max(abs(lE - lC), abs(lC - lA));
    float dirY = lE - lA;
    dir.y += dirY * w;
    lenY = clamp(abs(dirY) / lenY,0.,1.);
    lenY *= lenY;
    len += lenY * w;
}

//------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    vec3 c;
    vec4 con0,con1,con2,con3;
    
    // "rendersize" refers to size of source image before upscaling.
    P_COLOR vec4 COLOR;
    vec2 UV = texCoord;
    vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
    vec2 rendersize = vec2(1.0)/TEXTURE_PIXEL_SIZE;
    vec2 iResolution = vec2(1.0)/TEXTURE_PIXEL_SIZE; //TODO
    FsrEasuCon(
        con0, con1, con2, con3, rendersize, rendersize, iResolution.xy
    );
    
    vec2 ip = (UV/TEXTURE_PIXEL_SIZE);
    
    //------------------------------------------------------------------------------------------------------------------------------
    // Get position of 'f'.
    vec2 pp = ip * con0.xy + con0.zw; // Corresponding input pixel/subpixel
    vec2 fp = floor(pp);// fp = source nearest pixel
    pp -= fp; // pp = source subpixel

    //------------------------------------------------------------------------------------------------------------------------------
    // 12-tap kernel.
    //    b c
    //  e f g h
    //  i j k l
    //    n o
    // Gather 4 ordering.
    //  a b
    //  r g
    vec2 p0 = fp * con1.xy + con1.zw;
    
    // These are from p0 to avoid pulling two constants on pre-Navi hardware.
    vec2 p1 = p0 + con2.xy;
    vec2 p2 = p0 + con2.zw;
    vec2 p3 = p0 + con3.xy;

    // TextureGather is not available on WebGL2
    vec4 off = vec4(-.5,.5,-.5,.5)*con1.xxyy;
    // textureGather to texture offsets
    // x=west y=east z=north w=south
    vec3 bC = texture2D(CoronaSampler0, (p0 + off.xw)).rgb; float bL = bC.g + 0.5 *(bC.r + bC.b);
    vec3 cC = texture2D(CoronaSampler0, (p0 + off.yw)).rgb; float cL = cC.g + 0.5 *(cC.r + cC.b);
    vec3 iC = texture2D(CoronaSampler0, (p1 + off.xw)).rgb; float iL = iC.g + 0.5 *(iC.r + iC.b);
    vec3 jC = texture2D(CoronaSampler0, (p1 + off.yw)).rgb; float jL = jC.g + 0.5 *(jC.r + jC.b);
    vec3 fC = texture2D(CoronaSampler0, (p1 + off.yz)).rgb; float fL = fC.g + 0.5 *(fC.r + fC.b);
    vec3 eC = texture2D(CoronaSampler0, (p1 + off.xz)).rgb; float eL = eC.g + 0.5 *(eC.r + eC.b);
    vec3 kC = texture2D(CoronaSampler0, (p2 + off.xw)).rgb; float kL = kC.g + 0.5 *(kC.r + kC.b);
    vec3 lC = texture2D(CoronaSampler0, (p2 + off.yw)).rgb; float lL = lC.g + 0.5 *(lC.r + lC.b);
    vec3 hC = texture2D(CoronaSampler0, (p2 + off.yz)).rgb; float hL = hC.g + 0.5 *(hC.r + hC.b);
    vec3 gC = texture2D(CoronaSampler0, (p2 + off.xz)).rgb; float gL = gC.g + 0.5 *(gC.r + gC.b);
    vec3 oC = texture2D(CoronaSampler0, (p3 + off.yz)).rgb; float oL = oC.g + 0.5 *(oC.r + oC.b);
    vec3 nC = texture2D(CoronaSampler0, (p3 + off.xz)).rgb; float nL = nC.g + 0.5 *(nC.r + nC.b);
   
    //------------------------------------------------------------------------------------------------------------------------------
    // Simplest multi-channel approximate luma possible (luma times 2, in 2 FMA/MAD).
    // Accumulate for bilinear interpolation.
    vec2 dir = vec2(0);
    float len = 0.;

    FsrEasuSetF(dir, len, (1.-pp.x)*(1.-pp.y), bL, eL, fL, gL, jL);
    FsrEasuSetF(dir, len,    pp.x  *(1.-pp.y), cL, fL, gL, hL, kL);
    FsrEasuSetF(dir, len, (1.-pp.x)*  pp.y  , fL, iL, jL, kL, nL);
    FsrEasuSetF(dir, len,    pp.x  *  pp.y  , gL, jL, kL, lL, oL);

    //------------------------------------------------------------------------------------------------------------------------------
    // Normalize with approximation, and cleanup close to zero.
    vec2 dir2 = dir * dir;
    float dirR = dir2.x + dir2.y;
    bool zro = dirR < (1.0/32768.0);
    dirR = inversesqrt(dirR);
    dirR = zro ? 1.0 : dirR;
    dir.x = zro ? 1.0 : dir.x;
    dir *= vec2(dirR);
    // Transform from {0 to 2} to {0 to 1} range, and shape with square.
    len = len * 0.5;
    len *= len;
    // Stretch kernel {1.0 vert|horz, to sqrt(2.0) on diagonal}.
    float stretch = dot(dir,dir) / (max(abs(dir.x), abs(dir.y)));
    // Anisotropic length after rotation,
    //  x := 1.0 lerp to 'stretch' on edges
    //  y := 1.0 lerp to 2x on edges
    vec2 len2 = vec2(1. +(stretch-1.0)*len, 1. -.5 * len);
    // Based on the amount of 'edge',
    // the window shifts from +/-{sqrt(2.0) to slightly beyond 2.0}.
    float lob = .5 - .29 * len;
    // Set distance^2 clipping point to the end of the adjustable window.
    float clp = 1./lob;

    //------------------------------------------------------------------------------------------------------------------------------
    // Accumulation mixed with min/max of 4 nearest.
    //    b c
    //  e f g h
    //  i j k l
    //    n o
    vec3 min4 = min(min(fC,gC),min(jC,kC));
    vec3 max4 = max(max(fC,gC),max(jC,kC));
    // Accumulation.
    vec3 aC = vec3(0);
    float aW = 0.;
    FsrEasuTapF(aC, aW, vec2( 0,-1)-pp, dir, len2, lob, clp, bC);
    FsrEasuTapF(aC, aW, vec2( 1,-1)-pp, dir, len2, lob, clp, cC);
    FsrEasuTapF(aC, aW, vec2(-1, 1)-pp, dir, len2, lob, clp, iC);
    FsrEasuTapF(aC, aW, vec2( 0, 1)-pp, dir, len2, lob, clp, jC);
    FsrEasuTapF(aC, aW, vec2( 0, 0)-pp, dir, len2, lob, clp, fC);
    FsrEasuTapF(aC, aW, vec2(-1, 0)-pp, dir, len2, lob, clp, eC);
    FsrEasuTapF(aC, aW, vec2( 1, 1)-pp, dir, len2, lob, clp, kC);
    FsrEasuTapF(aC, aW, vec2( 2, 1)-pp, dir, len2, lob, clp, lC);
    FsrEasuTapF(aC, aW, vec2( 2, 0)-pp, dir, len2, lob, clp, hC);
    FsrEasuTapF(aC, aW, vec2( 1, 0)-pp, dir, len2, lob, clp, gC);
    FsrEasuTapF(aC, aW, vec2( 1, 2)-pp, dir, len2, lob, clp, oC);
    FsrEasuTapF(aC, aW, vec2( 0, 2)-pp, dir, len2, lob, clp, nC);
    //------------------------------------------------------------------------------------------------------------------------------
    // Normalize and dering.
    vec3 pix=min(max4,max(min4,aC/aW));
    
    COLOR.rgb = pix.rgb;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[


--]]
