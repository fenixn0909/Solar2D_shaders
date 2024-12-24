--[[
    
    https://godotshaders.com/shader/pixel-art-gradient/
    ARez
    December 16, 2024

    #VARIATION

]]


local kernel = {}

kernel.language = "glsl"

kernel.category = "filter"
kernel.group = "pixel"
kernel.name = "artGradient"

kernel.vertexData =
{
  { name = "Grid_Scale", default = 50, min = 1,  max = 1000,  index = 0, }, -- a_UserData.x 
  { name = "Dist_Add", default = -0.1, min = -1,  max = 0.2,  index = 1, }, -- a_UserData.x 
  { name = "Dist_Offset", default = -0.1, min = -1,  max = 2,  index = 2, }, -- a_UserData.x 
  { name = "Grad_Alpha", default = 0.5, min = 0,  max = 1,  index = 3, }, -- a_UserData.x 
}

kernel.fragment =
[[

float Grid_Scale = CoronaVertexUserData.x;
float Dist_Add = CoronaVertexUserData.y;     // Just a constant value to add to the gradient to control the strength
float Dist_Offset = CoronaVertexUserData.z;  // "Offsets the point" where the distance is measured from, effectively moving the gradient
float Grad_Alpha = CoronaVertexUserData.w;  // Gradient Alpha

//----------------------------------------------

uniform sampler2D TEXTURE;
int I_Grid_Scale = int(Grid_Scale); //: hint_range(1,100000, 1)  // If you are using upscaled pixel art, you can use this value to scale the grid up
vec4 ModulateColor = vec4(0.0, 0.0, 0.0, .5);  //: source_color 

//----------------------------------------------
vec2 grid(vec2 uv, vec2 tex_size){
    return fract(uv * tex_size / vec2(float(I_Grid_Scale)));
}
//----------------------------------------------

P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
P_COLOR vec4 COLOR = vec4(0);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    //----------------------------------------------
    
    vec4 orig_color = texture2D(TEXTURE, UV);
    vec2 tex_size = 1/TEXTURE_PIXEL_SIZE;
    vec2 grid_uv = grid(UV, tex_size);
    float dist = 0.0;
    
    // #VARIATION: LinearGradient
    //dist = 1.0 - (grid_uv.y + Dist_Offset);

    // #VARIATION: SuareGradient
    dist = sqrt(pow(1.0 - (grid_uv.x + Dist_Offset), 2.0) + pow(1.0 - (grid_uv.y + Dist_Offset), 2.0));


    dist += Dist_Add;
    dist = clamp(dist, 0.0, 1.0); // ClampDist 
    
    ModulateColor *= orig_color.a;
    COLOR = mix(orig_color, ModulateColor, (1.0 - dist) * Grad_Alpha);
    
    //----------------------------------------------
    COLOR.a = orig_color.a;
    COLOR.rgb *= orig_color.a;

    return ( COLOR );
}
]]

return kernel