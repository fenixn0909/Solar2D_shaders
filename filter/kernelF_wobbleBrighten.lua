local kernel = {}
kernel.category = "filter"
kernel.name = "wobbleBrighten"
 
-- Shader code uses time environment variable CoronaTotalTime
kernel.isTimeDependent = true
 
kernel.vertex =
[[
varying P_COLOR float delta; // Custom varying variable
 
P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
    P_POSITION float amplitude = 10;
 
    position.y += sin( 3.0 * CoronaTotalTime + CoronaTexCoord.x ) * amplitude * CoronaTexCoord.y;
 
    // Calculate value for varying
    delta = 0.4*(CoronaTexCoord.y + sin( 3.0 * CoronaTotalTime + 2.0 * CoronaTexCoord.x ));
 
    return position;
}
]]
 
kernel.fragment =
[[
varying P_COLOR float delta; // Matches declaration in vertex shader
 
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    // Brightness changes based on interpolated value of custom varying variable
    P_COLOR float brightness = delta;
 
    P_COLOR vec4 texColor = texture2D( CoronaSampler0, texCoord );
 
    // Pre-multiply the alpha to brightness
    brightness *= texColor.a;
 
    // Add the brightness
    texColor.rgb += brightness;
 
    // Modulate by the display object's combined alpha/tint.
    return CoronaColorScale( texColor );
}
]]

return kernel