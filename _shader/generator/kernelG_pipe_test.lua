 
--[[
    Test for mixing shaders
    
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "pipe"
kernel.name = "test"

kernel.graph = 
{
        nodes = {
                horizontal      =       { effect= 'generator.cloud.motionPF', input1= 'paint1' },
                vertical        =       { effect= 'generator.FG.fancyBling', input1= 'horizontal' },
        },
        -- output =  'horizontal',
        output =  'vertical',
}

return kernel


