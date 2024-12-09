local kernel = {}

kernel.language = "glsl"

kernel.category = "filter"
kernel.group = "upscale"
kernel.name = "basic"

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


//upscaling multiplier amount
const P_DEFAULT float SCALE = 0.5;

//image mipmap level, for base upscaling
const P_DEFAULT int ML = 0;

const P_DEFAULT float LINE_THICKNESS = 2;

//equality threshold of 2 colors before forming lines
P_DEFAULT float THRESHOLD = 0.4;

//anti aliasing scaling, smaller value make lines more blurry
P_DEFAULT float AA_SCALE = 3;



//draw diagonal line connecting 2 pixels if within threshold
P_UV vec4 diag(vec4 sum, vec2 uv, vec2 p1, vec2 p2, sampler2D iChannel0, float LINE_THICKNESS) {
    //vec4 v1 = texelFetch(iChannel0,ivec2(uv+vec2(p1.x,p1.y)),ML),
        //v2 = texelFetch(iChannel0,ivec2(uv+vec2(p2.x,p2.y)),ML);

    //vec4 v1 = CoronaTexelSize,
        //v2 = CoronaTexelSize;
    vec4 v1 = texture2D(iChannel0, (2 * uv + vec2(p1.x,p1.y))/2 * CoronaTexelSize.zw);
    vec4 v2 = texture2D(iChannel0, (2 * uv + vec2(p2.x,p2.y))/2 * CoronaTexelSize.zw);
    


    if (length(v1-v2) < THRESHOLD) {
      vec2 dir = p2-p1,
            lp = uv-(floor(uv+p1)+.5);
      dir = normalize(vec2(dir.y,-dir.x));
        float l = clamp((LINE_THICKNESS-dot(lp,dir))*AA_SCALE,0.,1.);
        sum = mix(sum,v1,l);
    }
    return sum;
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    //texCoord = (texCoord - 0.5) * SCALE + (0.5 * SCALE);
    vec2 ip = texCoord;
    //vec2 ip = (texCoord - 0.5) * SCALE + (0.5 * SCALE);
    ip = texCoord * (1.0 / CoronaTexelSize.zw);
  
    //start with nearest pixel as 'background'
    //vec4 s = texelFetch(TEXTURE,ivec2(ip),ML);
    //vec4 s = texelFetch(CoronaSampler0,ivec2(ip),ML);
    //vec4 s = CoronaTexelSize;

    //texture2D(tex, (2 * uv + vec2(1.))/2 * u_texsize);
    vec4 s = texture2D(CoronaSampler0, (2 * texCoord + vec2(1.))/2 * CoronaTexelSize.zw);


    //draw anti aliased diagonal lines of surrounding pixels as 'foreground'
    s = diag(s,ip,vec2(-1,0),vec2(0,1), CoronaSampler0, LINE_THICKNESS);
    s = diag(s,ip,vec2(0,1),vec2(1,0), CoronaSampler0, LINE_THICKNESS);
    s = diag(s,ip,vec2(1,0),vec2(0,-1), CoronaSampler0, LINE_THICKNESS);
    s = diag(s,ip,vec2(0,-1),vec2(-1,0), CoronaSampler0, LINE_THICKNESS);
    
    //COLOR = s;


  
    return CoronaColorScale( s );
}
]]

return kernel

--[[






void fragment()
{
  
  
}
--]]
