-- Effects.client.luau
-- CHAOS BRAINROT: MUTATION ISLAND
-- Client-side juice driven by server RemoteEvents: mutation sparkle bursts
-- on the player's character when a deposit mutates, a screen flash for the
-- rarest mutations, and a swirling aura while a Mutation Storm is active.
-- Purely cosmetic -- all game state stays on the server.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local mutationReveal = Remotes:WaitForChild("MutationReveal")
local eventAnnounce = Remotes:WaitForChild("EventAnnounce")

-- Flash frame for jackpot mutations.
local fxGui = Instance.new("ScreenGui")
fxGui.Name = "ChaosEffects"
fxGui.ResetOnSpawn = false
fxGui.DisplayOrder = 4
fxGui.Parent = playerGui

local flash = Instance.new("Frame")
flash.Name = "Flash"
flash.Size = UDim2.new(1, 0, 1, 0)
flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.Parent = fxGui

local function getRoot()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function burst(color, count, size)
	local root = getRoot()
	if not root then
		return
	end
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "MutationBurst"
	emitter.Color = ColorSequence.new(color)
	emitter.LightEmission = 1
	emitter.LightInfluence = 0
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, size or 0.5),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.7, 1.4)
	emitter.Speed = NumberRange.new(4, 9)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = root
	emitter:Emit(count or 30)

	local light = Instance.new("PointLight")
	light.Name = "MutationFlash"
	light.Color = color
	light.Brightness = 3
	light.Range = 14
	light.Parent = root

	task.spawn(function()
		task.wait(1.4)
		if emitter and emitter.Parent then
			emitter:Destroy()
		end
		if light and light.Parent then
			light:Destroy()
		end
	end)
end

mutationReveal.OnClientEvent:Connect(function(_entryName, mutationName, multiplier)
	local color = Color3.fromRGB(235, 240, 255)
	local visual = mutationName and Config.MutationVisuals[mutationName]
	if visual and visual.Glow then
		color = Color3.fromRGB(visual.Glow[1], visual.Glow[2], visual.Glow[3])
	end
	if mutationName == "Normal" or not mutationName then
		burst(color, 14, 0.35)
		return
	end
	burst(color, 34, 0.55)
	if multiplier and multiplier >= 8 then
		-- Jackpot mutation: full-screen flash in the mutation's color.
		flash.BackgroundColor3 = color
		flash.BackgroundTransparency = 0.55
		TweenService:Create(flash, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
		burst(color, 40, 0.7)
	end
end)

-- Mutation Storm aura around the player while the storm runs.
local stormAura = nil
local function removeStormAura()
	if stormAura and stormAura.Parent then
		stormAura:Destroy()
	end
	stormAura = nil
end

eventAnnounce.OnClientEvent:Connect(function(eventKey)
	if eventKey == "MutationStorm" then
		removeStormAura()
		local root = getRoot()
		if root then
			stormAura = Instance.new("ParticleEmitter")
			stormAura.Name = "StormAura"
			stormAura.Color = ColorSequence.new(Color3.fromRGB(190, 130, 255), Color3.fromRGB(255, 110, 230))
			stormAura.LightEmission = 1
			stormAura.LightInfluence = 0
			stormAura.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4),
				NumberSequenceKeypoint.new(1, 0),
			})
			stormAura.Rate = 22
			stormAura.Lifetime = NumberRange.new(0.8, 1.5)
			stormAura.Speed = NumberRange.new(2, 4)
			stormAura.SpreadAngle = Vector2.new(180, 180)
			stormAura.Parent = root
			task.spawn(function()
				task.wait(Config.MutationStormDuration + 2)
				if stormAura and stormAura.Name == "StormAura" then
					removeStormAura()
				end
			end)
		end
	elseif eventKey == "MutationStormEnd" then
		removeStormAura()
	end
end)

player.CharacterAdded:Connect(function()
	removeStormAura()
end)
