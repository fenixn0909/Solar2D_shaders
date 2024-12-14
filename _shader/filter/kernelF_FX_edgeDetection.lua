 
--[[
    https://godotshaders.com/shader/edge-detection-sobel-filter-and-gaussian-blur/
    FencerDevLog
    January 3, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "edgeDetection"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "offX",
    default = 0.0,
    min = -0.5,
    max = 0.5,
    index = 0, 
  },
}


kernel.fragment =
[[

uniform sampler2D SCREEN_TEXTURE;

//----------------------------------------------

// Gaussian blur kernel
const float gauss[25] = float[](
    0.00390625, 0.015625, 0.0234375, 0.015625, 0.00390625,
    0.015625, 0.0625, 0.09375, 0.0625, 0.015625, 0.0234375,
    0.09375, 0.140625, 0.09375, 0.0234375, 0.015625,
    0.0625, 0.09375, 0.0625, 0.015625, 0.00390625,
    0.015625, 0.0234375, 0.015625, 0.00390625
);


//----------------------------------------------

vec3 convolution(sampler2D tex, vec2 uv, vec2 pixel_size) {
    vec3 conv = vec3(0.0);
    
    for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
            conv += texture2D(tex, uv + vec2(float(col - 2), float(row - 2)) * pixel_size).rgb * gauss[row * 5 + col];
        }
    }
    return conv;
}

// -----------------------------------------------

P_COLOR vec4 COLOR;
mediump float TIME = CoronaTotalTime;



P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    P_UV vec2 SCREEN_UV = UV;
    P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;

    float alpha = texture2D( SCREEN_TEXTURE, UV ).a;

    //----------------------------------------------
  
    vec3 pixels[9];  // Sobel kernel
    // [0, 1, 2]
    // [3, 4, 5]
    // [6, 7, 8]
    for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
            vec2 uv = SCREEN_UV + vec2(float(col - 1), float(row - 1)) * SCREEN_PIXEL_SIZE;
            pixels[row * 3 + col] = convolution(SCREEN_TEXTURE, uv, SCREEN_PIXEL_SIZE);
        }
    }

    // Sobel operator
    vec3 gx = (
        pixels[0] * -1.0 + pixels[3] * -2.0 + pixels[6] * -1.0
        + pixels[2] * 1.0 + pixels[5] * 2.0 + pixels[8] * 1.0
    );
    vec3 gy = (
        pixels[0] * -1.0 + pixels[1] * -2.0 + pixels[2] * -1.0
        + pixels[6] * 1.0 + pixels[7] * 2.0 + pixels[8] * 1.0
    );
    vec3 sobel = sqrt(gx * gx + gy * gy);
    COLOR = vec4(sobel, 1.0);

    //----------------------------------------------
    //mixColor = vec4( fragCoord.x, fragCoord.y, 1., 1);

    // Clamp By Texture Aplha
    COLOR.a = alpha;
    COLOR.rgb *= COLOR.a;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


