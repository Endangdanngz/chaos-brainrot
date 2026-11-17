-- EconomyService.luau (ModuleScript)
-- CHAOS BRAINROT: MUTATION ISLAND
-- The server-authoritative income tick. Every second, each player's
-- displayed collection earns its income (mutation multipliers are baked into
-- each displayed item's Income; the permanent rebirth multiplier is applied
-- here). Clients never touch money -- they only display leaderstats.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Server = ServerScriptService:WaitForChild("Server")
local GameState = require(Server:WaitForChild("GameState"))

local EconomyService = {}
local started = false

function EconomyService.Start()
	if started then
		return
	end
	started = true

	task.spawn(function()
		while true do
			task.wait(Config.IncomeTickSeconds)
			for _, profile in pairs(GameState.Profiles) do
				local ips = GameState.GetIncomePerSecond(profile)
				profile.Player:SetAttribute("IncomePerSecond", math.floor(ips * 10) / 10)
				if ips > 0 then
					GameState.AddCash(profile, ips * Config.IncomeTickSeconds)
				end
			end
		end
	end)

	print("[ChaosBrainrot] EconomyService started.")
end

return EconomyService
