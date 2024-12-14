
--[[
  Origin Author: lucrecious
  https://godotshaders.com/author/lucrecious/


  This shader upscales the sprite using the Scale2x algorithm in GPU.

  Here’s the gist if you prefer it.

  To use: Simply add a shader material to your sprite with this shader code.

  If you want to put more shaders on top of this, you’ll either need to manually merge them with mine, or use back buffers with screen shaders.

  It’s not perfect but it a lot better than the regular rotation, I think.

  Here’s a slightly slower version but also slightly better.


--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "pixel"
kernel.name = "rotSprite3x"
kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  {
    name = "intensity",
    default = 0.65, 
    min = 0,
    max = 1,
    index = 0,  -- This corresponds to "CoronaVertexUserData.x"
  },
  {
    name = "size",
    default = 0.1, 
    min = 0,
    max = 1,
    index = 1,  -- This corresponds to "CoronaVertexUserData.y"
  },
  {
    name = "tilt",
    default = 0.2, 
    min = 0.0,
    max = 2.0,
    index = 2,  -- This corresponds to "CoronaVertexUserData.z"
  },
  {
    name = "speed",
    default = 1.0, 
    min = 0.1,
    max = 10.0,
    index = 3,  -- This corresponds to "CoronaVertexUserData.w"
  },
}

kernel.vertex =
[[
varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;
P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
  P_UV float numPixels = 1;
  slot_size = ( u_TexelSize.zw * numPixels );
  sample_uv_offset = ( slot_size * 0.5 );
  return position;
}
]]


kernel.fragment =
[[

varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;

const vec4 background = vec4(1., 1., 1., 0.);

uniform float pixel_scale = 1.0; //: hint_range(0.0, 1.0)

float dist(vec4 c1, vec4 c2) {
  return (c1 == c2) ? 0.0 : abs(c1.r - c2.r) + abs(c1.g - c2.g) + abs(c1.b - c2.b);
}

bool similar(vec4 c1, vec4 c2, vec4 cIpt) {
  return (c1 == c2 || (dist(c1, c2) <= dist(cIpt, c2) && dist(c1, c2) <= dist(cIpt, c1)));
}

bool different(vec4 c1, vec4 c2, vec4 cIpt) {
  return !similar(c1, c2, cIpt);
}

// rotsprite 3x enlargement algorithm:
// suppose we are looking at input pixel cE which is surrounded by 8 other 
// pixels:
//  cA cB cC
//  cD cE cF
//  cG cH cI
// and for that 1 input pixel cE we want to output 4 pixels oA, oB, oC, and oD:
//  E0 E1 E2
//  E3 E4 E5
//  E6 E7 E8
vec4 scale3x(sampler2D tex, vec2 uv, vec2 pixel_size) {
  vec4 cE = texture2D(tex, uv);
  cE = cE.a == 0.0 ? background : cE;
  
  vec4 cD = texture2D(tex, uv + pixel_size * vec2(-1., .0));
  cD = cD.a == 0.0 ? background : cD;
  vec4 cF = texture2D(tex, uv + pixel_size * vec2(1., .0));
  cF = cF.a == 0.0 ? background : cF;
  vec4 cH = texture2D(tex, uv + pixel_size * vec2(.0, 1.));
  cH = cH.a == 0.0 ? background : cH;
  vec4 cB = texture2D(tex, uv + pixel_size * vec2(.0, -1.));
  cB = cB.a == 0.0 ? background : cB;
  vec4 cA = texture2D(tex, uv + pixel_size * vec2(-1., -1.));
  cA = cA.a == 0.0 ? background : cA;
  vec4 cI = texture2D(tex, uv + pixel_size * vec2(1., 1.));
  cI = cI.a == 0.0 ? background : cI;
  vec4 cG = texture2D(tex, uv + pixel_size * vec2(-1., 1.));
  cG = cG.a == 0.0 ? background : cG;
  vec4 cC = texture2D(tex, uv + pixel_size * vec2(1., -1.));
  cC = cC.a == 0.0 ? background : cC;
  
  if (different(cD,cF, cE)
     && different(cH,cB, cE)
     && ((similar(cE, cD, cE) || similar(cE, cH, cE) || similar(cE, cF, cE) || similar(cE, cB, cE) ||
         ((different(cA, cI, cE) || similar(cE, cG, cE) || similar(cE, cC, cE)) &&
          (different(cG, cC, cE) || similar(cE, cA, cE) || similar(cE, cI, cE))))))
    {
    vec2 unit = uv - (floor(uv / pixel_size) * pixel_size);
    vec2 pixel_3_size = pixel_size / 3.0;
    
    // E0
    if (unit.x < pixel_3_size.x && unit.y < pixel_3_size.y) {
      return similar(cB, cD, cE) ? cB : cE;
    }
    
    
    // E1
    if (unit.x < pixel_3_size.x * 2.0 && unit.y < pixel_3_size.y) {
      return (similar(cB, cD, cE) && different(cE, cC, cE))
        || (similar(cB, cF, cE) && different(cE, cA, cE)) ? cB : cE;
    }
    
    // E2
    if (unit.y < pixel_3_size.y) {
      return similar(cB, cF, cE) ? cB : cE;
    }
    
    // E3
    if (unit.x < pixel_3_size.x && unit.y < pixel_3_size.y * 2.0) {
      return (similar(cB, cD, cE) && different(cE, cG, cE)
        || (similar(cH, cD, cE) && different(cE, cA, cE))) ? cD : cE;
    }
    
    // E5
    if (unit.x >= pixel_3_size.x * 2.0 && unit.x < pixel_3_size.x * 3.0 && unit.y < pixel_3_size.y * 2.0) {
      return (similar(cB, cF, cE) && different(cE, cI, cE))
        || (similar(cH, cF, cE) && different(cE, cC, cE)) ? cF : cE;
    }
    
    // E6
    if (unit.x < pixel_3_size.x && unit.y >= pixel_3_size.y * 2.0) {
      return similar(cH, cD, cE) ? cH : cE;
    }
    
    // E7
    if (unit.x < pixel_3_size.x * 2.0 && unit.y >= pixel_3_size.y * 2.0) {
      return (similar(cH, cD, cE) && different(cE, cI, cE))
        || (similar(cH, cF, cE) && different(cE, cG, cE)) ? cH : cE;
    }
    
    // E8
    if (unit.y >= pixel_3_size.y * 2.0) {
      return similar(cH, cF, cE) ? cH : cE;
    }
    }
  
  return cE;
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_UV vec2 uv_pix = ( sample_uv_offset + ( floor( texCoord / slot_size ) * slot_size ) );
    //P_COLOR vec4 COLOR = scale3x(CoronaSampler0, texCoord, CoronaTexelSize.xy * pixel_scale);
    P_COLOR vec4 COLOR = scale3x(CoronaSampler0, uv_pix, CoronaTexelSize.zw * pixel_scale);
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel


--[[

--]]





