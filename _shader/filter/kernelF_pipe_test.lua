 
--[[
    Test for mixing shaders
    
    ✳️ only using same category shader in nodes
    ✳️ only useful in filter kernels

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "pipe"
kernel.name = "test"

kernel.graph = 
{
        nodes = {
                first      =       { effect= 'filter.ripple.square', input1= 'paint1' },
                second     =       { effect= 'filter.FX.blackSpacePixel', input1= 'first' },
                third      =       { effect= 'filter.bright.coinGlint', input1= 'second' },
        },
        -- output =  'first',
        -- output =  'second',
        output =  'third',
}

return kernel


