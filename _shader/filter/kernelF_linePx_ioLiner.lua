
--[[
    
    https://godotshaders.com/shader/2d-outline-inline-configured-for-sprite-sheets/
    Juulpower
    August 25, 2023

    ✳️ width in Vertex and Fragment MUST be the same!!


]]

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "linePx"
kernel.name = "ioLiner"

kernel.isTimeDependent = true

kernel.timeTransform = { func = "pingpong", range = 5 }


kernel.vertexData   = {
  {
    name    = "r",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
    },{
    name    = "g",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 1,
    },{
    name    = "b",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 1,
    min     = 0,
    max     = 32,
    index   = 3,
  },
}

kernel.vertex =
[[

//varying bool add_margins = true; // only useful when inside is false
varying float b_add_margins = 1; // 0,1 : false, true
varying float width = 1.0; // : hint_range(0, 10) 


P_POSITION vec2 VertexKernel( P_POSITION vec2 VERTEX )
{
  if (b_add_margins == 1) {
    VERTEX += sign(VERTEX) * width; // replace sign(VERTEX) by (sign(VERTEX) * 2.0 - 1.0) if not Centered
  }
  return VERTEX;
}
]]

kernel.fragment = [[

varying float b_add_margins;
varying float width; 

//uniform vec4 color = vec4( 1.0, 0.0, 0.5, 1.0 ); //: hint_color 
uniform vec4 color = vec4( 1.0 ); //: hint_color 
uniform int pattern = 2; //  : hint_range(0, 2) diamond, circle, square 
uniform bool inside = false;
uniform vec2 number_of_images = vec2(1.0); // number of horizontal and vertical images in the sprite sheet

//P_NORMAL float size = CoronaVertexUserData.w;


//----------------------------------------------

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 image_top_left, vec2 image_bottom_right, sampler2D texture) {
  for (float i = -ceil(width); i <= ceil(width); i++) {
    float x = abs(i) > width ? width * sign(i) : i;
    float offset;
    
    if (pattern == 0) {
      offset = width - abs(x);
    } else if (pattern == 1) {
      offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
    } else if (pattern == 2) {
      offset = width;
    }
    
    for (float j = -ceil(offset); j <= ceil(offset); j++) {
      float y = abs(j) > offset ? offset * sign(j) : j;
      vec2 xy = uv + texture_pixel_size * vec2(x, y);
      
      if ((xy != clamp(xy, image_top_left, image_bottom_right) || texture2D(texture, xy).a <= 0.0) == inside) {
        return true;
      }
    }
  }
  
  return false;
}

//----------------------------------------------


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV );
    vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
    //sampler2D TEXTURE = texture2D(CoronaSampler0;

    //----------------------------------------------
      
    vec2 uv = UV;
    vec2 image_top_left = floor(uv * number_of_images) / number_of_images;
    vec2 image_bottom_right = image_top_left + vec2(1.0) / number_of_images;

    if (b_add_margins == 1) {
      vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0) * number_of_images);
      
      uv = (uv - texture_pixel_size * width - image_top_left) * TEXTURE_PIXEL_SIZE / texture_pixel_size + image_top_left;
      
      if (uv != clamp(uv, image_top_left, image_bottom_right)) {
        COLOR.a = 0.0;
      } else {
        COLOR = texture2D( CoronaSampler0, uv) ;
      }
    } else {
      COLOR = texture2D( CoronaSampler0, uv );
    }
    
    if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, CoronaSampler0)) {
      COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
      COLOR.a += (1.0 - COLOR.a) * color.a;
    }


    //----------------------------------------------
    return CoronaColorScale( COLOR );
}
]]
return kernel
-- graphics.defineEffect( kernel )





--[[

  shader_type canvas_item;

  uniform vec4 color : source_color = vec4(1.0);
  uniform float width : hint_range(0, 10) = 1.0;
  uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
  uniform bool inside = false;
  uniform bool add_margins = true; // only useful when inside is false
  uniform vec2 number_of_images = vec2(1.0); // number of horizontal and vertical images in the sprite sheet
  
  void vertex() {
    if (add_margins) {
      VERTEX += sign(VERTEX) * width; // replace sign(VERTEX) by (sign(VERTEX) * 2.0 - 1.0) if not Centered
    }
  }

  bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 image_top_left, vec2 image_bottom_right, sampler2D texture) {
    for (float i = -ceil(width); i <= ceil(width); i++) {
      float x = abs(i) > width ? width * sign(i) : i;
      float offset;
      
      if (pattern == 0) {
        offset = width - abs(x);
      } else if (pattern == 1) {
        offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
      } else if (pattern == 2) {
        offset = width;
      }
      
      for (float j = -ceil(offset); j <= ceil(offset); j++) {
        float y = abs(j) > offset ? offset * sign(j) : j;
        vec2 xy = uv + texture_pixel_size * vec2(x, y);
        
        if ((xy != clamp(xy, image_top_left, image_bottom_right) || texture(texture, xy).a <= 0.0) == inside) {
          return true;
        }
      }
    }
    
    return false;
  }

  void fragment() {
    vec2 uv = UV;
    vec2 image_top_left = floor(uv * number_of_images) / number_of_images;
    vec2 image_bottom_right = image_top_left + vec2(1.0) / number_of_images;

    if (add_margins) {
      vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0) * number_of_images);
      
      uv = (uv - texture_pixel_size * width - image_top_left) * TEXTURE_PIXEL_SIZE / texture_pixel_size + image_top_left;
      
      if (uv != clamp(uv, image_top_left, image_bottom_right)) {
        COLOR.a = 0.0;
      } else {
        COLOR = texture(TEXTURE, uv);
      }
    } else {
      COLOR = texture(TEXTURE, uv);
    }
    
    if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, TEXTURE)) {
      COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
      COLOR.a += (1.0 - COLOR.a) * color.a;
    }
  }


]]




