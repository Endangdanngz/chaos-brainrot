-- StealService.luau (ModuleScript)
-- CHAOS BRAINROT: MUTATION ISLAND
-- Player-versus-player stealing, kept fair:
--   * Only DISPLAYED brainrots can be stolen, only from an UNLOCKED base.
--   * A base lock can be bought with Cash and shields the base for 60s
--     (a glowing dome shows while it is active).
--   * The thief must carry the loot home on their head; if the owner tags
--     them (gets close) before they deposit it, the brainrot drops and
--     becomes wild again, keeping its mutation.
--   * A per-thief cooldown stops chain-stealing.
-- Everything is validated on the server.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local BrainrotData = require(Shared:WaitForChild("BrainrotData"))

local Server = ServerScriptService:WaitForChild("Server")
local GameState = require(Server:WaitForChild("GameState"))
local CollectionService = require(Server:WaitForChild("CollectionService"))

local StealService = {}
local inited = false

local function notify(player, text)
	GameState.GetRemote("Notify"):FireClient(player, text)
end

local function getRoot(player)
	local character = player and player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

-- ---------------------------------------------------------------------------
-- Base lock
-- ---------------------------------------------------------------------------
local function buyLock(player)
	local profile = GameState.GetProfile(player)
	if not profile then
		return
	end
	local now = os.clock()
	if now < profile.LockUntil then
		notify(player, "Your base is already locked (" .. math.ceil(profile.LockUntil - now) .. "s left).")
		return
	end
	if GameState.GetCash(profile) < Config.BaseLockPrice then
		notify(player, "Base lock costs $" .. Config.BaseLockPrice .. " -- not enough cash!")
		return
	end
	GameState.AddCash(profile, -Config.BaseLockPrice)
	profile.LockUntil = now + Config.BaseLockDuration
	notify(player, "Base locked for " .. Config.BaseLockDuration .. " seconds!")
end

local function startLockLoop()
	task.spawn(function()
		while true do
			task.wait(0.5)
			local world = GameState.World
			if world then
				local now = os.clock()
				for _, profile in pairs(GameState.Profiles) do
					local locked = now < profile.LockUntil
					profile.Player:SetAttribute("BaseLocked", locked)
					profile.Player:SetAttribute("LockSeconds", locked and math.ceil(profile.LockUntil - now) or 0)
					if profile.BaseIndex then
						local base = world.Bases[profile.BaseIndex]
						if base and base.Dome then
							base.Dome.Visible = locked
						end
					end
				end
			end
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Stealing
-- ---------------------------------------------------------------------------
local function attachToThief(thiefProfile, model)
	local character = thiefProfile.Player.Character
	local head = character and character:FindFirstChild("Head")
	local body = model and model:FindFirstChild("Body")
	if not head or not body then
		return false
	end
	body.Anchored = false
	model:PivotTo(head.CFrame * CFrame.new(0, 3.1, 0))
	local weld = Instance.new("WeldConstraint")
	weld.Name = "CarryWeld"
	weld.Part0 = body
	weld.Part1 = head
	weld.Parent = body
	return true
end

local function trySteal(thief, thiefProfile)
	local world = GameState.World
	if not world then
		return
	end
	local thiefRoot = getRoot(thief)
	if not thiefRoot then
		return
	end
	for _, victim in ipairs(Players:GetPlayers()) do
		if victim ~= thief then
			local victimProfile = GameState.GetProfile(victim)
			if victimProfile and victimProfile.BaseIndex and #victimProfile.Displayed > 0 then
				if os.clock() >= victimProfile.LockUntil then
					-- Find the displayed brainrot the thief is standing at.
					for i, item in ipairs(victimProfile.Displayed) do
						if item.Model and item.Model.Parent then
							local dist = (thiefRoot.Position - item.Model:GetPivot().Position).Magnitude
							if dist <= 6.5 then
								table.remove(victimProfile.Displayed, i)
								if not attachToThief(thiefProfile, item.Model) then
									table.insert(victimProfile.Displayed, i, item)
									return
								end
								thiefProfile.Carrying = {
									EntryId = item.EntryId,
									Model = item.Model,
									Mutation = item.Mutation,
									StolenFrom = victim,
								}
								thiefProfile.LastStealAt = os.clock()
								GameState.MarkDiscovered(thiefProfile, item.EntryId)
								local entry = BrainrotData.ById[item.EntryId]
								local entryName = entry and entry.Name or "a brainrot"
								thief:SetAttribute("Carrying", entryName)
								notify(thief, "You stole " .. entryName .. "! Carry it to YOUR base -- don't let the owner tag you!")
								notify(victim, thief.DisplayName .. " stole your " .. entryName .. "! Tag them before they reach their base!")
								return
							end
						end
					end
				end
			end
		end
	end
end

local function dropStolen(thiefProfile)
	local carrying = thiefProfile.Carrying
	if not carrying or not carrying.Model then
		thiefProfile.Carrying = nil
		return
	end
	local model = carrying.Model
	local body = model:FindFirstChild("Body")
	if body then
		local weld = body:FindFirstChild("CarryWeld")
		if weld then
			weld:Destroy()
		end
	end
	local victim = carrying.StolenFrom
	thiefProfile.Carrying = nil
	thiefProfile.Player:SetAttribute("Carrying", "")
	CollectionService.RegisterWild(model, carrying.EntryId, carrying.Mutation)
	local entry = BrainrotData.ById[carrying.EntryId]
	local entryName = entry and entry.Name or "the brainrot"
	notify(thiefProfile.Player, "Tagged! You dropped " .. entryName .. "!")
	if victim then
		notify(victim, "You tagged the thief! " .. entryName .. " dropped -- grab it back!")
	end
end

local function startStealLoops()
	-- Steal attempts: proximity to a displayed brainrot on an unlocked base.
	task.spawn(function()
		while true do
			task.wait(0.25)
			for _, player in ipairs(Players:GetPlayers()) do
				local profile = GameState.GetProfile(player)
				if profile and not profile.Carrying then
					if os.clock() - profile.LastStealAt >= Config.StealCooldown then
						trySteal(player, profile)
					end
				end
			end
		end
	end)

	-- Tag-backs: the owner catching the thief makes them drop the loot.
	task.spawn(function()
		while true do
			task.wait(0.2)
			for _, player in ipairs(Players:GetPlayers()) do
				local profile = GameState.GetProfile(player)
				if profile and profile.Carrying and profile.Carrying.StolenFrom then
					local victim = profile.Carrying.StolenFrom
					local thiefRoot = getRoot(player)
					local victimRoot = getRoot(victim)
					if thiefRoot and victimRoot then
						if (thiefRoot.Position - victimRoot.Position).Magnitude <= Config.TagRange then
							dropStolen(profile)
						end
					end
				end
			end
		end
	end)
end

function StealService.Init()
	if inited then
		return
	end
	inited = true

	GameState.GetRemote("RequestLock").OnServerEvent:Connect(function(player)
		buyLock(player)
	end)

	startLockLoop()
	startStealLoops()
	print("[ChaosBrainrot] StealService ready.")
end

return StealService
