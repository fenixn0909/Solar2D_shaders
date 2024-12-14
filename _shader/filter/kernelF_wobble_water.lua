local kernel = {}

kernel.language = "glsl"

kernel.category = "filter"
kernel.group = "wobble"
kernel.name = "water"

kernel.isTimeDependent = true

kernel.vertexData =
{
  
}

kernel.fragment =
[[
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_DEFAULT vec2 uv = ( texCoord.xy / CoronaVertexUserData.xy );
  uv.y += (cos((uv.y + (CoronaTotalTime * 0.04)) * 45.0) * 0.0019) +
  (cos((uv.y + (CoronaTotalTime * 0.1)) * 10.0) * 0.002);
    uv.x += (sin((uv.y + (CoronaTotalTime * 0.07)) * 15.0) * 0.0029) +
  (sin((uv.y + (CoronaTotalTime * 0.1)) * 15.0) * 0.002);
    P_COLOR vec4 texColor = texture2D(CoronaSampler0,uv);

    return CoronaColorScale( texColor );
}
]]

return kernel