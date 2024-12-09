--[[
    https://godotshaders.com/shader/darkened-blur/
    LambBrainz
    August 25, 2024

]]
--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur"
kernel.name = "darken"
kernel.isTimeDependent = true


kernel.fragment =
[[

//----------------------------------------------

uniform float lod = 0.0; //: hint_range(0.0, 5.0)
uniform float mix_percentage = 0.3; //: hint_range(0.0, 1.0)

int strength = 2; //: hint_range(1, 512) 

//----------------------------------------------


//----------------------------------------------
vec4 blur_size(sampler2D tex,vec2 fragCoord, vec2 pixelSize) {
    
    vec4 color = vec4(0.,0.,0.,0.);
    float strengthFloat = float(strength);  
    //float strengthFloat = strength;  

    vec2 pixel = fragCoord/pixelSize;
    int x_min = int(max(pixel.x-strengthFloat, 0));
    int x_max = int(min(int(pixel.x+strengthFloat), int(1./pixelSize.x)));
    int y_min = int(max(int(pixel.y-strengthFloat), 0));
    int y_max = int(min(int(pixel.y+strengthFloat), int(1./pixelSize.y)));

    int count =0;

    // Sum the pixels colors
    for(int x=x_min; x <= x_max; x++) {
        for(int y = y_min; y <= y_max; y++) {           
            color += texture2D(tex, vec2(float(x), float(y)) * pixelSize);
            count++;
        }
    }
    
    // Divide the color by the number of colors you summed up
    color /= float(count);
    
    return color;
}

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //Test
    //strength = int( sin(CoronaTotalTime*5)*4 +3);
    //----------------------------------------------

    P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( UV / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
    //COLOR = texture2D( CoronaSampler0, UV_Pix );

    //vec4 color = texture2D( CoronaSampler0, UV);
    //vec4 color = texture2D( CoronaSampler0, UV_Pix);
    vec4 color = blur_size( CoronaSampler0, UV, CoronaTexelSize.zw );
    COLOR = mix(color, vec4(0,0,0,color.a), mix_percentage);



    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale(COLOR);
}
]]

return kernel



--[[

--]]
