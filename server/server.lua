RegisterServerEvent("BGS_Archaeology_Free:GiveReward")
AddEventHandler("BGS_Archaeology_Free:GiveReward", function(reward)
	local _source = source
	if _source then
		exports.vorp_inventory:addItem(_source, reward, 1)
	end
end)

RegisterServerEvent("BGS_Archaeology_Free:GetShovelCount")
AddEventHandler("BGS_Archaeology_Free:GetShovelCount", function()
	local _source = source
	if _source and _source ~= nil then
		local count = exports.vorp_inventory:getItemCount(_source, nil, Config.ShovelItem)
		TriggerClientEvent("BGS_Archaeology_Free:GetShovelCountClient", _source, count)
	end
end)