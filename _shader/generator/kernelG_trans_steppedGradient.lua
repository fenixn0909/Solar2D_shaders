
--[[
    https://godotshaders.com/shader/stepped-gradient/
    imakeshaders
    September 28, 2024


--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "steppedGradient"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Progress",      default = 0.5, min = 0, max = 1, index = 0, },
} 

kernel.fragment =
[[

float Progress = CoronaVertexUserData.x;

//----------------------------------------------
vec4 Col_1 = vec4( 1.0, 1.0, 1.0, -1 );
vec4 Col_2 = vec4( 0.0, 0, 0, 1 );

//----------------------------------------------

float round( float value){
    return floor( value + float(0.5) );
}
//-----------------------------------------------
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    float progress = Progress;
    //----------------------------------------------
    Col_1.a = 1-Progress -0.15;
    float pos = smoothstep(0,1,UV.x);
    COLOR = mix(Col_1,Col_2, pos*.25 / (progress+0.00001) ); 

    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


