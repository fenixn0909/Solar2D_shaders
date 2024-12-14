
--[[
  Origin Author: hei
  https://godotshaders.com/author/hei/

  This shader “fakes” a 3D-camera perspective on CanvasItems.

  The shader works out-of-the-box with nodes Sprite and TextureRect, as long as the rect_size equals the size of the texture. If this isn’t the case, you can do the following change:

  //VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * tang * (1.0 - inset);
  // to (rect_size is a uniform):
  VERTEX += (UV - 0.5) * rect_size * tang * (1.0 - inset);
  
  Also, remember to enable mipmaps and anisotropic for the texture to retain quality with harsh angles.

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "perspective2D"

--Test
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
// Camera FOV
float fov = 30; //: hint_range(1, 179) 

float y_rot = 30.0; //: hint_range(-180, 180) 
float x_rot = 30.0; //: hint_range(-180, 180) 

// At 0, the image retains its size when unrotated.
// At 1, the image is resized so that it can do a full
// rotation without clipping inside its rect.
float inset = 0.5; //: hint_range(0, 1) 
// Consider changing this to a uniform and changing it from code

//varying flat vec2 o;
varying vec2 o;
varying vec3 p;

const float PI = 3.14159;

// Creates rotation matrix
P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
  P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
  P_UV vec2 UV = CoronaTexCoord.xy;
  P_POSITION vec2 VERTEX = position;


  float sin_b = sin(y_rot / 180.0 * PI);
  float cos_b = cos(y_rot / 180.0 * PI);
  float sin_c = sin(x_rot / 180.0 * PI);
  float cos_c = cos(x_rot / 180.0 * PI);
  
  mat3 inv_rot_mat;
  inv_rot_mat[0][0] = cos_b;
  inv_rot_mat[0][1] = 0.0;
  inv_rot_mat[0][2] = -sin_b;
  
  inv_rot_mat[1][0] = sin_b * sin_c;
  inv_rot_mat[1][1] = cos_c;
  inv_rot_mat[1][2] = cos_b * sin_c;
  
  inv_rot_mat[2][0] = sin_b * cos_c;
  inv_rot_mat[2][1] = -sin_c;
  inv_rot_mat[2][2] = cos_b * cos_c;
  
  
  float t = tan(fov / 360.0 * PI);
  p = inv_rot_mat * vec3((UV - 0.5), 0.5 / t);
  float v = (0.5 / t) + 0.5;
  p.xy *= v * inv_rot_mat[2].z;
  o = v * inv_rot_mat[2].xy;

  VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * t * (1.0 - inset);

  return VERTEX;
}
]]


kernel.fragment =
[[
//varying flat vec2 o;
varying vec2 o;
varying vec3 p;

bool cull_back = true;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  if (cull_back && p.z <= 0.0) { discard; }
  vec2 uv = (p.xy / p.z).xy - o;
  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, uv + 0.5);
  //COLOR = texture(TEXTURE, uv + 0.5);
  COLOR.a *= step(max(abs(uv.x), abs(uv.y)), 0.5);

  return CoronaColorScale( COLOR );
}
]]


return kernel




--[[



--]]





