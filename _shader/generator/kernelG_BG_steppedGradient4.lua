
--[[
    phoenixongogo
    Dec 24, 2024
    MIT
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "stepGradient4"

kernel.isTimeDependent = true

kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Steps_1','Steps_2','Steps_3','Smooth',    --
            'Ratio_1','Ratio_2','Ratio_3','NA',    -- sum(4 Ratio)/4 * each Ratio
            'Offset_1','Offset_2','Offset_3','NA',
            'NA','NA','NA','NA',
            
        },
        default = {
            8.0, 12.0, 9.0, 0.7,
            0.52, 0.54, 0.3, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        min = {
            1.0, 1.0, 1.0, 0.5,
            0.1, 0.1, 0.1, 0.1,
            -.5, -.5, -.5, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        max = {
            20, 20, 20, 1.2,
            1.0, 1.0, 1.0, 1.0,
            .5, .5, .5, .5,
            1.0, 1.0, 1.0, 1.0,
        },
    },
    {
        index = 1, 
        type = "mat4",  -- vec4 x 4
        name = "colorMat4",
        paramName = {
            'Col1_R','Col1_G','Col1_B','Col1_A',
            'Col2_R','Col2_G','Col2_B','Col2_A',
            'Col3_R','Col3_G','Col3_B','Col3_A',
            'Col4_R','Col4_G','Col4_B','Col4_A',
        },
        default = {
            1.0, .61, .31, 1.0,
            .78, .95, .39, 1.0,       
            .31, .79, .59, 1.0,      
            0.0, .25, .62, 1.0,
        },
        min = {
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        max = {
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
        },
        
    },
}


kernel.fragment =
[[

uniform mat4 u_UserData0; // mat4A
uniform mat4 u_UserData1; // mat4A_2

vec4 StepsV4 = u_UserData0[0];
vec4 RatioV4 = u_UserData0[1];
vec4 Offset4 = u_UserData0[2];

float Smooth = u_UserData0[0][3];

vec4 Col_1 = u_UserData1[0];
vec4 Col_2 = u_UserData1[1];
vec4 Col_3 = u_UserData1[2];
vec4 Col_4 = u_UserData1[3];
//----------------------------------------------
//----------------------------------------------

float round( float value){
    return floor( value + float(0.5) );
}

//----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //----------------------------------------------
    //Calculate each portion of colors by Ratio, to 3 Border / Boundary
    float portion_sum = RatioV4.x + RatioV4.y + RatioV4.z;  
    vec4 portion_share4 = 1 / (portion_sum / RatioV4);
    vec4 uvStepV4 = StepsV4 * (1/portion_share4);
    float arrBorder[4] = float[]( 0, portion_share4.x, portion_share4.x+portion_share4.y, 1);
    
    float boundary;
    for (int i = 0; i < 4; i++){
        if( UV.y > arrBorder[i] && UV.y <= arrBorder[i+1] ){
            boundary = round(smoothstep(0,1,( Offset4[i] + UV.y - arrBorder[i] ) * Smooth ) * uvStepV4[i]*2 );    // Gradient Steps
            COLOR = mix( u_UserData1[i], u_UserData1[i+1], boundary/float( StepsV4[i] ));                               // Gradient Offset
        }
    }
    
    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale(COLOR);
}
]]

return kernel


