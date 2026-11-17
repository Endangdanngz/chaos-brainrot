-- Main.server.luau
-- CHAOS BRAINROT: MUTATION ISLAND
-- Bootstrap: creates the RemoteEvents, owns player profiles (leaderstats +
-- DataStore with a Studio-safe session fallback), assigns base plots, and
-- starts every gameplay service. All money/inventory authority lives on the
-- server; this script is the entry point that wires it together.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local BrainrotData = require(Shared:WaitForChild("BrainrotData"))

local Server = ServerScriptService:WaitForChild("Server")
local GameState = require(Server:WaitForChild("GameState"))
local MutationService = require(Server:WaitForChild("MutationService"))
local CollectionService = require(Server:WaitForChild("CollectionService"))
local EconomyService = require(Server:WaitForChild("EconomyService"))
local EventService = require(Server:WaitForChild("EventService"))
local RebirthService = require(Server:WaitForChild("RebirthService"))
local StealService = require(Server:WaitForChild("StealService"))

-- ---------------------------------------------------------------------------
-- RemoteEvents (created here, before any service starts)
-- ---------------------------------------------------------------------------
local REMOTE_NAMES = {
	"EventAnnounce", -- server -> client: chaos event banner
	"Notify", -- server -> client: toast messages (steal, rebirth, lock...)
	"MutationReveal", -- server -> client: a deposit rolled a mutation
	"RequestRebirth", -- client -> server
	"RequestLock", -- client -> server
}

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end
for _, name in ipairs(REMOTE_NAMES) do
	if not remotesFolder:FindFirstChild(name) then
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = remotesFolder
	end
end

-- ---------------------------------------------------------------------------
-- DataStore (guarded: any failure means this session simply doesn't persist)
-- ---------------------------------------------------------------------------
local profileStore = nil
do
	local ok, store = pcall(function()
		return DataStoreService:GetDataStore(Config.DataStoreName)
	end)
	if ok then
		profileStore = store
	else
		warn("[ChaosBrainrot] DataStore unavailable, running session-only: " .. tostring(store))
	end
end

local function loadSave(userId)
	if not profileStore then
		return nil
	end
	local ok, data = pcall(function()
		return profileStore:GetAsync("player_" .. userId)
	end)
	if ok and type(data) == "table" then
		return data
	end
	return nil
end

local function writeSave(profile)
	if not profileStore or not profile then
		return
	end
	local displayed = {}
	for _, item in ipairs(profile.Displayed) do
		table.insert(displayed, { EntryId = item.EntryId, Mutation = item.Mutation })
	end
	local discovered = {}
	for entryId in pairs(profile.Discovered) do
		table.insert(discovered, entryId)
	end
	local leaderstats = profile.Player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end
	local cashValue = leaderstats:FindFirstChild("Cash")
	local gemsValue = leaderstats:FindFirstChild("Gems")
	local rebirthsValue = leaderstats:FindFirstChild("Rebirths")
	if not cashValue or not gemsValue or not rebirthsValue then
		return
	end
	local data = {
		Cash = cashValue.Value,
		Gems = gemsValue.Value,
		Rebirths = rebirthsValue.Value,
		Displayed = displayed,
		Discovered = discovered,
	}
	pcall(function()
		profileStore:SetAsync("player_" .. profile.Player.UserId, data)
	end)
end

-- ---------------------------------------------------------------------------
-- Base assignment
-- ---------------------------------------------------------------------------
local function assignBase(profile)
	local world = GameState.WaitForWorld()
	for _, base in ipairs(world.Bases) do
		if base.Owner == nil then
			base.Owner = profile.Player
			profile.BaseIndex = base.Index
			if base.SignLabel then
				base.SignLabel.Text = profile.Player.DisplayName .. "'s Base"
			end
			return base
		end
	end
	return nil -- server has more players than plots: player roams without a base
end

local function releaseBase(profile)
	local world = GameState.World
	if not world or not profile.BaseIndex then
		return
	end
	local base = world.Bases[profile.BaseIndex]
	if base and base.Owner == profile.Player then
		base.Owner = nil
		if base.SignLabel then
			base.SignLabel.Text = "Empty Plot"
		end
	end
	profile.BaseIndex = nil
end

local function teleportToBase(player)
	local profile = GameState.GetProfile(player)
	if not profile then
		return
	end
	local deadline = os.clock() + 15
	while not profile.BaseIndex and os.clock() < deadline do
		task.wait(0.25)
	end
	local world = GameState.World
	if not world or not profile.BaseIndex then
		return
	end
	local base = world.Bases[profile.BaseIndex]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if base and base.SpawnPad and root then
		root.CFrame = base.SpawnPad.CFrame + Vector3.new(0, 3, 0)
	end
end

-- ---------------------------------------------------------------------------
-- Player lifecycle
-- ---------------------------------------------------------------------------
local function onCharacterAdded(player, character)
	task.spawn(teleportToBase, player)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		humanoid.WalkSpeed = 20
	end
end

local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = Config.StartCash
	cash.Parent = leaderstats

	local gems = Instance.new("IntValue")
	gems.Name = "Gems"
	gems.Value = Config.StartGems
	gems.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	leaderstats.Parent = player

	local profile = {
		Player = player,
		CashRemainder = 0,
		Displayed = {},
		Carrying = nil,
		BaseIndex = nil,
		LockUntil = 0,
		LastStealAt = 0,
		Discovered = {},
		RestoreList = nil,
	}
	GameState.Profiles[player.UserId] = profile

	player:SetAttribute("IncomePerSecond", 0)
	player:SetAttribute("Carrying", "")
	player:SetAttribute("BaseLocked", false)
	player:SetAttribute("LockSeconds", 0)

	-- Click-to-move: clicking the ground walks the character there, which
	-- lets mouse-only players (and phone remote-desktop testers, whose WASD
	-- keys never reach the game) move around. Desktop keyboard movement
	-- still works in this mode; it only ADDS click navigation.
	pcall(function()
		player.DevComputerMovementMode = Enum.DevComputerMovementMode.ClickToMove
	end)

	-- Restore saved progress (session-only fallback when this returns nil).
	local save = loadSave(player.UserId)
	if save then
		cash.Value = math.max(0, math.floor(save.Cash or 0))
		gems.Value = math.max(0, math.floor(save.Gems or 0))
		rebirths.Value = math.max(0, math.floor(save.Rebirths or 0))
		if type(save.Discovered) == "table" then
			for _, entryId in ipairs(save.Discovered) do
				if BrainrotData.ById[entryId] then
					GameState.MarkDiscovered(profile, entryId)
				end
			end
		end
		if type(save.Displayed) == "table" then
			profile.RestoreList = save.Displayed
		end
	end

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character)
	end

	-- Assign a base plot, then rebuild any saved display collection on it.
	task.spawn(function()
		local base = assignBase(profile)
		if base and profile.RestoreList then
			CollectionService.RestoreDisplay(profile)
			profile.RestoreList = nil
		end
		if player.Character then
			teleportToBase(player)
		end
	end)
end

local function onPlayerRemoving(player)
	local profile = GameState.GetProfile(player)
	if not profile then
		return
	end
	writeSave(profile)
	if profile.Carrying and profile.Carrying.Model then
		profile.Carrying.Model:Destroy()
	end
	for _, item in ipairs(profile.Displayed) do
		if item.Model then
			item.Model:Destroy()
		end
	end
	releaseBase(profile)
	GameState.Profiles[player.UserId] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- Autosave + shutdown save.
task.spawn(function()
	while true do
		task.wait(Config.AutosaveSeconds)
		for _, profile in pairs(GameState.Profiles) do
			writeSave(profile)
		end
	end
end)

game:BindToClose(function()
	for _, profile in pairs(GameState.Profiles) do
		writeSave(profile)
	end
end)

-- ---------------------------------------------------------------------------
-- Start gameplay services
-- ---------------------------------------------------------------------------
task.spawn(EconomyService.Start)
task.spawn(CollectionService.Start)
task.spawn(EventService.Start)
RebirthService.Init()
StealService.Init()

print("[ChaosBrainrot] Main bootstrap complete: " .. BrainrotData.Count .. " brainrots loaded.")
