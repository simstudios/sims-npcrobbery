ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('sims-npcrobbery:recompensa')
AddEventHandler('sims-npcrobbery:recompensa', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local cashAmount = math.random(Config.minCashAmount, Config.maxCashAmount)
	xPlayer.addMoney(cashAmount)
	xPlayer.showNotification("You have rob "..cashAmount.."$ from the person.")
end)


ESX.RegisterServerCallback('sims-npcrobbery:contpolice', function(source, cb, store)
    local cops = 0
    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == Config.PoliceJob then
            cops = cops + 1
        end
    end
    if cops >= Config.RequiredCops then
    cb(true)
    else
		cb(false)
    end
end)

