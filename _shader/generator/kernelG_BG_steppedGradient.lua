
--[[
    https://godotshaders.com/shader/stepped-gradient/
    imakeshaders
    September 28, 2024

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "stepGradient"

kernel.isTimeDependent = true


kernel.vertexData =
{
  { name = "Step",            default = 10, min = 1, max = 50, index = 0, },
  { name = "Position",        default = .0, min = -1, max = 2, index = 1, },
} 


kernel.fragment =
[[

float Step = CoronaVertexUserData.x;
float Position = CoronaVertexUserData.y;

//----------------------------------------------

vec4 Col_Top = vec4(1.0);
vec4 Col_Bot = vec4(0, 0, 0, 1);
//float Position = 0.5; // : hint_range(-2, 2) 

int  I_Step  = int(Step); // : hint_range(1, 50) 

//----------------------------------------------

float round( float value){
    return floor( value + float(0.5) );
}

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //float pos = round(smoothstep(0,1,(Position + UV.y) / 2.0) * float( I_Step ));
    //COLOR = mix( Col_Top, Col_Bot, pos/float( I_Step ));

    float pos = round(smoothstep(0,1, (Position +UV.y)) * float( I_Step ) );
    COLOR = mix( Col_Top, Col_Bot, pos/float( I_Step ));
    
    //COLOR = mix( Col_Top, Col_Bot, UV.y );

    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale(COLOR);
}
]]

return kernel


