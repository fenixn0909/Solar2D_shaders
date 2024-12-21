local kernel = {}

kernel.language = "glsl"

kernel.category = "filter"
kernel.group = "deform"
kernel.name = "perspective"

kernel.isTimeDependent = true

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Ratio",      default = 0.5, min = -15, max = 15, index = 0, },
} 

kernel.fragment =
[[

float Ratio = CoronaVertexUserData.x;
//----------------------------------------------

uniform sampler2D TEXTURE;

P_UV vec2 iResolution = 1.0 / CoronaTexelSize.zw;
P_COLOR vec4 COLOR = vec4(0);

//----------------------------------------------


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    vec2 fragCoord = UV * iResolution;
    
    //----------------------------------------------
    //Screen resolution
    vec2 res = iResolution.xy;
    //Pixel coordinates centered in the middle of the screen
    vec2 pos = fragCoord - res*0.5;
    //Perspective ratio
    
    //Compute uv coordinates with perspective ratio
    vec2 uv = pos / (res - pos * Ratio).y + 0.5;
    
    

    //Sample texture at uv coordinates
    COLOR = texture2D(TEXTURE,uv);
    
    /*
    vec2 grid = uv*5.0+0.5;
    vec2 stripe = abs(fract(grid)-.5);
    COLOR = vec4(res.y/2e2-.5*stripe / fwidth(grid), 0, 1);
    */
    //----------------------------------------------

    return CoronaColorScale(COLOR);


}
]]

return kernel





