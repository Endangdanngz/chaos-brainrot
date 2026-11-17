-- EventService.luau (ModuleScript)
-- CHAOS BRAINROT: MUTATION ISLAND
-- Chaos events on a random 3-5 minute cadence. Every event is functional,
-- not cosmetic:
--   MeteorShower   -- meteors crash down and leave cash/gem shards to grab
--   ToxicRain      -- green fog, rare spawns boosted, standing in the open hurts
--   MutationStorm  -- mutation rolls are 3x luckier for 60 seconds
--   GravityCollapse-- the island's gravity drops for 45 seconds
--   TreasureSpawn  -- a glowing chest appears at a landmark, first come served
-- Events are announced to every client through the EventAnnounce remote.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Server = ServerScriptService:WaitForChild("Server")
local GameState = require(Server:WaitForChild("GameState"))

local EventService = {}
local started = false

-- Active event pickups (meteor shards, treasure chest):
-- [Instance] = { Kind = "Cash"|"Gems"|"Treasure", Amount, Radius, Expires }
local activePickups = {}

local function announce(eventKey, title, message, duration)
	GameState.GetRemote("EventAnnounce"):FireAllClients(eventKey, title, message, duration or 6)
end

local function notify(player, text)
	GameState.GetRemote("Notify"):FireClient(player, text)
end

local function getPickupFolder()
	local folder = Workspace:FindFirstChild("EventPickups")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "EventPickups"
		folder.Parent = Workspace
	end
	return folder
end

local function randomMainlandPoint()
	local world = GameState.World
	local zoneKeys = { "Meadow", "Swamp", "Ashlands" }
	local zone = world.Zones[zoneKeys[math.random(1, #zoneKeys)]]
	local angle = math.random() * math.pi * 2
	local dist = math.sqrt(math.random()) * zone.Radius * 0.85
	return Vector3.new(zone.Center.X + math.cos(angle) * dist, zone.GroundY, zone.Center.Z + math.sin(angle) * dist)
end

local function playerRoot(player)
	local character = player and player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

-- ---------------------------------------------------------------------------
-- MeteorShower
-- ---------------------------------------------------------------------------
local function spawnShard(position)
	local shard = Instance.new("Part")
	shard.Name = "MeteorShard"
	shard.Shape = Enum.PartType.Ball
	shard.Size = Vector3.new(1.3, 1.3, 1.3)
	shard.Position = position + Vector3.new(math.random(-3, 3), 1, math.random(-3, 3))
	shard.Color = Color3.fromRGB(255, 170, 60)
	shard.Material = Enum.Material.Neon
	shard.Anchored = true
	shard.CanCollide = false
	local light = Instance.new("PointLight")
	light.Color = shard.Color
	light.Brightness = 1.4
	light.Range = 9
	light.Parent = shard
	shard.Parent = getPickupFolder()
	if math.random() < 0.3 then
		activePickups[shard] = { Kind = "Gems", Amount = math.random(1, 3), Radius = 5.5, Expires = os.clock() + 30 }
	else
		activePickups[shard] = {
			Kind = "Cash",
			Amount = math.random(Config.MeteorCashMin, Config.MeteorCashMax),
			Radius = 5.5,
			Expires = os.clock() + 30,
		}
	end
end

local function dropMeteor(targetPos)
	task.spawn(function()
		local meteor = Instance.new("Part")
		meteor.Name = "Meteor"
		meteor.Shape = Enum.PartType.Ball
		meteor.Size = Vector3.new(2.6, 2.6, 2.6)
		meteor.Color = Color3.fromRGB(255, 120, 40)
		meteor.Material = Enum.Material.Neon
		meteor.Anchored = true
		meteor.CanCollide = false
		local startPos = targetPos + Vector3.new(math.random(-14, 14), 95, math.random(-14, 14))
		meteor.Position = startPos
		local light = Instance.new("PointLight")
		light.Color = meteor.Color
		light.Brightness = 2.5
		light.Range = 18
		light.Parent = meteor
		meteor.Parent = getPickupFolder()

		local steps = 14
		for i = 1, steps do
			if not meteor.Parent then
				return
			end
			meteor.Position = startPos:Lerp(targetPos + Vector3.new(0, 1.2, 0), i / steps)
			task.wait(0.045)
		end
		meteor:Destroy()
		spawnShard(targetPos)
		if math.random() < 0.55 then
			spawnShard(targetPos)
		end
	end)
end

local function runMeteorShower()
	announce("MeteorShower", "METEOR SHOWER!", "Meteors are crashing down -- grab the glowing shards!", 8)
	local endsAt = os.clock() + Config.MeteorShowerDuration
	while os.clock() < endsAt do
		dropMeteor(randomMainlandPoint())
		task.wait(2.2)
	end
end

-- ---------------------------------------------------------------------------
-- ToxicRain
-- ---------------------------------------------------------------------------
local function isSheltered(player)
	local root = playerRoot(player)
	if not root then
		return true
	end
	local world = GameState.World
	if not world then
		return true
	end
	for _, base in ipairs(world.Bases) do
		if (root.Position - base.Center).Magnitude <= 31 then
			return true
		end
	end
	return false
end

local function runToxicRain()
	announce("ToxicRain", "TOXIC RAIN!", "Rare brainrots love this weather -- but it burns! Shelter at a base!", 8)
	GameState.RareBoostUntil = os.clock() + Config.ToxicRainDuration

	local oldFogColor = Lighting.FogColor
	local oldFogEnd = Lighting.FogEnd
	Lighting.FogColor = Color3.fromRGB(96, 190, 96)
	Lighting.FogEnd = 520

	local endsAt = os.clock() + Config.ToxicRainDuration
	while os.clock() < endsAt do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 and not isSheltered(player) then
				humanoid:TakeDamage(Config.ToxicRainDamagePerSecond)
			end
		end
	end

	Lighting.FogColor = oldFogColor
	Lighting.FogEnd = oldFogEnd
end

-- ---------------------------------------------------------------------------
-- MutationStorm / GravityCollapse
-- ---------------------------------------------------------------------------
local function runMutationStorm()
	GameState.StormUntil = os.clock() + Config.MutationStormDuration
	announce("MutationStorm", "MUTATION STORM!", "Mutation luck x3 for 60 seconds -- deposit everything you carry!", 8)
	task.wait(Config.MutationStormDuration)
	announce("MutationStormEnd", "Storm over", "The mutation storm has passed.", 4)
end

local function runGravityCollapse()
	announce("GravityCollapse", "GRAVITY COLLAPSE!", "Gravity is failing -- jump like you're on the moon!", 8)
	Workspace.Gravity = Config.LowGravity
	task.wait(Config.GravityCollapseDuration)
	Workspace.Gravity = 196.2
	announce("GravityCollapseEnd", "Gravity restored", "Your feet feel heavy again.", 4)
end

-- ---------------------------------------------------------------------------
-- TreasureSpawn
-- ---------------------------------------------------------------------------
local TREASURE_SPOTS = {
	{ Name = "the Meadow plaza", Offset = Vector3.new(0, 3.2, 150) },
	{ Name = "the Neon Swamp", Offset = Vector3.new(-155, 3.2, 10) },
	{ Name = "the Ashlands", Offset = Vector3.new(-10, 3.2, -165) },
	{ Name = "the giant tree", Offset = Vector3.new(34, 3.2, 118) },
	{ Name = "the volcano's foot", Offset = Vector3.new(-16, 3.2, -190) },
}

local function runTreasureSpawn()
	local spot = TREASURE_SPOTS[math.random(1, #TREASURE_SPOTS)]
	local chest = Instance.new("Model")
	chest.Name = "TreasureChest"

	local box = Instance.new("Part")
	box.Name = "Box"
	box.Size = Vector3.new(3.4, 2, 2.4)
	box.Position = spot.Offset + Vector3.new(0, 1, 0)
	box.Color = Color3.fromRGB(122, 82, 44)
	box.Material = Enum.Material.Wood
	box.Anchored = true
	box.Parent = chest

	local lid = Instance.new("Part")
	lid.Name = "Lid"
	lid.Size = Vector3.new(3.6, 0.7, 2.6)
	lid.Position = spot.Offset + Vector3.new(0, 2.3, 0)
	lid.Color = Color3.fromRGB(255, 200, 70)
	lid.Material = Enum.Material.Metal
	lid.Anchored = true
	lid.Parent = chest

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 210, 90)
	light.Brightness = 2.2
	light.Range = 16
	light.Parent = box

	local tag = Instance.new("BillboardGui")
	tag.Name = "TreasureTag"
	tag.Size = UDim2.new(6, 0, 1.5, 0)
	tag.StudsOffset = Vector3.new(0, 2.6, 0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = 160
	tag.Adornee = box
	tag.Parent = chest
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 220, 110)
	label.TextStrokeTransparency = 0.25
	label.Text = "TREASURE!"
	label.Parent = tag

	chest.Parent = getPickupFolder()
	activePickups[chest] = {
		Kind = "Treasure",
		Amount = math.random(Config.TreasureCashMin, Config.TreasureCashMax),
		Radius = 7,
		Expires = os.clock() + 90,
		Position = spot.Offset,
	}
	announce("TreasureSpawn", "TREASURE SPOTTED!", "A treasure chest appeared near " .. spot.Name .. " -- first to reach it wins!", 8)
end

-- ---------------------------------------------------------------------------
-- Pickup collection loop (shards + treasure)
-- ---------------------------------------------------------------------------
local function startPickupLoop()
	task.spawn(function()
		while true do
			task.wait(0.25)
			local now = os.clock()
			for instance, pickup in pairs(activePickups) do
				if not instance or not instance.Parent then
					activePickups[instance] = nil
				elseif now > pickup.Expires then
					activePickups[instance] = nil
					instance:Destroy()
				else
					local position = pickup.Position or (instance:IsA("BasePart") and instance.Position) or nil
					if position then
						for _, player in ipairs(Players:GetPlayers()) do
							local root = playerRoot(player)
							if root and (root.Position - position).Magnitude <= pickup.Radius then
								local profile = GameState.GetProfile(player)
								if profile then
									if pickup.Kind == "Gems" then
										GameState.AddGems(profile, pickup.Amount)
										notify(player, "+" .. pickup.Amount .. " Gems from a meteor shard!")
									else
										GameState.AddCash(profile, pickup.Amount)
										if pickup.Kind == "Treasure" then
											notify(player, "You claimed the treasure: +$" .. pickup.Amount .. "!")
											announce("TreasureClaimed", "Treasure claimed!", player.DisplayName .. " grabbed the treasure chest!", 5)
										else
											notify(player, "+$" .. pickup.Amount .. " from a meteor shard!")
										end
									end
								end
								activePickups[instance] = nil
								instance:Destroy()
								break
							end
						end
					end
				end
			end
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Main event loop
-- ---------------------------------------------------------------------------
local EVENT_RUNNERS = {
	{ Key = "MeteorShower", Run = runMeteorShower },
	{ Key = "ToxicRain", Run = runToxicRain },
	{ Key = "MutationStorm", Run = runMutationStorm },
	{ Key = "GravityCollapse", Run = runGravityCollapse },
	{ Key = "TreasureSpawn", Run = runTreasureSpawn },
}

function EventService.Start()
	if started then
		return
	end
	started = true
	GameState.WaitForWorld()
	getPickupFolder()
	startPickupLoop()

	task.spawn(function()
		task.wait(75) -- grace period so players settle in before the first event
		local lastKey = nil
		while true do
			local waitTime = math.random(Config.EventMinInterval, Config.EventMaxInterval)
			task.wait(waitTime)
			local choices = {}
			for _, event in ipairs(EVENT_RUNNERS) do
				if event.Key ~= lastKey then
					table.insert(choices, event)
				end
			end
			local chosen = choices[math.random(1, #choices)]
			lastKey = chosen.Key
			local ok, err = pcall(chosen.Run)
			if not ok then
				warn("[ChaosBrainrot] Event " .. chosen.Key .. " failed: " .. tostring(err))
				-- Never leave the world in a broken event state.
				Workspace.Gravity = 196.2
				GameState.StormUntil = 0
				GameState.RareBoostUntil = 0
			end
		end
	end)

	print("[ChaosBrainrot] EventService started.")
end

return EventService
