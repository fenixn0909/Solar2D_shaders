
--[[
    https://godotshaders.com/shader/3d-hover-canvasitem/
    Sivabalan
    September 10, 2024

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "hover3D"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "MouseX",                default = 0, min = -320, max = 320, index = 0, },
  { name = "MouseY",                default = 0, min = -320, max = 320, index = 1, },
  { name = "Speular_Power",         default = 15, min = 3, max = 30, index = 2, },
  { name = "Speular_Intensity",     default = 1, min = -10, max = 10, index = 3, },
} 


kernel.vertex =
[[

varying vec2 texCoord;
varying float fragPerspective;
varying vec2 mouseoffset;

float MouseX = CoronaVertexUserData.x;
float MouseY = CoronaVertexUserData.y;


float _tilt_Scale = .25;
vec2 MouseUV = vec2( MouseX*10, MouseY*10 );

//-----------------------------------------------

P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
P_UV vec2 VERTEX = CoronaTexCoord / TEXTURE_PIXEL_SIZE;


P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
    
    //-----------------------------------------------
    // Normalize texture coordinates
    texCoord = VERTEX.xy * TEXTURE_PIXEL_SIZE;
    //texCoord = CoronaTexCoord;

    // Center the coordinates around the origin
    vec2 centeredCoord = texCoord - vec2(0.5, 0.5);
    vec2 mouse_centered = ((MouseUV + 0.5/TEXTURE_PIXEL_SIZE) * TEXTURE_PIXEL_SIZE) * 2.0 - 1.0;
    mouseoffset = mouse_centered / 2.0;

    // Rotation matrices around the x, y, and z axes    
    float cosX = cos(mouse_centered.y * _tilt_Scale);
    float sinX = sin(mouse_centered.y * _tilt_Scale);
    mat3 rotationX;
    rotationX[0] = vec3(1.0, 0.0, 0.0);
    rotationX[1] = vec3(0.0, cosX, -sinX);
    rotationX[2] = vec3(0.0, sinX, cosX);

    float cosY = cos(-mouse_centered.x * _tilt_Scale);
    float sinY = sin(-mouse_centered.x * _tilt_Scale);
    mat3 rotationY;
    rotationY[0] = vec3(cosY, 0.0, sinY);
    rotationY[1] = vec3(0.0, 1.0, 0.0);
    rotationY[2] = vec3(-sinY, 0.0, cosY);

    float cosZ = cos(0.);
    float sinZ = sin(0.);
    mat3 rotationZ;
    rotationZ[0] = vec3(cosZ, -sinZ, 0.0);
    rotationZ[1] = vec3(sinZ, cosZ, 0.0);
    rotationZ[2] = vec3(0.0, 0.0, 1.0);

    // Combine rotations
    mat3 rotation = rotationZ * rotationY * rotationX;

    // Apply the rotation to the vertex position
    vec3 transformedCoord = rotation * vec3(centeredCoord, 0.0);

    // Apply perspective projection
    float perspective = 1.0 / (1.0 - transformedCoord.z * 0.5);
    float perspective2 = 1.0 / (transformedCoord.z * 0.5);
    transformedCoord.xy *= perspective;     
    texCoord *= perspective;
    fragPerspective = perspective;
    
    // Transform back to screen coordinates
    //vec2 screenPosition = transformedCoord.xy + vec2(0.5, 0.5); 
    vec2 screenPosition = transformedCoord.xy + vec2(.5, .59); 
    VERTEX = screenPosition / TEXTURE_PIXEL_SIZE * .315;   


    //-----------------------------------------------
    
    //VERTEX += vec2( 1, 30.5 );

    //P_POSITION float amplitude = 10;
    //VERTEX.y += sin( 3.0 * CoronaTotalTime + CoronaTexCoord.x ) * amplitude * CoronaTexCoord.y;

    return VERTEX;
    //return VERTEX;
}

]]



kernel.fragment =
[[

varying vec2 texCoord;
varying float fragPerspective;
varying vec2 mouseoffset;

uniform sampler2D TEXTURE;


float Speular_Power = CoronaVertexUserData.z;
float Speular_Intensity = CoronaVertexUserData.w;


float IsSpecularLight = 1; // 1: On, 0: Off

vec2 Anchor = vec2( 1 );

//-----------------------------------------------

P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //perspective correction of UV
    vec2 finalTexCoord = texCoord / fragPerspective * Anchor;  
    vec4 texColor = texture2D(TEXTURE, finalTexCoord );      
    
    //sepcular light
    float colvalue = pow(clamp(1.0 - length(finalTexCoord - 0.5 + mouseoffset* 0.05), 0.0, 1.0), Speular_Power) * Speular_Intensity;
    vec3 specularCol = vec3(colvalue, colvalue, colvalue);
    
    COLOR = texColor + vec4(specularCol, 0.0) * step( 1, IsSpecularLight);

    //-----------------------------------------------
    

    return CoronaColorScale( COLOR );
}
]]


return kernel




--[[



--]]





