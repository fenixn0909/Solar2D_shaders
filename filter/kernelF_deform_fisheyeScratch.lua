
--[[
    https://godotshaders.com/shader/scratch-fisheye-effect/
    The2AndOnly
    October 6, 2024
--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "fisheyeScratch"
kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  {
    name = "amount",
    default = 100.0, 
    min = -5000,
    max = 5000,
    index = 0,  -- This corresponds to "CoronaVertexUserData.x"
  },
}


kernel.fragment =
[[

uniform sampler2D TEXTURE;

float amount = CoronaVertexUserData.x;
//----------------------------------------------


//----------------------------------------------

P_COLOR vec4 COLOR;
float TIME = CoronaTotalTime;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //amount = abs(sin(TIME))*1000;
    amount = sin(TIME)*5000;
    //amount = 1.1 - abs(sin(TIME))*1;
    //amount = 100.5;
    //----------------------------------------------

    float newAmount = (amount / 100.0) + 1.0;

    vec2 texcoord0 = UV;
    vec2 kCenter = vec2(0.5);

    vec2 vec = (texcoord0 - kCenter) / kCenter;
    float vecLength = length(vec);
    float r = pow(min(vecLength, 1.0), newAmount) * max(1.0, vecLength);
    vec2 unit = vec / vecLength;

    texcoord0 = kCenter + r * unit * kCenter;

    COLOR = texture2D( TEXTURE, texcoord0 );

    //----------------------------------------------
    
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel


--[[

--]]





