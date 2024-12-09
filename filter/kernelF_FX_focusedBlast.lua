

--[[
  Focused Blast
  https://godotshaders.com/shader/focused-blast/
  gringer November 26, 2024


--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "focusedBlast"

--Test
kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name    = "progress",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
  }
}
kernel.fragment = [[

uniform int point_count = 7; // Number of originating points
uniform float wave_length = 0.15; //Wavelength (as a proportion of the texture)
uniform float focal_radius = 0.121; // Radius of the circule including the focal points
uniform float falloff_sd = 0.2; //Standard Deviation for global pulse falloff
uniform float point_sd = 0.5; //Standard Deviation for point pulse falloff
uniform float cycle_period = 15.0; //Standard Deviation for point pulse falloff
uniform float starting_offset = -0.75; //Number of waves to offset start point
uniform bool scale_texture = true; //Should the background texture be scaled based on the focused energy




// ----------------------------------------------------------------------------------------------------

vec2 map_scale(vec2 uv, float x, float y){
  mat2 scale = mat2(vec2(x, 0.0), vec2(0.0, y));

  uv -= 0.5; // centre on origin
  uv = uv * scale; // apply scaling
  uv += 0.5; // re-centre to 0.5,0.5
  return uv;
}

// ----------------------------------------------------------------------------------------------------

float PI = 3.14159265359;
P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;
// ----------------------------------------------------------------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    // ----------------------------------------------------------------------------------------------------
    float ampSum = 0.0;
      float timeFrac = mod(TIME, cycle_period);
      // Initial inteference pattern
      for(int i = 0; i < point_count; i++){
        vec2 pt = vec2(sin(float(i) * 2.0 * PI / float(point_count)) * focal_radius + 0.5,
                       cos(float(i) * 2.0 * PI / float(point_count)) * focal_radius + 0.5);
        float dist = distance(pt, UV) / (wave_length);
        float point_smoothing = 2.0 / (point_sd * sqrt(2.0 * PI)) *
                                 exp(-1.0 * pow((dist - starting_offset - timeFrac / (wave_length * cycle_period)), 2.0) / pow(point_sd, 2.0));
        ampSum += sin(fract(dist + starting_offset - timeFrac / (wave_length * cycle_period)) * 2.0 * PI) * point_smoothing;
      }
      // how many waves is it into the centre
      float wave_centre_count = focal_radius / wave_length;
      // how long does it take to get there?
      float seconds_per_wave = wave_length * cycle_period;
      // [added fudge of 'sqrt(cycle_period / 10.0)'; I don't know why this is needed]
      float wave_centre_time = seconds_per_wave * wave_centre_count * sqrt(cycle_period / 10.0);
      float mag_scale = 0.0;
      if(scale_texture){
        if((timeFrac + starting_offset) > wave_centre_time){
          mag_scale = (clamp(((timeFrac + starting_offset) - wave_centre_time) / (wave_centre_time), 0.0, 1.0));
        }
      } else {
        mag_scale = 1.0;
      }
      // global filtering curve
      float centreDist = distance(vec2(0.5, 0.5), UV);
      float outer_smoothing = 1.0 / (falloff_sd * sqrt(2.0 * PI)) *
                              exp(-1.0 * pow(centreDist, 2.0) / pow(falloff_sd, 2.0));
      ampSum *= outer_smoothing;

      
      vec2 uvS = map_scale(UV, 1.0 / mag_scale, 1.0 / mag_scale); // uvScale
      //vec2 uvS = map_scale(UV, mag_scale, mag_scale); // uvScale
      
      vec4 baseTexture = texture2D( CoronaSampler0, uvS );
      //vec4 baseTexture = texture2D( CoronaSampler0, map_scale(UV, 1.0 / mag_scale, 1.0 / mag_scale) );
      vec4 maskColor = texture2D( CoronaSampler0, UV );
      vec2 uv2 = (UV - 0.5) + 0.5;
      vec4 checkColor = texture2D( CoronaSampler0, uv2 );

      maskColor.a = 0;
      if( maskColor.a < 0){
        discard;
      } else if( UV.x > UV.x-(mag_scale) ){
        maskColor.a = 1;
      }


      // Called for every pixel the material is visible on.
      vec4 colour = vec4(0.1 * ampSum,0.1 * ampSum, 0.1 * ampSum,abs(ampSum / 4.0));

      baseTexture *= maskColor.a;
      //baseTexture *= checkColor.a;
      //COLOR = baseTexture + colour;
      COLOR = baseTexture;
      

    // ----------------------------------------------------------------------------------------------------

    return CoronaColorScale( COLOR );
}
]]
return kernel

--[[
  
  
  

  void fragment(){
    vec4 currentColor = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    float blackDistance = distance(currentColor, vec4(vec3(0.0), 1.0));
    float whiteDistance = distance(currentColor, vec4(vec3(1.0), 1.0));
    float lightGrayDistance = distance(currentColor, vec4(vec3(0.666, 0.666, 0.666), 1.0));
    float darkGrayDistance = distance(currentColor, vec4(vec3(0.333, 0.333, 0.333), 1.0));
    
    if (
      whiteDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)
    )
    {
      COLOR = whiteColor;
    }
    else if (
      blackDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)
    )
    {
      COLOR = blackColor;
    }
    else if (
      darkGrayDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)
    )
    {
      COLOR = darkGreyColor;
    }
    else if (
      lightGrayDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)
    )
    {
      COLOR = lightGreyColor;
    }
    else{
      COLOR = whiteColor;
    }
  }

--]]

