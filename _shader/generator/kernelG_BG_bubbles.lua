
--[[
    https://www.shadertoy.com/view/4dl3zn


--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "bubbles"

kernel.isTimeDependent = true



kernel.vertexData =
{
  { name = "Speed",     default = 2, min = -50, max = 50, index = 0, },
  { name = "Volume",     default = 40, min = 0, max = 60, index = 1, },
  { name = "Move_X",     default = 0.2, min = -3, max = 3, index = 2, },
  { name = "Move_Y",     default = -.06, min = -3, max = 3, index = 3, },
} 

kernel.fragment =
[[


float Speed = CoronaVertexUserData.x;
float Volume = CoronaVertexUserData.y;
float Move_X = CoronaVertexUserData.z;    // vec2(0,0.2): rise, vec2(1,-.1): left lines
float Move_Y = CoronaVertexUserData.w;
//----------------------------------------------


//-----------------------------------------------
float iTime = CoronaTotalTime * Speed;
P_COLOR vec4 COLOR = vec4(0);
P_UV vec2 iResolution = 1 / CoronaTexelSize.zw;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

    P_UV vec2 fragCoord = texCoord * iResolution;

    //----------------------------------------------

    vec2 uv = (2.0*fragCoord-iResolution.xy) / iResolution.y;

    // background    
    vec3 color = vec3(0.8 + 0.2*uv.y);

    // bubbles  
    for( int i=0; i<Volume; i++ )
    {
        // bubble seeds
        float pha =      sin(float(i)*546.13+1.0)*0.5 + 0.5;
        float siz = pow( sin(float(i)*651.74+5.0)*0.5 + 0.5, 4.0 );
        float pox =      sin(float(i)*321.55+4.1) * iResolution.x / iResolution.y;

        // bubble size, position and color
        float rad = 0.1 + 0.5*siz;
        vec2  pos = vec2( pox, -1.0-rad + (2.0+2.0*rad)*mod(pha+0.1*iTime*(0.2+0.8*siz),1.0));
        float dis = length( uv - pos );
        vec3  col = mix( vec3(0.94,0.3,0.0), vec3(0.1,0.4,0.8), 0.5+0.5*sin(float(i)*1.2+1.9));
        //    col+= 8.0*smoothstep( rad*0.95, rad, dis );
        
        // render
        float f = length(uv-pos)/rad;
        f = sqrt(clamp(1.0-f*f,0.0,1.0));
        color -= col.zyx *(1.0-smoothstep( rad*0.95, rad, dis )) * f;
    }

    // vigneting    
    color *= sqrt(1.5-0.5*length(uv));

    COLOR = vec4(color,1.0);

    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


