
--[[
  
  Origin Author:  pengliu916
  https://www.shadertoy.com/view/cll3WH

  Dreamy star field for my baby visual stimuli 

  // --------------------------------------------------------
  // Palettes
  // iq https://www.shadertoy.com/view/ll2GD3
  // --------------------------------------------------------


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "BG"
kernel.name = "starFieldDreamy"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.fragment =
[[
P_DEFAULT float resolutionX = CoronaVertexUserData.x;
P_DEFAULT float resolutionY = CoronaVertexUserData.y;
//P_UV vec2 iResolution = vec2(resolutionX,resolutionY);
P_UV vec2 iResolution = vec2(1,1);
P_UV vec2 iMouse = vec2(1,1);

//----------------------------------------------
#define TWOPI 6.2831852
#define LAYERS 8.0
#define MAXOFFSET 0.8
#define HALF_SQRT2 0.7071

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b * cos( TWOPI * (c * t + d) );
}

mat2 rot(float angle) {
    return mat2(cos(angle), sin(angle), -sin(angle), cos(angle));
}

// feature need to have return value 0 for r>=1.0 and max value =1.0
float feature(vec2 r_theta) {
    float feature = max(1.0 - r_theta.x, 0.0);
    feature -= 0.25 * pow(cos(r_theta.y * 5.0) + 2.8, r_theta.x * 2.0);
    return pow(max(feature, 0.0), 1.0);
}
// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  //P_UV vec2 fragCoord = texCoord / iResolution;
  P_UV vec2 fragCoord = texCoord;
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;

  //----------------------------------------------
  
    vec2 paramHV = vec2(iMouse.xy) / iResolution.xy * vec2(2.0) - vec2(1.0);
        vec2 uv = (fragCoord) / iResolution.xy;
        uv = uv * 2.0 - 1.0;
        uv.y /= iResolution.x / iResolution.y;
        
        // now screen space should have u in range [-1, 1]
        
        vec3 sum = vec3(0.0);
        float scale = 1.0;
        
        for(float i = 0.0; i < LAYERS; ++i) {
        vec2 _uv = uv * 0.50 / HALF_SQRT2; // scaled to make corner-center dist <= 1.0 (when rotate 45°)
        _uv = _uv * rot(i * 2.0) + vec2(0.03, 0.04) * i; // rotate for every layer
        scale = mod(i - iTime * 0.3, LAYERS); // compute scale for every layer
        _uv *= scale; // apply scale to each layer
        //vec2 idx = trunc(_uv + vec2(LAYERS)); // get ID for each tile
        vec2 idx = floor(_uv + vec2(LAYERS)); // get ID for each tile
        _uv = mod(_uv, 1.0); // make local uv in range [0,1] again by tiling
        _uv = _uv * 2.0 - 1.0;
        
        //now _uv should in range [-1.0, 1.0]
    
        
        // noise is in range [-1.0, 1.0]
        vec3 noise = 2.0 * texture2D(CoronaSampler0, (idx + i) * 0.07).rgb - 1.0;
        //noise = vec3(0.0);
   
        // limited to MAXOFFSET
        noise.xy *= MAXOFFSET;
        
        // compute the scale limit
        vec2 margin = vec2(1.0) - abs(noise.xy);
        float zoomScale = min(margin.x, margin.y);
        zoomScale = mix(0.3, zoomScale * 0.5, (noise.z + 1.0) * 0.5);
        
        vec2 local_uv = (_uv + noise.xy) / zoomScale;
        
        // get polar coordinate
        vec2 r_theta = vec2(length(local_uv), atan(local_uv.y, local_uv.x));
        r_theta.y += sin(iTime * noise.z + noise.y * 5.0) * noise.x * 20.0;
    
        // get color
        vec3 color = pal((idx.x * idx.y / 10.0 + iTime * noise.z * 3.0), vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0), vec3(0.0,0.10,0.20));
        sum += feature(r_theta) * color * (LAYERS - scale) / LAYERS * (noise.x  + 3.0);
    }
    
    COLOR = vec4(pow(sum * 1.5, vec3(1.8 / 2.2)), 1.0);

  //----------------------------------------------
  //COLOR.a *= alpha;
  //COLOR.rgb *= COLOR.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


