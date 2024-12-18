
--[[
    Origin Author: arlez80
    https://godotshaders.com/author/arlez80/

    ギザギザトランジションシェーダー by あるる（きのもと 結衣）
    Saw Transition Shader by KINOMOTO Yui

    MIT License

    #VARIATION Find the tag and tweak them for different patterns

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "saw"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Progress",     default = .5, min = 0, max = 1, index = 0, },
  { name = "Alpha",      default = .75, min = 0, max = 1, index = 1, },
  { name = "Left",        default = .5, min = -1.5, max = 1.5, index = 2, },
  { name = "Right",      default = .5, min = -1.5, max = 1.5, index = 3, },
} 

kernel.fragment =
[[

float Progress = CoronaVertexUserData.x;
float Alpha = CoronaVertexUserData.y;
float Left = CoronaVertexUserData.z;
float Right = CoronaVertexUserData.w;

//----------------------------------------------

uniform float saw_b_shift = -0.267;
uniform float saw_a_interval = 1.0;
uniform float saw_b_interval = 2.0;
uniform float saw_a_scale = 1.0;
uniform float saw_b_scale = 0.821;

uniform vec2 UV_Scale = vec2( 2.0, 8.0 );

//vec4 Col_Cover = vec4( 0.0, 0.0, 0.0, 1.0 ); // Black 
vec4 Col_Cover = vec4( 1.0, 0.0, 0.0, Alpha ); // Red
//----------------------------------------------


vec3 when_eq(vec3 x, vec3 y) {
  return abs(sign(x - y));
  return abs(sign(x - y));
}

float f_when_eq(float x, float y) {
  //return 1.0 - abs(sign(x - y));
  return abs(sign(x - y));
}


float calc_saw( float y, float interval, float scale )
{
  return max( ( abs( interval / 2.0 - mod( y, interval ) ) - ( interval / 2.0 - 0.5 ) ) * scale, 0.0 );
}

//----------------------------------------------


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
    float left = Left-(Progress * 2 -0.65);
    float right = (Right + Progress) * 2 -0.65;

    //----------------------------------------------

    vec2 scaled_uv = UV * UV_Scale;
    float saw_a = calc_saw( scaled_uv.y, saw_a_interval, saw_a_scale );
    float saw_b = calc_saw( scaled_uv.y + saw_b_shift, saw_b_interval, saw_b_scale );


    P_COLOR float v_alpha = 1 //Col_Cover.a 
    * float( scaled_uv.x < max( saw_a, saw_b ) + right )
    * float( max( saw_a, saw_b ) + left < scaled_uv.x );

    // #VARIATION: Reverse Alpha
    v_alpha = f_when_eq(v_alpha, 1.0);

    P_COLOR vec4 COLOR = vec4(Col_Cover.rgb, v_alpha);

    COLOR.a *= Col_Cover.a;
    COLOR.rgb *= COLOR.a;

    //----------------------------------------------

    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


