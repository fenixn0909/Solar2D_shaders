
--[[
  https://godotshaders.com/shader/shock-damage/
  videlanicolas
  September 1, 2024

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "shockDamage"

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
//----------------------------------------------
varying float speed = .75;
varying float stable = -2.5; //: hint(-1, -3, -10)
uniform float amplitude = 10.0;
uniform float frequecy = 133.0;

//----------------------------------------------

P_DEFAULT float TIME = CoronaTotalTime;
//----------------------------------------------

P_POSITION vec2 VertexKernel( P_POSITION vec2 VERTEX )
{
  
  //----------------------------------------------
  float exponent = mod(TIME * speed, 3.0);
  VERTEX.x += amplitude * exp( stable * exponent ) * sin(frequecy*exponent);

  return VERTEX;
}
]]

kernel.fragment =
[[
varying float speed;
varying float stable;


uniform vec3 shock_color = vec3(1.0, 0.0, 0.0); // : source_color
// -----------------------------------------------


P_DEFAULT float TIME = CoronaTotalTime;

// -----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  P_COLOR vec4 COLOR;
  
  
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  
  float exponent = mod(TIME * speed, 3.0);
  COLOR = texture2D(CoronaSampler0, UV);
  COLOR.rgb += shock_color * exp( stable * exponent );
  COLOR.rgb *= COLOR.a;

  //----------------------------------------------
  

  return CoronaColorScale( COLOR );
}


]]

return kernel


--[[



--]]





