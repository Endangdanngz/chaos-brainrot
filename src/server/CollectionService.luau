-- CollectionService.luau (ModuleScript)
-- CHAOS BRAINROT: MUTATION ISLAND
-- Owns the wild brainrot population: spawning per zone with weighted rarity
-- rolls, proximity pickup (the character rides above the player's head),
-- and depositing onto base pedestals where a mutation is rolled and the
-- character becomes a permanent income producer on display.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local BrainrotData = require(Shared:WaitForChild("BrainrotData"))

local Server = ServerScriptService:WaitForChild("Server")
local GameState = require(Server:WaitForChild("GameState"))
local MutationService = require(Server:WaitForChild("MutationService"))

local CollectionService = {}

local started = false

local function getWildFolder()
	local folder = Workspace:FindFirstChild("WildBrainrots")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "WildBrainrots"
		folder.Parent = Workspace
	end
	return folder
end

local function getDisplayFolder()
	local folder = Workspace:FindFirstChild("DisplayedBrainrots")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "DisplayedBrainrots"
		folder.Parent = Workspace
	end
	return folder
end

-- ---------------------------------------------------------------------------
-- Rarity / spawning
-- ---------------------------------------------------------------------------
local function rollRarity(weights)
	local boosted = GameState.IsRareBoostActive()
	local total = 0
	local adjusted = {}
	for rarity, weight in pairs(weights) do
		local w = weight
		if boosted then
			local rank = Config.RarityOrder[rarity] or 1
			if rank >= 3 then
				w = w * 2
			else
				w = w * 0.5
			end
		end
		adjusted[rarity] = w
		total += w
	end
	local roll = math.random() * total
	local cumulative = 0
	for rarity, w in pairs(adjusted) do
		cumulative += w
		if roll <= cumulative then
			return rarity
		end
	end
	return "Common"
end

function CollectionService.CountWildInZone(zoneKey)
	local count = 0
	for _, wild in pairs(GameState.Wild) do
		if wild.Zone == zoneKey then
			count += 1
		end
	end
	return count
end

function CollectionService.SpawnWild(zoneKey)
	local world = GameState.World
	if not world then
		return nil
	end
	local zone = world.Zones[zoneKey]
	local spawnConfig = Config.ZoneSpawns[zoneKey]
	if not zone or not spawnConfig then
		return nil
	end
	local rarity = rollRarity(spawnConfig.Weights)
	local entry = BrainrotData.Pick(zoneKey, rarity)
	local model = BrainrotData.BuildModel(entry)

	local angle = math.random() * math.pi * 2
	local dist = math.sqrt(math.random()) * zone.Radius
	local pos = Vector3.new(
		zone.Center.X + math.cos(angle) * dist,
		zone.GroundY,
		zone.Center.Z + math.sin(angle) * dist
	)
	model:PivotTo(CFrame.new(pos) * CFrame.Angles(0, math.random() * math.pi * 2, 0))
	model.Parent = getWildFolder()

	GameState.Wild[model] = {
		EntryId = entry.Id,
		Mutation = nil,
		Zone = zoneKey,
		BasePos = pos,
		Spin = math.random() * math.pi * 2,
		Phase = math.random() * math.pi * 2,
	}
	return model
end

-- Re-register an existing model as a wild brainrot (used when a stolen
-- brainrot is dropped): it keeps its mutation and can be picked up again.
function CollectionService.RegisterWild(model, entryId, mutation)
	local pivot = model:GetPivot()
	local world = GameState.World
	local groundY = pivot.Position.Y
	local nearestZone = "Meadow"
	if world then
		local best = math.huge
		for zoneKey, zone in pairs(world.Zones) do
			local d = (Vector3.new(pivot.Position.X, 0, pivot.Position.Z) - Vector3.new(zone.Center.X, 0, zone.Center.Z)).Magnitude
			if d < best then
				best = d
				nearestZone = zoneKey
				groundY = zone.GroundY
			end
		end
	end
	local body = model:FindFirstChild("Body")
	if body then
		body.Anchored = true
	end
	model:PivotTo(CFrame.new(pivot.Position.X, groundY, pivot.Position.Z) * CFrame.Angles(0, math.random() * math.pi * 2, 0))
	model.Parent = getWildFolder()
	GameState.Wild[model] = {
		EntryId = entryId,
		Mutation = mutation,
		Zone = nearestZone,
		BasePos = Vector3.new(pivot.Position.X, groundY, pivot.Position.Z),
		Spin = math.random() * math.pi * 2,
		Phase = math.random() * math.pi * 2,
	}
end

-- ---------------------------------------------------------------------------
-- Pickup / carry / deposit
-- ---------------------------------------------------------------------------
local function getRoot(player)
	local character = player and player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

function CollectionService.PickupWild(profile, model, wild)
	local player = profile.Player
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local body = model and model:FindFirstChild("Body")
	if not head or not body then
		return false
	end

	GameState.Wild[model] = nil
	body.Anchored = false
	model:PivotTo(head.CFrame * CFrame.new(0, 3.1, 0))

	local weld = Instance.new("WeldConstraint")
	weld.Name = "CarryWeld"
	weld.Part0 = body
	weld.Part1 = head
	weld.Parent = body

	profile.Carrying = {
		EntryId = wild.EntryId,
		Model = model,
		Mutation = wild.Mutation,
		StolenFrom = nil,
	}
	GameState.MarkDiscovered(profile, wild.EntryId)
	local entry = BrainrotData.ById[wild.EntryId]
	player:SetAttribute("Carrying", entry and entry.Name or "")
	return true
end

function CollectionService.PlaceOnPedestal(profile, model, slot)
	local world = GameState.World
	if not world or not profile.BaseIndex then
		return false
	end
	local base = world.Bases[profile.BaseIndex]
	local pedestal = base and base.Pedestals[slot]
	if not pedestal then
		return false
	end
	local topPos = pedestal.Position + Vector3.new(0, pedestal.Size.Y / 2, 0)
	local faceCenter = Vector3.new(base.Center.X, topPos.Y, base.Center.Z)
	-- Face outward from the base centre so visitors see the collection.
	local outward = (topPos - faceCenter)
	outward = Vector3.new(outward.X, 0, outward.Z)
	local lookTarget = topPos + (outward.Magnitude > 0.1 and outward.Unit or Vector3.new(0, 0, 1)) * 10
	model:PivotTo(CFrame.lookAt(topPos, lookTarget))
	local body = model:FindFirstChild("Body")
	if body then
		body.Anchored = true
	end
	model.Parent = getDisplayFolder()
	return true
end

-- Lowest free pedestal slot for a profile (displayed items remember their
-- slot, so a stolen piece leaves a gap that later deposits refill first).
function CollectionService.FindFreeSlot(profile)
	if not profile.BaseIndex then
		return nil
	end
	local used = {}
	for _, item in ipairs(profile.Displayed) do
		if item.Slot then
			used[item.Slot] = true
		end
	end
	for slot = 1, Config.PedestalsPerBase do
		if not used[slot] then
			return slot
		end
	end
	return nil
end

function CollectionService.DepositCarried(profile)
	local carrying = profile.Carrying
	if not carrying then
		return false
	end
	local player = profile.Player

	-- Validate placement BEFORE touching the carry weld, so a failed deposit
	-- never strands the model.
	local slot = CollectionService.FindFreeSlot(profile)
	if not slot then
		if profile.BaseIndex then
			GameState.GetRemote("Notify"):FireClient(player, "Your base is full! (" .. Config.PedestalsPerBase .. " pedestals)")
		else
			GameState.GetRemote("Notify"):FireClient(player, "You have no base plot on this server!")
		end
		return false
	end

	local model = carrying.Model
	local entry = BrainrotData.ById[carrying.EntryId]
	if not entry or not model or not model.Parent then
		profile.Carrying = nil
		player:SetAttribute("Carrying", "")
		return false
	end

	local body = model:FindFirstChild("Body")
	if body then
		local weld = body:FindFirstChild("CarryWeld")
		if weld then
			weld:Destroy()
		end
	end

	-- The mutation roll happens HERE, at deposit time -- unless the model
	-- already carries one (a stolen / recovered display piece keeps it).
	local mutation = carrying.Mutation
	if not mutation then
		mutation = MutationService.Roll()
	end
	MutationService.ApplyVisual(model, mutation)
	local income = MutationService.IncomeFor(entry, mutation)

	if not CollectionService.PlaceOnPedestal(profile, model, slot) then
		return false
	end

	table.insert(profile.Displayed, {
		Model = model,
		EntryId = entry.Id,
		Mutation = mutation,
		Income = income,
		Slot = slot,
	})
	profile.Carrying = nil
	player:SetAttribute("Carrying", "")

	GameState.GetRemote("MutationReveal"):FireClient(
		player,
		entry.Name,
		mutation,
		MutationService.GetMultiplier(mutation)
	)
	return true
end

-- Rebuild a saved display collection after login.
function CollectionService.RestoreDisplay(profile)
	if not profile.RestoreList then
		return
	end
	for i, saved in ipairs(profile.RestoreList) do
		if i > Config.PedestalsPerBase then
			break
		end
		local entry = BrainrotData.ById[saved.EntryId]
		if entry then
			local mutation = saved.Mutation or "Normal"
			if not MutationService.IsValid(mutation) then
				mutation = "Normal"
			end
			local model = BrainrotData.BuildModel(entry)
			MutationService.ApplyVisual(model, mutation)
			if CollectionService.PlaceOnPedestal(profile, model, i) then
				table.insert(profile.Displayed, {
					Model = model,
					EntryId = entry.Id,
					Mutation = mutation,
					Income = MutationService.IncomeFor(entry, mutation),
					Slot = i,
				})
				GameState.MarkDiscovered(profile, entry.Id)
			else
				model:Destroy()
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Main loops
-- ---------------------------------------------------------------------------
function CollectionService.Start()
	if started then
		return
	end
	started = true
	GameState.WaitForWorld()
	getWildFolder()
	getDisplayFolder()

	-- Per-zone spawn loops.
	for zoneKey, spawnConfig in pairs(Config.ZoneSpawns) do
		task.spawn(function()
			-- Stagger the first spawns so the island fills in quickly.
			for _ = 1, math.floor(spawnConfig.MaxWild / 2) do
				CollectionService.SpawnWild(zoneKey)
			end
			while true do
				task.wait(spawnConfig.Interval)
				if CollectionService.CountWildInZone(zoneKey) < spawnConfig.MaxWild then
					CollectionService.SpawnWild(zoneKey)
				end
			end
		end)
	end

	-- Idle animation: wild brainrots bob and slowly spin in place.
	task.spawn(function()
		while true do
			local dt = task.wait(0.12)
			local now = os.clock()
			for model, wild in pairs(GameState.Wild) do
				if model and model.Parent then
					wild.Spin += dt * 0.45
					local bob = math.sin(now * 2 + wild.Phase) * 0.28
					local pos = wild.BasePos + Vector3.new(0, bob, 0)
					model:PivotTo(CFrame.new(pos) * CFrame.Angles(0, wild.Spin, 0))
				end
			end
		end
	end)

	-- Pickup / deposit proximity loop.
	task.spawn(function()
		while true do
			task.wait(0.2)
			local world = GameState.World
			if not world then
				continue
			end
			for _, player in ipairs(Players:GetPlayers()) do
				local profile = GameState.GetProfile(player)
				local root = profile and getRoot(player)
				if profile and root then
					if profile.Carrying then
						-- Carry maintenance: if the model was destroyed, clear
						-- the carry; if it fell into the ocean, drop it back
						-- into the wild; if the player respawned, the weld
						-- still points at the old head -- re-attach it.
						local carrying = profile.Carrying
						local model = carrying.Model
						if not model or not model.Parent then
							profile.Carrying = nil
							player:SetAttribute("Carrying", "")
							carrying = nil
						elseif model:GetPivot().Position.Y < -5 then
							profile.Carrying = nil
							player:SetAttribute("Carrying", "")
							CollectionService.RegisterWild(model, carrying.EntryId, carrying.Mutation)
							carrying = nil
						else
							local character = player.Character
							local head = character and character:FindFirstChild("Head")
							local body = model:FindFirstChild("Body")
							if head and body then
								local weld = body:FindFirstChild("CarryWeld")
								if not weld or weld.Part1 ~= head then
									if weld then
										weld:Destroy()
									end
									body.Anchored = false
									model:PivotTo(head.CFrame * CFrame.new(0, 3.1, 0))
									local newWeld = Instance.new("WeldConstraint")
									newWeld.Name = "CarryWeld"
									newWeld.Part0 = body
									newWeld.Part1 = head
									newWeld.Parent = body
								end
							end
						end
					end
					if profile.Carrying then
						-- Deposit at the player's own pad.
						if profile.BaseIndex then
							local base = world.Bases[profile.BaseIndex]
							if base and (root.Position - base.DepositPad.Position).Magnitude <= Config.DepositRadius then
								CollectionService.DepositCarried(profile)
							end
						end
					else
						-- Find the nearest wild brainrot in reach.
						local nearestModel, nearestWild, nearestDist = nil, nil, Config.PickupRadius
						for model, wild in pairs(GameState.Wild) do
							if model and model.Parent then
								local d = (root.Position - model:GetPivot().Position).Magnitude
								if d <= nearestDist then
									nearestModel, nearestWild, nearestDist = model, wild, d
								end
							end
						end
						if nearestModel then
							CollectionService.PickupWild(profile, nearestModel, nearestWild)
						end
					end
				end
			end
		end
	end)

	print("[ChaosBrainrot] CollectionService started.")
end

return CollectionService
