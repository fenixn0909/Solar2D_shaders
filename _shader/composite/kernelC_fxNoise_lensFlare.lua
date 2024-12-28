

--[[
    https://godotshaders.com/shader/lens-flare-shader/
    malhotraprateek
    February 24, 2022

    ShaderToy
    https://www.shadertoy.com/view/4sX3Rs

--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "fxNoise"
kernel.name = "lensFlare"

kernel.isTimeDependent = true


kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Mouse_X', 'Mouse_Y', 'Mouse_Z','',
            'Tint_R','Tint_G','Tint_B','',    
            'Pos_X','Pos_Y','','',
            '','','','',
        },
        default = {
            1.0, 1.0, -2.0, 1.0,
            1.4, 1.2, 1.0, 0.0,
            10, 10, 0.0, 0.0,    
            0.0, 0.0, 0.0, 0.0,
        },
        min = {
            -1000.0, -1000.0, -5.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            -1.0, -1.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        max = {
            1000.0, 1000.0, 5.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1000.0, 1000.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
        },
    },
}


kernel.fragment = [[

//----------------------------------------------

//uniform sampler2D SCREEN_TEXTURE;  CoronaSampler0
//uniform sampler2D Texture_Noise; CoronaSampler1


uniform mat4 u_UserData0; // uniSetting

vec3 iMouse = u_UserData0[0].xyz;
vec3 Col_Tint = u_UserData0[1].rgb;
vec2 Pos_Sun = u_UserData0[2].xy;


//vec3 iMouse = vec3(.5);

//vec3 Col_Tint = vec3(1.4,1.2,1.0);




//----------------------------------------------

float noise_float(float t, vec2 texResolution)
{
    return texture2D(CoronaSampler1,vec2(t,0.0)/texResolution).x;
}

float noise_vec2(vec2 t, vec2 texResolution)
{
    return texture2D(CoronaSampler1,t/texResolution).x;
}

vec3 lensflare(vec2 uv,vec2 pos, vec2 texResolution)
{
    vec2 main = uv-pos;
    vec2 uvd = uv*(length(uv));
    
    float ang = atan(main.x,main.y);
    float dist = length(main);
    dist = pow(dist,0.1);
    
    float n = noise_vec2(vec2(ang*16.0,dist*32.0), texResolution);
    
    // Do not need an artificial sun
    //float f0 = 1.0/(length(uv-pos)*16.0+1.0);
    //f0 = f0 + f0*(sin(noise_float(sin(ang*2.+pos.x)*4.0 - cos(ang*3.+pos.y), texResolution)*16.)*.1 + dist*.1 + .8);
    
    float f1 = max(0.01-pow(length(uv+1.2*pos),1.9),.0)*7.0;

    float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*0.25;
    float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*0.23;
    float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*0.21;
    
    vec2 uvx = mix(uv,uvd,-0.5);
    
    float f4 = max(0.01-pow(length(uvx+0.4*pos),2.4),.0)*6.0;
    float f42 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*5.0;
    float f43 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*3.0;
    
    uvx = mix(uv,uvd,-.4);
    
    float f5 = max(0.01-pow(length(uvx+0.2*pos),5.5),.0)*2.0;
    float f52 = max(0.01-pow(length(uvx+0.4*pos),5.5),.0)*2.0;
    float f53 = max(0.01-pow(length(uvx+0.6*pos),5.5),.0)*2.0;
    
    uvx = mix(uv,uvd,-0.5);
    
    float f6 = max(0.01-pow(length(uvx-0.3*pos),1.6),.0)*6.0;
    float f62 = max(0.01-pow(length(uvx-0.325*pos),1.6),.0)*3.0;
    float f63 = max(0.01-pow(length(uvx-0.35*pos),1.6),.0)*5.0;
    
    vec3 c = vec3(.0);
    
    c.r+=f2+f4+f5+f6; c.g+=f22+f42+f52+f62; c.b+=f23+f43+f53+f63;
    c = c*1.3 - vec3(length(uvd)*.05);
    
    // Do not need an artificial sun
    //c+=vec3(f0);
    
    return c;
}

vec3 cc(vec3 color, float factor,float factor2) // color modifier
{
    float w = color.x+color.y+color.z;
    return mix(color,vec3(w)*factor,w*factor2);
}

//----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);
P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;
vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
float iTime = CoronaTotalTime;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    vec2 FRAGCOORD = UV * iResolution;
    //vec2 texResolution = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 texResolution = Pos_Sun;
    P_UV vec2 fragCoord = ( UV / CoronaVertexUserData.xy );
    //----------------------------------------------

    //vec2 uv = fragCoord.xy / iResolution.xy - 0.5;
    vec2 uv = UV - 0.5;
    //vec2 uv = UV *= .5;
    //uv = UV - 0.5;

    uv.x *= iResolution.x/iResolution.y; //fix aspect ratio
    vec3 mouse = vec3(iMouse.xy/iResolution.xy ,iMouse.z);
    mouse.x *= iResolution.x/iResolution.y; //fix aspect ratio
    if (iMouse.z<.5)
    {
        mouse.x=sin(iTime)*.5;
        mouse.y=sin(iTime*.913)*.5;
    }
    
    //vec3 color = vec3(1.4,1.2,1.0)*lensflare(uv,mouse.xy);
    vec3 color = vec3(1.4,1.2,1.0)*lensflare(uv, mouse.xy, texResolution);
    //color -= noise_vec2(fragCoord.xy)*.015;
    color -= noise_vec2(fragCoord.xy, texResolution)*.015;
    color = cc(color,.5,.1);
    COLOR = vec4(color,1.0);

    //----------------------------------------------
    return CoronaColorScale(COLOR);
}
]]
return kernel

--[[
  

--]]

