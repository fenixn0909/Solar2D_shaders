 
--[[
    Solar2D ShaderBank
    
    NOTE -
    ✳️ Noise Textures:   works only in Composite Mode.
    ✳️ Sprite Textures:  work as simply an imageRect in both Generator and Composite Mode.
    ✳️ You can apply specific shader for testing by calling "m.apply_specific_shader()", 
        just uncomment them and fill the filename after corresponding mode.


    KEYBOARD INPUT -
    ✳️ mC_nBKS:  how fast you like when tweaking ParamSliders by pressing Boost-Key

    left, right: cycling shaders.
    up, down: cycling menu pages. < Param(VertexData), Texture, Filename >
    1,2,3,4: go mode
    5,6,7,8: tweak ParamSlider1, 5 and 8 boost steps speed by "mC_nBKS" ... and so on
    y,u,i,o: tweak ParamSlider2
    h,j,k,l: tweak ParamSlider3
    n,m, ',' , '.' : tweak ParamSlider4
    You could change the keycode on "Input" section to fit your keyboard layout.
    

    RESOURCE - 
    ✳️ You could add your own image resources for testing by modifying the "mC_aaImgFN" table,
        keep the filename short to prevent mess up the layout.
    
    Images using in the project are generated by Microsoft Bing Image Creator
                                            Creator: phoenixongogo, 2024 Dec.       License: MIT         
]]

----------------------------------------------------------------------------------------------------
-- Hard Coded Referance
----------------------------------------------------------------------------------------------------
local mC_pthFldr = "_img/"
local mC_akCate = { 'Generator', 'Filter', 'F_Trans', 'Composite' }

local mC_aaImgFN = {
    { "BG1.jpeg","BG2.jpeg","BG3.jpeg","BG4.jpeg","BG5.jpeg"},
    { "SPR1.png","SPR2.png","SPR3.png","SPR4.png","SPR5.png","NOZ1.jpeg","NOZ2.jpeg","NOZ3.jpeg","NOZ4.jpeg","NOZ5.jpeg"},
    { "NOZ1.jpeg","NOZ2.jpeg","NOZ3.jpeg","NOZ4.jpeg","NOZ5.jpeg"},
}

local mC_nBKS = 5     -- Boost-Key Step Scale
local mC_pthG = "_shader/generator/"
local mC_pthF = "_shader/filter/"
local mC_pthT = "_shader/filter_trans/"
local mC_pthC = "_shader/composite/"
----------------------------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "textureWrapX", "repeat" )
display.setDefault( "textureWrapY", "repeat" )
----------------------------------------------------------------------------------------------------
local shdilr = require( "_plugin.shdilr" )
local widget = require( "widget" )
widget.setTheme( "widget_theme_android_holo_light" ) -- 'widget_theme_android_holo_dark', 'widget_theme_ios7'
----------------------------------------------------------------------------------------------------
local m_abs = math.abs
local SCRN_DCX, SCRN_DCY = display.contentCenterX, display.contentCenterY
local SCRN_DT,SCRN_DB,SCRN_DL,SCRN_DR = display.screenOriginY,display.contentHeight-display.screenOriginY,display.screenOriginX,display.contentWidth-display.screenOriginX
local SCRN_DSOX,SCRN_DSOY = display.safeScreenOriginX,display.safeScreenOriginY; -- print("DSOX,DSOY = ",DSOX,DSOY) -- YX for Orientation Reason

----------------------------------------------------------------------------------------------------
local toggle_visible = function( b_, ... ) for i=1,#arg do    arg[i].isVisible = b_ end end
local a_val2ind = function( a_, k_ ) for i=1, #a_ do    if a_[i] == k_ then return i     end end end    --@Array Value to Index 
local _lfs = require( "lfs" )
local s_match = string.match
local file_get_match_sub = function( sPth_, sPtrn_, sTrim_ ) --@strPath, @strPattern
    local _path = system.pathForFile( sPth_, system.ResourceDirectory )
    local _a = {}
    for file in _lfs.dir( _path ) do  
        if file:match( sPtrn_ ) then    _a[#_a+1] = file:gsub( sTrim_, "" )     end
    end
return _a    end
----------------------------------------------------------------------------------------------------
--=== Image
local mtiPage = { pgPrama= 1, pgTexture= 2, pgFile= 3 }

--=== Image
local maoImage = {} -- 1:Background, 2:Sprite, 3:Noise
local maiImgCur = { 0, 0, 1 } -- Note for ERROR prevention: DON'T mess it up!   1:Background, 2:Sprite, 3:Noise

--=== Shader Data
local maShdrVD_cur      

--=== Management
local miCateCur = 1
local mkCateCur = mC_akCate[ miCateCur ]
local miSwitchCur = 1

--=== UI
local moSegCon
local moPckrWhl

local mtoText = {}
local maoSlider = {}
local maoSwitch = {}
local maoButton = {}


--=== Group
local maoGrp = {}

----------------------------------------------------------------------------------------------------

local M,m,mm,mtFn,mLstnr = {},{},{},{},{}
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Public
----------------------------------------------------------------------------------------------------

M.startup = function()  -- Calls only once
    

    local _aList
    _aList = file_get_match_sub( mC_pthG, '^%a.*', '.lua' )
    shdilr.load_list( mC_pthG:gsub('%/','%.'), _aList, 1 )
    _aList = file_get_match_sub( mC_pthF, '^%a.*', '.lua' )
    shdilr.load_list( mC_pthF:gsub('%/','%.'), _aList, 2 )
    _aList = file_get_match_sub( mC_pthT, '^%a.*', '.lua' )
    shdilr.load_list( mC_pthT:gsub('%/','%.'), _aList, 3 )
    _aList = file_get_match_sub( mC_pthC, '^%a.*', '.lua' )
    shdilr.load_list( mC_pthC:gsub('%/','%.'), _aList, 4 )

    Runtime:addEventListener( "key", mLstnr.onEvent_Key )

    
end


M.init = function()
    
    maoGrp = {}
    --=== Init Group
    -- 0:rootUI, 1:pageMain, 2:pageParam, 3:pageTexture, 4:imgBG, 5:imgSpr, 6:imgNoise
    for i=0,6 do
        maoGrp[i] = display.newGroup()
        if i>0 then maoGrp[0]:insert( maoGrp[i] ) end
    end

    --=== RootUI
    m.upd_img( 1, 1 )
    m.upd_img( 2, 1 )

    m.init_switch( maoGrp[0], maoSwitch, mLstnr.aPage_switch ) -- Page Change
    moSegCon = m.new_segCon( maoGrp[0], mLstnr.segCon, mC_akCate ) -- Shader Category

    --=== Page: Param
    m.init_param_text( maoGrp[1], mtoText )
    m.init_slider( maoGrp[1], maoSlider, mLstnr.aVD_slider )
    --=== Page: Texture
    moPckrWhl = m.initNew_wheel( maoGrp[2], mLstnr.pickerWheel )
    --=== Page: Filename, Shift Button
    m.init_file_text( maoGrp[3], mtoText )
    m.init_menu_button( maoGrp[3], maoButton, mLstnr.aFile_botton )

    --=== Hide Groups
    toggle_visible( false, maoGrp[2], maoGrp[3])

    --=== Apply Shader Or ......
    m.apply_bank_shader()

    --=== Apply Specific Shader by Category and Filename
    -- m.apply_specific_shader( mC_akCate[1], 'kernelG_BG_electricHatch' )
    -- m.apply_specific_shader( mC_akCate[1], 'kernelG_BG_starFall' )
    m.apply_specific_shader( mC_akCate[1], 'kernelG_FX_simpleSpiralsDemo' )
    -- m.apply_specific_shader( mC_akCate[2], 'kernelF_deform_vortexOverlay' )
    -- m.apply_specific_shader( mC_akCate[2], 'kernelF_deform_perspective' )
    -- m.apply_specific_shader( mC_akCate[3], 'kernelF_trans_rippleBurnOut' )
    -- m.apply_specific_shader( mC_akCate[4], 'kernelC_wobble_ripple' )
    
    ----------------------------------------------------------------------------------------------------

end

----------------------------------------------------------------------------------------------------
-- Initiation
----------------------------------------------------------------------------------------------------

--=== File Text
m.init_file_text = function( grp_, toText_ )
    local _bX = SCRN_DL + 8
    local _bY = SCRN_DSOY+320 + 50
    local _dY = 25
    local _toText = {}
    -- toText_.filename =  display.newText{ align= 'left', x= _bX, y= _bY , fontSize= 16, text= '', font=  native.systemFont };  toText_.filename.anchorX = 0
    -- toText_.kernal =  display.newText{ align= 'left', x= _bX, y= _bY+_dY, fontSize= 16, text= '', font=  native.systemFont };  toText_.kernal.anchorX = 0
    
    toText_.filename =  native.newTextField( _bX, _bY, 270, 20);        toText_.filename.anchorX = 0  
    toText_.kernal =    native.newTextField( _bX, _bY+_dY, 270, 20 );   toText_.kernal.anchorX = 0  

    grp_:insert( toText_.filename )
    grp_:insert( toText_.kernal )
end

--=== Param Text
m.init_param_text = function( grp_, toText_ )
    local _vDbY = SCRN_DB - 16
    local _vDdY = -32
    local _vDbX = SCRN_DL + 4
    local _vDdX = 120

    toText_.tVD_name = {}
    toText_.tVD_float = {}

    for i=4,1,-1 do
        toText_.tVD_name[i] =   display.newText{ align= 'left', x= _vDbX, y= _vDbY + _vDdY*m_abs(i-4),        fontSize= 16, text= 'name', font=  native.systemFont };  toText_.tVD_name[i].anchorX = 0
        toText_.tVD_float[i] =  display.newText{ align= 'left', x= SCRN_DL+_vDdX, y= _vDbY + _vDdY*m_abs(i-4),  fontSize= 16, text= 'flaot', font=  native.systemFont };  toText_.tVD_float[i].anchorX = 0
        grp_:insert( toText_.tVD_name[i] )
        grp_:insert( toText_.tVD_float[i] )
    end
end

--=== Slider
m.init_slider = function( grp_, aoSlider_, aLstnr_ )
    local _bX = SCRN_DR - 108
    local _bY = SCRN_DB - 16
    local _dY = -32
    for i=4,1,-1 do
        aoSlider_[i] = widget.newSlider({
            x= _bX, y= _bY+_dY*m_abs(i-4), width = 100, listener = aLstnr_[i],
            value= 0,  -- Start slider at 10% (optional)
        })
        grp_:insert( aoSlider_[i] )
    end
end

--=== Switch
m.init_switch = function( grp_, aoSwitch_, aLstnr_ )
    local _bX, _bY = SCRN_DR-24, SCRN_DB-24
    local _dY = -40
    for i=1,3 do
        aoSwitch_[i] = widget.newSwitch {
            style= "radio", id= "Page "..i,
            initialSwitchState= i==1 ,
            -- onPress= mLstnr.aPage_switch[i],
            onPress= aLstnr_[i],
        }
        aoSwitch_[i].x, aoSwitch_[i].y = _bX, _bY +_dY*(3-i)
        grp_:insert( aoSwitch_[i] )
    end
end

--=== SegmentControl
m.new_segCon = function( grp_, lstnr_, akCate_ )
    local _oSegCon = widget.newSegmentedControl {
        left= 0  , top= SCRN_DSOY, segmentWidth= 80,
        segments= akCate_,
        defaultSegment= 1,
        onPress= lstnr_
    }
    grp_:insert( _oSegCon )
return _oSegCon    end

--=== Button
m.init_menu_button = function( grp_, aoButton_, aLstnr_ )
    local _bX, _bY = SCRN_DL+74, SCRN_DB-40
    local _dX = 140
    local _aTxt = { 'Prev', 'Next'}
    for i=1,2 do
        aoButton_[i] = widget.newButton({
            label= _aTxt[i], id= "onEvent", shape= "roundedRect",
            x= _bX + _dX*(i-1), y= _bY ,
            width= 108, height= 52,
            fontSize= 25, -- font= appFont,
            fillColor= { default={ 0.3,0.5,0.8,1 }, over={ 0.7,0.8,0.9,1 } },
            labelColor= { default={ 1,1,1,1 }, over={ 1,0.8,0.2,0.8 } },
            onEvent= aLstnr_[i],  -- Use "onEvent" listener type
        })
        grp_:insert( aoButton_[i] )
    end
end

--=== PickWheel
m.initNew_wheel = function( grp_, lstnr_ )
    local _dColumn = { 
        { align= "center", width= 90, startIndex= 1, labels= mC_aaImgFN[1] },
        { align= "center", width= 90, startIndex= 1, labels= mC_aaImgFN[2] },
        { align= "center", width= 90, startIndex= 1, labels= mC_aaImgFN[3] },
    }

    local _oPickWhl = widget.newPickerWheel {
        left= SCRN_DL,
        top= SCRN_DB - 148, 
        columnColor = { 0.1, 0.1, 0.1 }, columns= _dColumn,

        width= 270, height= 120, rowHeight= 32,
        fontColorSelected = { 1, 1, 1 },
        fontColor= { 0.65, 0.65, 0.65 }, fontSize= 18,
        
        style= 'resizable',
        onValueSelected= lstnr_
    }
    grp_:insert( _oPickWhl )
return _oPickWhl    end

----------------------------------------------------------------------------------------------------
-- Apply Shader
----------------------------------------------------------------------------------------------------

m.apply_specific_shader = function( kC_, kN_ )  -- @keyCategory, @keyFileName

    local _iC = a_val2ind( mC_akCate, kC_ )    assert(_iC, "not found key in mC_akCate, key: "..kC_)  
    mkCateCur = kC_
    miCateCur = _iC
    moSegCon:setActiveSegment( _iC )
    shdilr.bank_set_union( _iC )
    shdilr.bank_set_iBF_byKey( kN_ )

    m.apply_bank_shader()
end

m.apply_bank_shader = function()
    maShdrVD_cur = shdilr.bank_get_dVertext() or {}
    --=== Apply Text
    m.upd_text( maShdrVD_cur, mtoText )
    --=== Apply Shader
    mm.set_composite_fill()
    shdilr:bank_apply( maoImage[2], {} )
end

mm.set_composite_fill = function()
    if miCateCur == 4 then
        local _pth1 = mC_pthFldr..mC_aaImgFN[2][ maiImgCur[2] ]
        local _pth2 = mC_pthFldr..mC_aaImgFN[3][ maiImgCur[3] ]
        shdilr.set_comp_fill( maoImage[2], _pth1, _pth2 )
    end
end

----------------------------------------------------------------------------------------------------
-- Update
----------------------------------------------------------------------------------------------------

m.upd_text = function( d_, toText_ )

    local _aVD = d_
    toText_.kernal.text = shdilr.bank_get_kernal()
    toText_.filename.text = shdilr.bank_get_fileName()

    for i=1,4 do
        toggle_visible( false, toText_.tVD_name[i], toText_.tVD_float[i], maoSlider[i] )
        if _aVD[i] then 
            toText_.tVD_name[i].text = _aVD[i].name
            toText_.tVD_float[i].text = _aVD[i].default
            toggle_visible( true, toText_.tVD_name[i], toText_.tVD_float[i], maoSlider[i] )
            mm.slider_value_to_percent( i, _aVD[i].default )
        end
    end
end

m.upd_img = function( iT_, iI_ ) --@indexType, @indexImage

    if iI_ == maiImgCur[iT_] then return    end
    if iT_ == 3  then    if miCateCur ~= 4 then return end  -- Upd Noise only in composite mode
        mm.set_composite_fill()    
        shdilr:bank_apply( maoImage[2], {} ) -- Apply Shader: when Noise changed
        maiImgCur[iT_] = iI_
    return true    end

    local _sizeWH = 320
    maiImgCur[iT_] = iI_
    if maoImage[iT_] then maoImage[iT_].parent:remove( maoImage[iT_] ) end
    maoImage[iT_] = display.newImageRect( maoGrp[3+iT_], mC_pthFldr..mC_aaImgFN[iT_][iI_], _sizeWH, _sizeWH ); maoImage[iT_]:translate( SCRN_DCX, SCRN_DSOY + _sizeWH*.5+32 );
    
    -- Apply Shader: when Sprite changed
    if iT_ == 2 then    shdilr:bank_apply( maoImage[2], {} ) end

return true    end


----------------------------------------------------------------------------------------------------
-- Auxiliary
----------------------------------------------------------------------------------------------------

mm.slider_value_to_percent = function( i_, fV_ ) --@Index, @fValue
    local _tVD = maShdrVD_cur[i_]
    local _fTick = (_tVD.max - _tVD.min) / 100
    local _percent = (fV_-_tVD.min) / _fTick
    maoSlider[ i_ ]:setValue( _percent )
end

mm.slider_percent_to_value = function( i_, fV_ ) --@Index, @fPercentage
    local _tVD = maShdrVD_cur[i_]   if not _tVD then     return end
    local _fTick = (_tVD.max - _tVD.min) / 100
    local _value = fV_ * _fTick + _tVD.min
    mtoText.tVD_float[i_].text = _value
    shdilr.sync_param( maoImage[2], { [_tVD.name]= _value } )
end

----------------------------------------------------------------------------------------------------
-- Listener
----------------------------------------------------------------------------------------------------

mLstnr.aVD_slider = {}
for i=1,4 do    mLstnr.aVD_slider[i] = function( e_ ) mm.slider_percent_to_value( i, e_.value )     end end -- print( "Slider "..i.. "at " .. e_.value .. "%" )

mLstnr.aPage_switch = {}
for i=1,3 do    mLstnr.aPage_switch[i] = function( e_ ) mm.trig_switch(i)     end end -- print("e_.target.id: "..e_.target.id)

mLstnr.aFile_botton = {}
for i=1,2 do    mLstnr.aFile_botton[i] = function( e_ )
    if ( "ended" == e_.phase ) then     -- or "cancelled" == e_.phase
        if i==1 then mtFn.iptU['left']() end
        if i==2 then mtFn.iptU['right']() end
    end
end end

mLstnr.segCon = function( e_ )
    local _nSN = e_.target.segmentNumber
    if mkCateCur == mC_akCate[ _nSN ] then return    end
    mkCateCur = mC_akCate[ _nSN ]
    miCateCur = _nSN
    -- print("mkCateCur: "..mkCateCur)

    shdilr.bank_set_union( _nSN )
    m.apply_bank_shader()
end

mLstnr.pickerWheel = function( e_ )   -- e_:{ column = 3, row = 21 }
    local _iT, _iI = e_.column, e_.row     --@indImgType, @indImage
    m.upd_img( _iT, _iI )
end

mLstnr.onEvent_Key = function( e_ )
    if      (e_.phase == "up") then    if mtFn.iptU[ e_.keyName ] then     mtFn.iptU[ e_.keyName ]() end
    elseif  (e_.phase == "down") then  if mtFn.iptD[ e_.keyName ] then     mtFn.iptD[ e_.keyName ]() end
    end
end

----------------------------------------------------------------------------------------------------
-- Input
----------------------------------------------------------------------------------------------------

mtFn.iptU, mtFn.iptD = {},{}

mtFn.iptD['1'] = function() mm.go_mode(1) end    --=== Go Mode 1
mtFn.iptD['2'] = function() mm.go_mode(2) end    --=== Go Mode 2
mtFn.iptD['3'] = function() mm.go_mode(3) end    --=== Go Mode 3
mtFn.iptD['4'] = function() mm.go_mode(4) end    --=== Go Mode 4

mtFn.iptU['left'] = function() mm.swap_shader(1) end     --=== Prev Shader
mtFn.iptU['right'] = function() mm.swap_shader(2) end    --=== Next Shader
mtFn.iptU['up'] = function()   mm.swap_menu'-' end     --=== Prev Page
mtFn.iptU['down'] = function() mm.swap_menu'+' end     --=== Next Shader

mtFn.iptU['w'] = function() mm.swap_img('prev',1) end    --=== Prev Background
mtFn.iptU['s'] = function() mm.swap_img('next',1) end    --=== Next Background
mtFn.iptU['e'] = function() mm.swap_img('prev',2) end    --=== Prev Sprite
mtFn.iptU['d'] = function() mm.swap_img('next',2) end    --=== Next Sprite
mtFn.iptU['r'] = function() mm.swap_img('prev',3) end    --=== Prev Noise
mtFn.iptU['f'] = function() mm.swap_img('next',3) end    --=== Next Noise

local B = mC_nBKS
mtFn.iptD['6'] = function() mm.tweak_slider('-',1,B) end    --=== Decrease Param 1 Boost
mtFn.iptD['7'] = function() mm.tweak_slider('-',1,1) end    --=== Decrease Param 1 
mtFn.iptD['8'] = function() mm.tweak_slider('+',1,1) end    --=== Increase Param 1
mtFn.iptD['9'] = function() mm.tweak_slider('+',1,B) end    --=== Increase Param 1 Boost
mtFn.iptD['y'] = function() mm.tweak_slider('-',2,B) end    --=== Decrease Param 2 Boost
mtFn.iptD['u'] = function() mm.tweak_slider('-',2,1) end    --=== Decrease Param 2 
mtFn.iptD['i'] = function() mm.tweak_slider('+',2,1) end    --=== Increase Param 2
mtFn.iptD['o'] = function() mm.tweak_slider('+',2,B) end    --=== Increase Param 2 Boost
mtFn.iptD['h'] = function() mm.tweak_slider('-',3,B) end    --=== Decrease Param 3 Boost
mtFn.iptD['j'] = function() mm.tweak_slider('-',3,1) end    --=== Decrease Param 3 
mtFn.iptD['k'] = function() mm.tweak_slider('+',3,1) end    --=== Increase Param 3
mtFn.iptD['l'] = function() mm.tweak_slider('+',3,B) end    --=== Increase Param 3 Boost
mtFn.iptD['n'] = function() mm.tweak_slider('-',4,B) end    --=== Decrease Param 4 Boost
mtFn.iptD['m'] = function() mm.tweak_slider('-',4,1) end    --=== Decrease Param 4 
mtFn.iptD[','] = function() mm.tweak_slider('+',4,1) end    --=== Increase Param 4
mtFn.iptD['.'] = function() mm.tweak_slider('+',4,B) end    --=== Increase Param 4 Boost


mm.go_mode = function( i_ )
    moSegCon:setActiveSegment(i_)
    mLstnr.segCon{target={segmentNumber= i_}}--  {target={segmentNumber= i_}} e_.target.segmentNumber
end
mm.swap_shader = function( i_ )    local _akOpt = {'bank_prev','bank_next'}     assert(_akOpt[i_], 'invalid ind: '..i_)
    shdilr[_akOpt[i_]]()
    shdilr.bank_print_dbInfo()
    m.apply_bank_shader()
end
mm.swap_menu = function( k_ )    local _iNew    assert( (k_=='+' or k_=='-'), "invalid key: "..k_)
    if k_ == '-' then    _iNew = miSwitchCur-1 == 0 and #maoSwitch or miSwitchCur-1    elseif k_ == '+' then _iNew = miSwitchCur+1 > #maoSwitch and 1 or miSwitchCur+1     end;
    mm.trig_switch(_iNew)
end
mm.trig_switch = function( i_ )
    toggle_visible( false, maoGrp[1], maoGrp[2], maoGrp[3], mtoText.filename, mtoText.kernal);    maoGrp[i_].isVisible = true
    if i_ == mtiPage['pgFile'] then toggle_visible(true, mtoText.filename, mtoText.kernal) end
    miSwitchCur = i_;    maoSwitch[i_]:setState({ isOn= true })
end
mm.swap_img = function( k_, i_ )    local _iNew     --@keyOpt, @indImgType
    if k_ == 'prev' then _iNew = maiImgCur[i_]-1 < 1 and  #mC_aaImgFN[i_] or maiImgCur[i_]-1    elseif k_ == 'next' then _iNew = maiImgCur[i_]+1 > #mC_aaImgFN[i_] and 1 or maiImgCur[i_]+1    end; assert(_iNew,'invalid key: '..k_)
    if m.upd_img( i_, _iNew ) then moPckrWhl:selectValue( i_, _iNew, false ) end
end
mm.tweak_slider = function( k_, i_, n_ )    assert( (k_=='+' or k_=='-'), "invalid key: "..k_)  --@keyOpt, @indSlider, @numVolume
    local _v = maoSlider[i_].value
    if k_ == '-' then _v = _v-n_    elseif k_ == '+' then _v = _v+n_    end
    _v = _v < 0 and 0 or _v;    _v = _v > 100 and 100 or _v     -- Clamp 0~100
    maoSlider[i_]:setValue( _v )
    mm.slider_percent_to_value( i_, _v )
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

M.startup()
M.init()



----------------------------------------------------------------------------------------------------

return M

