
--[[
    https://godotshaders.com/shader/smooth-outline-2d/
    Tanders
    March 14, 2022
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "line"
kernel.name = "outterSmooth"
kernel.isTimeDependent = true


kernel.vertexData =
{
  { name = "Speed",                     default = 0, min = -10, max = 10, index = 0, },
  { name = "Width", --[[#OVERHEAD]]     default = 2, min = 0, max = 64, index = 1, },
  { name = "Size",                      default = 5, min = 0, max = 20, index = 2, },
  { name = "Alpha",                     default = .5, min = 0, max = 1, index = 3, },
} 



kernel.fragment =
[[


float Speed = CoronaVertexUserData.x;
float Width = CoronaVertexUserData.y;
float Size = CoronaVertexUserData.z;
float Alpha = CoronaVertexUserData.w;

//----------------------------------------------
uniform sampler2D TEXTURE;


bool Smooth = true;
vec4 Col_Outline = vec4(1.0, 1.0, 1.0, .75);      //hint_color 
int I_Size = int( Size );         //hint_range(1, 10) 



//----------------------------------------------

float when_gt(float x, float y) { //greater than return 1
    return max(sign(x - y), 0.0);
}

vec4 when_neq(vec4 x, vec4 y) { // not equal
    return abs(sign(x - y));
}

//----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);
float TIME = CoronaTotalTime;
vec2 TEXTURE_SIZE = 1 / CoronaTexelSize.zw;
//vec2 TEXTURE_SIZE = vec2( 320, 320 );

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    //----------------------------------------------
    float _width = Width + ((sin(TIME* Speed) + 2.0) -2.0) * 10.0;
    //vec2 unit = (1.0/float(I_Size) ) / vec2(textureSize(TEXTURE, 0));
    vec2 unit = (1.0*float(I_Size) ) / TEXTURE_SIZE;
    vec4 pixel_color = texture2D(TEXTURE, UV);
    if (pixel_color.a == 0.0) {
        pixel_color = Col_Outline;
        pixel_color.a = 0.0;
        for (float x = -ceil(_width); x <= ceil(_width); x++) {
            for (float y = -ceil(_width); y <= ceil(_width); y++) {
                if (texture2D(TEXTURE, UV + vec2(x*unit.x, y*unit.y)).a == 0.0 || (x==0.0 && y==0.0)) {
                    continue;
                }
                if (Smooth) {
                    pixel_color.a += Col_Outline.a / (pow(x,2)+pow(y,2)) * (1.0-pow(2.0, -_width));
                    if (pixel_color.a > 1.0) {
                        pixel_color.a = 1.0;
                    }
                } else {
                    pixel_color.a = Col_Outline.a;
                }
            }
        }
    }
    COLOR = pixel_color;
    
    //----------------------------------------------
    vec4 col_texture = texture2D(TEXTURE, UV);
    COLOR.rgb *= COLOR.a;
    COLOR.a += when_gt( abs(pixel_color.a - col_texture.a), 0 ) * Alpha;
    

    return COLOR;
}
]]

return kernel



--[[




--]]