
--[[
  https://godotshaders.com/shader/rotating-radial-stripes/
  fruityfred
  November 8, 2024
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "radialStripe"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",     default = .6, min = -5, max = 5, index = 0, },
  { name = "Stripes",   default = 64, min = 0, max = 200, index = 1, },
  { name = "CenterX",   default = .05, min = -2, max = 2, index = 2, },
  { name = "CenterY",   default = .95, min = -2, max = 2, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Stripes = CoronaVertexUserData.y;
float CenterX = CoronaVertexUserData.z;
float CenterY = CoronaVertexUserData.w;

//----------------------------------------------

P_UV vec2 Center = vec2( CenterX, CenterY );

P_COLOR vec4 Col_Stripe = vec4(0.9, 0.6, 0.5, 1.0);
P_COLOR float color_modifier = .6;

//----------------------------------------------

const float TAU =  6.283185307179586;

//----------------------------------------------

P_COLOR vec4 COLOR = Col_Stripe;
P_DEFAULT float TIME = CoronaTotalTime;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
    //----------------------------------------------

    // Fix aspect ratio issue.
    //vec2 uv_deriv = fwidthFine(UV);
    vec2 uv_deriv = abs(dFdx(UV)) + abs(dFdy(UV));
    float aspect_ratio = uv_deriv.y / uv_deriv.x;
    vec2 corrected_uv = UV * vec2(aspect_ratio, 1.0);
    vec2 corrected_center = Center * vec2(aspect_ratio, 1.0);

    // Get the angle between the center of the effect and the UV.
    vec2 dir = corrected_center - corrected_uv;
    float angle = atan(dir.y, dir.x) - (TIME * Speed);

    // Check if the angle is in a stripe or not.
    if (mod(floor(angle / (TAU / float(Stripes))), 2) == 0.0) {
        // If yes, apply the modifier to the pixel.
        COLOR.rgb *= color_modifier;

        // Transparent
        COLOR.a *= color_modifier;
        //COLOR.a *= 0.;
    }

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


