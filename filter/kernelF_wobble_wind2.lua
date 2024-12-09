local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "wobble"
kernel.name = "wind2"

kernel.isTimeDependent = true


kernel.uniformData = 
{
    name = "worldMatrix",
    default = {
      10.0, 10.0, 0.0, 0.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 0.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 0.0
    },
    min = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    max = {
      10.0, 10.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    type="mat4",
    index = 0, -- u_UserData0
}





kernel.vertex =
[[
#define SPEED 0.1

uniform P_COLOR mat4 u_UserData0; 
uniform P_COLOR mat4 u_UserData1; 

P_DEFAULT float speed = 0.1;
P_DEFAULT float minStrength = 0.02; //: hint_range(0.0, 1.0) 
P_DEFAULT float maxStrength = 0.05; //: hint_range(0.0, 1.0) 
P_DEFAULT float strengthScale = 185.0;
P_DEFAULT float interval = 0.1;
P_DEFAULT float detail = 100.0;
P_DEFAULT float distortion = 1.0; //: hint_range(0.0, 1.0)
P_DEFAULT float heightOffset = 0.0; //: hint_range(0.0, 1.0)
P_DEFAULT float offset = 0.0;


P_POSITION float getWind (P_POSITION vec2 vertex, P_UV vec2 uv, P_DEFAULT float time)
{
    P_DEFAULT float diff = pow(maxStrength - minStrength, 2.0);
    P_DEFAULT float strength = clamp(minStrength + diff + sin(time / interval) * diff, minStrength, maxStrength) * strengthScale;
    
    //P_DEFAULT float windSide = max(0.0, (1.0-uv.y) - heightOffset); // Blow Top
    P_DEFAULT float windSide = min(1.0, (0.0+uv.y) + heightOffset); // Blow Top
    P_RANDOM float wind = (sin(time) + cos(time * detail)) * strength * windSide;
    //P_DEFAULT float wind = (sin(time) + cos(time * detail)) * strength * windSide;
    

    return wind; 
}


P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{


    //With the offset value, you can if you want different moves for each asset. Just put a random value (1, 2, 3) in the editor. Don't forget to mark the material as unique if you use this
    
    speed = mod(5, 4) * 0.1;

    //P_DEFAULT float time = CoronaTotalTime * speed + offset;
    //P_UV vec4 pos = u_UserData0[0] * vec4(1.0, 1.0, 1.0, 1.0);
    P_DEFAULT float posX = u_UserData0[0][0];
    P_DEFAULT float posY = u_UserData0[0][1];
    P_DEFAULT float time = CoronaTotalTime * speed + posX * posY;// not working when moving...
    position.x += getWind(position.xy, CoronaTexCoord, time);


    return position;
}
]]





return kernel