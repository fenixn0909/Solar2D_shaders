--[[

    https://github.com/kan6868/Solar2D-Shader/blob/main/water_surface/surface.lua

    kan6868

    Improvement: chaning direction

]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "wobble"
kernel.name = "waterSurface"

kernel.isTimeDependent = true



kernel.vertexData =
{
  { name = "Speed",     default = 0.05, min = 0, max = 1, index = 0, },
  { name = "Scale",     default = .25, min = 0, max = 1, index = 1, },
  { name = "Opacity",   default = .75, min = 0, max = 1, index = 2, },
  { name = "Intensity", default = .1, min = 0, max = .2, index = 3, },
} 


kernel.fragment = [[
    
uniform sampler2D TEXTURE;
//uniform sampler2D NOISE;
//----------------------------------------------
P_COLOR float Speed = CoronaVertexUserData.x;
P_COLOR float Scale = CoronaVertexUserData.y;
P_COLOR float Opacity = CoronaVertexUserData.z;
P_COLOR float Intensity = CoronaVertexUserData.w;

//----------------------------------------------
P_RANDOM float avg(P_COLOR vec4 color) {
    return (color.r + color.g + color.b) / 3.0;
}
//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

    P_COLOR vec4 noise1 = texture2D(CoronaSampler1, sin(mod( texCoord * Scale + CoronaTotalTime * Speed, 1.0)) );

    P_COLOR vec4 tex = texture2D(TEXTURE, vec2(texCoord) + avg(noise1) * Intensity);

    noise1.rgb = vec3(avg(noise1));

    //fog in water
    P_COLOR float alpha = Opacity;

    if (tex.a == 0.0)
    {
        alpha = 0.0;
    }

    return CoronaColorScale((noise1) * alpha + tex);
}
]]




return kernel