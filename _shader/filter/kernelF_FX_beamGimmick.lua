
--[[
    
    Scan line, Ray sweep, SlashFX, Glint object, Buff, Nerf...

    phoenixongogo
    Dec 25, 2024
    
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "beamGimmick"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Progress",    default = .5, min = 0, max = 1, index = 0, },
  { name = "Prog_Factor",     default = .125, min = -0, max = 1.5, index = 1, },
  { name = "SkewY",     default = .5, min = -10, max = 10, index = 2, },
  { name = "OffsetX",    default =  .75, min = -5, max = 5, index = 3, },
} 


kernel.fragment =
[[
float Progress = CoronaVertexUserData.x;
float Prog_Factor = CoronaVertexUserData.y;
float SkewY = CoronaVertexUserData.z;
float OffsetX = CoronaVertexUserData.w;

//----------------------------------------------

uniform sampler2D TEXTURE;


vec4 Col_Slash = vec4(1.05, 0.5, 0.5, .5); // Light gray
vec4 Col_2 = vec4(1.0, 1., 1.0, 1.0); // Dark gray


//-----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    COLOR = texture2D( TEXTURE, UV );
    //----------------------------------------------
  
    //COLOR = vec4( step( 0.5, UV.x * UV.x ) );
    //COLOR = vec4( step( 0.1, abs( UV.x - UV.y ) ) );
    //COLOR = vec4( step( 0.1, abs( UV.x - UV.y ) ) );
    
    //COLOR = vec4( smoothstep( -0, 1, UV.x/UV.y  ) );
    //COLOR = vec4( smoothstep( 1, -1.5, abs( UV.x - UV.y )  ) );
    
    //COLOR = vec4( smoothstep( 0, Progress, abs( UV.x - UV.y )  ) );
    
    //float progress = (Progress - Prog_Factor) * 2.5;
    float progress = (Progress-.25) * 2.5;
    float rMix1 = smoothstep( Prog_Factor, progress, abs( OffsetX - UV.x - UV.y*SkewY ));
    float rMix2 = smoothstep( Prog_Factor-.1, progress, abs( OffsetX - UV.x - UV.y*SkewY ));
    

    //COLOR = vec4( smoothstep( Prog_Factor, progress, abs( OffsetX - UV.x - UV.y*SkewY  )  ) );
    Col_Slash.rgb *= COLOR.a;

    COLOR.rgb = mix( COLOR.rgb, Col_Slash.rgb, rMix1-.25 );
    COLOR.rgb = mix( COLOR.rgb, Col_2.rgb, rMix2-.25 );

    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


