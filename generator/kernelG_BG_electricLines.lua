
--[[
  
  Origin Author: arlez80
  https://godotshaders.com/shader/procedural-electric-background-shader/
  
  A procedural electric background shader.

  動的電子背景シェーダー by あるる（きのもと 結衣） @arlez80
  Procedural Electric Background Shader by Yui Kinomoto @arlez80

  MIT License

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "electricLines"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.fragment =
[[
P_DEFAULT float resolutionX = CoronaVertexUserData.x;
P_DEFAULT float resolutionY = CoronaVertexUserData.y;
P_UV vec2 iResolution = vec2(resolutionX,resolutionY);
//----------------------------------------------
uniform vec4 background_color = vec4( 0.0, 0.0, 0.0, 0.0 ); //: hint_color 
vec4 line_color = vec4( 1.0, 1.0, 1.0, 1.0 ); //: hint_color 
uniform float line_freq = 7; //9.56
uniform float height = 0.6; //0.6
uniform float speed = 0.8; //0.8
uniform vec2 scale = vec2( 1.0, 16.0 ); //vec2( 2.0, 16.0 )

// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  P_DEFAULT float TIME = CoronaTotalTime;
  P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) + 0.35;
  //----------------------------------------------
  
    vec2 uv = UV * scale;
    float shift = cos( floor( uv.y ) );
    uv.x += shift;

    float freq = clamp( cos( uv.x * line_freq ) * 3.0, 0.0, 1.0 ) * height;
    float line = 1.0 - clamp( abs( freq - mod( uv.y, 1.0 ) ) * 11.0, 0.0, 1.0 );

    // Add Color Variation
    line_color.r = uv.x * 1.5 * abs(sin(TIME*3));
    line_color.g = uv.y * abs(sin(TIME*2));
    line_color.b = uv.x*uv.y * abs(sin(TIME*7));


    COLOR = mix( background_color, line_color, line * mod( uv.x - TIME * speed * abs( shift ), 1.0 ) /*  * mod( TIME + shift, 1.0 ) */ );

  //----------------------------------------------
  //float alpha = when_gt( result.r, 0.5) *0.75;
  //COLOR = vec4( result, alpha );
  COLOR.a *= alpha;
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


