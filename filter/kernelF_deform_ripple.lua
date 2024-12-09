
--[[
  Origin Author: Nevoski
  https://godotshaders.com/author/Nevoski/
  
  I converted/modified this shader from this ShaderToy ripple shader: https://www.shadertoy.com/view/ldBXDD

  Just attach the shader to a ColorRect, and play with the shader parameters to get stronger or weaker ripple effects. Everything behind the ColorRect will be affected by the shader.

  // Converted/modified from ShaderToy: https://www.shadertoy.com/view/ldBXDD
  // Attach this shader to a ColorRect

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "ripple"
kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  {
    name = "screenPxX",
    default = 1, 
    min = 0,
    max = 9999,
    index = 0,  -- This corresponds to "CoronaVertexUserData.x"
  },
  {
    name = "screenPxY",
    default = 1, 
    min = 0,
    max = 9999,
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
uniform float wave_count = 2000.0; //: hint_range(1.0, 20.0, 1.0) 
uniform float speed = 3.0; //: hint_range(0.0, 10.0, 0.1) 

uniform vec2 u_resolution;
uniform vec4 gl_FragCoord; 
uniform vec4 glViewport; // Test

//uniform float screen_width = 960; // Test
//uniform float screen_height = 640; // Test

float screen_width = CoronaVertexUserData.x; // Test
float screen_height = CoronaVertexUserData.y; // Test





float height = 0.003; //: hint_range(0.0, 0.1, 0.001)


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 SCREEN_SIZE = vec2(screen_width, screen_height);
  P_UV vec2 SCREEN_PIXEL_SIZE = 1 / SCREEN_SIZE;
  //P_UV vec2 SCREEN_PIXEL_SIZE = 1 / vec2(screen_width, screen_height);
  //P_UV vec2 SCREEN_PIXEL_SIZE = vec2(1 / u_resolution.y, 1 / u_resolution.x );
  //P_UV vec2 SCREEN_UV = gl_FragCoord.xy * SCREEN_PIXEL_SIZE;


  

  P_UV vec2 UV = texCoord;
  //P_UV vec2 UV = gl_FragCoord.xy / u_resolution;
  //P_UV vec2 UV = gl_FragCoord.xy / SCREEN_SIZE;
  P_UV vec4 FRAGCOORD = gl_FragCoord;
  P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
  
  P_DEFAULT float TIME = CoronaTotalTime;
  //Test
  height = sin(CoronaTotalTime)*0.1;


  vec2 cPos = -1.0 + 2.0 * UV / (1.0 / TEXTURE_PIXEL_SIZE);
  float cLength = length(cPos);
  vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy + (cPos/cLength) * cos(cLength * wave_count - TIME * speed) * height;
  uv -= 0.5; // Offset Correction
  vec3 col = texture2D(CoronaSampler0,uv).xyz;
  P_COLOR vec4 COLOR = vec4(col,1.0);

  return CoronaColorScale( COLOR );
}
]]

return kernel


--[[



--]]





