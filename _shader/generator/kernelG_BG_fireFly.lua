
--[[
  
    Origin Author:  flyingrub
    https://www.shadertoy.com/view/WsBXRG

    Heavily inspired by https://www.shadertoy.com/view/lscczl
    -- Overhead version ⬆️

    #VARIATION: Goto the tag and tweak them for different patterns

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG" 
kernel.name = "fireFly"


kernel.isTimeDependent = true

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",     default = 1.5, min = 0, max = 30, index = 0, },
  { name = "Size",       default = 2.5, min = 0, max = 5, index = 1, },
  { name = "Zoom",     default = 20, min = 0.01, max = 50, index = 2, },
  { name = "EdgeR",   default = 2, min = 1, max = 10, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Size = CoronaVertexUserData.y;
float Zoom = CoronaVertexUserData.z;
float EdgeR = CoronaVertexUserData.w;
//----------------------------------------------

//float Speed = .5;
//float Zoom = 20.; // The less the larger and fewer
//float Size = 1.5; // The less the smaller



vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;
vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;

float PixelW = SCREEN_PIXEL_SIZE.y;

P_COLOR vec4 Col_Fly = vec4( 1.0, 0.0, 0.0, 1 );

// #VARIATION: Fly Blinks
#define isBlink


//----------------------------------------------

float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

vec2 GetPos(vec2 id, vec2 offs, float t) {
    float n = random(id+offs);
    float n1 = fract(n*10.);
    float n2 = fract(n*100.);
    float a = t+n;
    return offs + vec2(sin(a*n1), cos(a*n2))*.8;
}

// -----------------------------------------------


P_DEFAULT float iTime = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_UV vec2 FRAGCOORD = UV * iResolution;
    P_COLOR vec4 COLOR = vec4(0);
    //----------------------------------------------
    
    vec2 uv = (FRAGCOORD.xy-iResolution.xy*.5)/iResolution.y;
    uv = uv * Zoom;

    float col = 0;
    vec3 colV = vec3(0);

    for (int i =-1; i<=1; i++) {
        for (int j =-1; j<=1; j++) {
            vec2 offset = vec2(i,j);
            vec2 id = floor(uv);
            vec2 gv = fract(uv);
            vec2 pos = GetPos(id, offset, iTime*Speed+10.);
            
            //=== Color Variation
            float randV = 1.0;

            #ifdef isBlink
              //randV = smoothstep(0.1, 0.9, abs(sin(iTime*1)*0.5 ) );
              randV = abs(sin(iTime*1)*0.5 );
              //randV = step( 0.5, abs(sin(iTime*2)) ) +1;
            #endif

            // Single Color Flies
            float p_size = random(id+offset+randV/7)/20.*Size;
            col += smoothstep(PixelW *Zoom, 0.0, length(pos-gv)-p_size);

            // Rainbow Flies
            float p_sizeR = random(id+offset+randV*7)/20.*Size;
            float p_sizeG = random(id+offset+randV*3)/20.*Size;
            float p_sizeB = random(id+offset-randV*4)/20.*Size;
            colV.r += smoothstep(PixelW *Zoom,0.0,length(pos-gv)-p_sizeR);
            colV.g += smoothstep(PixelW *Zoom,0.0,length(pos-gv)-p_sizeG);
            colV.b += smoothstep(PixelW *Zoom,0.0,length(pos-gv)-p_sizeB);

        }
    }
    
    // DEBUG? Show Grid
    //col += step(0.9,fract(uv.x));
    //col += step(0.9,fract(uv.y));

    // #VARIATION: Fly colors
    //COLOR = vec4(vec3(col), 1.0);   //White Flies
    //COLOR = vec4( Col_Fly.rgb * col, Col_Fly.a);   //Color Flies
    COLOR = vec4(vec3(colV), 1.0);  //Rainbow Flies

    //----------------------------------------------
    
    // #VARIATION: Background Alpha
    // Color Filter < Remove Darker Color >
    COLOR.a = max(sign( (COLOR.r + COLOR.g + COLOR.b) - 0.1 ), 0.0);
    
    // Keep Black Layer
    //COLOR.a = max(sign( 3.1 - (COLOR.r + COLOR.g + COLOR.b)), 0.0);
    //COLOR.a = (COLOR.a+COLOR.g+COLOR.b)/3;

    COLOR.rgb *= COLOR.a;
    
    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


