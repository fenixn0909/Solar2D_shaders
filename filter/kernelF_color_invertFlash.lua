local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "invertFlash"

kernel.vertexData =
{
  {
    name = "intensity",
    default = 0,
    min = 0,
    max = 1,
    index = 0, -- v_UserData.x
  },
}

kernel.isTimeDependent = true


kernel.fragment =
[[
P_COLOR float tweener;
//----------------------------------------------



//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  float twnThres = sin(CoronaTotalTime*5);
  tweener = step( abs(tan(CoronaTotalTime*7)), 0.15+twnThres);
  //----------------------------------------------
  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV ); 
  //if (COLOR.a > 0){ COLOR = vec4(1.0 - COLOR.rgb, COLOR.a); }
  if (tweener > 0){ COLOR = vec4(1.0 - COLOR.rgb, COLOR.a); }
  

  //----------------------------------------------
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel


