
--[[
  https://godotshaders.com/shader/neuronal-network-waves/
  ahaugas
  October 15, 2024

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "neuronalNetworkWave"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "textureRatio",
    default = 1,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "paletteRowCols",
    default = 4,
    min = 1,
    max = 16,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
}


kernel.fragment =
[[

//----------------------------------------------

P_UV vec2 mouse_position = vec2(0.5, 0.5);
uniform vec4 wave_color = vec4(1.0, 2.0, 4.0, 1.0); // : source_color
uniform float wave_transparency = 1.0; // : hint_range(0.0, 1.0)

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;
vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;

vec4 FRAGCOORD = gl_FragCoord;

//----------------------------------------------


mat2 rotate2D(float r) {
    // Matriz de rotación 2D  
    return mat2(vec2(cos(r), sin(r)), vec2(-sin(r), cos(r)));
}

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    // Moving Patterns
    mouse_position.x = cos(TIME*3); 
    mouse_position.y = sin(TIME*13.25);

    //----------------------------------------------

    // Coordenadas de textura
    vec2 uv = (FRAGCOORD.xy / TEXTURE_PIXEL_SIZE.y) * 0.001;  
    // Color inicial
    vec3 col = vec3(0.0);
    // Tiempo
    float t = TIME;
    // Variables para el cálculo del ruido
    vec2 n = vec2(0.0), q;
    vec2 N = vec2(0.0);
    // Posición inicial
    vec2 p = uv + sin(t*0.1/10.0);
    // Escala inicial
    float S = 10.0;
    // Matriz de rotación
    mat2 m = rotate2D(1.0 - (mouse_position.x * 0.001));
    // Bucle principal para generar el ruido
    for (float j = 0.0; j < 30.0; j++) {
      // Rotar la posición y el vector normal
      p *= m;
      n *= m;
      // Calcular el valor del ruido
      q = p * S + j + n + t;
      n += sin(q);
      N += cos(q) / S;
      // Aumentar la escala
      S *= 1.2;
    }

    // Evitar divisiones por cero
    float lengthN = max(length(N), 0.001);
    // Calcular el color final
    col = wave_color.rgb * pow((N.x + N.y + 0.4) + 0.005 / lengthN, 2.1);
    // Slimy
    // col = pow(max(vec3(0),(N.x+N.y+.5)*.1*wave_color.rgb+.003/length(N)),vec3(.65));
    COLOR = vec4(col, wave_transparency);

    //----------------------------------------------
    //COLOR.a = max(sign(0.8 - (COLOR.r + COLOR.g + COLOR.b)), 0.0);
    
    // Rid of Darker Color
    // < Solid >
    //COLOR.a = max(sign((COLOR.r + COLOR.g + COLOR.b) - 0.2), 0.0);
    // < Smooth >
    COLOR.a = min(max((COLOR.r + COLOR.g + COLOR.b) - 0.2, 0.2), 1.2); // Fading
    
    COLOR.rgb *= COLOR.a;



    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


