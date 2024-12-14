--[[
  Origin Author: flytrap
  https://godotshaders.com/author/flytrap/

  I am still a beginner at shading, but I tried to put together something pretty.

  Stars rendered using https://godotshaders.com/shader/stars-shader/ by https://godotshaders.com/author/gerardogc2378/

  Using FBM on perlin noise to generate clouds, and parallax scrolling through in a circle.


--]]



local kernel = {}

kernel.language = "glsl"

kernel.category = "filter"
kernel.group = "scene"
kernel.name = "nebula"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "x",
    default = 1,
    min = 0,
    max = 4,
    index = 0, -- v_UserData.x
  },
  {
    name = "y",
    default = 1,
    min = 0,
    max = 4,
    index = 1, -- v_UserData.y
  },
}


kernel.fragment =
[[

//uniform vec3 color_replace = vec3(1.0,1.0,0.0);
uniform int OCTAVE = 12;
uniform float timescale = 5.0;
uniform vec4 CLOUD1_COL = vec4(0.41,0.64,0.78,0.4); //: hint_color 
uniform vec4 CLOUD2_COL = vec4(0.99,0.79,0.46,0.2); //: hint_color
uniform vec4 CLOUD3_COL = vec4(0.81,0.31,0.59,1.0); //: hint_color
uniform vec4 CLOUD4_COL = vec4(0.27,0.15,0.33,1.0); //: hint_color
uniform vec4 SPACE = vec4(0.09,0.06,0.28,0.3); //: hint_color
uniform float zoomScale = 6.0;
uniform float size = 10.0;
uniform float starscale = 20.0;
uniform float prob = 0.98; //: hint_range(0.0,1.0)

float rand(vec2 v_ipt){
    return fract(sin(dot(v_ipt,vec2(23.53,44.0)))*42350.45);
}

float perlin(vec2 v_ipt){
    vec2 i = floor(v_ipt);
    vec2 j = fract(v_ipt);
    vec2 coord = smoothstep(0.,1.,j);
    
    float a = rand(i);
    float b = rand(i+vec2(1.0,0.0));
    float c = rand(i+vec2(0.0,1.0));
    float d = rand(i+vec2(1.0,1.0));

    return mix(mix(a,b,coord.x),mix(c,d,coord.x),coord.y);
}

float fbm(vec2 v_ipt){
    float value = 0.0;
    float scale = 0.5;
    
    for(int i = 0; i < OCTAVE; i++){
        value += perlin(v_ipt)*scale;
        v_ipt*=2.0;
        scale*=0.5;
    }
    return value;
}

float fbmCloud(vec2 v_ipt, float minimum){
    float value = 0.0;
    float scale = 0.5;
    
    for(int i = 0; i < OCTAVE; i++){
        value += perlin(v_ipt)*scale;
        v_ipt*=2.0;
        scale*=0.5;
    }
    return smoothstep(0.,1.,(smoothstep(minimum,1.,value)-minimum)/(1.0-minimum));
}

float fbmCloud2(vec2 v_ipt, float minimum){
    float value = 0.0;
    float scale = 0.5;
    
    for(int i = 0; i < OCTAVE; i++){
        value += perlin(v_ipt)*scale;
        v_ipt*=2.0;
        scale*=0.5;
    }
    return (smoothstep(minimum,1.,value)-minimum)/(1.0-minimum);
}



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_UV vec2 UV = texCoord;
    float TIME = CoronaTotalTime;
    P_COLOR vec4 COLOR;

    vec4 originalColor = texture2D(CoronaSampler0, UV);
    float timescaled = TIME * timescale;
    //vec2 zoomUV = vec2(zoomScale * UV.x + UV.x*0.04*TIME*sin(0.07*TIME), zoomScale * UV.y + UV.y*0.05*TIME*cos(0.06*TIME));
    vec2 zoomUV2 = vec2(zoomScale * UV.x + 0.03*timescaled*sin(0.07*timescaled), zoomScale * UV.y + 0.03*timescaled*cos(0.06*timescaled));
    vec2 zoomUV3 = vec2(zoomScale * UV.x + 0.027*timescaled*sin(0.07*timescaled), zoomScale * UV.y + 0.025*timescaled*cos(0.06*timescaled));
    vec2 zoomUV4 = vec2(zoomScale * UV.x + 0.021*timescaled*sin(0.07*timescaled), zoomScale * UV.y + 0.021*timescaled*cos(0.07*timescaled));
    float tide = 0.05*sin(TIME);
    float tide2 = 0.06*cos(0.3*TIME);
    //if(color_replace == originalColor.rgb){
        vec4 nebulaTexture = vec4(SPACE.rgb, 0.5+0.2*sin(0.23*TIME +UV.x-UV.y));
        nebulaTexture += fbmCloud2(zoomUV3, 0.24 + tide)*CLOUD1_COL;
        nebulaTexture += fbmCloud(zoomUV2*0.9, 0.33 - tide)*CLOUD2_COL;
        nebulaTexture = mix(nebulaTexture,CLOUD3_COL,fbmCloud(vec2(0.9*zoomUV4.x,0.9*zoomUV4.y), 0.25+tide2));
        nebulaTexture = mix(nebulaTexture,CLOUD4_COL,fbmCloud(zoomUV3*0.7+2.0, 0.4+tide2));
        vec2 zoomstar = starscale*zoomUV2;
        vec2 pos = floor(zoomstar / size);
        float starValue = rand(pos);
        if(starValue>prob){
            vec2 center = size * pos + vec2(size, size) * 0.5;
            float t = 0.9 + 0.2 * sin(TIME * 8.0 + (starValue - prob) / (1.0 - prob) * 45.0);
            float color = 1.0 - distance(zoomstar, center) / (0.5 * size);
            nebulaTexture = mix(nebulaTexture, vec4(1.0,1.0,1.0,1.0),smoothstep(0.,1.,color * t / (abs(zoomstar.y - center.y)) * t / (abs(zoomstar.x - center.x))));
        } else {
            zoomstar *= 5.0;
            pos = floor(zoomstar / size);
            float starValue2 = rand(pos + vec2(13.0,13.0));
            if(starValue2 >= 0.95){
                vec2 center = size * pos + vec2(size, size) * 0.5;
                float t = 0.9 + 0.2 * sin(TIME * 8.0 + (starValue - prob) / (1.0 - prob) * 45.0);
                float color = 1.0 - distance(zoomstar, center) / (0.5 * size);
                nebulaTexture = mix(nebulaTexture, vec4(1.0,1.0,1.0,1.0),fbmCloud(pos,0.0)*smoothstep(0.,1.,color * t / (abs(zoomstar.y - center.y)) * t / (abs(zoomstar.x - center.x))));
            }
        }
        COLOR = vec4(nebulaTexture.rgb, 1.0);
        //COLOR = vec4(nebulaTexture.rgb,nebulaTexture.a * 1.2)
    //} else {
    //  COLOR = originalColor;
    //}
  
    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[


--]]
