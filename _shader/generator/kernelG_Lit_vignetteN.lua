 
--[[
    Multiple Vignettes
    Support 7 lights


    phoenixongogo
    Jan 08, 2025

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "Lit"
kernel.name = "vignetteN"   

kernel.isTimeDependent = true

kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Num_Lit', 'Flick', 'Flick_Speed','Aspect_Y',
            'Lit1_X', 'Lit1_Y', 'Lit1_Rad','Lit1_Smooth',
            'Lit2_X', 'Lit2_Y', 'Lit2_Rad','Lit2_Smooth',
            'Lit3_X', 'Lit3_Y', 'Lit3_Rad','Lit3_Smooth',
        },
        default = {
            1.0, .05, 3.0, 1.0,
            .5, .5, .2, .02,
            .5, .5, .2, .02,
            .5, .5, .2, .02,
        },
        min = {
            1,  .0, 0.0, 0.1,
            .0, .0, .001, 0.01,
            .0, .0, .001, 0.01,
            .0, .0, .001, 0.01,
        },
        max = {
            7.0, .25, 15.0, 2.0,
            1.0, 1.0, 1.0, .5,
            1.0, 1.0, 1.0, .5,
            1.0, 1.0, 1.0, .5,
        },
    },

    {
        index = 1, 
        type = "mat4",  -- vec4 x 4
        name = "uniLit",
        paramName = {
            'Lit4_X', 'Lit4_Y', 'Lit4_Rad','Lit4_Smooth',
            'Lit5_X', 'Lit5_Y', 'Lit5_Rad','Lit5_Smooth',
            'Lit6_X', 'Lit6_Y', 'Lit6_Rad','Lit6_Smooth',
            'Lit7_X', 'Lit7_Y', 'Lit7_Rad','Lit7_Smooth',
            
        },
        default = {
            .5, .5, .2, .02,
            .5, .5, .2, .02,
            .5, .5, .2, .02,
            .5, .5, .2, .02,
        },
        min = {
            .0, .0, .001, 0.01,
            .0, .0, .001, 0.01,
            .0, .0, .001, 0.01,
            .0, .0, .001, 0.01,
        },
        max = {
            1.0, 1.0, 1.0, .5,
            1.0, 1.0, 1.0, .5,
            1.0, 1.0, 1.0, .5,
            1.0, 1.0, 1.0, .5,
        },
    },
}


kernel.vertex =
[[

varying float chk = 0.;
varying vec2 Texel_Size = CoronaTexelSize.zw;

P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
    return position;
}
]]

kernel.fragment =
[[

varying float chk;
varying vec2 Texel_Size;

//----------------------------------------------
uniform mat4 u_UserData0; // uniSetting
uniform mat4 u_UserData1; // uniLit
//----------------------------------------------
mat4 lt0 = u_UserData0;
mat4 lt1 = u_UserData1;

float aLit[28] = float[28]( 
    lt0[1][0], lt0[1][1], lt0[1][2], lt0[1][3],
    lt0[2][0], lt0[2][1], lt0[2][2], lt0[2][3],
    lt0[3][0], lt0[3][1], lt0[3][2], lt0[3][3],

    lt1[0][0], lt1[0][1], lt1[0][2], lt1[0][3],
    lt1[1][0], lt1[1][1], lt1[1][2], lt1[1][3],
    lt1[2][0], lt1[2][1], lt1[2][2], lt1[2][3],
    lt1[3][0], lt1[3][1], lt1[3][2], lt1[3][3]
);

float Num_Lit = u_UserData0[0][0];
float Flick = u_UserData0[0][1];
float Flick_Speed = u_UserData0[0][2];
float Aspect_Y = u_UserData0[0][3];

//Viewport( 0, 0, 240, 240);
//DepthRangef( 0, 1);

//----------------------------------------------
float TIME = CoronaTotalTime;
vec2 iResolution = 1.0 / CoronaTexelSize.zw;
P_COLOR vec4 COLOR = vec4(1);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    float aspect = 320./280.;
    //----------------------------------------------
    

    //if( gl_FragCoord.x == gl_FragCoord.y ){
    //if( chk > 0 ){
    if( CoronaContentScale.x == CoronaContentScale.y ){
    //if( CoronaTexelSize.x == CoronaTexelSize.y ){
        return CoronaColorScale( vec4(1,0,0,1) );
    }

    vec2 uv = UV;
    //uv.y *= Texel_Size.y / Texel_Size.x;
    uv.x *= CoronaContentScale.x / CoronaContentScale.y;
    //uv.y *= Aspect_Y;


    vec4 finColor = vec4(0);
    for(int i=0; i < int(Num_Lit); i++){
        int shft = i*4;    //Shift
        vec2 circlePos = vec2( aLit[shft], aLit[shft+1]);  
        float radius = aLit[shft+2];          
        float smooth = aLit[shft+3] + abs(sin(TIME*Flick_Speed))*Flick ;

        float dist= length(uv - circlePos);
        float circle = smoothstep(radius - smooth, radius + smooth, dist);
        vec4 color = (1.0 - circle) * vec4(1);
        finColor += color;
        
        COLOR = finColor;
    }

    COLOR = 1-finColor;
    COLOR.rgb = vec3(0);
    
    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


