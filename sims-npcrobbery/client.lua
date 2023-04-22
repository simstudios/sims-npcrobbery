ESX = exports["es_extended"]:getSharedObject()
local robbingInProgress = false
local robbingTXTDRW = false
local randmsg = ''
local txtDrawCoords = nil
local robbedPeds = {}


RegisterNetEvent('esx:playerLoaded') 
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:playerLogout') 
AddEventHandler('esx:playerLogout', function(xPlayer, isNew)
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)


Citizen.CreateThread(function()
	while true do
		local sleep = 1500
		local ped = PlayerPedId()
		if not robbingInProgress then
			if IsPedArmed(ped, 6) and not IsPedInAnyVehicle(ped, false) then 
				local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))
				local job = ESX.PlayerData.job.name
				local canRob = nil

				if aiming and not IsPedAPlayer(targetPed) and not IsPedInAnyVehicle(targetPed, false) and not Config.blacklistedJobs[job] then


					ESX.TriggerServerCallback('sims-npcrobbery:contpolice', function(cb)
						canRob = cb
					end)
					while canRob == nil do
						Wait(0)
					end
					if canRob == true then
						
						if DoesEntityExist(targetPed) and IsEntityAPed(targetPed) and not IsEntityDead(targetPed) then
							local robbingCanceled = false
							local distance = GetDistanceBetweenCoords(GetEntityCoords(ped, true), GetEntityCoords(targetPed, true), false)
							if distance < 6 then
								sleep = 0
								if robbedPeds[targetPed] == nil then
									robbingInProgress = true

									LoadAnim('missfbi5ig_22')
									LoadAnim('oddjobs@shop_robbery@rob_till')
									SetPedDropsWeaponsWhenDead(targetPed, false)
									ClearPedTasks(targetPed)
									TaskSetBlockingOfNonTemporaryEvents(targetPed, true)
									SetPedFleeAttributes(targetPed, 0, 0)
									SetPedCombatAttributes(targetPed, 17, 1)
									SetPedSeeingRange(targetPed, 0.0)
									SetPedHearingRange(targetPed, 0.0)
									SetPedAlertness(targetPed, 0)
									SetPedKeepTask(targetPed, true)

									FreezeEntityPosition(targetPed, true)
									ESX.ShowNotification('Keep aiming at the npc while stealing from him')
									robbingTXTDRW = true
									txtDrawCoords = GetEntityCoords(targetPed, true)
									TaskTurnPedToFaceEntity(targetPed, ped, -1)
									TaskPlayAnim(targetPed, "missfbi5ig_22", "hands_up_anxious_scientist", 8.0, -1, -1, 12, 1, 0, 0, 0)
									Wait(0)
									TaskPlayAnim(targetPed, "missfbi5ig_22", "hands_up_loop_scientist", 8.0, 1.0, Config.robbingTime + 5000, 1)
									local aiming2, targetPed2 = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))
									if not aiming2 or targetPed2 ~= targetPed then
										robbingCanceled = true
										TaskReactAndFleePed(targetPed, ped)
										return
									end
									Wait(0)

									local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId(), true), GetEntityCoords(targetPed, true), false)
									if not IsEntityDead(targetPed) and distance < 6 and not robbingCanceled then

										txtDrawCoords = nil
										robbingTXTDRW = false
										PlaySoundFrontend(-1, 'YES', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
										ESX.ShowNotification('The person is obeying your orders')
										FreezeEntityPosition(targetPed, true)
										FreezeEntityPosition(ped, false)
										ClearPedTasks(targetPed)
										TaskGoToEntity(targetPed, ped, -1, 1.5, 1.0, 100, 0)

										Wait(4000)
										TaskTurnPedToFaceEntity(ped, targetPed, -1)
										TaskTurnPedToFaceEntity(targetPed, ped, -1) 

										Wait(1500)
										ClearPedTasks(targetPed)
										FreezeEntityPosition(targetPed, true)
										TaskPlayAnim(targetPed, "missfbi5ig_22", "hands_up_loop_scientist", 8.0, 1.0, Config.robbingTime, 1)
										TaskPlayAnim(ped, "oddjobs@shop_robbery@rob_till", "loop", 8.0, 1.0, Config.robbingTime, 1)
										PlaySoundFrontend(-1, 'Grab_Parachute', 'BASEJUMPS_SOUNDS', 1)								
										Citizen.Wait(Config.robbingTime)
										ClearPedTasksImmediately(ped)
										TriggerServerEvent('sims-npcrobbery:recompensa')
										FreezeEntityPosition(targetPed, false)
										robbedPeds[targetPed] = true
										TaskReactAndFleePed(targetPed, ped)
										SetPedKeepTask(targetPed, true)
										robbingInProgress = false

									else

										ESX.ShowNotification('The person ran away...')
										PlaySoundFrontend(-1, 'Out_Of_Bounds_Timer', 'DLC_HEISTS_GENERAL_FRONTEND_SOUNDS', 1)
										FreezeEntityPosition(targetPed, false)
										TaskReactAndFleePed(targetPed, ped)
										SetPedKeepTask(targetPed, true)
										robbingInProgress = false
										txtDrawCoords = nil
										robbingTXTDRW = false
										return

									end
								else
									ESX.ShowNotification('You have already stolen from that person.')
								end
						end
					else
						if DoesEntityExist(targetPed) then
							TaskReactAndFleePed(targetPed, ped)
							SetPedKeepTask(targetPed, true)
						end
						robbingInProgress = false
					end

						exit = false
					else
						ESX.ShowNotification("There are not enough police to rob civilians.")
					end

				end
			end
		end
		Wait(sleep)
	end
end)

function LoadAnim(animDict)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(10)
	end
end