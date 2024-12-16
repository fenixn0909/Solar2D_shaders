
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
  { name = "MouseX",           default = 1.0, min = -10, max = 9, index = 0, },
  { name = "MouseY",          default = 1, min = -20, max = 20, index = 1, },
  -- { name = "Hardness",        default = 500, min = -1000, max = 1000, index = 2, },
  -- { name = "RotationSpeexd",   default = 1.0, min = -100, max = 100, index = 3, },
} 


kernel.fragment =
[[

float MouseX = CoronaVertexUserData.x;
float MouseY = CoronaVertexUserData.y;
//float Hardness = CoronaVertexUserData.z;
//float RotationSpeed = CoronaVertexUserData.w;
//----------------------------------------------
//----------------------------------------------

P_UV vec2 MousePos = vec2( MouseX, MouseY );
//P_UV vec2 MousePos = vec2(0.5, 0.5);
uniform vec4 wave_color = vec4(1.0, 2.0, 4.0, 1.0); // : source_color
uniform float Alpha = .70; // : hint_range(0.0, 1.0)

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;
vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
//----------------------------------------------


mat2 rotate2D(float r) {
    // Matriz de rotación 2D  
    return mat2(vec2(cos(r), sin(r)), vec2(-sin(r), cos(r)));
}

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    // Moving Patterns Test
    //MousePos.x = cos(TIME*3); 
    //MousePos.y = sin(TIME*13.25);

    //----------------------------------------------

    // Coordenadas de textura
    vec2 uv = (UV.xy / TEXTURE_PIXEL_SIZE.y) * 0.001;  
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
    //mat2 m = rotate2D(1.0 - (MousePos.x * 0.1));
    mat2 m = rotate2D(1.0 - (MousePos.x * 0.1)) + MousePos.y*0.1 ;
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
    //col = pow(max(vec3(0),(N.x+N.y+.5)*.1*wave_color.rgb+.003/length(N)),vec3(.65));
    COLOR = vec4(col, Alpha);

    //----------------------------------------------
    //COLOR.a = max(sign(0.8 - (COLOR.r + COLOR.g + COLOR.b)), 0.0);
    
    // Rid of Darker Color
    // < Solid >
    //COLOR.a = max(sign((COLOR.r + COLOR.g + COLOR.b) - 0.2), 0.0);
    // < Smooth >
    COLOR.a = min(max((COLOR.r + COLOR.g + COLOR.b) - 0.2, 0.2), 1.2); // Fading
    COLOR.rgb *= COLOR.a;
    // < Overlay >
    COLOR.a = Alpha;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


