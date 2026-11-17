-- RebirthService.luau (ModuleScript)
-- CHAOS BRAINROT: MUTATION ISLAND
-- Rebirth: pay the configured Cash threshold to reset your cash and your
-- displayed collection, in exchange for a permanent income multiplier and
-- access to the Crystal Void through the portal in the Meadow. The server
-- validates everything; the client's button only sends a request.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Server = ServerScriptService:WaitForChild("Server")
local GameState = require(Server:WaitForChild("GameState"))

local RebirthService = {}
local inited = false

local function notify(player, text)
	GameState.GetRemote("Notify"):FireClient(player, text)
end

local function teleportPlayer(player, position)
	local character = player and player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
		root.AssemblyLinearVelocity = Vector3.zero
	end
end

local function doRebirth(player)
	local profile = GameState.GetProfile(player)
	if not profile then
		return
	end
	local cash = GameState.GetCash(profile)
	if cash < Config.RebirthRequirement then
		notify(player, "Rebirth needs $" .. Config.RebirthRequirement .. " -- you have $" .. cash .. ".")
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	-- Reset cash and the displayed collection; keep gems, discoveries and
	-- the base plot itself.
	leaderstats.Cash.Value = 0
	profile.CashRemainder = 0
	for _, item in ipairs(profile.Displayed) do
		if item.Model then
			item.Model:Destroy()
		end
	end
	profile.Displayed = {}
	if profile.Carrying and profile.Carrying.Model then
		profile.Carrying.Model:Destroy()
	end
	profile.Carrying = nil
	player:SetAttribute("Carrying", "")

	leaderstats.Rebirths.Value += 1
	GameState.AddGems(profile, Config.RebirthGemBonus)

	local multiplier = 1 + Config.RebirthMultiplierPer * leaderstats.Rebirths.Value
	notify(
		player,
		"REBIRTH! Income multiplier is now x" .. multiplier .. " and the Crystal Void portal is open to you!"
	)

	-- Respawn the player at their own base to show off the fresh start.
	local world = GameState.World
	if world and profile.BaseIndex then
		local base = world.Bases[profile.BaseIndex]
		if base and base.SpawnPad then
			teleportPlayer(player, base.SpawnPad.Position)
		end
	end
end

-- Portal pads: Meadow -> Crystal Void (needs 1 Rebirth), Void -> Meadow.
local portalWarnAt = {}
local function startPortalLoop()
	task.spawn(function()
		local world = GameState.WaitForWorld()
		while true do
			task.wait(0.3)
			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root then
					if (root.Position - world.PortalPad.Position).Magnitude <= 7.5 then
						local leaderstats = player:FindFirstChild("leaderstats")
						local rebirths = leaderstats and leaderstats:FindFirstChild("Rebirths")
						if rebirths and rebirths.Value >= 1 then
							teleportPlayer(player, world.VoidSpawn)
							notify(player, "Welcome to the Crystal Void.")
						else
							local now = os.clock()
							if not portalWarnAt[player] or now - portalWarnAt[player] > 5 then
								portalWarnAt[player] = now
								notify(player, "The Void Portal needs 1 Rebirth!")
							end
						end
					elseif (root.Position - world.ReturnPad.Position).Magnitude <= 7.5 then
						teleportPlayer(player, world.PortalPad.Position + Vector3.new(0, 0, 10))
					end
				end
			end
		end
	end)
end

function RebirthService.Init()
	if inited then
		return
	end
	inited = true

	GameState.GetRemote("RequestRebirth").OnServerEvent:Connect(function(player)
		doRebirth(player)
	end)

	startPortalLoop()
	print("[ChaosBrainrot] RebirthService ready.")
end

return RebirthService
