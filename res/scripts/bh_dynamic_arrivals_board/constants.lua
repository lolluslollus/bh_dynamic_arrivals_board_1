local constants = {
    refreshCount = 5000, -- refresh every 5 seconds
    searchRadius4NearbyStation2Join = 50,

    eventId = 'bh_arrivals_manager',
    eventSources = {
        ['bh_gui_engine'] = 'bh_gui_engine.lua',
    },
    events = {
        ['hide_warnings'] = 'hide_warnings',
        ['join_board_to_station'] = 'join_board_to_station',
        ['remove_display_construction'] = 'remove_display_construction',
    }
}

return constants
