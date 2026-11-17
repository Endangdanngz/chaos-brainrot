-- GameState.luau (ModuleScript)
-- CHAOS BRAINROT: MUTATION ISLAND
-- Single shared runtime state for every server service. All server scripts
-- require this one module instance, so the tables below are the game's
-- single source of truth at runtime. Nothing here touches the client.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local GameState = {}

-- ---------------------------------------------------------------------------
-- Profiles: [userId] = {
--   Player        = Player instance,
--   CashRemainder = fractional cash accumulator (leaderstats holds the floor),
--   Displayed     = { { Model, EntryId, Mutation, Income } } on base pedestals,
--   Carrying      = nil | { EntryId, Model, Mutation, StolenFrom (Player|nil) },
--   BaseIndex     = number,
--   LockUntil     = os.clock() timestamp when the base lock expires,
--   LastStealAt   = os.clock() timestamp of the player's last steal,
--   Discovered    = { [entryId] = true },
-- }
-- ---------------------------------------------------------------------------
GameState.Profiles = {}

-- Wild brainrots loose in the world: [Model] = { EntryId, Mutation, Zone }
GameState.Wild = {}

-- Filled in by WorldBuilder once the island exists:
-- World = {
--   Zones = { Meadow = { Center, Radius, GroundY }, ... },
--   Bases = { { Index, Center, Pedestals = {Part}, DepositPad, SignLabel,
--               Dome, SpawnPad, Owner = nil | Player } },
--   VoidSpawn = Vector3, PortalPad = Part,
-- }
GameState.World = nil
GameState.WorldReady = Instance.new("BindableEvent")

-- Live event flags (os.clock() timestamps; 0 = inactive).
GameState.StormUntil = 0
GameState.RareBoostUntil = 0

function GameState.IsStormActive()
	return os.clock() < GameState.StormUntil
end

function GameState.IsRareBoostActive()
	return os.clock() < GameState.RareBoostUntil
end

-- Fetch a RemoteEvent created by Main. Yields until it exists, so services
-- can call this safely regardless of script start order.
function GameState.GetRemote(name)
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	return remotes:WaitForChild(name)
end

-- Wait until WorldBuilder has published the world layout.
function GameState.WaitForWorld()
	if GameState.World then
		return GameState.World
	end
	GameState.WorldReady.Event:Wait()
	return GameState.World
end

function GameState.GetProfile(player)
	if not player then
		return nil
	end
	return GameState.Profiles[player.UserId]
end

-- Block until Main has created the player's profile (used by services whose
-- PlayerAdded handler may run before Main's).
function GameState.WaitForProfile(player)
	local profile = GameState.Profiles[player.UserId]
	if profile then
		return profile
	end
	local deadline = os.clock() + 30
	while not profile and os.clock() < deadline do
		task.wait(0.1)
		profile = GameState.Profiles[player.UserId]
	end
	return profile
end

-- Total income per second a profile's displayed collection produces,
-- including mutation multipliers and the permanent rebirth multiplier.
function GameState.GetIncomePerSecond(profile)
	if not profile then
		return 0
	end
	local sum = 0
	for _, item in ipairs(profile.Displayed) do
		sum += item.Income
	end
	local rebirths = 0
	local leaderstats = profile.Player and profile.Player:FindFirstChild("leaderstats")
	if leaderstats then
		local rb = leaderstats:FindFirstChild("Rebirths")
		if rb then
			rebirths = rb.Value
		end
	end
	return sum * (1 + Config.RebirthMultiplierPer * rebirths)
end

-- Add cash server-side (the ONLY way cash changes besides rebirth reset).
-- Keeps the fractional remainder so slow incomes still accumulate.
function GameState.AddCash(profile, amount)
	if not profile or not amount or amount == 0 then
		return
	end
	profile.CashRemainder += amount
	local whole = math.floor(profile.CashRemainder)
	if whole ~= 0 then
		profile.CashRemainder -= whole
		local leaderstats = profile.Player:FindFirstChild("leaderstats")
		if leaderstats then
			local cash = leaderstats:FindFirstChild("Cash")
			if cash then
				cash.Value += whole
			end
		end
	end
end

function GameState.AddGems(profile, amount)
	if not profile or not amount then
		return
	end
	local leaderstats = profile.Player:FindFirstChild("leaderstats")
	if leaderstats then
		local gems = leaderstats:FindFirstChild("Gems")
		if gems then
			gems.Value += amount
		end
	end
end

function GameState.GetCash(profile)
	local leaderstats = profile.Player:FindFirstChild("leaderstats")
	if leaderstats then
		local cash = leaderstats:FindFirstChild("Cash")
		if cash then
			return cash.Value
		end
	end
	return 0
end

-- Mark a roster entry as discovered (drives the Collection Index UI via a
-- player attribute the client can read).
function GameState.MarkDiscovered(profile, entryId)
	if not profile.Discovered[entryId] then
		profile.Discovered[entryId] = true
		profile.Player:SetAttribute("Found_" .. entryId, true)
	end
end

return GameState
