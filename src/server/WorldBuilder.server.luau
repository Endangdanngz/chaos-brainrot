-- WorldBuilder.server.luau
-- CHAOS BRAINROT: MUTATION ISLAND
-- Builds the entire island procedurally at server start: four themed zones
-- (Spawn Meadow, Neon Swamp, Volcano Ashlands, and the floating Crystal Void
-- islet), eight player base plots around the shore, and the landmark set
-- pieces (giant tree, volcano, crystal tower, mountain). No baseplate, no
-- external assets -- everything is Parts, MeshParts-style primitives,
-- ParticleEmitters and Lighting effects placed by this script.
-- Publishes the layout into GameState.World for the gameplay services.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ServerScriptService = game:GetService("ServerScriptService")

local GameState = require(ServerScriptService:WaitForChild("Server"):WaitForChild("GameState"))

local island = Instance.new("Folder")
island.Name = "ChaosIsland"
island.Parent = Workspace

local decor = Instance.new("Folder")
decor.Name = "Decor"
decor.Parent = island

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
local function makePart(name, size, cframe, color, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent or decor
	return part
end

local function makeDisc(name, radius, height, position, color, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(height, radius * 2, radius * 2)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent or decor
	return part
end

local function makeTree(position, trunkColor, leafColor, scale, tilt)
	local group = Instance.new("Folder")
	group.Name = "Tree"
	group.Parent = decor
	local trunkHeight = 13 * scale
	local trunk = makePart(
		"Trunk",
		Vector3.new(2.2 * scale, trunkHeight, 2.2 * scale),
		CFrame.new(position + Vector3.new(0, trunkHeight / 2, 0)) * CFrame.Angles(0, 0, math.rad(tilt or 0)),
		trunkColor,
		Enum.Material.Wood,
		group
	)
	trunk.Shape = Enum.PartType.Cylinder
	for i = 1, 3 do
		local offset = Vector3.new((i - 2) * 2.6 * scale, trunkHeight + (i % 2) * 1.6 * scale, (i % 2) * 2.2 * scale)
		local leaf = makePart(
			"Leaves",
			Vector3.new(8.5 * scale, 7 * scale, 8.5 * scale),
			CFrame.new(position + offset),
			leafColor,
			Enum.Material.Grass,
			group
		)
		leaf.Shape = Enum.PartType.Ball
	end
	return group
end

local function makeSign(position, lookAt, text, textColor, scale)
	local board = makePart(
		"SignBoard",
		Vector3.new(16 * scale, 6 * scale, 0.6),
		CFrame.lookAt(position, Vector3.new(lookAt.X, position.Y, lookAt.Z)),
		Color3.fromRGB(40, 34, 54),
		Enum.Material.Wood
	)
	local gui = Instance.new("BillboardGui")
	gui.Name = "SignGui"
	gui.Size = UDim2.new(22 * scale, 0, 7 * scale, 0)
	gui.StudsOffset = Vector3.new(0, 1, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 220
	gui.Adornee = board
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Name = "SignText"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = textColor
	label.TextStrokeTransparency = 0.3
	label.Text = text
	label.Parent = gui
	return board, label
end

-- ---------------------------------------------------------------------------
-- Lighting / atmosphere (the screenshot look)
-- ---------------------------------------------------------------------------
Lighting.ClockTime = 16.6
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(96, 86, 122)
Lighting.OutdoorAmbient = Color3.fromRGB(128, 122, 150)
Lighting.FogColor = Color3.fromRGB(150, 130, 180)
Lighting.FogStart = 350
Lighting.FogEnd = 1100

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.26
atmosphere.Offset = 0.2
atmosphere.Color = Color3.fromRGB(214, 196, 235)
atmosphere.Decay = Color3.fromRGB(108, 92, 150)
atmosphere.Glare = 0.35
atmosphere.Haze = 1.6
atmosphere.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.55
bloom.Size = 26
bloom.Threshold = 0.82
bloom.Parent = Lighting

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Saturation = 0.14
colorCorrection.Contrast = 0.06
colorCorrection.TintColor = Color3.fromRGB(255, 246, 238)
colorCorrection.Parent = Lighting

local sunRays = Instance.new("SunRaysEffect")
sunRays.Intensity = 0.09
sunRays.Spread = 0.7
sunRays.Parent = Lighting

-- ---------------------------------------------------------------------------
-- Ocean + island shell
-- ---------------------------------------------------------------------------
local ocean = makePart(
	"Ocean",
	Vector3.new(1600, 2, 1600),
	CFrame.new(0, -3.5, 0),
	Color3.fromRGB(28, 92, 150),
	Enum.Material.Glass
)
ocean.Transparency = 0.3
ocean.CanCollide = false

makeDisc("IslandBase", 275, 7, Vector3.new(0, -1.5, 0), Color3.fromRGB(104, 168, 92), Enum.Material.Grass)
makeDisc("SandRim", 282, 3, Vector3.new(0, -2.2, 0), Color3.fromRGB(232, 208, 150), Enum.Material.Sand)

-- ---------------------------------------------------------------------------
-- Zone: Spawn Meadow (south) -- safe, bright, the postcard shot
-- ---------------------------------------------------------------------------
local MEADOW = Vector3.new(0, 2, 150)
makeDisc("MeadowGround", 88, 1.2, Vector3.new(0, 2.2, 150), Color3.fromRGB(116, 196, 96), Enum.Material.Grass)

-- Plaza + title sign + spawn location
makeDisc("Plaza", 20, 0.6, Vector3.new(0, 3, 150), Color3.fromRGB(178, 172, 186), Enum.Material.Slate)
local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "IslandSpawn"
spawnLocation.Size = Vector3.new(10, 1, 10)
spawnLocation.CFrame = CFrame.new(0, 3.6, 150)
spawnLocation.Color = Color3.fromRGB(120, 220, 160)
spawnLocation.Material = Enum.Material.Neon
spawnLocation.Neutral = true
spawnLocation.Anchored = true
spawnLocation.Transparency = 0.4
spawnLocation.Parent = island

makeSign(Vector3.new(0, 10, 128), Vector3.new(0, 10, 200), "CHAOS BRAINROT\nMUTATION ISLAND", Color3.fromRGB(255, 230, 120), 1.6)

-- The giant tree landmark
makeTree(Vector3.new(34, 3, 118), Color3.fromRGB(110, 76, 46), Color3.fromRGB(74, 178, 92), 2.1, 2)
makeTree(Vector3.new(-48, 3, 178), Color3.fromRGB(110, 76, 46), Color3.fromRGB(88, 190, 100), 1.2, -3)
makeTree(Vector3.new(-30, 3, 108), Color3.fromRGB(110, 76, 46), Color3.fromRGB(88, 190, 100), 0.95, 4)
makeTree(Vector3.new(56, 3, 182), Color3.fromRGB(110, 76, 46), Color3.fromRGB(70, 170, 88), 1.05, 0)

-- Flowers + grass tufts scattered over the meadow
local flowerColors = {
	Color3.fromRGB(255, 110, 160),
	Color3.fromRGB(255, 220, 90),
	Color3.fromRGB(170, 130, 255),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 140, 90),
}
for i = 1, 46 do
	local angle = math.random() * math.pi * 2
	local dist = 14 + math.random() * 68
	local pos = MEADOW + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
	if i % 3 == 0 then
		makePart("GrassTuft", Vector3.new(0.5, 1.6, 0.5), CFrame.new(pos + Vector3.new(0, 3.6, 0)) * CFrame.Angles(math.rad(8), 0, math.rad(6)), Color3.fromRGB(84, 178, 84), Enum.Material.Grass)
	else
		makePart("Flower", Vector3.new(0.55, 0.55, 0.55), CFrame.new(pos + Vector3.new(0, 3.5, 0)), flowerColors[math.random(1, #flowerColors)], Enum.Material.Neon)
	end
end

-- Rebirth portal ring (teleports to Crystal Void once unlocked)
local portalCenter = Vector3.new(52, 3, 96)
local portalPad = makePart("VoidPortalPad", Vector3.new(7, 0.6, 7), CFrame.new(portalCenter + Vector3.new(0, 0.4, 0)), Color3.fromRGB(140, 90, 255), Enum.Material.Neon)
for i = 1, 10 do
	local angle = (i / 10) * math.pi * 2
	local blockPos = portalCenter + Vector3.new(math.cos(angle) * 5.2, 4.6 + math.sin(angle) * 5.2 * 0, math.sin(angle) * 0)
	-- ring stands vertical, facing the meadow centre
	blockPos = portalCenter + Vector3.new(math.cos(angle) * 5.2, 4.4 + math.sin(angle) * 5.2, 0)
	local block = makePart("PortalRing", Vector3.new(1.1, 1.1, 1.1), CFrame.new(blockPos), Color3.fromRGB(168, 120, 255), Enum.Material.Neon)
	block.Shape = Enum.PartType.Ball
end
makeSign(portalCenter + Vector3.new(0, 9.5, 0), MEADOW, "VOID PORTAL\n(1 Rebirth)", Color3.fromRGB(200, 160, 255), 0.8)

-- ---------------------------------------------------------------------------
-- Zone: Neon Swamp (west) -- murky water, glowing puddles, twisted trees
-- ---------------------------------------------------------------------------
local SWAMP = Vector3.new(-155, 2, 10)
makeDisc("SwampGround", 82, 1.2, Vector3.new(-155, 2.2, 10), Color3.fromRGB(66, 84, 62), Enum.Material.Slate)

local puddleColors = { Color3.fromRGB(64, 255, 214), Color3.fromRGB(190, 90, 255), Color3.fromRGB(120, 255, 120) }
for i = 1, 9 do
	local angle = math.random() * math.pi * 2
	local dist = 12 + math.random() * 58
	local pos = SWAMP + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
	local puddle = makeDisc("NeonPuddle", 4 + math.random() * 5, 0.3, pos + Vector3.new(0, 2.9, 0), puddleColors[math.random(1, #puddleColors)], Enum.Material.Neon)
	puddle.CanCollide = false
end
for i = 1, 7 do
	local angle = math.random() * math.pi * 2
	local dist = 20 + math.random() * 52
	local pos = SWAMP + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
	makeTree(pos, Color3.fromRGB(58, 48, 66), Color3.fromRGB(52, 110, 84), 0.9 + math.random() * 0.5, (math.random() - 0.5) * 22)
end
-- Mist blobs drifting over the swamp (static translucent spheres)
for i = 1, 6 do
	local angle = math.random() * math.pi * 2
	local dist = 10 + math.random() * 60
	local pos = SWAMP + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
	local mist = makePart("SwampMist", Vector3.new(16, 4, 16), CFrame.new(pos + Vector3.new(0, 6, 0)), Color3.fromRGB(190, 255, 230), Enum.Material.Glass)
	mist.Shape = Enum.PartType.Ball
	mist.Transparency = 0.75
	mist.CanCollide = false
end
makeSign(Vector3.new(-155, 9, -52), Vector3.new(-155, 9, 40), "NEON SWAMP", Color3.fromRGB(120, 255, 220), 0.9)

-- ---------------------------------------------------------------------------
-- Zone: Volcano Ashlands (north) -- basalt, lava, the volcano landmark
-- ---------------------------------------------------------------------------
local ASHLANDS = Vector3.new(-10, 2, -165)
makeDisc("AshlandsGround", 86, 1.2, Vector3.new(-10, 2.2, -165), Color3.fromRGB(62, 58, 66), Enum.Material.Slate)

-- Volcano: stacked cylinders + glowing crater + smoke
local volcanoBase = Vector3.new(-16, 3, -228)
makeDisc("VolcanoTier1", 52, 16, volcanoBase + Vector3.new(0, 8, 0), Color3.fromRGB(74, 66, 74), Enum.Material.Slate)
makeDisc("VolcanoTier2", 36, 15, volcanoBase + Vector3.new(0, 22, 0), Color3.fromRGB(66, 58, 68), Enum.Material.Slate)
makeDisc("VolcanoTier3", 22, 14, volcanoBase + Vector3.new(0, 35, 0), Color3.fromRGB(58, 52, 62), Enum.Material.Slate)
local crater = makeDisc("Crater", 15, 2, volcanoBase + Vector3.new(0, 42.5, 0), Color3.fromRGB(255, 110, 30), Enum.Material.Neon)
crater.CanCollide = false
local smokeAnchor = makePart("SmokeAnchor", Vector3.new(2, 2, 2), CFrame.new(volcanoBase + Vector3.new(0, 46, 0)), Color3.fromRGB(90, 86, 96), Enum.Material.SmoothPlastic)
smokeAnchor.Transparency = 1
smokeAnchor.CanCollide = false
local smoke = Instance.new("ParticleEmitter")
smoke.Name = "VolcanoSmoke"
smoke.Color = ColorSequence.new(Color3.fromRGB(110, 104, 118), Color3.fromRGB(60, 56, 68))
smoke.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 6), NumberSequenceKeypoint.new(1, 22) })
smoke.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 1) })
smoke.Rate = 7
smoke.Lifetime = NumberRange.new(4, 7)
smoke.Speed = NumberRange.new(7, 11)
smoke.SpreadAngle = Vector2.new(24, 24)
smoke.Parent = smokeAnchor
local craterLight = Instance.new("PointLight")
craterLight.Color = Color3.fromRGB(255, 120, 40)
craterLight.Brightness = 2.4
craterLight.Range = 60
craterLight.Parent = crater

-- Lava pools that actually hurt
local lavaParts = {}
for i = 1, 4 do
	local angle = math.random() * math.pi * 2
	local dist = 18 + math.random() * 48
	local pos = ASHLANDS + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
	local lava = makeDisc("LavaPool", 5 + math.random() * 4, 0.35, pos + Vector3.new(0, 2.9, 0), Color3.fromRGB(255, 96, 26), Enum.Material.Neon)
	lava.CanCollide = false
	table.insert(lavaParts, lava)
end
-- Obsidian spikes
for i = 1, 10 do
	local angle = math.random() * math.pi * 2
	local dist = 24 + math.random() * 55
	local pos = ASHLANDS + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
	local spike = makePart("ObsidianSpike", Vector3.new(2.2, 6 + math.random() * 6, 2.2), CFrame.new(pos + Vector3.new(0, 5, 0)) * CFrame.Angles(math.rad((math.random() - 0.5) * 24), math.rad(math.random() * 90), math.rad((math.random() - 0.5) * 24)), Color3.fromRGB(30, 28, 40), Enum.Material.Slate)
	spike.Shape = Enum.PartType.Cylinder
end
makeSign(Vector3.new(-10, 9, -104), Vector3.new(-10, 9, -160), "VOLCANO ASHLANDS", Color3.fromRGB(255, 150, 80), 0.9)

-- Lava damage (server-side, debounced per character)
local lavaDebounce = {}
for _, lava in ipairs(lavaParts) do
	lava.Touched:Connect(function(hit)
		local character = hit and hit.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local now = os.clock()
			if not lavaDebounce[character] or now - lavaDebounce[character] > 0.6 then
				lavaDebounce[character] = now
				humanoid:TakeDamage(12)
			end
		end
	end)
end

-- Snow-capped mountain landmark (east)
local mountainBase = Vector3.new(150, 3, -120)
makeDisc("MountainTier1", 46, 20, mountainBase + Vector3.new(0, 10, 0), Color3.fromRGB(110, 108, 118), Enum.Material.Slate)
makeDisc("MountainTier2", 30, 18, mountainBase + Vector3.new(0, 26, 0), Color3.fromRGB(124, 122, 132), Enum.Material.Slate)
makeDisc("MountainCap", 17, 12, mountainBase + Vector3.new(0, 39, 0), Color3.fromRGB(245, 248, 252), Enum.Material.Snow)

-- Shore rocks
for i = 1, 16 do
	local angle = math.random() * math.pi * 2
	local dist = 238 + math.random() * 26
	local pos = Vector3.new(math.cos(angle) * dist, 2, math.sin(angle) * dist)
	makePart("ShoreRock", Vector3.new(3 + math.random() * 4, 2.5 + math.random() * 3, 3 + math.random() * 4), CFrame.new(pos + Vector3.new(0, 1.5, 0)) * CFrame.Angles(0, math.rad(math.random() * 180), 0), Color3.fromRGB(128, 126, 134), Enum.Material.Slate)
end

-- ---------------------------------------------------------------------------
-- Zone: Crystal Void islet (floating, reached by the rebirth portal)
-- ---------------------------------------------------------------------------
local VOID = Vector3.new(340, 44, -310)
makeDisc("VoidGround", 56, 3, VOID, Color3.fromRGB(44, 36, 66), Enum.Material.Slate)
makeDisc("VoidGlowRim", 57.5, 1, VOID + Vector3.new(0, -1.6, 0), Color3.fromRGB(140, 90, 255), Enum.Material.Neon)

-- Crystal tower landmark: three huge glowing wedges
local crystalColors = { Color3.fromRGB(168, 120, 255), Color3.fromRGB(110, 220, 255), Color3.fromRGB(255, 110, 220) }
for i = 1, 3 do
	local crystal = Instance.new("WedgePart")
	crystal.Name = "CrystalTower"
	local height = 26 - i * 5
	crystal.Size = Vector3.new(7, height, 7)
	crystal.CFrame = CFrame.new(VOID + Vector3.new((i - 2) * 9, height / 2 + 1, -14)) * CFrame.Angles(0, math.rad(i * 40), math.rad((i - 2) * 6))
	crystal.Color = crystalColors[i]
	crystal.Material = Enum.Material.Neon
	crystal.Anchored = true
	crystal.Parent = decor
end
-- Floating mini crystals
for i = 1, 8 do
	local angle = math.random() * math.pi * 2
	local dist = 16 + math.random() * 34
	local pos = VOID + Vector3.new(math.cos(angle) * dist, 4 + math.random() * 7, math.sin(angle) * dist)
	local crystal = Instance.new("WedgePart")
	crystal.Name = "FloatingCrystal"
	crystal.Size = Vector3.new(2.2, 4.5, 2.2)
	crystal.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(math.random() * 40), math.rad(math.random() * 180), 0)
	crystal.Color = crystalColors[math.random(1, #crystalColors)]
	crystal.Material = Enum.Material.Neon
	crystal.Anchored = true
	crystal.CanCollide = false
	crystal.Parent = decor
end
local voidPad = makePart("VoidSpawnPad", Vector3.new(8, 0.6, 8), CFrame.new(VOID + Vector3.new(0, 2, 16)), Color3.fromRGB(200, 160, 255), Enum.Material.Neon)
local returnPad = makePart("ReturnPortalPad", Vector3.new(7, 0.6, 7), CFrame.new(VOID + Vector3.new(0, 2, 34)), Color3.fromRGB(120, 255, 190), Enum.Material.Neon)
makeSign(VOID + Vector3.new(0, 10, 26), VOID, "CRYSTAL VOID", Color3.fromRGB(210, 170, 255), 0.9)

-- ---------------------------------------------------------------------------
-- Player base plots: 8 around the shore ring
-- ---------------------------------------------------------------------------
local basesFolder = Instance.new("Folder")
basesFolder.Name = "Bases"
basesFolder.Parent = island

local bases = {}
local BASE_COUNT = 8
for index = 1, BASE_COUNT do
	local angle = ((index - 1) / BASE_COUNT) * math.pi * 2 + math.rad(22)
	local center = Vector3.new(math.cos(angle) * 216, 3, math.sin(angle) * 216)
	local folder = Instance.new("Folder")
	folder.Name = "Base" .. index
	folder.Parent = basesFolder

	local platform = makeDisc("Platform", 27, 2, center + Vector3.new(0, -0.5, 0), Color3.fromRGB(88, 84, 104), Enum.Material.Slate, folder)
	platform.Name = "Platform"

	-- Face the island centre for pedestal layout.
	local facing = math.atan2(-center.X, -center.Z)

	-- 10 pedestals in two arcs of five.
	local pedestals = {}
	for slot = 1, 10 do
		local row = slot <= 5 and 1 or 2
		local col = (slot - 1) % 5
		local localOffset = Vector3.new((col - 2) * 8.5, 0, row == 1 and -6 or -14)
		local worldOffset = Vector3.new(
			localOffset.X * math.cos(facing) - localOffset.Z * math.sin(facing),
			0,
			localOffset.X * math.sin(facing) + localOffset.Z * math.cos(facing)
		)
		local pedestalPos = center + worldOffset + Vector3.new(0, 1.5, 0)
		local pedestal = makePart("Pedestal" .. slot, Vector3.new(3, 3, 3), CFrame.new(pedestalPos) * CFrame.Angles(0, facing, 0), Color3.fromRGB(104, 98, 122), Enum.Material.Slate, folder)
		makePart("PedestalTrim" .. slot, Vector3.new(3.3, 0.35, 3.3), CFrame.new(pedestalPos + Vector3.new(0, 1.65, 0)) * CFrame.Angles(0, facing, 0), Color3.fromRGB(120, 230, 255), Enum.Material.Neon, folder)
		table.insert(pedestals, pedestal)
	end

	-- Deposit pad (front, toward the island centre) and spawn pad (back).
	local towardCenter = Vector3.new(-center.X, 0, -center.Z).Unit
	local depositPad = makePart("DepositPad", Vector3.new(9, 0.5, 9), CFrame.new(center + towardCenter * 13 + Vector3.new(0, 0.6, 0)), Color3.fromRGB(90, 255, 140), Enum.Material.Neon, folder)
	depositPad.Shape = Enum.PartType.Cylinder
	depositPad.CanCollide = false
	local spawnPad = makePart("SpawnPad", Vector3.new(5, 0.5, 5), CFrame.new(center - towardCenter * 16 + Vector3.new(0, 0.6, 0)), Color3.fromRGB(255, 214, 90), Enum.Material.Neon, folder)
	spawnPad.CanCollide = false

	-- Owner sign.
	local _, signLabel = makeSign(center + towardCenter * 24 + Vector3.new(0, 6.5, 0), center, "Empty Plot", Color3.fromRGB(255, 255, 255), 0.75)

	-- Lock dome (shown while the base lock is active).
	local dome = makePart("LockDome", Vector3.new(56, 30, 56), CFrame.new(center + Vector3.new(0, 4, 0)), Color3.fromRGB(120, 200, 255), Enum.Material.Glass, folder)
	dome.Shape = Enum.PartType.Ball
	dome.Transparency = 0.72
	dome.CanCollide = false
	dome.Visible = false

	bases[index] = {
		Index = index,
		Center = center,
		Pedestals = pedestals,
		DepositPad = depositPad,
		SpawnPad = spawnPad,
		SignLabel = signLabel,
		Dome = dome,
		Owner = nil,
	}
end

-- ---------------------------------------------------------------------------
-- Publish the layout
-- ---------------------------------------------------------------------------
GameState.World = {
	Zones = {
		Meadow = { Center = Vector3.new(0, 3.2, 150), Radius = 76, GroundY = 3.2 },
		Swamp = { Center = Vector3.new(-155, 3.2, 10), Radius = 70, GroundY = 3.2 },
		Ashlands = { Center = Vector3.new(-10, 3.2, -165), Radius = 72, GroundY = 3.2 },
		Void = { Center = Vector3.new(340, 46, -310), Radius = 46, GroundY = 45.6 },
	},
	Bases = bases,
	VoidSpawn = VOID + Vector3.new(0, 4, 16),
	PortalPad = portalPad,
	ReturnPad = returnPad,
}
GameState.WorldReady:Fire()

print("[ChaosBrainrot] World built: 4 zones, " .. #bases .. " base plots.")
