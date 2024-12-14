
--[[
    https://godotshaders.com/shader/plasma-waves/
    kcfresh53
    September 26, 2023
    
    ✳️ Need check on device!! issue: gl_FragCoord ✳️
    
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "plasmaWave"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "scrnPxW",
    default = 600,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "scrnPxH",
    default = 2000,
    min = 1,
    max = 9999,     
    index = 1,    -- v_UserData.y
  },
}


kernel.fragment =
[[


float scrnPxW = CoronaVertexUserData.x;
float scrnPxH = CoronaVertexUserData.y;

const float tweak = 1;
P_UV vec2 SCREEN_PIXEL_SIZE = tweak/vec2( scrnPxW, scrnPxH );



const float overallSpeed = 1.2;
const float gridSmoothWidth = 0.015;
const float axisWidth = 0.05;
const float majorLineWidth = 0.025;
const float minorLineWidth = 0.0125;
const float majorLineFrequency = 5.0;
const float minorLineFrequency = 1.0;
const vec4 gridColor = vec4(0.5);
const float scale = 5.0;
const vec4 lineColor = vec4(0.25, 0.5, 1.0, 1.0);
const float minLineWidth = 0.02;
const float maxLineWidth = 0.5;
const float lineSpeed = 1.0 * overallSpeed;
const float lineAmplitude = 1.0;
const float lineFrequency = 0.2;
const float warpSpeed = 0.2 * overallSpeed;
const float warpFrequency = 0.5; //0.5
const float warpAmplitude = 1.0;
const float offsetFrequency = 0.5;
const float offsetSpeed = 1.33 * overallSpeed;
const float minOffsetSpread = 0.6;
const float maxOffsetSpread = 2.0;
const int linesPerGroup = 16;

//const vec4[] bgColors = {
//    vec4(lineColor * 0.5),
//    vec4(lineColor - vec4(0.2, 0.2, 0.7, 1))
//};

//const vec4[] bgColors;
vec4 bgColors0 = vec4(lineColor * 0.5);
vec4 bgColors1 = vec4(lineColor - vec4(0.2, 0.2, 0.7, 1));


P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed


//----------------------------------------------
#define drawCircle(P, r, U)     smoothstep(r + gridSmoothWidth, r, length(U - (P)))
#define drawSmoothLine(P, w, t) smoothstep((w) / 2.0, 0.0, abs(P - (t)))
#define drawCrispLine(P, w, t)  smoothstep(gridSmoothWidth, 0.0, abs(P - (w) / 2.0 - (t)))
#define drawPeriodicLine(f, w, t)  drawCrispLine(f / 2.0, w, abs(mod(t, f) - f / 2.0))

float drawGridLines(float axis)
{
    return drawCrispLine(0.0, axisWidth, axis)
        + drawPeriodicLine(majorLineFrequency, majorLineWidth, axis)
        + drawPeriodicLine(minorLineFrequency, minorLineWidth, axis);
}

float drawGrid(vec2 space)
{
    return min(1.0, drawGridLines(space.x)
                  + drawGridLines(space.y));
}

// Probably can optimize w/ noise, but currently using Fourier transform
float random(float t)
{
    return (cos(t) + cos(t * 1.3 + 1.3) + cos(t * 1.4 + 1.4)) / 3.0;
}

float getPlasmaY(float x, float horizontalFade, float offset)
{
    return random(x * lineFrequency + TIME * lineSpeed) * horizontalFade * lineAmplitude + offset;
}

//----------------------------------------------



P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    vec4 FRAGCOORD = gl_FragCoord;
    
    //----------------------------------------------

    vec2 uv = FRAGCOORD.xy / (1.0/SCREEN_PIXEL_SIZE).xy ;
    vec2 space = (FRAGCOORD.xy - (1.0/SCREEN_PIXEL_SIZE).xy / 2.0) / (1.0/SCREEN_PIXEL_SIZE).x * 2.0 * scale;

    float horizontalFade = 1.0 - (cos(uv.x * 6.28) * 0.5 + .5);
    float verticalFade = 1.0 - (cos(uv.y * 6.28) * 0.5 + .5);
    //float horizontalFade = 1.0 - (cos(uv.x * 6.28) * 0.5 );
    //float verticalFade = 1.0 - (cos(uv.y * 6.28) * 0.5 );


    // Fun with nonlinear transformations! (wind / turbulence)
    space.y += random(space.x * warpFrequency + TIME * warpSpeed) * warpAmplitude * (0.5 + horizontalFade);
    space.x += random(space.y * warpFrequency + TIME * warpSpeed + 2.0) * warpAmplitude * horizontalFade;

    vec4 lines = vec4(0);

    for (int l = 0; l < linesPerGroup; l++)
    {
        float normalizedLineIndex = float(l) / float(linesPerGroup);
        float offsetTime = TIME * offsetSpeed;
        float offsetPosition = float(l) + space.x * offsetFrequency;
        float rand = random(offsetPosition + offsetTime) * 0.5 + 0.5;
        float halfWidth = mix(minLineWidth, maxLineWidth, rand * horizontalFade) / 2.0;
        float offset = random(offsetPosition + offsetTime * (1.0 + normalizedLineIndex)) * mix(minOffsetSpread, maxOffsetSpread, horizontalFade);
        float linePosition = getPlasmaY(space.x, horizontalFade, offset);
        float line = drawSmoothLine(linePosition, halfWidth, space.y) / 2.0 + drawCrispLine(linePosition, halfWidth * 0.15, space.y);

        float circleX = mod(float(l) + TIME * lineSpeed, 25.0) - 12.0;
        vec2 circlePosition = vec2(circleX, getPlasmaY(circleX, horizontalFade, offset));
        float circle = drawCircle(circlePosition, 0.01, space) * 4.0;

        line = line + circle;
        lines += line * lineColor * rand;
    }

    COLOR = mix( bgColors0, bgColors1, uv.x);
    COLOR *= verticalFade;
    COLOR.a = 1.0;
    // Debug grid:
    // COLOR = mix(COLOR, gridColor, drawGrid(space));
    COLOR += lines;

    //----------------------------------------------


    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


