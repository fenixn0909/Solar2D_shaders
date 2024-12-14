local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "emboss"

kernel.vertexData =
{
    {
        name = "colorR",
        default = 0,
        min = 0,
        max = 1,
        index = 0, -- v_UserData.x
    },
    {
        name = "colorG",
        default = 0,
        min = 0,
        max = 1,
        index = 1, -- v_UserData.y
    },
    {
        name = "colorB",
        default = 0,
        min = 0,
        max = 1,
        index = 2, -- v_UserData.z
    },

    {
        name = "intensity",
        default = 1,
        min = 0,
        max = 4,
        index = 3, -- v_UserData.w
    },
}

kernel.fragment =
[[
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_COLOR vec4 sample0 = texture2D( u_FillSampler0, texCoord - u_TexelSize.xy );
    P_COLOR vec4 sample1 = texture2D( u_FillSampler0, texCoord + u_TexelSize.xy );
    P_COLOR vec4 result = vec4( 0.0, 0.0, 0.0, ( ( sample0.a + sample1.a ) * 0.5 ) );
    result.rgb -= sample0.rgb * 5.0 * v_UserData.w;
    result.rgb += sample1.rgb * 5.0 * v_UserData.w;
    result.rgb = vec3( ( result.r + result.g + result.b ) * 0.3333 );

    
    P_COLOR vec3 mixed = result.rgb + v_UserData.xyz;
    result.rgb = mixed;

    // Pre-multiply alpha.
    result.rgb *= result.a;
    return result * v_ColorScale;
}
]]

return kernel













