
--[[
  Origin Author: 9exa
  https://godotshaders.com/shader/vortex-overlay/
  
  A colorRect that causes the elipse of pixels behind it to rotate.

  Uniforms:

  rotation_offset – rotates the entire elipse by this amount

  intensity – pixels will rotate in proportion to its distance from the edge of the elipse. Up to *intensity* full rotations

  invert – if true, pixels will instead rotate in proportion to its distance from the center of the elipse.

  rel_rect_size – The size of the colorRect relative to the viewport. Must be set in the node script

  max_blend – The color of the colorRect will be mixed into the effect at most this amount, at the center of the vortex.

  The effect will not work in the editor, as it uses the screenUV

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "vortexOverlay"

--Test
kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name = "texWidth",
    default = 64,
    min = 1,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "texHeight",
    default = 64,
    min = 1,
    max = 9999,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
  {
    name = "screenWidth",
    default = 64,
    min = 1,
    max = 9999,
    index = 2,    
  },
  {
    name = "screenHeight",
    default = 64,
    min = 1,
    max = 9999,     -- 16x16->256
    index = 3,    
  },
}


kernel.fragment =
[[
P_DEFAULT vec2 texSize = vec2( CoronaVertexUserData.x, CoronaVertexUserData.y );
P_DEFAULT float screenWidth = CoronaVertexUserData.z;
P_DEFAULT float screenHeight = CoronaVertexUserData.w;

//----------------------------------------------
uniform float max_blend = .2; //: hint_range(0,1) incr for blackhole
uniform float rotation_offset = 0; //0
float intensity = 10; //: hint_range(0, 10)
uniform bool isInvert = false;
//uniform vec2 rel_rect_size = vec2(1024, 600);
vec2 rel_rect_size = texSize;

float distFromCen(vec2 p) {
  return distance(p, vec2(0.5));
}
//rotates by angle radians
vec2 rotate(vec2 p, float angle){
  return vec2(cos(angle)*p.x-sin(angle)*p.y, sin(angle)*p.x + cos(angle)*p.y);
}

//----------------------------------------------
 
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  //P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );

  P_UV vec2 SCREEN_PIXEL_SIZE = 1 / vec2(screenWidth, screenHeight);
  //P_UV vec2 SCREEN_PIXEL_SIZE = 1 / texSize;
  //P_UV vec2 SCREEN_PIXEL_SIZE = vec2(1);
  P_UV vec2 SCREEN_UV = gl_FragCoord.xy * SCREEN_PIXEL_SIZE;

  P_COLOR vec4 COLOR;

  //intensity = sin(CoronaTotalTime*1) * 10; 10 too round
  intensity = sin(CoronaTotalTime*1) * 4;
  //intensity = 0;
  //----------------------------------------------
    vec4 c = COLOR;
    
    float distMod = isInvert ? distFromCen(UV) : 0.5 - distFromCen(UV);
    float angle = intensity * distMod * 6.28318 + rotation_offset;
    vec2 newp = rotate(UV-vec2(0.5), angle) + vec2(0.5);
    vec2 disp = (newp - UV) * rel_rect_size * SCREEN_PIXEL_SIZE;
    //vec2 disp = (UV - newp ) * rel_rect_size * SCREEN_PIXEL_SIZE;
    //disp.y = -disp.y; // for some reason UV and SCEEN_UV are inveresed
    disp.y = disp.y; // for some reason UV and SCEEN_UV are inveresed
    //COLOR = mix(texture2D(CoronaSampler0, SCREEN_UV + disp), c, max_blend * 2.0 * (0.5-distFromCen(UV)));
    COLOR = mix(texture2D(CoronaSampler0, UV + disp), c, max_blend * 2.0 * (0.5-distFromCen(UV)));
    //COLOR = c;
    //Doesn'[t apply effect outside of circle]
    if (distFromCen(UV) > 0.5) {
      //COLOR = texture2D(CoronaSampler0, SCREEN_UV);
      COLOR = texture2D(CoronaSampler0, UV);
    }

  //----------------------------------------------
  return CoronaColorScale(COLOR);
}

]]

return kernel


--[[

--]]





