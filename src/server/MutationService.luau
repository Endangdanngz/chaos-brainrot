-- MutationService.luau (ModuleScript)
-- CHAOS BRAINROT: MUTATION ISLAND
-- Rolls a mutation when a brainrot is deposited and applies the mutation's
-- look (tint / material / glow particles) to the character model. The roll
-- table lives in Config; during a MutationStorm event every non-Normal
-- weight is boosted.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local ServerScriptService = game:GetService("ServerScriptService")
local GameState = require(ServerScriptService:WaitForChild("Server"):WaitForChild("GameState"))

local MutationService = {}

local MULTIPLIERS = {}
for _, mutation in ipairs(Config.Mutations) do
	MULTIPLIERS[mutation.Name] = mutation.Multiplier
end

function MutationService.GetMultiplier(mutationName)
	return MULTIPLIERS[mutationName] or 1
end

function MutationService.IsValid(mutationName)
	return type(mutationName) == "string" and MULTIPLIERS[mutationName] ~= nil
end

function MutationService.IncomeFor(entry, mutationName)
	return entry.Income * MutationService.GetMultiplier(mutationName)
end

-- Roll a mutation name using Config chances. When a MutationStorm is active
-- the rare outcomes become much more likely.
function MutationService.Roll()
	local storm = GameState.IsStormActive()
	local total = 0
	local weights = {}
	for i, mutation in ipairs(Config.Mutations) do
		local weight = mutation.Chance
		if storm and mutation.Name ~= "Normal" then
			weight = weight * Config.MutationStormBoost
		end
		weights[i] = weight
		total += weight
	end
	local roll = math.random() * total
	local cumulative = 0
	for i, mutation in ipairs(Config.Mutations) do
		cumulative += weights[i]
		if roll <= cumulative then
			return mutation.Name
		end
	end
	return "Normal"
end

local GLITCH_PALETTE = {
	Color3.fromRGB(255, 92, 246),
	Color3.fromRGB(92, 255, 230),
	Color3.fromRGB(255, 230, 92),
	Color3.fromRGB(140, 120, 255),
	Color3.fromRGB(120, 255, 120),
}

-- Apply the mutation's visual treatment to a built model. Safe to call on a
-- model that already shows another mutation (sparkles/glow are replaced).
function MutationService.ApplyVisual(model, mutationName)
	if not model then
		return
	end
	local visual = Config.MutationVisuals[mutationName]
	model:SetAttribute("Mutation", mutationName)
	if not visual then
		return
	end

	local body = model:FindFirstChild("Body")
	if not body then
		return
	end

	-- Clear a previous mutation's effects.
	local oldSparkles = body:FindFirstChild("MutationSparkles")
	if oldSparkles then
		oldSparkles:Destroy()
	end
	local oldGlow = body:FindFirstChild("MutationGlow")
	if oldGlow then
		oldGlow:Destroy()
	end

	if visual.Tint then
		local tint = Color3.fromRGB(visual.Tint[1], visual.Tint[2], visual.Tint[3])
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name ~= "Eye" and descendant.Name ~= "Pupil" then
				descendant.Color = tint
			end
		end
	end

	if visual.Material then
		local ok, material = pcall(function()
			return Enum.Material[visual.Material]
		end)
		if ok and material then
			body.Material = material
		end
	end

	if mutationName == "Glitched" then
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name ~= "Eye" and descendant.Name ~= "Pupil" then
				if math.random() < 0.45 then
					descendant.Color = GLITCH_PALETTE[math.random(1, #GLITCH_PALETTE)]
				end
			end
		end
	end

	if visual.Glow then
		local glowColor = Color3.fromRGB(visual.Glow[1], visual.Glow[2], visual.Glow[3])

		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Name = "MutationSparkles"
		sparkles.Color = ColorSequence.new(glowColor)
		sparkles.LightEmission = 1
		sparkles.LightInfluence = 0
		sparkles.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.35),
			NumberSequenceKeypoint.new(1, 0),
		})
		sparkles.Rate = 14
		sparkles.Lifetime = NumberRange.new(0.6, 1.3)
		sparkles.Speed = NumberRange.new(1, 2.5)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Parent = body

		local light = Instance.new("PointLight")
		light.Name = "MutationGlow"
		light.Color = glowColor
		light.Brightness = 1.1
		light.Range = 8
		light.Parent = body
	end
end

return MutationService
