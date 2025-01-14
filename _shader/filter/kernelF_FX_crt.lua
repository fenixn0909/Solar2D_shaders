--[[
    https://github.com/kan6868/Solar2D-Shader/blob/main/crt/crt.lua
    kan6868

--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "crt"
kernel.isTimeDependent = true

kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Roll_Speed','Roll_Size','Roll_Vari','Distort_Vol',
            'ScanL_Alpha','ScanL_W','Grille_Alpha','Static_Noise',
            'Noise_Alpha','Noise_Speed','Vignette_Vol','Vignette_Alpha',
            'Aberration','Brightness','Discolor',''

        },
        default = {
            4.0, 15.0, 1.8, 0.05,
            0.25, 0.1, 0.3, 0.18,
            0.6, 5.0,  0.4,  0.5,
            0.03, 1.4, 1.0,  0.,  
        },
        min = {
            .0, .0, .0, 0.0,
            .0, .0, .0, 0.0,
            .0, .0, .0, 0.0,
            .0, .0, .0, 0.0,
        },
        max = {
            15.0, 50.0, 10.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 25.0, 1.0, 1.0,
            1.0, 5.0, 1.0, 1.0,
        },
    },

    {
        index = 1, 
        type = "mat4",  -- vec4 x 4
        name = "uniLit",
        paramName = {

            'Warp_Amount','Clip_Warp','Resolution_X','Resolution_Y',
            '','','','',
            '','','','',
            '','','','',
        },
        default = {
            3.0, 1.0, 280, 320,
            .0, .0, .0, .0,
            .0, .0, .0, .0,
            .0, .0, .0, .0,
        },
        min = {
            .0, .0, 3.0, 3.0,
            .0, .0, .0, .0,
            .0, .0, .0, .0,
            .0, .0, .0, .0,
        },
        max = {
            10., 1., 1024., 1024.,
            1., 1., 1., 1.,
            1., 1., 1., 1.,
            1., 1., 1., 1.,
        },
    },
}


kernel.fragment = 
[[

uniform mat4 u_UserData0; // uniSetting
uniform mat4 u_UserData1; // uniLit
//----------------------------------------------

float Roll_Speed    = u_UserData0[0][0];    // Positive values are down, negative are up
float Roll_Size     = u_UserData0[0][1];
float Roll_Vari     = u_UserData0[0][2];    // This valie is not an exact science. You have to play around with the value to find a look you like. How this works is explained in the code below.
float Distort_Vol   = u_UserData0[0][3];    // The distortion created by the rolling effect.
float ScanL_Alpha   = u_UserData0[1][0];
float ScanL_W       = u_UserData0[1][1];
float Grille_Alpha  = u_UserData0[1][2];
float Static_Noise  = u_UserData0[1][3];
float Noise_Alpha   = u_UserData0[2][0];
float Noise_Speed   = u_UserData0[2][1];    // There is a movement in the noise pattern that can be hard to see first. This sets the speed of that movement.
float Vignette_Vol  = u_UserData0[2][2];    // Size of the vignette, how far towards the middle it should go.
float Vignette_Alpha= u_UserData0[2][3];
float Aberration    = u_UserData0[3][0];    // Chromatic Aberration, a distortion on each color channel.
float Brightness    = u_UserData0[3][1];    // When adding scanline gaps and grille the image can get very dark. Brightness tries to compensate for that.
float Discolor      = u_UserData0[3][2];    // 1.0 = true, 0.0 = false // Add a Discolor effect simulating a VHS

float Warp_Amount   = u_UserData1[0][0];    // Warp the texture edges simulating the curved glass of a CRT monitor or old TV.
float Clip_Warp     = u_UserData1[0][1];    // 1.0 = true, 0.0 = false
float Resolution_X  = u_UserData1[0][2];
float Resolution_Y  = u_UserData1[0][3];

//----------------------------------------------

vec2 Resolution = vec2(Resolution_X, Resolution_Y); // Set the number of rows and columns the texture will be divided in. Scanlines and grille will make a square based on these values

//----------------------------------------------

P_DEFAULT vec2 random(P_DEFAULT vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

P_DEFAULT float noise(P_DEFAULT vec2 uv) {
    P_DEFAULT vec2 uv_index = floor(uv);
    P_DEFAULT vec2 uv_fract = fract(uv);

    P_DEFAULT vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) * 0.5 + 0.5;
}

P_DEFAULT vec2 warp(P_DEFAULT vec2 uv){
    P_DEFAULT vec2 delta = uv - 0.5;
    P_DEFAULT float delta2 = dot(delta.xy, delta.xy);
    P_DEFAULT float delta4 = delta2 * delta2;
    P_DEFAULT float delta_offset = delta4 * Warp_Amount;

    return uv + delta * delta_offset;
}

P_DEFAULT float border (P_DEFAULT vec2 uv){
    P_DEFAULT float radius = min(Warp_Amount, 0.08);
    radius = max(min(min(abs(radius * 2.0), abs(1.0)), abs(1.0)), 1e-5);
    P_DEFAULT vec2 abs_uv = abs(uv * 2.0 - 1.0) - vec2(1.0, 1.0) + radius;
    P_DEFAULT float dist = length(max(vec2(0.0), abs_uv)) / radius;
    P_DEFAULT float square = smoothstep(0.96, 1.0, dist);
    return clamp(1.0 - square, 0.0, 1.0);
}

P_DEFAULT float vignette(P_DEFAULT vec2 uv){
    uv *= 1.0 - uv.xy;
    P_DEFAULT float vignette = uv.x * uv.y * 15.0;
    return pow(vignette, Vignette_Vol * Vignette_Alpha);
}

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_COLOR vec4 color = texture2D( CoronaSampler0, texCoord);

    P_UV vec2 uv = warp(texCoord);

    P_UV vec2 text_uv = uv;
      P_UV vec2 roll_uv = vec2(0.0);

    P_DEFAULT float time = CoronaTotalTime;

    //pixelate
    text_uv = ceil(uv * Resolution) / Resolution;

    P_DEFAULT float roll_line = 0.0;
    P_COLOR vec4 texture;
    
    if (Noise_Alpha > 0.0)
    {
      roll_line = smoothstep(0.3, 0.9, sin(uv.y * Roll_Size - (time * Roll_Speed) ) );
      roll_line *= roll_line * smoothstep(0.3, 0.9, sin(uv.y * Roll_Size * Roll_Vari - (time * Roll_Speed * Roll_Vari) ) );
      roll_uv = vec2(( roll_line * Distort_Vol * (1.-texCoord.x)), 0.0);

      texture.r = texture2D(CoronaSampler0, text_uv + roll_uv * 0.8 + vec2(Aberration, 0.0) * 0.1).r;
      texture.g = texture2D(CoronaSampler0, text_uv + roll_uv * 1.2 - vec2(Aberration, 0.0) * 0.1 ).g;
      texture.b = texture2D(CoronaSampler0, text_uv + roll_uv).b;
      texture.a = 1.0;
    }
    
    P_DEFAULT float r = texture.r;
    P_DEFAULT float g = texture.g;
    P_DEFAULT float b = texture.b;

    uv = warp(texCoord);

    if (Grille_Alpha > 0.0){
      
      P_DEFAULT float g_r = smoothstep(0.85, 0.95, abs(sin(uv.x * (Resolution.x * 3.14159265))));
      r = mix(r, r * g_r, Grille_Alpha);
      
      P_DEFAULT float g_g = smoothstep(0.85, 0.95, abs(sin(1.05 + uv.x * (Resolution.x * 3.14159265))));
      g = mix(g, g * g_g, Grille_Alpha);
      
      P_DEFAULT float b_b = smoothstep(0.85, 0.95, abs(sin(2.1 + uv.x * (Resolution.x * 3.14159265))));
      b = mix(b, b * b_b, Grille_Alpha);
      
    }
    
    texture.r = clamp(r * Brightness, 0.0, 1.0);
    texture.g = clamp(g * Brightness, 0.0, 1.0);
    texture.b = clamp(b * Brightness, 0.0, 1.0);

    P_DEFAULT float scanlines = 0.5;
    if (ScanL_Alpha > 0.0)
    {
      scanlines = smoothstep(ScanL_W, ScanL_W + 0.5, abs(sin(uv.y * (Resolution.y * 3.14159265))));
      texture.rgb = mix(texture.rgb, texture.rgb * vec3(scanlines), ScanL_Alpha);
    }
    
    if (Noise_Alpha > 0.0)
    {
      P_DEFAULT float noise = smoothstep(0.4, 0.5, noise(uv * vec2(2.0, 200.0) + vec2(10.0, (CoronaTotalTime * (Noise_Speed))) ) );
      
      roll_line *= noise * scanlines * clamp(random((ceil(uv * Resolution) / Resolution) + vec2(CoronaTotalTime * 0.8, 0.0)).x + 0.8, 0.0, 1.0);
      texture.rgb = clamp(mix(texture.rgb, texture.rgb + roll_line, Noise_Alpha), vec3(0.0), vec3(1.0));
    }
    
    if (Static_Noise > 0.0)
    {
      texture.rgb += clamp(random((ceil(uv * Resolution) / Resolution) + fract(CoronaTotalTime)).x, 0.0, 1.0) * Static_Noise;
    }
    
    
    texture.rgb *= border(uv);
    texture.rgb *= vignette(uv);

    if (Clip_Warp == 1.0)
    {
      texture.a = border(uv);
    }
    
    P_DEFAULT float saturation = 0.5;
    P_DEFAULT float contrast = 1.2;

    if (Discolor == 1.0)
    {
      // Saturation
      P_COLOR vec3 greyscale = vec3(texture.r + texture.g + texture.b) / 3.0;
      texture.rgb = mix(texture.rgb, greyscale, saturation);
      
      // Contrast
      P_DEFAULT float midpoint = pow(0.5, 2.2);
      texture.rgb = (texture.rgb - vec3(midpoint)) * contrast + midpoint;
    }

    return CoronaColorScale(texture);
}

]]
return kernel

--[[



--]]