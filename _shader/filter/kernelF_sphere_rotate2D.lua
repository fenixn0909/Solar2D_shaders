
--[[
    https://godotshaders.com/shader/2d-spherical-rotations-in-any-direction-from-image/
    ks_disco
    December 20, 2024

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "sphere"
kernel.name = "rotate2D"

kernel.vertexData =
{
  { name = "RotX",  default = 0, min = -.3, max = .3, index = 0, },
  { name = "RotY",  default = 0, min = -.15, max = .15, index = 1, },
  { name = "RotZ",  default = .94, min = 0, max = 1, index = 2, },
  { name = "RotW",  default = 0, min = -.3, max = .3, index = 3, },
} 

kernel.fragment =
[[

float RotX = CoronaVertexUserData.x;
float RotY = CoronaVertexUserData.y;
float RotZ = CoronaVertexUserData.z;
float RotW = CoronaVertexUserData.w;
//-----------------------------------------------

uniform sampler2D TEXTURE;
vec4 quaternion = vec4(RotX, RotY, RotZ, RotW); // Default: identity quaternion

float UV_Correction = .25; // .5 

const float PI = 3.14159265359;
const float TAU =  6.283185307179586;

//-----------------------------------------------

// Function to rotate a vector using a quaternion
vec3 rotate_with_quaternion(vec3 v, vec4 q) {
    vec3 t = 2.0 * cross(q.xyz, v);
    return v + q.w * t + cross(q.xyz, t);
}

//-----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    // Map UVs to normalized coordinates (-1, 1)
    float px = 2.0 * (UV.x - 0.5);
    float py = 2.0 * (UV.y - 0.5);

    if (px * px + py * py > 1.0) {
        COLOR.a = 0.0; // Outside of sphere
    } else {
        // Map to a 3D unit sphere
        float pz = sqrt(max(0.0, 1.0 - px * px - py * py));
        vec3 sphere_pos = vec3(px, py, pz);

        // Apply quaternion rotation
        sphere_pos = rotate_with_quaternion(sphere_pos, quaternion);

        // Convert rotated position to UV coordinates
        float theta = atan(sphere_pos.z, sphere_pos.x);
        float phi = acos(clamp(sphere_pos.y, -1.0, 1.0));
        
        // Map spherical coordinates to UV space
        vec2 spherical_uv = vec2(UV_Correction + theta / TAU, phi / PI);

        // Sample texture using spherical coordinates
        COLOR = texture2D(TEXTURE, spherical_uv);
    }

    //-----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]


return kernel




--[[



--]]





