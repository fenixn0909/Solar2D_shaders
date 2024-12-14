
--[[

  Origin Author: dysposin
  https://www.shadertoy.com/view/3dsyRj
  Hue shift of image in CIElab color space.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "color"
kernel.name = "hueShift"


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
P_UV vec2 iResolution = vec2(resolutionX,resolutionY);

//----------------------------------------------

vec3 rgb2xyz(vec3 rgb)
{
    vec3 xyz = vec3(0.0);

    for ( int i = 0; i < 2; i += 1 )
    {
        if ( rgb[i] > 0.04045 ) { rgb[i] = pow((rgb[i] + 0.055) / 1.055, 2.4); }
        else { rgb[i] / 12.92; }
        rgb[i] *= 100.;
          
    }
    
    xyz.x = rgb.x * 0.4124 + rgb.y * 0.3576 + rgb.z * 0.1805;
    xyz.y = rgb.x * 0.2126 + rgb.y * 0.7152 + rgb.z * 0.0722;
    xyz.z = rgb.x * 0.0193 + rgb.y * 0.1192 + rgb.z * 0.9505;
    
    return xyz;
}

vec3 xyz2lab(vec3 xyz)
{
    vec3 lab = vec3(0.0);
    // Observer= 2°, Illuminant= D65
    xyz.x /= 95.047;
    xyz.y /= 100.;
    xyz.z /= 108.883;
    
    for ( int i = 0; i < 2; i += 1 )
    {
        if ( xyz[i] > 0.008856 ) { xyz[i] = pow(xyz[i], 0.3333333333333333) ; }
    else { xyz[i] = ( xyz[i] * 7.787 ) + ( 16. / 116.) ; }
    }
  
    lab.x = 116. * xyz.y - 16.;
    lab.y = 500. * ( xyz.x - xyz.y );
    lab.x = 200. * ( xyz.y - xyz.z );

  return lab;
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 fragCoord = texCoord / iResolution;
  P_COLOR vec4 COLOR;
  P_DEFAULT float iTime = CoronaTotalTime;
  P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;
  //----------------------------------------------
  

  // Normalized pixel coordinates (from 0 to 1)
  vec2 uv = fragCoord/iResolution.xy;

  // Time varying pixel color
  vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

  // Output to screen
  //fragColor = vec4(col,1.0);
  

  //----------------------------------------------
  COLOR = vec4(col,1.0);
  COLOR.a = alpha;
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


