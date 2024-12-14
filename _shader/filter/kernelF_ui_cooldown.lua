

--[[
    Radial / Cooldown shader
    https://godotshaders.com/shader/radial-cooldown-shader/
    Buggit
    June 5, 2024
--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "ui"
kernel.name = "cooldown"

kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  {
    name = "progress",
    default = .15, 
    min = 0,
    max = 1,
    index = 0,  -- This corresponds to "CoronaVertexUserData.x"
  },
}

kernel.fragment =
[[

//----------------------------------------------
uniform sampler2D TEXTURE;
float Progress = CoronaVertexUserData.x;        // : hint_range(0.0, 1.0);     // Uniform for the cooldown progress, ranges from 0.0 (full cooldown) to 1.0 (no cooldown)

uniform bool use_transparency = true;           // : hint_tooltip("Toggle to make unseen area transparent");     // Uniform to toggle between disappearing or transparent unseen area
uniform float Alpha  = 0.15;                    //: hint_range(0.0, 1.0);    // Uniform to control the alpha value of the transparent unseen area
P_COLOR vec4 Col_Rect = vec4( 0.0, 0.0, 0.0, 1.0);

const float TAU =  6.283185307179586;

//----------------------------------------------

// Function to check if a point is inside the cooldown arc
bool in_cooldown(vec2 uv, float progress) {
    // Convert UV coordinates to centered coordinates (-0.5 to 0.5)
    vec2 centered_uv = uv - vec2(0.5);

    // Calculate the angle of the UV coordinate ✳️ Clockwise: atan(-x,y)
    float angle = atan(-centered_uv.x, centered_uv.y) / (TAU);

    // Check if the point is within the cooldown arc
    return (angle + 0.5  <= progress - 0.0 );
}

//----------------------------------------------


P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------
    
    // Sample the texture at the given UV coordinates
    vec4 tex_color = texture2D(TEXTURE, UV);

    // Check if the current fragment is within the cooldown arc
    if (in_cooldown(UV, Progress)) {
        // If within the cooldown, set the color to the texture color
        COLOR = tex_color;

    } else {
        // If not within the cooldown, check the transparency toggle
        if (use_transparency) {
            // Set the color to the texture color with adjusted alpha
            COLOR = vec4(tex_color.rgb, Alpha);
            COLOR = mix( COLOR, Col_Rect, 0.75);

        } else {
            // Set the color to transparent
            COLOR = vec4(0.0, 0.0, 0.0, 0.0);
            // Leave Color Rect
            COLOR = Col_Rect;
        }
    }


    //----------------------------------------------
    
    //COLOR.rgb *= COLOR.a;
    //COLOR.rgb *= pixelColor.rgb;

    return CoronaColorScale( COLOR );
}
]]

return kernel