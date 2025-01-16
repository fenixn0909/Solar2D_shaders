
--[[
    https://godotshaders.com/shader/palette-limiter-shader/
    DrManatee
    December 1, 2022
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "color"
kernel.name = "paletteLimit"

kernel.vertexData =
{
  { name = "NumCol",     default = 16, min = 2, max = 256, index = 0, },
} 


kernel.fragment =
[[
    
uniform sampler2D TEXTURE;         // CoronaSampler0
//uniform sampler2D PALETTE_TEXTURE; // CoronaSampler1

float NumCol = CoronaVertexUserData.x;


int I_NumCol = int( NumCol ); // : hint_range(2,16) 

//----------------------------------------------

vec3 palette_limiter (in vec3 albedo){
    float estimation_cutoff = 0.001;
    vec3 closest_color;
    float min_dist = 2.0;
    float n = float(I_NumCol);
    
    for (int i=0; i<I_NumCol; i++ ){
        float index = 1.000/(2.000*n)+float(i)/n;
        vec3 index_color = texture2D( CoronaSampler1, vec2(index,0.5)).rgb;
        float dist = length(index_color - albedo);
        if (dist < min_dist) {
            min_dist = dist;
            closest_color = index_color;
            if (min_dist < estimation_cutoff){
                return closest_color;
            }
        }
    }
    return closest_color;
}

//----------------------------------------------

P_COLOR vec4 COLOR;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------

    COLOR.rgb = palette_limiter(texture2D( TEXTURE,UV ).rgb);
    COLOR.a = texture2D( TEXTURE,UV ).a;
    
    //----------------------------------------------
    
    COLOR.rgb *= COLOR.a;


    return COLOR;
}
]]

return kernel

