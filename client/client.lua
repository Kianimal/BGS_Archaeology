local isDigging = false
local shovelObject = nil
local itemObject = nil
local itemModel = nil
local Prompt
local Prompt2
local Group = GetRandomIntInRange(0, 0xffffff)
local Group2 = GetRandomIntInRange(0, 0xffffff)
local GroupName
local usedPoints = {}

function shuffle(table)
	for i = #table, 2, -1 do
		local j = math.random(i)
		table[i], table[j] = table[j], table[i]
	end
	return table
end

function contains(table, element)
	if table ~= 0 then
		for k, v in pairs(table) do
			if v == element then
				return true
			end
		end
	end
	return false
end

function CreateVarString(p0, p1, variadic)
	return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end

function CreateDigPrompt(promptText, controlAction)
	local str = promptText
	Prompt = PromptRegisterBegin()
	PromptSetControlAction(Prompt, controlAction)
	str = CreateVarString(10, "LITERAL_STRING", str)
	PromptSetText(Prompt, str)
	PromptSetEnabled(Prompt, false)
	PromptSetVisible(Prompt, false)
	PromptSetHoldMode(Prompt, 1000)
	PromptSetGroup(Prompt, Group)
	PromptRegisterEnd(Prompt)
end

function CreatePickupPrompt(promptText, controlAction)
	local str = promptText
	Prompt2 = PromptRegisterBegin()
	PromptSetControlAction(Prompt2, controlAction)
	str = CreateVarString(10, "LITERAL_STRING", str)
	PromptSetText(Prompt2, str)
	PromptSetEnabled(Prompt2, false)
	PromptSetVisible(Prompt2, false)
	PromptSetHoldMode(Prompt2, 1000)
	PromptSetGroup(Prompt2, Group2)
	PromptRegisterEnd(Prompt2)
end

function GetDestination()
	return shuffle(Config.Locations)[1]
end

function AttachEnt(from, to, boneIndex, x, y, z, pitch, roll, yaw, useSoftPinning, collision, vertex, fixedRot)
	return AttachEntityToEntity(
		from,
		to,
		boneIndex,
		x,
		y,
		z,
		pitch,
		roll,
		yaw,
		false,
		useSoftPinning,
		collision,
		false,
		vertex,
		fixedRot,
		false,
		false
	)
end

function PlayerDig(destination)
	if shovelObject then
		DeleteObject(shovelObject)
		SetEntityAsNoLongerNeeded(shovelObject)
		shovelObject = nil
	end
	table.insert(usedPoints, destination.coords)
	local ped = PlayerPedId()
	local shovelModel = GetHashKey("p_shovel02x")
	local dirtPileModel = GetHashKey("mp005_p_dirtpile_cum_unburied")
	itemModel = GetHashKey(destination.model)
	TaskTurnPedToFaceEntity(ped, destination.dirtPile, -1)
	Wait(2000)
	ClearPedTasks(ped)
	RequestModel(shovelModel)
	RequestModel(dirtPileModel)
	RequestModel(itemModel)
	while not HasModelLoaded(shovelModel) and not HasModelLoaded(dirtPileModel) and not HasModelLoaded(itemModel) do
		Citizen.Wait(0)
	end
	local coords = GetEntityCoords(ped)
	shovelObject = CreateObject(shovelModel, coords.x, coords.y, coords.z, true, true, true)
	local boneIndex = GetEntityBoneIndexByName(ped, "skel_r_hand")
	RequestAnimDict("amb_work@world_human_gravedig@working@male_b@idle_a")
	while not HasAnimDictLoaded("amb_work@world_human_gravedig@working@male_b@idle_a") do
		Wait(0)
	end
	TaskPlayAnim(ped, "amb_work@world_human_gravedig@working@male_b@idle_a", "idle_a", 1.0, 1.0, -1, 1, 0, false, false, false)
	AttachEnt(
		shovelObject,
		ped,
		boneIndex,
		0.06,
		-0.06,
		-0.03,
		270.0,
		165.0,
		17.0,
		0,
		1,
		1,
		1
	)
	RemoveAnimDict("amb_work@world_human_gravedig@working@male_b@idle_a")
	Wait(10000)
	DeleteObject(destination.dirtPile)
	local dirtPileObject = CreateObject(dirtPileModel, destination.coords.x, destination.coords.y, destination.coords.z, true, true, true)
	itemObject = CreateObject(itemModel, destination.coords.x, destination.coords.y, destination.coords.z, true, true, true)
	SetEntityAsMissionEntity(dirtPileObject, true, true)
	SetEntityAsMissionEntity(itemObject, true, true)
	destination.rewardItem = itemObject
	destination.dirtPile = dirtPileObject
	Citizen.InvokeNative(0x7DFB49BCDB73089A, itemObject, true)
	Citizen.InvokeNative(0x9587913B9E772D29, dirtPileObject, true)
	Citizen.InvokeNative(0x9587913B9E772D29, itemObject, true)
	SetModelAsNoLongerNeeded(dirtPileModel)
	SetModelAsNoLongerNeeded(shovelModel)
	SetModelAsNoLongerNeeded(itemModel)
	ClearPedTasks(ped)
	DeleteObject(shovelObject)
	shovelObject = nil
	isDigging = false
end

CreateDigPrompt(Config.Language.PromptText, Config.ControlAction)
CreatePickupPrompt(Config.Language.PickupPromptText, Config.PickupControlAction)

function CreatePile(destination)
	if not DoesEntityExist(destination.dirtPile) and not contains(usedPoints, destination.coords) then
		local dirtPileModel = GetHashKey("mp005_p_dirtpile_big03_buried")
		RequestModel(dirtPileModel)
		while not HasModelLoaded(dirtPileModel) do
			Citizen.Wait(0)
		end
		local dirtPileObject = CreateObject(dirtPileModel, destination.coords.x, destination.coords.y, destination.coords.z, true, true, true)
		Wait(500)
		Citizen.InvokeNative(0x9587913B9E772D29, dirtPileObject, true)
		SetEntityAsMissionEntity(dirtPileObject, true, true)
		destination.dirtPile = dirtPileObject
	end
end

RegisterNetEvent("BGS_Archaeology_Free:GetShovelCountClient")
AddEventHandler("BGS_Archaeology_Free:GetShovelCountClient", function(count)
	if count > 0 then
		LocalPlayer.state:set("HasShovel", true, true)
	else
		LocalPlayer.state:set("HasShovel", false, true)
	end
end)

RegisterNetEvent("vorp:SelectedCharacter", function()
	CreateThread(function()
		while true do

			Wait(1000)

			local ped = PlayerPedId()
			local pedCoords = GetEntityCoords(ped)

			TriggerServerEvent("BGS_Archaeology_Free:GetShovelCount")

			for k, v in pairs(Config.Locations) do
				local dirtPileObject
				if not DoesEntityExist(v.dirtPile) and not contains(usedPoints, v.coords) and Citizen.InvokeNative(0xDA8B2EAF29E872E2, v.coords) then
					CreatePile(v)
					if GetEntityHeightAboveGround(v.dirtPile) > 0.0 then
						Citizen.InvokeNative(0x9587913B9E772D29, dirtPileObject, true)
					end
				end
				while GetDistanceBetweenCoords(pedCoords, v.coords) <= Config.MinimumDistance and not isDigging and not contains(usedPoints, v.coords) and LocalPlayer.state.HasShovel do
					Wait(1)
					pedCoords = GetEntityCoords(ped)
					GroupName = Config.Language.PromptGroupName .. " - " .. v.name
					GroupName = CreateVarString(10, "LITERAL_STRING", GroupName)
					PromptSetActiveGroupThisFrame(Group, GroupName)
					PromptSetEnabled(Prompt, true)
					PromptSetVisible(Prompt, true)

					if PromptHasHoldModeCompleted(Prompt) then
						isDigging = true
						PlayerDig(v)
					end
				end

				if v.rewardItem then
					while GetDistanceBetweenCoords(GetEntityCoords(v.rewardItem), pedCoords) <= Config.MinimumDistance do
						Wait(1)
						pedCoords = GetEntityCoords(ped)
						GroupName = v.rewardName
						GroupName = CreateVarString(10, "LITERAL_STRING", GroupName)
						PromptSetActiveGroupThisFrame(Group2, GroupName)
						PromptSetEnabled(Prompt2, true)
						PromptSetVisible(Prompt2, true)
						local promptText = CreateVarString(10, "LITERAL_STRING", Config.Language.PickupPromptText)
						PromptSetText(Prompt2, promptText)
						if PromptHasHoldModeCompleted(Prompt2) then
							DeleteObject(v.rewardItem)
							TriggerServerEvent("BGS_Archaeology_Free:GiveReward", v.reward)
						end
					end
					if GetDistanceBetweenCoords(GetEntityCoords(v.rewardItem), pedCoords) > Config.MinimumDistance then
						PromptSetEnabled(Prompt2, false)
						PromptSetVisible(Prompt2, false)
					end
				end
			end
		end
	end)
end)

