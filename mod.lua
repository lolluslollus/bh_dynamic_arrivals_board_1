function data()
	-- local function _addModel(oldFileName, newFileName)
	-- 	-- UG TODO the api does not support this
    --     local oldModelId = api.res.modelRep.find(oldFileName)
    --     local oldModel = api.res.modelRep.get(oldModelId)
    --     local newModel = api.type.ModelDesc.new() -- not available
    --     newModel.fileName = newFileName
    --     -- newModel.type = oldModel.type

    --     api.res.modelRep.add(newModel.fileName, newModel, true) -- fileName, resource, visible
    -- end

	return {
		info = {
			minorVersion = 18,
			severityAdd = 'NONE',
			severityRemove = 'WARNING',
			name = _('ModName'),
			description = _('ModDesc'),
			tags = { 'Misc', 'Script Mod', 'Track Asset', },
			visible = true,
			authors = {
                {
					name = 'lollus',
					role = 'CREATOR'
				},
				{
					name = 'badgerrhax',
					role = 'CREATOR'
				},
			}
		},
		-- postRunFn = function(settings, params)
        --     _addModel(
        --         'lolloArrivalsDeparturesPredictor/platform_departures_board_floating.mdl',
        --         'lolloArrivalsDeparturesPredictor/platform_departures_board_floating_2.mdl'
        --     )
        -- end
	}
end
