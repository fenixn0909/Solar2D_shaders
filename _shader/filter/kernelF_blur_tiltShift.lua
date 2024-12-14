
--[[
  
  Origin Author: ChaffDev
  https://godotshaders.com/shader/tilt-shift-shader/
  
  So when I was playing Link’s Awaking on switch I looked at the tilt shift effect, I knew I had to put this fun game down, jump into godot and start writing a shader to do the exact same thing. Because I love fun. And I couldn’t think of anything more fun then a shader.
   
  There are three variables that you can use to make the tilt shift effect.
   
  Blur: To control the blur intensity
   
  Limit: To control the area that will be out of focus
   
  Intensity: To control the fall off of the effect. Best kept closer to the limit.
   
  There’s also a debug variable that you can use to dial in the settings.
   
  Why would you need something like this?
   
  Well Godot has built in DOF blur for near and far but on certail angles this is not useful for producing the same look. DOF far might still work but near specifically blurs things close to camera so on a top down angle it won’t really work. In 3d at the angle I am using I use DOF far but have this shader on the lower part of the screen to simulate something closer to link’s awaking.
   
  Then there’s 2d applications for this shader. If you’re making a city builder or some world map. Maybe it could be useful.

--]]

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur"
kernel.name = "tiltShift"

kernel.vertexData =
{
  {
    name = "intensity",
    default = 0,
    min = 0,
    max = 1,
    index = 0, -- v_UserData.x
  },
}

kernel.isTimeDependent = true


kernel.fragment =
[[
P_COLOR vec3 tweener = vec3(1);
//----------------------------------------------

float limit = 0.3; //: hint_range(0.0,0.5) 
float blur = 5; //: hint_range(0.0,5.0)
float intensity = 0.28; //: hint_range (0.0, 0.28, 0.5)
vec4 colorDB = vec4( 0.9, 0.5, 0.5, 1);
uniform bool debug = true;



//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_UV vec2 SCREEN_UV = texCoord;
  P_COLOR vec4 COLOR;
  P_DEFAULT float TIME = CoronaTotalTime;
  //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) + 0.35;
  intensity = sin(CoronaTotalTime);
  intensity = 0.28;
  //strength = 0.6;
  //----------------------------------------------
  if (UV.y<limit){ 
        
      float _step = smoothstep(UV.y,limit,intensity);
      vec4 color = texture2D(CoronaSampler0, SCREEN_UV, blur);
      COLOR = color;
      
      if (debug==true){
        //COLOR = vec4(1.0,1.0,1.0,1.0);
        COLOR = colorDB;
      }
        
      COLOR.a = _step ;

      
    } else if (UV.y > 1.0-limit) {
        
      float _step = smoothstep(UV.y,1.0-limit,1.0-intensity) ;
      vec4 color = texture2D(CoronaSampler0, SCREEN_UV, blur);
      COLOR = color;
      
      if (debug==true){
        //COLOR = vec4(1.0,1.0,1.0,1.0);
        COLOR = colorDB;
      }
      COLOR.a = _step;
        
    }else{
        COLOR.a = 0; 

    }


  //----------------------------------------------
  COLOR.rgb *= COLOR.a;
  //COLOR = texture2D(CoronaSampler0, SCREEN_UV, blur);

  return CoronaColorScale( COLOR );
}
]]

return kernel