
--[[
    Status Bar < With Color Tween + Grids >
    
    Creat a rect by the size you want, apply and tweak it as you like.
    Pass 'progress' and 'progress_prev' to control the length of the bar.

    phoenixongogo
    Dec 9, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "UI"
kernel.name = "statusBar"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 0.5,
    min = 0,
    max = 1,
    index = 0,    
  },
  {
    name = "progress_prev",
    default = 0.82,
    min = 0,
    max = 1,
    index = 1,    
  },
  {
    name = "num_grids",
    default = 7,
    min = 0,
    max = 99,
    index = 2,    
  },
  
}

kernel.fragment =
[[

uniform sampler2D OVERLAY;

float Progress = CoronaVertexUserData.x;
float Prev = CoronaVertexUserData.y;
lowp float Num_Grids = CoronaVertexUserData.z;

P_COLOR vec4 Col_Base = vec4( 0.0, 0.0, 0.0, 1.0);
P_COLOR vec4 Col_Bar = vec4( 0.7, 1.0, 0.8, 1.0);
P_COLOR vec4 Col_Tween_Trans = vec4( 0.85, 0.35, 0.35, 1.0);  // To disable Tween: Set vec4 same with Col_Bar 
P_COLOR vec4 Col_Sustain = vec4( 0.65, 0.3, 0.35, 1.0);
P_COLOR vec3 Col_Reflect = vec3( 0.65, 0.75, .6);

float Smooth_Edge = 0.2;
float Reflect_Thick_Upper = 0.175;
float Reflect_Thick_Lower = 0.05;

//----------------------------------------------

P_COLOR vec4 COLOR;

//----------------------------------------------

float when_neq_v4(vec4 x, vec4 y) { // not equal
  return float( abs(sign(x - y)) );
}

float when_eq_v4(vec4 x, vec4 y) {
  return float( 1.0 - abs(sign(x - y)) );
}

float when_eq(float x, float y) {
  return 1.0 - abs(sign(x - y));
}

float when_gt(float x, float y) { //greater than return 1
  return max(sign(x - y), 0.0);
}

float when_lt(float x, float y) {
  return max(sign(y - x), 0.0);
}

vec4 get_bar_color( float chk_dir, float chk_sign, float c_mixP ){
    vec4 col_sustain = when_lt( chk_dir, Prev * chk_sign ) * Col_Sustain;  // Col_Sustain
    vec4 col_tween = when_lt( chk_dir, Progress * chk_sign ) * mix( Col_Tween_Trans, Col_Bar, c_mixP );  // Show Tween Color
    return max( col_tween, max(col_sustain, Col_Base) );    // Set Proper Color
}

float get_stripe_strength( float uv, float pos, float thick, float strength ){
    lowp float cnt = 1;
    cnt -= when_lt( uv, pos-thick*.5 );
    cnt -= when_gt( uv, pos+thick*.5 );
    return when_gt( cnt, 0 ) * abs( strength - uv*.5 ) ;
}

float get_smooth_step( float uv,  float range ){ //vec3 cur_color,
    lowp float s_upper = when_gt( uv, 1-range) * (uv - (1-range))*5;
    lowp float s_lower = when_lt( uv, range) * (range - uv)*5;
    return max( s_upper, s_lower);
}


//----------------------------------------------

P_DEFAULT float TIME = CoronaTotalTime; // * speed


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //=== Testing, Comment out when using vertexData
    Progress = abs(sin(TIME*0.7));
    Prev = abs(sin(TIME*0.3));
    //----------------------------------------------

    //=== Choose Direction
    float uv_chk; float uv_chk_anti; float sign_chk; float prog_chk;

    uv_chk = UV.x; uv_chk_anti = UV.y; sign_chk = 1, prog_chk = Progress;       //Right<Full>
    //uv_chk = UV.y; uv_chk_anti = UV.x; sign_chk = 1, prog_chk = Progress;       //Bottom<Full>
    //uv_chk = -UV.x; uv_chk_anti = UV.y; sign_chk = -1, prog_chk = 1-Progress;   //Left<Full>
    //uv_chk = -UV.y; uv_chk_anti = UV.x; sign_chk = -1, prog_chk = 1-Progress;   //Top<Full>

    COLOR = get_bar_color( uv_chk, sign_chk, prog_chk ); 
    
    //=== Pre-cheker for afterward rendering
    lowp float nb_is_tween_col = when_neq_v4( COLOR, Col_Sustain );
    nb_is_tween_col *= when_neq_v4( COLOR, Col_Base );


    //=== Apply Reflection
    //get_stripe_strength ( float uv, float pos, float thick, float strength )
    COLOR.rgb += Col_Reflect * get_stripe_strength( uv_chk_anti, 0.3, Reflect_Thick_Upper, 0.3) * nb_is_tween_col;
    COLOR.rgb += Col_Reflect * get_stripe_strength( uv_chk_anti, 0.8, Reflect_Thick_Lower, 0.47) * nb_is_tween_col;
    
    //=== Apply Smooth Edge Gradient
    float step = get_smooth_step( uv_chk_anti, Smooth_Edge );
    COLOR.rgb -= COLOR.rgb * step;

    //=== Apply Grids
    float gap = 1.0 / Num_Grids;
    for (int i = 0; i < Num_Grids+1 ; i++){
        COLOR.rgb -= 1.25 * get_stripe_strength( abs(uv_chk), i*gap, 0.01, .3+ abs(uv_chk)*.5);
    }

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


