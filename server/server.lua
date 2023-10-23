RegisterServerEvent("BGS_Archaeology_Free:GiveReward")
AddEventHandler("BGS_Archaeology_Free:GiveReward", function(reward)
	local _source = source
	exports.vorp_inventory:addItem(_source, reward, 1)
end)