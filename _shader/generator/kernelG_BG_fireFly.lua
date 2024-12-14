
--[[
  
  Origin Author:  flyingrub
  https://www.shadertoy.com/view/WsBXRG

  Heavily inspired by https://www.shadertoy.com/view/lscczl
  -- Overhead version ⬆️

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG" 
kernel.name = "fireFly"


kernel.isTimeDependent = true

kernel.vertexData =
{
  
}


kernel.fragment =
[[
P_UV vec2 iResolution = vec2(1. ,1.);
//----------------------------------------------
  //#define resolution iResolution
  //#define frame iFrame
  //#define frame CoronaTotalTime
  //#define pixel_width 1./iResolution.y
  #define pixel_width 1./ 1050

  #define isBlink

  const float speed = .5;
  const float grid = 2.; // The less the larger and fewer
  const float size = 4.5; // The less the smaller

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

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = ( texCoord.xy / iResolution );
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;

  //scale = sin(CoronaTotalTime*3) * 1000;
  //amount = abs(sin(CoronaTotalTime*1)) * 3 + 1.5; // For Dot
  //amount = abs(sin(CoronaTotalTime*1)) *2  + 1; // For Line
  //saturation = abs(sin(CoronaTotalTime)) * 1 + .7;
  
  //----------------------------------------------
  
    vec2 uv = (fragCoord.xy-iResolution.xy*.5)/iResolution.y;
    uv = uv * grid;

    float col;

    vec3 colV;

    for (int i =-1; i<=1; i++) {
        for (int j =-1; j<=1; j++) {
            vec2 offset = vec2(i,j);
            vec2 id = floor(uv);
            vec2 gv = fract(uv);
            vec2 pos = GetPos(id, offset, iTime*speed+10.);
            
            //float p_size = random(id+offset)/20.*size;
            //col += smoothstep(pixel_width*grid,0.0,length(pos-gv)-p_size);

            // Color Variation

            float randV = 1;

            #ifdef isBlink
              //randV = smoothstep(0.1, 0.9, abs(sin(CoronaTotalTime*1)*0.5 ) );
              randV = abs(sin(CoronaTotalTime*1)*0.5 );
              //randV = step( 0.5, abs(sin(CoronaTotalTime*2)) ) +1;
            #endif
            

            float p_sizeR = random(id+offset+randV*7)/20.*size;
            float p_sizeG = random(id+offset+randV*3)/20.*size;
            float p_sizeB = random(id+offset-randV*4)/20.*size;
            colV.r += smoothstep(pixel_width*grid,0.0,length(pos-gv)-p_sizeR);
            colV.g += smoothstep(pixel_width*grid,0.0,length(pos-gv)-p_sizeG);
            colV.b += smoothstep(pixel_width*grid,0.0,length(pos-gv)-p_sizeB);

      }
    }
    
    //col += step(0.98,fract(uv.x));
    //col += step(0.98,fract(uv.y));

    
  
    // Output to screen
    //COLOR = vec4(vec3(col), 1);
    COLOR = vec4(vec3(colV), 1);

  //----------------------------------------------
  COLOR.a = (COLOR.a+COLOR.g+COLOR.b)/3;
  //COLOR.a *= alpha;
  COLOR.rgb *= COLOR.a;
  //COLOR.rgb = col2;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


