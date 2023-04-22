-- simstudios

Config = {}

Config.RequiredCops = 1 -- Police Required
Config.PoliceJob = 'police' -- You're police job

Config.minCashAmount = 20 -- Minimum money you can get
Config.maxCashAmount = 60  -- Maximum money you can get

Config.robbingTime = 5000
Config.blacklistedJobs = { -- Jobs that are not allowed to steal |||||| true = cannot steal |||| false = if they can steal
	['police'] = true, 
	['sheriff'] = true,
	['ambulance'] = false, 
}
