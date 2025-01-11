
--[[
    https://www.shadertoy.com/view/Md2SR3

    
    // Note: Choose fThreshhold in the range [0.99, 0.9999].
    // Higher values (i.e., closer to one) yield a sparser starfield.

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "starField"

kernel.isTimeDependent = true


kernel.vertexData =
{
  { name = "Speed",     default = 2, min = -50, max = 50, index = 0, },
  { name = "Threshold",     default = 0.97, min = .9, max = 0.99999, index = 1, },
  { name = "Move_X",     default = 0.2, min = -3, max = 3, index = 2, },
  { name = "Move_Y",     default = -.06, min = -3, max = 3, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Threshold = CoronaVertexUserData.y;
float Move_X = CoronaVertexUserData.z;    // vec2(0,0.2): rise, vec2(1,-.1): left lines
float Move_Y = CoronaVertexUserData.w;
//----------------------------------------------

P_COLOR vec3 Col_BG = vec3( 0.1, 0.2, 0.4 );


//----------------------------------------------


float Noise2d( in vec2 x )
{
    float xhash = cos( x.x * 37.0 );
    float yhash = cos( x.y * 57.0 );
    return fract( 415.92653 * ( xhash + yhash ) );
}

// Convert Noise2d() into a "star field" by stomping everthing below fThreshhold to zero.
float NoisyStarField( in vec2 vSamplePos, float fThreshhold )
{
    float StarVal = Noise2d( vSamplePos );
    if ( StarVal >= fThreshhold )
        StarVal = pow( (StarVal - fThreshhold)/(1.0 - fThreshhold), 6.0 );
    else
        StarVal = 0.0;
    return StarVal;
}

// Stabilize NoisyStarField() by only sampling at integer values.
float StableStarField( in vec2 vSamplePos, float fThreshhold )
{
    // Linear interpolation between four samples.
    // Note: This approach has some visual artifacts.
    // There must be a better way to "anti alias" the star field.
    float fractX = fract( vSamplePos.x );
    float fractY = fract( vSamplePos.y );
    vec2 floorSample = floor( vSamplePos );    
    float v1 = NoisyStarField( floorSample, fThreshhold );
    float v2 = NoisyStarField( floorSample + vec2( 0.0, 1.0 ), fThreshhold );
    float v3 = NoisyStarField( floorSample + vec2( 1.0, 0.0 ), fThreshhold );
    float v4 = NoisyStarField( floorSample + vec2( 1.0, 1.0 ), fThreshhold );

    float StarVal =   v1 * ( 1.0 - fractX ) * ( 1.0 - fractY )
                    + v2 * ( 1.0 - fractX ) * fractY
                    + v3 * fractX * ( 1.0 - fractY )
                    + v4 * fractX * fractY;
    return StarVal;
}


//-----------------------------------------------
float iTime = CoronaTotalTime * Speed * 60;
P_COLOR vec4 COLOR = vec4(0);
P_UV vec2 iResolution = 1 / CoronaTexelSize.zw;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

    P_UV vec2 fragCoord = texCoord * iResolution;

    //----------------------------------------------

    vec3 vColor = Col_BG * fragCoord.y / iResolution.y;

    
    vec2 vSamplePos = fragCoord.xy + vec2( Move_X * float( iTime ), Move_Y * float( iTime ) );
    float StarVal = StableStarField( vSamplePos, Threshold );
    vColor += vec3( StarVal );
    
    COLOR = vec4(vColor, 1.0);                        

    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


