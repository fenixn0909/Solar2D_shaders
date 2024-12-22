local kernel = {}

kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "ray"
kernel.name = "holy"
kernel.isTimeDependent = true

kernel.uniformData = 
{
    {
        index = 0, -- u_UserData0
        type="mat4",
        name = "matAimC",
        paramName = {
            'Speed','Angle','Position','Spread',
            'Cutoff','Falloff','Edge_Fade','Seed',
            'Ray1_Density','Ray2_Density','Ray2_Intensity','none',
            'Col_R','Col_G','Col_B','Col_A',
        },
        default = {
          1.0, -.3, -.2, .5,
            .1, .2, .15, .50,
            8., 39., .3, 0,
            1., .9, .65, .8,
        },
        min = {
            0.0, 0.0, -2.0, -20.0,
            -20.0, 0.0, 0.0, -10.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        max = {
            10.0, 10.0, 2.0, 20.0,
            1.0, 5.0, 1.0, 10.0,
            10.0, 50.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
        },
        
    },
    
}

kernel.fragment =
[[
uniform mat4 u_UserData0;

float Speed = u_UserData0[0].x;     //1.0;
float Angle = u_UserData0[0].y;    //-0.3;
float Position = u_UserData0[0].z;   //-0.2;
float Spread = u_UserData0[0].w;       //0.5; // hint_range(0.0, 1.0)

float Cutoff = u_UserData0[1].x;       //0.1; //  hint_range(-1.0, 1.0)
float Falloff = u_UserData0[1].y;     //.2; // hint_range(0.0, 1.0)
float Edge_Fade = u_UserData0[1].z;    //.15; // hint_range(0.0, 1.0)
float Seed = u_UserData0[1].w;      //5.0;

float Ray1_Density = u_UserData0[2].x; //8.0;
float Ray2_Density = u_UserData0[2].y; //30.0;
float Ray2_Intensity = u_UserData0[2].z;   //0.3; // : hint_range(0.0, 1.0)

float Col_R = u_UserData0[3].x;
float Col_G = u_UserData0[3].y;
float Col_B = u_UserData0[3].z;
float Col_A = u_UserData0[3].w;

P_COLOR vec4 Col_lit = vec4(Col_R, Col_G, Col_B, Col_A); // : hint_Col_lit

bool hdr = false;

//----------------------------------------------
P_RANDOM float random( P_UV vec2 _uv) {
    return fract(sin(dot(_uv.xy,
            vec2(12.9898, 78.233))) * 43758.5453123);                       
}

//P_DEFAULT float noise (in vec2 uv) {
float noise (P_UV vec2 uv) {
    P_UV vec2 i = floor(uv);
    P_UV vec2 f = fract(uv);

    // Four corners in 2D of a tile
    P_DEFAULT float a = random(i);
    P_DEFAULT float b = random(i + vec2(1.0, 0.0));
    P_DEFAULT float c = random(i + vec2(0.0, 1.0));
    P_DEFAULT float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve. Same as SmoothStep()
    P_UV vec2 u = f * f * (3.0-2.0 * f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

mat2 rotate( P_DEFAULT float _angle){
    return mat2(vec2(cos(_angle), -sin(_angle)),
                vec2(sin(_angle), cos(_angle)));
}

vec4 screen( P_DEFAULT vec4 base, P_DEFAULT vec4 blend){
  return 1.0 - (1.0 - base) * (1.0 - blend);
}

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    // Rotate, skew and move the UVs
    P_UV vec2 UV = texCoord;
    P_DEFAULT float TIME = CoronaTotalTime;

    P_UV vec2 transformed_uv = ( rotate(Angle) * (UV - Position) )  / ( (UV.y + Spread) - (UV.y * Spread) );

    // Animate the ray according the the new transformed UVs
    P_UV vec2 ray1 = vec2(transformed_uv.x * Ray1_Density + sin(TIME * 0.1 * Speed) * (Ray1_Density * 0.2) + Seed, 1.0);
    P_UV vec2 ray2 = vec2(transformed_uv.x * Ray2_Density + sin(TIME * 0.2 * Speed) * (Ray1_Density * 0.2) + Seed, 1.0);

    // Cut off the ray's edges
    P_DEFAULT float cut = step(Cutoff, transformed_uv.x) * step(Cutoff, 1.0 - transformed_uv.x);
    ray1 *= cut;
    ray2 *= cut;

    // Apply the noise pattern (i.e. create the rays)
    P_DEFAULT float rays;

    if (hdr){
    // This is not really HDR, but check this to not clamp the two merged rays making 
    // their values go over 1.0. Can make for some nice effect
    rays = noise(ray1) + (noise(ray2) * Ray2_Intensity);
    }
    else{
     rays = clamp(noise(ray1) + (noise(ray2) * Ray2_Intensity), 0., 1.);
    }

    // Fade out edges
    rays *= smoothstep(0.0, Falloff, (1.0 - UV.y)); // Bottom
    rays *= smoothstep(0.0 + Cutoff, Edge_Fade + Cutoff, transformed_uv.x); // Left
    rays *= smoothstep(0.0 + Cutoff, Edge_Fade + Cutoff, 1.0 - transformed_uv.x); // Right

    // Color to the rays
    P_COLOR vec3 shine = vec3(rays) * Col_lit.rgb;

    // Try different blending modes for a nicer effect. "Screen" is included in the code,
    // but take a look at https://godotshaders.com/snippet/blending-modes/ for more.
    // With "Screen" blend mode:

    //shine = screen(texture(SCREEN_TEXTURE, SCREEN_UV), vec4(Col_lit)).rgb;

    P_COLOR vec4 COLOR = vec4(shine, rays * Col_lit.a);

    //----------------------------------------------

    // Fade by Alpha
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale(COLOR);
}




]]

return kernel


--[[




void fragment()
{
  
  
}
--]]
