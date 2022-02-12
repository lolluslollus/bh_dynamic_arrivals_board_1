local constants = require('lolloArrivalsDeparturesPredictor.constants')
local stringUtils = require('lolloArrivalsDeparturesPredictor.stringUtils')

local _dynamicOnOffButtonId = 'lollo_arrivals_departures_predictor_dynamic_on_off_button'
local _stationPickerWindowId = 'lollo_arrivals_departures_predictor_picker_window'
local _warningWindowWithMessageId = 'lollo_arrivals_departures_predictor_warning_window_with_message'

local _texts = {
    dynamicOff = _('DynamicDisplaysOff'),
    dynamicOn = _('DynamicDisplaysOn'),
    goBack = _('GoBack'),
    goThere = _('GoThere'), -- cannot put this directly inside the loop for some reason
    join = _('Join'),
    stationPickerWindowTitle = _('StationPickerWindowTitle'),
    warningWindowTitle = _('WarningWindowTitle'),
}

local _windowXShift = -200

local utils = {
    moveCamera = function(position)
        local cameraData = game.gui.getCamera()
        game.gui.setCamera({position[1], position[2], cameraData[3], cameraData[4], cameraData[5]})
    end,
    modifyOnOffButtonLayout = function(layout, isOn)
        local img = nil
        if isOn then
            -- img = api.gui.comp.ImageView.new('ui/design/components/checkbox_valid.tga')
            img = api.gui.comp.ImageView.new('ui/lolloArrivalsDeparturesPredictor/checkbox_valid.tga')
            img:setTooltip(_texts.dynamicOn)
            layout:addItem(img, api.gui.util.Alignment.HORIZONTAL, api.gui.util.Alignment.VERTICAL)
            -- layout:addItem(api.gui.comp.TextView.new(_texts.dynamicOn), api.gui.util.Alignment.HORIZONTAL, api.gui.util.Alignment.VERTICAL)
        else
            img = api.gui.comp.ImageView.new('ui/lolloArrivalsDeparturesPredictor/checkbox_invalid.tga')
            img:setTooltip(_texts.dynamicOff)
            layout:addItem(img, api.gui.util.Alignment.HORIZONTAL, api.gui.util.Alignment.VERTICAL)
            -- layout:addItem(api.gui.comp.TextView.new(_texts.dynamicOff), api.gui.util.Alignment.HORIZONTAL, api.gui.util.Alignment.VERTICAL)
        end
    end
}

local guiHelpers = {
    showNearbyStationPicker = function(isTheNewObjectCargo, stationCons, tentativeStationConId, joinCallback)
        -- print('showNearbyStationPicker starting')
        local layout = api.gui.layout.BoxLayout.new('VERTICAL')
        local window = api.gui.util.getById(_stationPickerWindowId)
        if window == nil then
            window = api.gui.comp.Window.new(_texts.stationPickerWindowTitle, layout)
            window:setId(_stationPickerWindowId)
        else
            window:setContent(layout)
            window:setVisible(true, false)
        end

        local function addJoinButtons()
            if type(stationCons) ~= 'table' then return end

            local components = {}
            for _, stationCon in pairs(stationCons) do
                local name = api.gui.comp.TextView.new(stationCon.uiName or stationCon.name or '')
                local cargoIcon = stationCon.isCargo
                    and api.gui.comp.ImageView.new('ui/icons/construction-menu/category_cargo.tga')
                    or api.gui.comp.TextView.new('')
                local passengerIcon = stationCon.isPassenger
                    and api.gui.comp.ImageView.new('ui/icons/construction-menu/category_passengers.tga')
                    or api.gui.comp.TextView.new('')

                local gotoButtonLayout = api.gui.layout.BoxLayout.new('HORIZONTAL')
                gotoButtonLayout:addItem(api.gui.comp.ImageView.new('ui/design/window-content/locate_small.tga'))
                gotoButtonLayout:addItem(api.gui.comp.TextView.new(_texts.goThere))
                local gotoButton = api.gui.comp.Button.new(gotoButtonLayout, true)
                gotoButton:onClick(
                    function()
                        utils.moveCamera(stationCon.position)
                        -- game.gui.setCamera({con.position[1], con.position[2], 100, 0, 0})
                    end
                )

                local joinButtonLayout = api.gui.layout.BoxLayout.new('HORIZONTAL')
                joinButtonLayout:addItem(api.gui.comp.ImageView.new('ui/design/components/checkbox_valid.tga'))
                joinButtonLayout:addItem(api.gui.comp.TextView.new(_texts.join))
                local joinButton = api.gui.comp.Button.new(joinButtonLayout, true)
                joinButton:onClick(
                    function()
                        if type(joinCallback) == 'function' then joinCallback(stationCon.id) end
                        window:setVisible(false, false)
                    end
                )
                if stationCon.id == tentativeStationConId then
                    joinButton:setEnabled(false)
                end

                components[#components + 1] = {name, cargoIcon, passengerIcon, gotoButton, joinButton}
            end

            if #components > 0 then
                local guiStationsTable = api.gui.comp.Table.new(#components, 'NONE')
                guiStationsTable:setNumCols(5)
                for _, value in pairs(components) do
                    guiStationsTable:addRow(value)
                end
                layout:addItem(guiStationsTable)
            end
        end

        addJoinButtons()

        -- window:setHighlighted(true)
        local position = api.gui.util.getMouseScreenPos()
        window:setPosition(position.x + _windowXShift, position.y)
        window:onClose(
            function()
                window:setVisible(false, false)
            end
        )
    end,
    showWarningWindowWithMessage = function(text)
        local layout = api.gui.layout.BoxLayout.new('VERTICAL')
        local window = api.gui.util.getById(_warningWindowWithMessageId)
        if window == nil then
            window = api.gui.comp.Window.new(_texts.warningWindowTitle, layout)
            window:setId(_warningWindowWithMessageId)
        else
            window:setContent(layout)
            window:setVisible(true, false)
        end

        layout:addItem(api.gui.comp.TextView.new(text))

        window:setHighlighted(true)
        local position = api.gui.util.getMouseScreenPos()
        window:setPosition(position.x + _windowXShift, position.y)
        -- window:addHideOnCloseHandler()
        window:onClose(
            function()
                window:setVisible(false, false)
            end
        )
    end,
    initNotausButton = function(isDynamicOn, funcOfBool)
        if api.gui.util.getById(_dynamicOnOffButtonId) then return end

        local buttonLayout = api.gui.layout.BoxLayout.new('HORIZONTAL')
        utils.modifyOnOffButtonLayout(buttonLayout, isDynamicOn)
        local button = api.gui.comp.ToggleButton.new(buttonLayout)
        button:setSelected(isDynamicOn, false)
        button:onToggle(function(isOn) -- isOn is boolean
            print('toggled; isOn = ', isOn)
            while buttonLayout:getNumItems() > 0 do
                local item0 = buttonLayout:getItem(0)
                buttonLayout:removeItem(item0)
            end
            utils.modifyOnOffButtonLayout(buttonLayout, isOn)
            button:setSelected(isOn, false)
            funcOfBool(isOn)
        end)

        button:setId(_dynamicOnOffButtonId)

        api.gui.util.getById('gameInfo'):getLayout():addItem(button) -- adds a button in the right place
    end,
}

local _fuckAround = function()
    local _mbl = api.gui.util.getById('mainButtonsLayout')
    _mbl:getItem(1):setHighlighted(true) -- flashes the main 7 buttons at the centre
    _mbl:getItem(1):getLayout()
    _mbl:getItem(1):getLayout():getNumItems() -- returns 7


    -- this adds a button to the bottom right
    local _mmbb = api.gui.util.getById("mainMenuBottomBar")
    _mmbb:setHighlighted(true) -- flashes the bottom bar
    local buttonLayout = api.gui.layout.BoxLayout.new('HORIZONTAL')
    buttonLayout:addItem(api.gui.comp.ImageView.new('ui/design/components/checkbox_invalid.tga'))
    buttonLayout:addItem(api.gui.comp.TextView.new('Lollo'))
    local button = api.gui.comp.Button.new(buttonLayout, true)
    button:setId('LolloButton')

    _mmbb:getLayout():addItem(button)

    -- where best to add my button?
    _mmbb:getLayout():getItem(0):setHighlighted(true) -- far left and tiny
    _mmbb:getLayout():getItem(1):setHighlighted(true) -- most of the width. The id is 'gameInfo'
    _mmbb:getLayout():getItem(2):setHighlighted(true) -- tiny, just left of the music player
    _mmbb:getLayout():getItem(3):setHighlighted(true) -- I see nothing
    _mmbb:getLayout():getItem(4):setHighlighted(true) -- music player
    _mmbb:getLayout():getItem(5):setHighlighted(true) -- tiny, just right of the music player
    _mmbb:getLayout():getItem(6):setHighlighted(true) -- pause, play, fast, very fast and the date

    _mmbb:getLayout():getItem(1):getLayout()
    -- easier:
    api.gui.util.getById('gameInfo'):getLayout():getNumItems() -- returns 5
    api.gui.util.getById('gameInfo'):getLayout():addItem(button) -- adds a button in the right place
    api.gui.util.getById('LolloButton'):getLayout():getItem(0):getNumItems() -- returns 2, coz I put two things into my button
    -- adds a third icon to my button
    api.gui.util.getById('LolloButton'):getLayout():getItem(0):addItem(api.gui.comp.ImageView.new('ui/design/components/checkbox_valid.tga'))
end

return guiHelpers
