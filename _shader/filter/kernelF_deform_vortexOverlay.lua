
--[[
  Origin Author: 9exa
  https://godotshaders.com/shader/vortex-overlay/
  
  A colorRect that causes the elipse of pixels behind it to rotate.

  Uniforms:

  Rot_Offset – rotates the entire elipse by this amount

  Intensity – pixels will rotate in proportion to its distance from the edge of the elipse. Up to *Intensity* full rotations

  invert – if true, pixels will instead rotate in proportion to its distance from the center of the elipse.

  rel_rect_size – The size of the colorRect relative to the viewport. Must be set in the node script

  Max_Blend – The color of the colorRect will be mixed into the effect at most this amount, at the center of the vortex.

  The effect will not work in the editor, as it uses the screenUV

  NOT WORKING?

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "vortexOverlay"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Max_Blend",          default = .5, min = 0, max = 1, index = 0, },
  { name = "Rot_Offset",     default = 0, min = -10.1, max = 100, index = 1, },
  { name = "Intensity",    default = 5, min = 0.1, max = 15, index = 2, },
  { name = "Rect_Size",    default = 64, min = -1000, max = 1000, index = 2, },
} 

kernel.fragment =
[[

float Max_Blend = CoronaVertexUserData.x;
float Rot_Offset = CoronaVertexUserData.y;
float Intensity = CoronaVertexUserData.z;
float Rect_Size = CoronaVertexUserData.w;

//----------------------------------------------

//----------------------------------------------
//uniform float Max_Blend = .5; //: hint_range(0,1) incr for blackhole
//uniform float Rot_Offset = 0; //0
//float Intensity = 5; //: hint_range(0, 10)
uniform bool isInvert = true;
//uniform vec2 rel_rect_size = vec2(1024, 600);
vec2 rel_rect_size = vec2( Rect_Size );

//----------------------------------------------

float distFromCen(vec2 p) {
  return distance(p, vec2(0.5));
}
//rotates by angle radians
vec2 rotate(vec2 p, float angle){
  return vec2(cos(angle)*p.x-sin(angle)*p.y, sin(angle)*p.x + cos(angle)*p.y);
}

//----------------------------------------------
 
P_COLOR vec4 COLOR;
vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

  P_UV vec2 SCREEN_UV = UV;


  Intensity = sin(CoronaTotalTime*1) * 10; // 10 to round
  //Intensity = sin(CoronaTotalTime*1) * 4;
  //Intensity = 0;
  //----------------------------------------------
    vec4 c = COLOR;
    
    float distMod = isInvert ? distFromCen(UV) : 0.5 - distFromCen(UV);
    float angle = Intensity * distMod * 6.28318 + Rot_Offset;
    vec2 newp = rotate(UV-vec2(0.5), angle) + vec2(0.5);
    vec2 disp = (newp - UV) * rel_rect_size * SCREEN_PIXEL_SIZE;
    //vec2 disp = (UV - newp ) * rel_rect_size * SCREEN_PIXEL_SIZE;
    //disp.y = -disp.y; // for some reason UV and SCEEN_UV are inveresed
    disp.y = disp.y; // for some reason UV and SCEEN_UV are inveresed
    //COLOR = mix(texture2D(CoronaSampler0, SCREEN_UV + disp), c, Max_Blend * 2.0 * (0.5-distFromCen(UV)));
    COLOR = mix(texture2D(CoronaSampler0, UV + disp), c, Max_Blend * 2.0 * (0.5-distFromCen(UV)));
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





