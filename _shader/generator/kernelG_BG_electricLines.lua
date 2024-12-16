
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
  { name = "Speed",           default = .8, min = -10, max = 9, index = 0, },
  { name = "Freq",            default = 9.56, min = -20, max = 20, index = 1, },
  { name = "ScaleX",          default = 2.0, min = -3, max = 10, index = 2, },
  { name = "ScaleY",          default = 16.0, min = -100, max = 100, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Freq = CoronaVertexUserData.y;
float ScaleX = CoronaVertexUserData.z;
float ScaleY = CoronaVertexUserData.w;
//----------------------------------------------

//----------------------------------------------

//uniform float Speed = 0.8; //0.8
//uniform float Freq = 7; //9.56
uniform float Height = 0.6; //0.6
//uniform vec2 scale = vec2( 2.0, 16.0 ); //vec2( 2.0, 16.0 )
vec2 scale = vec2( ScaleX, ScaleY ); //vec2( 2.0, 16.0 )

uniform vec4 Col_BG = vec4( 0.0, 0.0, 0.0, 0.0 ); //: hint_color 
vec4 Col_Line = vec4( 1.0, 1.0, 1.0, 1.0 ); //: hint_color 

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

    float freq = clamp( cos( uv.x * Freq ) * 3.0, 0.0, 1.0 ) * Height;
    float line = 1.0 - clamp( abs( freq - mod( uv.y, 1.0 ) ) * 11.0, 0.0, 1.0 );

    // Add Color Variation
    Col_Line.r = uv.x * 1.5 * abs(sin(TIME*3));
    Col_Line.g = uv.y * abs(sin(TIME*2));
    Col_Line.b = uv.x*uv.y * abs(sin(TIME*7));


    COLOR = mix( Col_BG, Col_Line, line * mod( uv.x - TIME * Speed * abs( shift ), 1.0 ) /*  * mod( TIME + shift, 1.0 ) */ );

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


