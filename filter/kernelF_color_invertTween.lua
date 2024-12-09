local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "invertTween"

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
P_COLOR vec3 tweener = vec3(1);
//----------------------------------------------



//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  tweener.r = abs(sin(CoronaTotalTime*5 * 0.2));
  tweener.g = abs(sin(CoronaTotalTime*3 * 0.2));
  tweener.b = abs(sin(CoronaTotalTime*7 * 0.2));

  //strength = 0.6;
  //----------------------------------------------
  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV ); 
  //if (COLOR.a > 0){ COLOR = vec4(1.0 - COLOR.rgb, COLOR.a); }
  
  P_COLOR vec4 invColor = vec4(1 - COLOR.rgb, COLOR.a);
  COLOR.r = mix( COLOR.r, invColor.r, tweener.r);
  COLOR.g = mix( COLOR.g, invColor.g, tweener.g);
  COLOR.b = mix( COLOR.b, invColor.b, tweener.b);

  //COLOR = vec4(strength - COLOR.rgb, COLOR.a);


  //----------------------------------------------
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel