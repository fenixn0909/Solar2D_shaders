
--[[

    https://github.com/kan6868/Solar2D-Shader/blob/main/burn/burn.lua
    kan6868

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "FX"
kernel.name = "burn"


kernel.isTimeDependent = true

kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Progress','OCTAVES', 'Thickness', '',
            '', '', '','',
            '', '', '','',
            '', '', '','',
        },
        default = {
            .5, 6, .05, .05,
            6, .5, .2, .02,
            .5, .5, .2, .02,
            .5, .5, .2, .02,
        },
        min = {
             0, 1, 0.01, 0.01,
             1, .0, .001, 0.01,
            .0, .0, .001, 0.01,
            .0, .0, .001, 0.01,
        },
        max = {
            1, 15, 2.0, 2.0,
            15, 1.0, 1.0, .5,
            1.0, 1.0, 1.0, .5,
            1.0, 1.0, 1.0, .5,
        },
    },
}

kernel.fragment =
[[

uniform P_COLOR mat4 u_UserData0; // duration
//----------------------------------------------

P_COLOR float Progress = u_UserData0[0][0];
P_COLOR float OCTAVES = u_UserData0[0][1];
P_COLOR float Thickness = u_UserData0[0][2];

P_COLOR vec4 Col_Ash = vec4( 1.0, 0.0, 0.0, 0.0);
P_COLOR vec4 Col_Fire = vec4( 1., .75, .65, 1.0);



//----------------------------------------------
P_COLOR float rand(P_DEFAULT vec2 coord){
    return fract(sin(dot(coord, vec2(12.9898, 78.233)))* 43758.5453123);
}
  
P_COLOR float noise(P_DEFAULT vec2 coord){
    P_COLOR vec2 i = floor(coord);
    P_COLOR vec2 f = fract(coord);
    P_COLOR float a = rand(i);
    P_COLOR float b = rand(i + vec2(1.0, 0.0));
    P_COLOR float c = rand(i + vec2(0.0, 1.0));
    P_COLOR float d = rand(i + vec2(1.0, 1.0));
  
    P_COLOR vec2 cubic = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}
  
P_COLOR float fbm(P_DEFAULT vec2 coord){
    P_COLOR float value = 0.0;
    P_COLOR float scale = 0.5;
  
    for(float i = 0.0; i < OCTAVES; i++){
        value += noise(coord) * scale;
        coord *= 2.0;
        scale *= 0.5;
    }
    return value;
}

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_COLOR vec4 color = texture2D( CoronaSampler0, texCoord );
    P_COLOR vec4 object = texture2D( CoronaSampler0, texCoord );
    P_COLOR vec4 tex = texture2D( CoronaSampler1, texCoord );

    P_COLOR float Outer_Edge = Progress;
    P_COLOR float Inner_Edge = Outer_Edge + Thickness * Progress;

    //----------------------------------------------
    
    P_COLOR float noise = fbm(texCoord * 6.0);

    if (noise < Inner_Edge) {
        P_COLOR float grad_factor = (Inner_Edge - noise) / Thickness;
        grad_factor = clamp(grad_factor, 0.0, 1.0);
        P_COLOR vec4 fire_grad = mix(Col_Fire, Col_Ash, grad_factor);

        P_COLOR float inner_fade = (Inner_Edge - noise) / 0.02;
        inner_fade = clamp(inner_fade, 0.0, 1.0);

        color = mix(color, fire_grad, inner_fade);
    }

    if (noise < Outer_Edge) {
        color.a = 1.0 - (Outer_Edge - noise)/ 0.03;
        color.a = clamp(color.a, 0.0, 1.0);
    }
    //----------------------------------------------
    color.a *= object.a;
    color.rgb *= color.a;
    
    return CoronaColorScale( color );
}
]]

return kernel

--[[
    
--]]


