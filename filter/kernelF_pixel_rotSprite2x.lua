
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
kernel.name = "rotSprite2x"
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


kernel.fragment =
[[
const vec4 background = vec4(1., 1., 1., 0.);

float dist(vec4 c1, vec4 c2) {
  return (c1 == c2) ? 0.0 : abs(c1.r - c2.r) + abs(c1.g - c2.g) + abs(c1.b - c2.b);
}

bool similar(vec4 c1, vec4 c2, vec4 cIpt) {
  return (c1 == c2 || (dist(c1, c2) <= dist(cIpt, c2) && dist(c1, c2) <= dist(cIpt, c1)));
}

bool different(vec4 c1, vec4 c2, vec4 cIpt) {
  return !similar(c1, c2, cIpt);
}


// rotsprite 2x enlargement algorithm:
// suppose we are looking at input pixel cE which is surrounded by 8 other 
// pixels:
//  cA cB cC
//  cD cE cF
//  cG cH cI
// and for that 1 input pixel cE we want to output 4 pixels oA, oB, oC, and oD:
//  oA oB
//  oC oD
vec4 scale2x(sampler2D tex, vec2 uv, vec2 pixel_size) {
  vec4 v_in = texture2D(tex, uv);

  vec4 cD = texture2D(tex, uv + pixel_size * vec2(-1., .0));
  cD.a = 1.0;
  vec4 cF = texture2D(tex, uv + pixel_size * vec2(1., .0));
  cF.a = 1.0;
  vec4 cH = texture2D(tex, uv + pixel_size * vec2(.0, 1.));
  cH.a = 1.0;
  vec4 cB = texture2D(tex, uv + pixel_size * vec2(.0, -1.));
  cB.a = 1.0;
  vec4 cA = texture2D(tex, uv + pixel_size * vec2(-1., -1.));
  cA.a = 1.0;
  vec4 cI = texture2D(tex, uv + pixel_size * vec2(1., 1.));
  cI.a = 1.0;
  vec4 cG = texture2D(tex, uv + pixel_size * vec2(-1., 1.));
  cG.a = 1.0;
  vec4 cC = texture2D(tex, uv + pixel_size * vec2(1., -1.));
  cC.a = 1.0;

  if (different(cD,cF, v_in)
     && different(cH,cB, v_in)
     && ((similar(v_in, cD, v_in) || similar(v_in, cH, v_in) || similar(v_in, cF, v_in) || similar(v_in, cB, v_in) ||
         ((different(cA, cI, v_in) || similar(v_in, cG, v_in) || similar(v_in, cC, v_in)) &&
          (different(cG, cC, v_in) || similar(v_in, cA, v_in) || similar(v_in, cI, v_in))))))
    {
    vec2 unit = uv - (floor(uv / pixel_size) * pixel_size);
    vec2 pixel_half_size = pixel_size / 2.0;
    if (unit.x < pixel_half_size.x && unit.y < pixel_half_size.y) {
      return ((similar(cB, cD, v_in) && ((different(v_in, cA, v_in) || different(cB, background, v_in)) && (different(v_in, cA, v_in) || different(v_in, cI, v_in) || different(cB, cC, v_in) || different(cD, cG, v_in)))) ? cB : v_in);
    }

    if (unit.x >= pixel_half_size.x && unit.y < pixel_half_size.y) {
      return ((similar(cF, cB, v_in) && ((different(v_in, cC, v_in) || different(cF, background, v_in)) && (different(v_in, cC, v_in) || different(v_in, cG, v_in) || different(cF, cI, v_in) || different(cB, cA, v_in)))) ? cF : v_in);
    }

    if (unit.x < pixel_half_size.x && unit.y >= pixel_half_size.y) {
      return ((similar(cD, cH, v_in) && ((different(v_in, cG, v_in) || different(cD, background, v_in)) && (different(v_in, cG, v_in) || different(v_in, cC, v_in) || different(cD, cA, v_in) || different(cH, cI, v_in)))) ? cD : v_in);
    }

        return ((similar(cH, cF, v_in) && ((different(v_in, cI, v_in) || different(cH, background, v_in)) && (different(v_in, cI, v_in) || different(v_in, cA, v_in) || different(cH, cG, v_in) || different(cF, cC, v_in)))) ? cH : v_in);
    }

  return v_in;
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_COLOR vec4 COLOR = scale2x(CoronaSampler0, texCoord, CoronaTexelSize.zw);
    return CoronaColorScale( COLOR );
}
]]

return kernel


--[[

--]]





