
--[[

  https://godotshaders.com/shader/stylised-squares-fade-2d/
  MehdiTheLord
  June 3, 2024

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "squares"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[

//uniform float fade : hint_range( 0.0, 1.0, 0.01 ) = 0.0;
uniform float tiling = 10.0; // : hint_range(0.0, 100.0, 1.0)

P_DEFAULT float progress = CoronaVertexUserData.x;
//----------------------------------------------

int modi( int a, int b ){ return (a)-((a)/(b))*(b); }


float get_grid( vec2 uv )
{
  uv = abs( uv );
  //return float( int( uv.x * 100.0 ) % int( ( 1.0 - pow( progress, 2 ) ) * 100. ) ) * float( int( uv.y * 100.0 ) % int( ( 1.0 - pow( progress, 2 ) ) * 100. ) );
  
  //return 
    //float( int( uv.x * 100.0 ) % int( ( 1.0 - pow( progress, 2 ) ) * 100. ) )*  
    //float( int( uv.y * 100.0 ) % int( ( 1.0 - pow( progress, 2 ) ) * 100. ) );
  return 
    modi( int( uv.x * 100.0 ), int( ( 1.0 - pow( progress, 2 ) ) * 100. ) )* 
    modi( int( uv.y * 100.0 ), int( ( 1.0 - pow( progress, 2 ) ) * 100. ) ); 


  //return float( modi( int( uv.x * 100.0 ), int( ( 1.0 - pow( progress, 2 ) ) * 100.) ) * float( modi( int( uv.y * 100.0 ), int( ( 1.0 - pow( progress, 2 ) )  * 100. ) );
}



float get_line( float uv )
{
  uv = mod( uv * tiling, 1.0 );
  //return round( ( min( uv, 1.0 - uv ) / ( progress )) );
  return
    floor( ( min( uv, 1.0 - uv ) / ( progress )) + float(0.5) );

  //round( value ) = floor( value + type(0.5) )

}


//----------------------------------------------


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);

  //----------------------------------------------
  
  COLOR.a = COLOR.a * ( get_line( UV.x ) * get_line( UV.y ) );
  
  //Normal
  COLOR.rgb *= min( COLOR.a, 1.);
  
  //Expose
  //COLOR.rgb *= min( COLOR.a, 1.);
  

  //----------------------------------------------
    

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


