
--[[
  Origin Author: SamuelWolfang
  https://godotshaders.com/shader/five-nights-at-freddys-style-fisheye/

  Har har har har har

  I couldn’t find any online that could replicate this effect, so I made my own.
  I tried applying the effect on both UV.y and the UV.x, but the result is kinda hideous.

  Feel free to make suggestions!

  Enjoy!

  EDIT: I just had to search for ‘FNaF’ on this exact website to find the effect I needed lmaoo oh well


--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "fisheyeNite5"
kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  
}


kernel.fragment =
[[

//----------------------------------------------
#define PI 3.14159265359

//defines the coefficient
float coeff = 0; // : hint_range(0, .5);

//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    // Pixelization
    P_UV vec2 FRAGCOORD = ( CoronaTexelSize.zw * 0.5 + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw ) );
    //P_COLOR vec4 texColor = texture2D( CoronaSampler0, FRAGCOORD);

    P_UV vec2 SCREEN_UV = texCoord;
    //P_UV vec2 SCREEN_UV = FRAGCOORD; // Pixelization
    P_COLOR vec4 COLOR;

    coeff = sin(CoronaTotalTime * 1)*2;
    
    //----------------------------------------------

      //gets the SCREEN_UV
      vec2 suv = SCREEN_UV;
      
      //side maps 0.0>1.0 into -1.0>1.0
      //side as in "-1.0 is the left side, 1.0 is the right one"
      float side = (SCREEN_UV.y * 2.0) - 1.0;
      
      //mountain maps 0.0>1.0 into a 0.0>0.0, where the mid-value is 1.0.
      float mountain = -abs((SCREEN_UV.x * 2.0) - 1.0) + 1.0;
      
      //maps mountain into a sine-wave's first ramp
      mountain = mountain * PI/2.0;
      
      //newv says 'how much should the pixel be moved based in its position?'
      //mountain defines the amount, coeff scales it and 'sin' smooths it out.
      //the multiplication with PI/2.0 is mandatory for sin to work
      float newv = coeff * sin(mountain);
      
      //modifies the screen uv saved before
      //(newv * side) applies the effect on both left and right.
      //if 'side' wasn't here, the effect would be applied only one way.
      //even more important is the subtraction with 'coeff*size'.
      //this scales the shader up and down so that you don't end up with borders.
      suv.y += ((newv * side) - (coeff*side));
      
      //updates the texture
      COLOR = texture2D(CoronaSampler0, suv);

    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel


--[[

--]]





