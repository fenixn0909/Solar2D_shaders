--[[
    https://godotshaders.com/shader/bounce-wave/
    afrasier
    January 1, 2025
    
    
    Quantize_To: might be useful on low pixels images

]]
--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "wobble"
kernel.name = "float"
kernel.isTimeDependent = true


kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Speed_X', 'Speed_Y', 'Sine_AmpX','Sine_AmpY',
            'Quantize_To', 'fIs_Do_Abs', 'fIs_Do_Quantize','DEBUG',
            '','','','',
            '','','','',
        },
        default = {
            1.0, 2.0, 0.0, 5.0,
            .1, 0., 0., .0,
            .5, .5, .2, .02,
            .5, .5, .2, .02,
        },
        min = {
            .0,  .0, .0, .0,
            .1, .0, .0, -1000,
            .0, .0, .001, 0.01,
            .0, .0, .001, 0.01,
        },
        max = {
            50.0, 50.0, 50.0, 50.0,
            20.0, 1.0, 1.0, 1000,
            1.0, 1.0, 1.0, .5,
            1.0, 1.0, 1.0, .5,

        },
    },

}


kernel.vertex =
[[
uniform mat4 u_UserData0; // uniSetting

float Speed_X   = u_UserData0[0][0];
float Speed_Y   = u_UserData0[0][1];
float Sine_AmpX = u_UserData0[0][2];    
float Sine_AmpY = u_UserData0[0][3];

float Quantize_To = u_UserData0[1][0];
float fIs_Do_Abs = u_UserData0[1][1];
float fIs_Do_Quantize = u_UserData0[1][2];
float DEBUG = u_UserData0[1][3];
//-----------------------------------------------

vec2 Sine_Amp = vec2(Sine_AmpX, Sine_AmpY);
vec2 Sine_Speed = vec2(Speed_X, Speed_Y);

//-----------------------------------------------

float round( float value){
  return floor( value + float(0.5) );
}

//-----------------------------------------------

float TIME = CoronaTotalTime ;
P_UV vec2 VERTEX = CoronaTexCoord / CoronaTexelSize.zw;


P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{ 
    VERTEX = position;

    vec2 s = sin(TIME * Sine_Speed);
    
    if ( fIs_Do_Abs > 0 ) {
        s = abs(s);
    }
    VERTEX += s * Sine_Amp;
    if ( fIs_Do_Quantize > 0 ) {
        VERTEX.x = round(VERTEX.x / Quantize_To);
        VERTEX.y = round(VERTEX.y / Quantize_To);
        VERTEX *= Quantize_To;
    }

    //if( position.x <= position.y ){
    //if( position.x <= DEBUG ){
    if( position.x <= position.y + DEBUG ){
        VERTEX.x -= position.y+ DEBUG;
        //VERTEX.x = -20;
        //VERTEX.x = position.x;
        //VERTEX.x = position.x + 20;
    }

    VERTEX.x += position.y+ DEBUG;

    return VERTEX;

}
]]


return kernel



--[[

--]]
