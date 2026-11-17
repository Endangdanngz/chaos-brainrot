-- BrainrotData.luau
-- CHAOS BRAINROT: MUTATION ISLAND
-- The full roster of original brainrot characters plus the procedural model
-- builder. Every character is assembled from primitive Parts (Block / Sphere /
-- Cylinder) following its own visual recipe, so each one has a distinct
-- silhouette without any external assets.
--
-- Recipe schema:
--   Body  = { Shape, Size={x,y,z}, Color={r,g,b}, Material, Transparency?,
--             Upright? (cylinders stand up unless false) }
--   Accent = {r,g,b} secondary color used by parts with Color = "Accent"
--   Parts = { { Name, Shape, Size, Offset (relative to body centre),
--               Rotation? (degrees), Color = "Accent"|"Body"|"Dark"|"White"|{r,g,b},
--               Material?, Transparency? } }

local BrainrotData = {}

local ROSTER = {
	-- ---------------------------------------------------------------- COMMON
	{
		Id = "sir_wobbles", Name = "Sir Wobbles", Rarity = "Common", Income = 2, Zone = "Meadow",
		Body = { Shape = "Sphere", Size = { 2.3, 2.3, 2.3 }, Color = { 124, 224, 148 }, Material = "SmoothPlastic", Transparency = 0.15 },
		Accent = { 200, 205, 215 },
		Parts = {
			{ Name = "Sword", Shape = "Block", Size = { 0.22, 1.7, 0.22 }, Offset = { 1.45, 0.1, 0.2 }, Rotation = { 0, 0, -35 }, Color = "Accent", Material = "Metal" },
			{ Name = "Shield", Shape = "Cylinder", Size = { 0.25, 1.3, 1.3 }, Offset = { -1.35, -0.1, 0.3 }, Color = { 150, 96, 60 }, Material = "Wood" },
			{ Name = "Plume", Shape = "Sphere", Size = { 0.55, 0.8, 0.55 }, Offset = { 0, 1.35, 0 }, Color = { 255, 92, 120 }, Material = "SmoothPlastic" },
		},
	},
	{
		Id = "captain_crumb", Name = "Captain Crumb", Rarity = "Common", Income = 2, Zone = "Meadow",
		Body = { Shape = "Sphere", Size = { 2.3, 2.3, 1.3 }, Color = { 196, 138, 78 }, Material = "SmoothPlastic" },
		Accent = { 30, 30, 36 },
		Parts = {
			{ Name = "Chip1", Shape = "Sphere", Size = { 0.34, 0.34, 0.2 }, Offset = { -0.6, 0.55, 0.62 }, Color = { 84, 50, 30 }, Material = "SmoothPlastic" },
			{ Name = "Chip2", Shape = "Sphere", Size = { 0.3, 0.3, 0.2 }, Offset = { 0.65, -0.3, 0.62 }, Color = { 84, 50, 30 }, Material = "SmoothPlastic" },
			{ Name = "Chip3", Shape = "Sphere", Size = { 0.26, 0.26, 0.2 }, Offset = { 0.15, -0.75, 0.62 }, Color = { 84, 50, 30 }, Material = "SmoothPlastic" },
			{ Name = "HatBrim", Shape = "Cylinder", Size = { 0.18, 1.9, 1.9 }, Offset = { 0, 1.15, 0 }, Color = "Accent", Material = "Slate" },
			{ Name = "HatTop", Shape = "Cylinder", Size = { 0.55, 1.15, 1.15 }, Offset = { 0, 1.45, 0 }, Color = "Accent", Material = "Slate" },
		},
	},
	{
		Id = "professor_pickle", Name = "Professor Pickle", Rarity = "Common", Income = 3, Zone = "Meadow",
		Body = { Shape = "Cylinder", Size = { 1.5, 2.9, 1.5 }, Color = { 88, 168, 64 }, Material = "SmoothPlastic" },
		Accent = { 24, 24, 30 },
		Parts = {
			{ Name = "Bump1", Shape = "Sphere", Size = { 0.3, 0.3, 0.3 }, Offset = { 0.5, 0.7, 0.6 }, Color = { 110, 190, 84 }, Material = "SmoothPlastic" },
			{ Name = "Bump2", Shape = "Sphere", Size = { 0.26, 0.26, 0.26 }, Offset = { -0.55, -0.4, 0.55 }, Color = { 110, 190, 84 }, Material = "SmoothPlastic" },
			{ Name = "Monocle", Shape = "Cylinder", Size = { 0.1, 0.85, 0.85 }, Offset = { 0.42, 0.35, 0.72 }, Rotation = { 90, 0, 0 }, Color = { 240, 240, 250 }, Material = "Glass", Transparency = 0.4 },
			{ Name = "HatBrim", Shape = "Cylinder", Size = { 0.16, 1.8, 1.8 }, Offset = { 0, 1.55, 0 }, Color = "Accent", Material = "Slate" },
			{ Name = "HatTop", Shape = "Cylinder", Size = { 0.8, 1.05, 1.05 }, Offset = { 0, 1.95, 0 }, Color = "Accent", Material = "Slate" },
		},
	},
	{
		Id = "barry_breadstick", Name = "Barry Breadstick", Rarity = "Common", Income = 1, Zone = "Meadow",
		Body = { Shape = "Cylinder", Size = { 0.95, 3.6, 0.95 }, Color = { 222, 178, 106 }, Material = "SmoothPlastic" },
		Accent = { 160, 110, 58 },
		Parts = {
			{ Name = "ArmL", Shape = "Cylinder", Size = { 0.28, 1.5, 0.28 }, Offset = { -0.85, 0.5, 0 }, Rotation = { 0, 0, 55 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "ArmR", Shape = "Cylinder", Size = { 0.28, 1.5, 0.28 }, Offset = { 0.85, 0.5, 0 }, Rotation = { 0, 0, -55 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "Scarf", Shape = "Cylinder", Size = { 0.35, 1.25, 1.25 }, Offset = { 0, 1.15, 0 }, Color = { 214, 64, 84 }, Material = "Fabric" },
		},
	},
	{
		Id = "momo_marshmallow", Name = "Momo the Marshmallow", Rarity = "Common", Income = 2, Zone = "Meadow",
		Body = { Shape = "Block", Size = { 2.1, 2.0, 1.9 }, Color = { 250, 248, 244 }, Material = "SmoothPlastic" },
		Accent = { 255, 158, 196 },
		Parts = {
			{ Name = "CheekL", Shape = "Sphere", Size = { 0.42, 0.3, 0.16 }, Offset = { -0.68, -0.28, 0.93 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "CheekR", Shape = "Sphere", Size = { 0.42, 0.3, 0.16 }, Offset = { 0.68, -0.28, 0.93 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "BowL", Shape = "Block", Size = { 0.55, 0.4, 0.2 }, Offset = { -0.35, 1.2, 0.3 }, Rotation = { 0, 0, 30 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "BowR", Shape = "Block", Size = { 0.55, 0.4, 0.2 }, Offset = { 0.35, 1.2, 0.3 }, Rotation = { 0, 0, -30 }, Color = "Accent", Material = "SmoothPlastic" },
		},
	},
	{
		Id = "turnip_tim", Name = "Turnip Tim", Rarity = "Common", Income = 3, Zone = "Meadow",
		Body = { Shape = "Sphere", Size = { 2.2, 2.4, 2.2 }, Color = { 238, 232, 222 }, Material = "SmoothPlastic" },
		Accent = { 92, 186, 84 },
		Parts = {
			{ Name = "RootTail", Shape = "Cylinder", Size = { 0.3, 0.9, 0.3 }, Offset = { 0, -1.45, 0 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "Leaf1", Shape = "Block", Size = { 0.24, 1.1, 0.55 }, Offset = { -0.3, 1.55, 0 }, Rotation = { 0, 0, 25 }, Color = "Accent", Material = "Grass" },
			{ Name = "Leaf2", Shape = "Block", Size = { 0.24, 1.3, 0.55 }, Offset = { 0.25, 1.65, 0 }, Rotation = { 0, 0, -18 }, Color = "Accent", Material = "Grass" },
			{ Name = "Leaf3", Shape = "Block", Size = { 0.24, 0.9, 0.5 }, Offset = { 0, 1.5, -0.25 }, Rotation = { 20, 0, 0 }, Color = { 70, 160, 70 }, Material = "Grass" },
		},
	},
	{
		Id = "eggward", Name = "Eggward", Rarity = "Common", Income = 2, Zone = "Meadow",
		Body = { Shape = "Sphere", Size = { 1.9, 2.6, 1.9 }, Color = { 252, 250, 246 }, Material = "SmoothPlastic" },
		Accent = { 255, 178, 44 },
		Parts = {
			{ Name = "Yolk", Shape = "Sphere", Size = { 1.0, 1.0, 0.5 }, Offset = { 0, -0.35, 0.8 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "WingL", Shape = "Block", Size = { 0.22, 0.9, 0.6 }, Offset = { -1.05, 0.1, 0 }, Rotation = { 0, 0, 18 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "WingR", Shape = "Block", Size = { 0.22, 0.9, 0.6 }, Offset = { 1.05, 0.1, 0 }, Rotation = { 0, 0, -18 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "Tuft", Shape = "Sphere", Size = { 0.4, 0.55, 0.4 }, Offset = { 0, 1.45, 0 }, Color = "Accent", Material = "SmoothPlastic" },
		},
	},

	-- -------------------------------------------------------------- UNCOMMON
	{
		Id = "disco_potato", Name = "Disco Potato", Rarity = "Uncommon", Income = 5, Zone = "Swamp",
		Body = { Shape = "Sphere", Size = { 2.2, 1.9, 2.0 }, Color = { 168, 124, 74 }, Material = "SmoothPlastic" },
		Accent = { 226, 232, 240 },
		Parts = {
			{ Name = "MirrorBall", Shape = "Sphere", Size = { 0.95, 0.95, 0.95 }, Offset = { 0, 1.45, 0 }, Color = "Accent", Material = "Metal" },
			{ Name = "Shades", Shape = "Block", Size = { 1.5, 0.42, 0.18 }, Offset = { 0, 0.28, 0.98 }, Color = { 18, 18, 24 }, Material = "Glass" },
			{ Name = "Chain", Shape = "Cylinder", Size = { 0.16, 1.3, 1.3 }, Offset = { 0, -0.35, 0.55 }, Rotation = { 90, 0, 0 }, Color = { 255, 205, 70 }, Material = "Metal" },
		},
	},
	{
		Id = "count_sockula", Name = "Count Sockula", Rarity = "Uncommon", Income = 6, Zone = "Swamp",
		Body = { Shape = "Cylinder", Size = { 1.6, 2.8, 1.6 }, Color = { 236, 234, 240 }, Material = "Fabric" },
		Accent = { 178, 30, 44 },
		Parts = {
			{ Name = "Stripe1", Shape = "Cylinder", Size = { 0.28, 1.68, 1.68 }, Offset = { 0, 0.95, 0 }, Color = "Accent", Material = "Fabric" },
			{ Name = "Stripe2", Shape = "Cylinder", Size = { 0.28, 1.68, 1.68 }, Offset = { 0, 0.55, 0 }, Color = "Accent", Material = "Fabric" },
			{ Name = "Cape", Shape = "Block", Size = { 1.9, 2.5, 0.22 }, Offset = { 0, -0.1, -0.95 }, Color = { 32, 26, 44 }, Material = "Fabric" },
			{ Name = "FangL", Shape = "Block", Size = { 0.16, 0.34, 0.1 }, Offset = { -0.28, -0.52, 0.8 }, Color = "White", Material = "SmoothPlastic" },
			{ Name = "FangR", Shape = "Block", Size = { 0.16, 0.34, 0.1 }, Offset = { 0.28, -0.52, 0.8 }, Color = "White", Material = "SmoothPlastic" },
		},
	},
	{
		Id = "bubble_bard", Name = "Bubble Bard", Rarity = "Uncommon", Income = 5, Zone = "Swamp",
		Body = { Shape = "Sphere", Size = { 2.5, 1.7, 1.6 }, Color = { 255, 146, 66 }, Material = "SmoothPlastic" },
		Accent = { 190, 235, 255 },
		Parts = {
			{ Name = "Bubble", Shape = "Sphere", Size = { 1.7, 1.7, 1.7 }, Offset = { 0.85, 0.35, 0 }, Color = "Accent", Material = "Glass", Transparency = 0.55 },
			{ Name = "TailFin", Shape = "Block", Size = { 0.24, 1.1, 0.8 }, Offset = { -1.45, 0, 0 }, Rotation = { 0, 0, 0 }, Color = { 230, 110, 40 }, Material = "SmoothPlastic" },
			{ Name = "TopFin", Shape = "Block", Size = { 0.7, 0.55, 0.2 }, Offset = { -0.2, 0.95, 0 }, Color = { 230, 110, 40 }, Material = "SmoothPlastic" },
			{ Name = "Lute", Shape = "Sphere", Size = { 0.85, 1.0, 0.4 }, Offset = { 0.4, -0.75, 0.75 }, Color = { 146, 96, 54 }, Material = "Wood" },
		},
	},
	{
		Id = "madame_muffin", Name = "Madame Muffin", Rarity = "Uncommon", Income = 7, Zone = "Swamp",
		Body = { Shape = "Cylinder", Size = { 2.2, 1.5, 2.2 }, Color = { 178, 120, 196 }, Material = "Fabric" },
		Accent = { 255, 205, 70 },
		Parts = {
			{ Name = "Dome", Shape = "Sphere", Size = { 2.35, 1.3, 2.35 }, Offset = { 0, 0.8, 0 }, Color = { 146, 92, 60 }, Material = "SmoothPlastic" },
			{ Name = "Cherry", Shape = "Sphere", Size = { 0.5, 0.5, 0.5 }, Offset = { 0.4, 1.55, 0.3 }, Color = { 216, 40, 60 }, Material = "SmoothPlastic" },
			{ Name = "Crown", Shape = "Cylinder", Size = { 0.5, 0.95, 0.95 }, Offset = { -0.55, 1.5, -0.2 }, Color = "Accent", Material = "Metal" },
			{ Name = "Sprinkle1", Shape = "Block", Size = { 0.3, 0.1, 0.12 }, Offset = { -0.7, 1.25, 0.6 }, Rotation = { 0, 30, 0 }, Color = { 90, 200, 255 }, Material = "SmoothPlastic" },
			{ Name = "Sprinkle2", Shape = "Block", Size = { 0.3, 0.1, 0.12 }, Offset = { 0.75, 1.3, -0.4 }, Rotation = { 0, -50, 0 }, Color = { 255, 120, 200 }, Material = "SmoothPlastic" },
		},
	},
	{
		Id = "gloopy", Name = "Gloopy", Rarity = "Uncommon", Income = 4, Zone = "Swamp",
		Body = { Shape = "Sphere", Size = { 2.4, 1.7, 2.4 }, Color = { 92, 226, 205 }, Material = "Glass", Transparency = 0.3 },
		Accent = { 40, 190, 170 },
		Parts = {
			{ Name = "Core", Shape = "Sphere", Size = { 1.0, 1.0, 1.0 }, Offset = { 0, -0.1, 0 }, Color = { 190, 255, 240 }, Material = "Neon" },
			{ Name = "Drip1", Shape = "Sphere", Size = { 0.6, 0.9, 0.6 }, Offset = { -0.95, -0.55, 0.5 }, Color = "Body", Material = "Glass", Transparency = 0.3 },
			{ Name = "Drip2", Shape = "Sphere", Size = { 0.5, 0.7, 0.5 }, Offset = { 0.9, -0.6, -0.4 }, Color = "Body", Material = "Glass", Transparency = 0.3 },
			{ Name = "CrownDrop", Shape = "Sphere", Size = { 0.45, 0.65, 0.45 }, Offset = { 0.3, 1.05, 0 }, Color = "Accent", Material = "SmoothPlastic" },
		},
	},
	{
		Id = "waffle_wizard", Name = "Waffle Wizard", Rarity = "Uncommon", Income = 8, Zone = "Swamp",
		Body = { Shape = "Block", Size = { 2.1, 2.1, 1.1 }, Color = { 216, 160, 84 }, Material = "SmoothPlastic" },
		Accent = { 110, 74, 196 },
		Parts = {
			{ Name = "GridV1", Shape = "Block", Size = { 0.16, 2.1, 0.08 }, Offset = { -0.52, 0, 0.57 }, Color = { 178, 124, 56 }, Material = "SmoothPlastic" },
			{ Name = "GridV2", Shape = "Block", Size = { 0.16, 2.1, 0.08 }, Offset = { 0.52, 0, 0.57 }, Color = { 178, 124, 56 }, Material = "SmoothPlastic" },
			{ Name = "GridH1", Shape = "Block", Size = { 2.1, 0.16, 0.08 }, Offset = { 0, 0.52, 0.57 }, Color = { 178, 124, 56 }, Material = "SmoothPlastic" },
			{ Name = "HatBrim", Shape = "Cylinder", Size = { 0.16, 2.0, 2.0 }, Offset = { 0, 1.1, 0 }, Color = "Accent", Material = "Fabric" },
			{ Name = "HatCone1", Shape = "Cylinder", Size = { 0.85, 1.25, 1.25 }, Offset = { 0, 1.55, 0 }, Color = "Accent", Material = "Fabric" },
			{ Name = "HatCone2", Shape = "Cylinder", Size = { 0.8, 0.7, 0.7 }, Offset = { 0.12, 2.2, 0 }, Rotation = { 0, 0, -14 }, Color = "Accent", Material = "Fabric" },
			{ Name = "WandStar", Shape = "Sphere", Size = { 0.42, 0.42, 0.42 }, Offset = { 1.45, 0.75, 0.3 }, Color = { 255, 230, 120 }, Material = "Neon" },
		},
	},

	-- ------------------------------------------------------------------ RARE
	{
		Id = "turbo_snail", Name = "Turbo Snail", Rarity = "Rare", Income = 12, Zone = "Swamp",
		Body = { Shape = "Block", Size = { 2.8, 1.0, 1.3 }, Color = { 150, 220, 120 }, Material = "SmoothPlastic" },
		Accent = { 196, 110, 220 },
		Parts = {
			{ Name = "Shell", Shape = "Sphere", Size = { 1.9, 1.9, 1.9 }, Offset = { -0.35, 1.0, 0 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "ShellSwirl", Shape = "Sphere", Size = { 1.1, 1.1, 0.4 }, Offset = { -0.35, 1.0, 0.95 }, Color = { 150, 70, 190 }, Material = "SmoothPlastic" },
			{ Name = "Rocket", Shape = "Cylinder", Size = { 0.55, 1.4, 0.55 }, Offset = { -0.35, 2.2, 0 }, Rotation = { 0, 0, 90 }, Color = { 210, 214, 222 }, Material = "Metal" },
			{ Name = "Flame", Shape = "Sphere", Size = { 0.6, 0.9, 0.6 }, Offset = { -1.35, 2.2, 0 }, Color = { 255, 140, 40 }, Material = "Neon" },
			{ Name = "StalkL", Shape = "Cylinder", Size = { 0.14, 0.8, 0.14 }, Offset = { 1.35, 0.75, 0.3 }, Rotation = { 0, 0, -18 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "StalkR", Shape = "Cylinder", Size = { 0.14, 0.8, 0.14 }, Offset = { 1.35, 0.75, -0.3 }, Rotation = { 0, 0, -18 }, Color = "Body", Material = "SmoothPlastic" },
		},
	},
	{
		Id = "dj_jellybean", Name = "DJ Jellybean", Rarity = "Rare", Income = 20, Zone = "Swamp",
		Body = { Shape = "Sphere", Size = { 1.9, 2.4, 1.7 }, Color = { 232, 64, 150 }, Material = "SmoothPlastic" },
		Accent = { 40, 42, 54 },
		Parts = {
			{ Name = "PhoneL", Shape = "Cylinder", Size = { 0.55, 0.8, 0.8 }, Offset = { -1.05, 0.45, 0 }, Rotation = { 0, 0, 90 }, Color = "Accent", Material = "Slate" },
			{ Name = "PhoneR", Shape = "Cylinder", Size = { 0.55, 0.8, 0.8 }, Offset = { 1.05, 0.45, 0 }, Rotation = { 0, 0, 90 }, Color = "Accent", Material = "Slate" },
			{ Name = "PhoneBand", Shape = "Block", Size = { 2.0, 0.22, 0.3 }, Offset = { 0, 1.15, 0 }, Color = "Accent", Material = "Slate" },
			{ Name = "GlowRing", Shape = "Cylinder", Size = { 0.3, 2.3, 2.3 }, Offset = { 0, -1.15, 0 }, Color = { 90, 240, 255 }, Material = "Neon" },
		},
	},
	{
		Id = "robo_ramen", Name = "Robo-Ramen", Rarity = "Rare", Income = 15, Zone = "Ashlands",
		Body = { Shape = "Cylinder", Size = { 2.5, 1.3, 2.5 }, Color = { 240, 242, 246 }, Material = "SmoothPlastic" },
		Accent = { 160, 168, 180 },
		Parts = {
			{ Name = "Noodles", Shape = "Sphere", Size = { 2.2, 0.8, 2.2 }, Offset = { 0, 0.75, 0 }, Color = { 250, 214, 120 }, Material = "SmoothPlastic" },
			{ Name = "EggHalf", Shape = "Sphere", Size = { 0.65, 0.4, 0.65 }, Offset = { 0.6, 1.05, 0.4 }, Color = { 255, 170, 60 }, Material = "SmoothPlastic" },
			{ Name = "Stick1", Shape = "Cylinder", Size = { 0.12, 1.7, 0.12 }, Offset = { -0.7, 1.6, -0.3 }, Rotation = { 18, 0, 12 }, Color = { 170, 120, 70 }, Material = "Wood" },
			{ Name = "Stick2", Shape = "Cylinder", Size = { 0.12, 1.7, 0.12 }, Offset = { -0.35, 1.6, -0.55 }, Rotation = { 18, 0, 4 }, Color = { 170, 120, 70 }, Material = "Wood" },
			{ Name = "ArmL", Shape = "Cylinder", Size = { 0.3, 1.2, 0.3 }, Offset = { -1.45, -0.1, 0 }, Rotation = { 0, 0, 40 }, Color = "Accent", Material = "Metal" },
			{ Name = "ArmR", Shape = "Cylinder", Size = { 0.3, 1.2, 0.3 }, Offset = { 1.45, -0.1, 0 }, Rotation = { 0, 0, -40 }, Color = "Accent", Material = "Metal" },
			{ Name = "Antenna", Shape = "Cylinder", Size = { 0.1, 0.8, 0.1 }, Offset = { 0, 1.5, -0.6 }, Color = "Accent", Material = "Metal" },
		},
	},
	{
		Id = "cactus_cowboy", Name = "Cactus Cowboy", Rarity = "Rare", Income = 18, Zone = "Ashlands",
		Body = { Shape = "Cylinder", Size = { 1.6, 3.1, 1.6 }, Color = { 74, 160, 84 }, Material = "SmoothPlastic" },
		Accent = { 196, 132, 74 },
		Parts = {
			{ Name = "ArmL1", Shape = "Cylinder", Size = { 0.45, 1.1, 0.45 }, Offset = { -1.05, 0.2, 0 }, Rotation = { 0, 0, 90 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "ArmL2", Shape = "Cylinder", Size = { 0.45, 1.0, 0.45 }, Offset = { -1.55, 0.75, 0 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "ArmR1", Shape = "Cylinder", Size = { 0.45, 1.1, 0.45 }, Offset = { 1.05, 0.2, 0 }, Rotation = { 0, 0, 90 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "ArmR2", Shape = "Cylinder", Size = { 0.45, 1.0, 0.45 }, Offset = { 1.55, 0.75, 0 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "HatBrim", Shape = "Cylinder", Size = { 0.16, 2.1, 2.1 }, Offset = { 0, 1.6, 0 }, Color = "Accent", Material = "Fabric" },
			{ Name = "HatTop", Shape = "Cylinder", Size = { 0.65, 1.15, 1.15 }, Offset = { 0, 1.95, 0 }, Color = "Accent", Material = "Fabric" },
			{ Name = "Bandana", Shape = "Cylinder", Size = { 0.3, 1.68, 1.68 }, Offset = { 0, 0.75, 0 }, Color = { 200, 44, 54 }, Material = "Fabric" },
			{ Name = "Flower", Shape = "Sphere", Size = { 0.42, 0.42, 0.42 }, Offset = { 0.4, 1.75, 0.5 }, Color = { 255, 130, 180 }, Material = "SmoothPlastic" },
		},
	},
	{
		Id = "lava_lamp_larry", Name = "Lava Lamp Larry", Rarity = "Rare", Income = 22, Zone = "Ashlands",
		Body = { Shape = "Cylinder", Size = { 1.7, 2.9, 1.7 }, Color = { 255, 120, 60 }, Material = "Glass", Transparency = 0.35 },
		Accent = { 70, 72, 84 },
		Parts = {
			{ Name = "Blob1", Shape = "Sphere", Size = { 0.85, 0.85, 0.85 }, Offset = { 0.2, -0.7, 0 }, Color = { 255, 70, 40 }, Material = "Neon" },
			{ Name = "Blob2", Shape = "Sphere", Size = { 0.6, 0.6, 0.6 }, Offset = { -0.3, 0.55, 0.15 }, Color = { 255, 100, 50 }, Material = "Neon" },
			{ Name = "Base", Shape = "Cylinder", Size = { 0.55, 2.0, 2.0 }, Offset = { 0, -1.65, 0 }, Color = "Accent", Material = "Metal" },
			{ Name = "Cap", Shape = "Cylinder", Size = { 0.4, 1.3, 1.3 }, Offset = { 0, 1.6, 0 }, Color = "Accent", Material = "Metal" },
		},
	},

	-- ------------------------------------------------------------------ EPIC
	{
		Id = "magma_moose", Name = "Magma Moose", Rarity = "Epic", Income = 55, Zone = "Ashlands",
		Body = { Shape = "Block", Size = { 2.6, 2.2, 2.0 }, Color = { 96, 62, 48 }, Material = "Slate" },
		Accent = { 255, 110, 30 },
		Parts = {
			{ Name = "Snout", Shape = "Block", Size = { 1.3, 1.0, 0.9 }, Offset = { 0, -0.35, 1.35 }, Color = { 130, 90, 66 }, Material = "Slate" },
			{ Name = "AntlerL1", Shape = "Block", Size = { 0.24, 1.4, 0.24 }, Offset = { -1.0, 1.55, 0 }, Rotation = { 0, 0, 35 }, Color = "Accent", Material = "Neon" },
			{ Name = "AntlerL2", Shape = "Block", Size = { 0.2, 0.9, 0.2 }, Offset = { -1.55, 1.95, 0 }, Rotation = { 0, 0, -25 }, Color = "Accent", Material = "Neon" },
			{ Name = "AntlerR1", Shape = "Block", Size = { 0.24, 1.4, 0.24 }, Offset = { 1.0, 1.55, 0 }, Rotation = { 0, 0, -35 }, Color = "Accent", Material = "Neon" },
			{ Name = "AntlerR2", Shape = "Block", Size = { 0.2, 0.9, 0.2 }, Offset = { 1.55, 1.95, 0 }, Rotation = { 0, 0, 25 }, Color = "Accent", Material = "Neon" },
			{ Name = "Crack1", Shape = "Block", Size = { 0.14, 1.6, 0.1 }, Offset = { -0.7, 0, 1.01 }, Rotation = { 0, 0, 20 }, Color = "Accent", Material = "Neon" },
			{ Name = "Crack2", Shape = "Block", Size = { 0.14, 1.2, 0.1 }, Offset = { 0.75, -0.2, 1.01 }, Rotation = { 0, 0, -30 }, Color = "Accent", Material = "Neon" },
		},
	},
	{
		Id = "phoenix_fries", Name = "Phoenix Fries", Rarity = "Epic", Income = 65, Zone = "Ashlands",
		Body = { Shape = "Block", Size = { 2.0, 1.8, 1.4 }, Color = { 206, 44, 52 }, Material = "SmoothPlastic" },
		Accent = { 255, 196, 64 },
		Parts = {
			{ Name = "Fry1", Shape = "Cylinder", Size = { 0.4, 1.6, 0.4 }, Offset = { -0.65, 1.5, 0 }, Rotation = { 0, 0, 8 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "Fry2", Shape = "Cylinder", Size = { 0.4, 1.9, 0.4 }, Offset = { 0, 1.65, 0 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "Fry3", Shape = "Cylinder", Size = { 0.4, 1.5, 0.4 }, Offset = { 0.65, 1.45, 0 }, Rotation = { 0, 0, -8 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "WingL", Shape = "Block", Size = { 0.22, 1.3, 0.9 }, Offset = { -1.25, 0.45, -0.1 }, Rotation = { 0, 0, 40 }, Color = { 255, 120, 40 }, Material = "Neon" },
			{ Name = "WingR", Shape = "Block", Size = { 0.22, 1.3, 0.9 }, Offset = { 1.25, 0.45, -0.1 }, Rotation = { 0, 0, -40 }, Color = { 255, 120, 40 }, Material = "Neon" },
			{ Name = "TailFlame", Shape = "Sphere", Size = { 0.7, 1.1, 0.7 }, Offset = { 0, 0.3, -1.0 }, Color = { 255, 90, 30 }, Material = "Neon" },
		},
	},
	{
		Id = "obsidian_owl", Name = "Obsidian Owl", Rarity = "Epic", Income = 45, Zone = "Ashlands",
		Body = { Shape = "Sphere", Size = { 2.2, 2.5, 2.0 }, Color = { 34, 32, 44 }, Material = "Slate" },
		Accent = { 90, 240, 255 },
		EyeColor = { 90, 240, 255 },
		Parts = {
			{ Name = "Belly", Shape = "Sphere", Size = { 1.5, 1.7, 0.7 }, Offset = { 0, -0.35, 0.75 }, Color = { 84, 80, 104 }, Material = "Slate" },
			{ Name = "EarL", Shape = "Block", Size = { 0.3, 0.7, 0.3 }, Offset = { -0.75, 1.35, 0 }, Rotation = { 0, 0, 15 }, Color = "Body", Material = "Slate" },
			{ Name = "EarR", Shape = "Block", Size = { 0.3, 0.7, 0.3 }, Offset = { 0.75, 1.35, 0 }, Rotation = { 0, 0, -15 }, Color = "Body", Material = "Slate" },
			{ Name = "Beak", Shape = "Block", Size = { 0.45, 0.3, 0.35 }, Offset = { 0, -0.15, 1.0 }, Color = { 255, 180, 60 }, Material = "SmoothPlastic" },
			{ Name = "Gem", Shape = "Sphere", Size = { 0.4, 0.55, 0.3 }, Offset = { 0, 0.75, 0.92 }, Color = "Accent", Material = "Neon" },
		},
	},
	{
		Id = "storm_sushi", Name = "Storm Sushi", Rarity = "Epic", Income = 75, Zone = "Ashlands",
		Body = { Shape = "Cylinder", Size = { 2.3, 1.6, 2.3 }, Color = { 246, 244, 240 }, Material = "SmoothPlastic" },
		Accent = { 255, 150, 90 },
		Parts = {
			{ Name = "Salmon", Shape = "Block", Size = { 1.9, 0.55, 1.5 }, Offset = { 0, 1.05, 0 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "NoriBand", Shape = "Cylinder", Size = { 0.5, 2.36, 2.36 }, Offset = { 0, 0.1, 0 }, Color = { 30, 40, 34 }, Material = "SmoothPlastic" },
			{ Name = "Cloud", Shape = "Sphere", Size = { 1.9, 0.9, 1.5 }, Offset = { 0, 2.15, 0 }, Color = { 120, 128, 148 }, Material = "SmoothPlastic" },
			{ Name = "Bolt1", Shape = "Block", Size = { 0.3, 0.85, 0.14 }, Offset = { -0.2, 1.45, 0.5 }, Rotation = { 0, 0, 22 }, Color = { 255, 235, 90 }, Material = "Neon" },
			{ Name = "Bolt2", Shape = "Block", Size = { 0.3, 0.8, 0.14 }, Offset = { 0.18, 0.95, 0.52 }, Rotation = { 0, 0, 22 }, Color = { 255, 235, 90 }, Material = "Neon" },
		},
	},

	-- ------------------------------------------------------------- LEGENDARY
	{
		Id = "golden_gator", Name = "Golden Gator", Rarity = "Legendary", Income = 160, Zone = "Swamp",
		Body = { Shape = "Block", Size = { 2.0, 1.3, 3.4 }, Color = { 232, 184, 64 }, Material = "Metal" },
		Accent = { 20, 20, 26 },
		Parts = {
			{ Name = "Snout", Shape = "Block", Size = { 1.5, 0.8, 1.3 }, Offset = { 0, -0.15, 2.25 }, Color = "Body", Material = "Metal" },
			{ Name = "Tail", Shape = "Block", Size = { 1.1, 0.7, 1.8 }, Offset = { 0, 0, -2.5 }, Rotation = { 18, 0, 0 }, Color = "Body", Material = "Metal" },
			{ Name = "Shades", Shape = "Block", Size = { 1.7, 0.45, 0.2 }, Offset = { 0, 0.45, 1.72 }, Color = "Accent", Material = "Glass" },
			{ Name = "Tooth1", Shape = "Block", Size = { 0.16, 0.3, 0.1 }, Offset = { -0.5, -0.6, 2.85 }, Color = "White", Material = "SmoothPlastic" },
			{ Name = "Tooth2", Shape = "Block", Size = { 0.16, 0.3, 0.1 }, Offset = { 0, -0.6, 2.9 }, Color = "White", Material = "SmoothPlastic" },
			{ Name = "Tooth3", Shape = "Block", Size = { 0.16, 0.3, 0.1 }, Offset = { 0.5, -0.6, 2.85 }, Color = "White", Material = "SmoothPlastic" },
			{ Name = "Spike1", Shape = "Block", Size = { 0.4, 0.45, 0.4 }, Offset = { 0, 0.85, -0.6 }, Color = { 200, 150, 40 }, Material = "Metal" },
			{ Name = "Spike2", Shape = "Block", Size = { 0.4, 0.45, 0.4 }, Offset = { 0, 0.85, -1.5 }, Color = { 200, 150, 40 }, Material = "Metal" },
		},
	},
	{
		Id = "emperor_espresso", Name = "Emperor Espresso", Rarity = "Legendary", Income = 200, Zone = "Ashlands",
		Body = { Shape = "Cylinder", Size = { 2.3, 2.0, 2.3 }, Color = { 244, 242, 238 }, Material = "SmoothPlastic" },
		Accent = { 84, 52, 34 },
		Parts = {
			{ Name = "CoffeeTop", Shape = "Cylinder", Size = { 0.25, 2.0, 2.0 }, Offset = { 0, 1.0, 0 }, Color = "Accent", Material = "SmoothPlastic" },
			{ Name = "Handle", Shape = "Cylinder", Size = { 0.9, 0.28, 0.28 }, Offset = { 1.45, 0.1, 0 }, Rotation = { 0, 0, 90 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "GoldBand", Shape = "Cylinder", Size = { 0.35, 2.36, 2.36 }, Offset = { 0, -0.6, 0 }, Color = { 255, 200, 70 }, Material = "Metal" },
			{ Name = "Steam1", Shape = "Sphere", Size = { 0.55, 0.8, 0.55 }, Offset = { -0.5, 1.65, 0 }, Color = "White", Material = "SmoothPlastic", Transparency = 0.45 },
			{ Name = "Steam2", Shape = "Sphere", Size = { 0.45, 0.7, 0.45 }, Offset = { 0.45, 1.85, 0.2 }, Color = "White", Material = "SmoothPlastic", Transparency = 0.45 },
			{ Name = "Steam3", Shape = "Sphere", Size = { 0.38, 0.6, 0.38 }, Offset = { 0, 2.2, -0.3 }, Color = "White", Material = "SmoothPlastic", Transparency = 0.55 },
		},
	},
	{
		Id = "void_reaper_ravioli", Name = "Void Reaper Ravioli", Rarity = "Legendary", Income = 280, Zone = "Void",
		Body = { Shape = "Block", Size = { 2.3, 1.1, 2.3 }, Color = { 240, 222, 178 }, Material = "SmoothPlastic" },
		Accent = { 30, 26, 44 },
		EyeColor = { 168, 110, 255 },
		Parts = {
			{ Name = "Hood", Shape = "Sphere", Size = { 2.1, 1.6, 2.1 }, Offset = { 0, 0.95, -0.25 }, Color = "Accent", Material = "Slate" },
			{ Name = "ScythePole", Shape = "Cylinder", Size = { 0.16, 3.4, 0.16 }, Offset = { 1.5, 0.7, 0 }, Rotation = { 0, 0, -12 }, Color = { 90, 70, 54 }, Material = "Wood" },
			{ Name = "ScytheBlade", Shape = "Block", Size = { 1.5, 0.5, 0.12 }, Offset = { 1.95, 2.3, 0 }, Rotation = { 0, 0, -18 }, Color = { 190, 200, 220 }, Material = "Metal" },
			{ Name = "Crimp1", Shape = "Sphere", Size = { 0.5, 0.4, 0.5 }, Offset = { -1.05, 0, 1.05 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "Crimp2", Shape = "Sphere", Size = { 0.5, 0.4, 0.5 }, Offset = { 1.05, 0, -1.05 }, Color = "Body", Material = "SmoothPlastic" },
		},
	},

	-- ---------------------------------------------------------------- MYTHIC
	{
		Id = "aurora_axolotl", Name = "Aurora Axolotl", Rarity = "Mythic", Income = 650, Zone = "Void",
		Body = { Shape = "Sphere", Size = { 2.5, 1.8, 2.1 }, Color = { 255, 168, 205 }, Material = "SmoothPlastic" },
		Accent = { 255, 90, 170 },
		Parts = {
			{ Name = "GillL1", Shape = "Block", Size = { 0.18, 0.85, 0.4 }, Offset = { -1.35, 0.35, 0.3 }, Rotation = { 0, 0, 45 }, Color = "Accent", Material = "Neon" },
			{ Name = "GillL2", Shape = "Block", Size = { 0.18, 0.85, 0.4 }, Offset = { -1.42, 0.3, -0.15 }, Rotation = { 0, 20, 45 }, Color = "Accent", Material = "Neon" },
			{ Name = "GillL3", Shape = "Block", Size = { 0.18, 0.8, 0.4 }, Offset = { -1.35, 0.25, -0.6 }, Rotation = { 0, 40, 45 }, Color = "Accent", Material = "Neon" },
			{ Name = "GillR1", Shape = "Block", Size = { 0.18, 0.85, 0.4 }, Offset = { 1.35, 0.35, 0.3 }, Rotation = { 0, 0, -45 }, Color = "Accent", Material = "Neon" },
			{ Name = "GillR2", Shape = "Block", Size = { 0.18, 0.85, 0.4 }, Offset = { 1.42, 0.3, -0.15 }, Rotation = { 0, -20, -45 }, Color = "Accent", Material = "Neon" },
			{ Name = "GillR3", Shape = "Block", Size = { 0.18, 0.8, 0.4 }, Offset = { 1.35, 0.25, -0.6 }, Rotation = { 0, -40, -45 }, Color = "Accent", Material = "Neon" },
			{ Name = "Tail", Shape = "Block", Size = { 0.5, 1.0, 1.6 }, Offset = { 0, -0.1, -1.7 }, Rotation = { 24, 0, 0 }, Color = "Body", Material = "SmoothPlastic" },
			{ Name = "BellyGlow", Shape = "Sphere", Size = { 1.5, 1.0, 0.5 }, Offset = { 0, -0.45, 0.85 }, Color = { 190, 255, 235 }, Material = "Neon" },
		},
	},
	{
		Id = "celestine_comet_cake", Name = "Celestine Comet Cake", Rarity = "Mythic", Income = 800, Zone = "Void",
		Body = { Shape = "Cylinder", Size = { 2.5, 1.2, 2.5 }, Color = { 255, 214, 232 }, Material = "SmoothPlastic" },
		Accent = { 255, 244, 200 },
		Parts = {
			{ Name = "Tier2", Shape = "Cylinder", Size = { 1.0, 1.8, 1.8 }, Offset = { 0, 1.05, 0 }, Color = { 240, 238, 255 }, Material = "SmoothPlastic" },
			{ Name = "Icing", Shape = "Cylinder", Size = { 0.3, 2.56, 2.56 }, Offset = { 0, 0.55, 0 }, Color = "White", Material = "SmoothPlastic" },
			{ Name = "Candle1", Shape = "Cylinder", Size = { 0.14, 0.7, 0.14 }, Offset = { -0.5, 1.85, 0.2 }, Color = { 120, 200, 255 }, Material = "SmoothPlastic" },
			{ Name = "Candle2", Shape = "Cylinder", Size = { 0.14, 0.7, 0.14 }, Offset = { 0.5, 1.85, -0.2 }, Color = { 255, 140, 200 }, Material = "SmoothPlastic" },
			{ Name = "Flame1", Shape = "Sphere", Size = { 0.3, 0.42, 0.3 }, Offset = { -0.5, 2.35, 0.2 }, Color = { 255, 190, 80 }, Material = "Neon" },
			{ Name = "Flame2", Shape = "Sphere", Size = { 0.3, 0.42, 0.3 }, Offset = { 0.5, 2.35, -0.2 }, Color = { 255, 190, 80 }, Material = "Neon" },
			{ Name = "CometTail1", Shape = "Sphere", Size = { 0.85, 0.85, 0.85 }, Offset = { -0.4, 0.5, -1.9 }, Color = { 140, 220, 255 }, Material = "Neon", Transparency = 0.25 },
			{ Name = "CometTail2", Shape = "Sphere", Size = { 0.6, 0.6, 0.6 }, Offset = { -0.55, 0.6, -2.9 }, Color = { 170, 160, 255 }, Material = "Neon", Transparency = 0.45 },
			{ Name = "CometTail3", Shape = "Sphere", Size = { 0.4, 0.4, 0.4 }, Offset = { -0.65, 0.7, -3.8 }, Color = { 220, 170, 255 }, Material = "Neon", Transparency = 0.6 },
		},
	},
	{
		Id = "infinite_burrito", Name = "The Infinite Burrito", Rarity = "Mythic", Income = 1000, Zone = "Void",
		Body = { Shape = "Cylinder", Size = { 1.9, 3.6, 1.9 }, Color = { 232, 198, 138 }, Material = "SmoothPlastic", Upright = false },
		Accent = { 200, 205, 215 },
		Parts = {
			{ Name = "FoilL", Shape = "Sphere", Size = { 1.7, 1.2, 1.7 }, Offset = { -1.95, 0, 0 }, Color = "Accent", Material = "Metal" },
			{ Name = "FoilR", Shape = "Sphere", Size = { 1.7, 1.2, 1.7 }, Offset = { 1.95, 0, 0 }, Color = "Accent", Material = "Metal" },
			{ Name = "AuraRing", Shape = "Cylinder", Size = { 0.22, 2.6, 2.6 }, Offset = { 0, 0, 0 }, Rotation = { 0, 0, 90 }, Color = { 150, 120, 255 }, Material = "Neon" },
			{ Name = "Sprinkle1", Shape = "Sphere", Size = { 0.28, 0.28, 0.28 }, Offset = { -0.8, 0.95, 0.3 }, Color = { 110, 255, 190 }, Material = "Neon" },
			{ Name = "Sprinkle2", Shape = "Sphere", Size = { 0.28, 0.28, 0.28 }, Offset = { 0.3, 1.0, -0.4 }, Color = { 255, 110, 220 }, Material = "Neon" },
			{ Name = "Sprinkle3", Shape = "Sphere", Size = { 0.28, 0.28, 0.28 }, Offset = { 1.0, 0.9, 0.5 }, Color = { 110, 190, 255 }, Material = "Neon" },
			{ Name = "Filling", Shape = "Sphere", Size = { 1.2, 1.2, 0.5 }, Offset = { 0, 0, 0 }, Color = { 120, 200, 90 }, Material = "SmoothPlastic" },
		},
	},
}

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
BrainrotData.List = ROSTER
BrainrotData.ById = {}
BrainrotData.ByZone = {}

for _, entry in ipairs(ROSTER) do
	BrainrotData.ById[entry.Id] = entry
	if not BrainrotData.ByZone[entry.Zone] then
		BrainrotData.ByZone[entry.Zone] = {}
	end
	table.insert(BrainrotData.ByZone[entry.Zone], entry)
end

BrainrotData.Count = #ROSTER

-- Pick a random entry for a zone + rarity. Falls back to any entry of that
-- rarity, then to any entry of the zone, so a spawn roll never comes up empty.
function BrainrotData.Pick(zoneKey, rarityName)
	local zonePool = BrainrotData.ByZone[zoneKey]
	if zonePool then
		local matches = {}
		for _, entry in ipairs(zonePool) do
			if entry.Rarity == rarityName then
				table.insert(matches, entry)
			end
		end
		if #matches > 0 then
			return matches[math.random(1, #matches)]
		end
	end
	local rarityPool = {}
	for _, entry in ipairs(ROSTER) do
		if entry.Rarity == rarityName then
			table.insert(rarityPool, entry)
		end
	end
	if #rarityPool > 0 then
		return rarityPool[math.random(1, #rarityPool)]
	end
	if zonePool and #zonePool > 0 then
		return zonePool[math.random(1, #zonePool)]
	end
	return ROSTER[math.random(1, #ROSTER)]
end

-- ---------------------------------------------------------------------------
-- Model builder
-- ---------------------------------------------------------------------------
local function toColor(value, entry)
	if type(value) == "table" then
		return Color3.fromRGB(value[1], value[2], value[3])
	elseif value == "Accent" then
		return Color3.fromRGB(entry.Accent[1], entry.Accent[2], entry.Accent[3])
	elseif value == "Body" then
		return Color3.fromRGB(entry.Body.Color[1], entry.Body.Color[2], entry.Body.Color[3])
	elseif value == "Dark" then
		return Color3.fromRGB(24, 24, 30)
	elseif value == "White" then
		return Color3.fromRGB(250, 250, 250)
	end
	return Color3.fromRGB(255, 255, 255)
end

local function toMaterial(name)
	if type(name) == "string" then
		local ok, result = pcall(function()
			return Enum.Material[name]
		end)
		if ok and result then
			return result
		end
	end
	return Enum.Material.SmoothPlastic
end

local function toShape(name)
	if name == "Sphere" then
		return Enum.PartType.Ball
	elseif name == "Cylinder" then
		return Enum.PartType.Cylinder
	end
	return Enum.PartType.Block
end

local function makePart(name, shape, size, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = toShape(shape)
	part.Size = Vector3.new(size[1], size[2], size[3])
	part.Color = color
	part.Material = material
	part.CanCollide = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	return part
end

local function weldTo(part, body)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = body
	weld.Part1 = part
	weld.Parent = body
end

-- Build a fresh Model for a roster entry. The model origin sits at ground
-- level under the body; the Body part is the PrimaryPart and starts Anchored
-- (callers unanchor it when the model needs to be carried).
function BrainrotData.BuildModel(entry)
	local model = Instance.new("Model")
	model.Name = entry.Id

	local bodySize = entry.Body.Size
	local body = makePart(
		"Body",
		entry.Body.Shape,
		bodySize,
		Color3.fromRGB(entry.Body.Color[1], entry.Body.Color[2], entry.Body.Color[3]),
		toMaterial(entry.Body.Material)
	)
	body.Anchored = true
	if entry.Body.Transparency then
		body.Transparency = entry.Body.Transparency
	end
	-- Cylinders lie along X by default; stand them up unless the recipe
	-- explicitly wants a horizontal cylinder (the Infinite Burrito).
	if entry.Body.Shape == "Cylinder" and entry.Body.Upright ~= false then
		body.Rotation = Vector3.new(0, 0, 90)
	end
	body.Position = Vector3.new(0, bodySize[2] / 2, 0)
	body.Parent = model
	model.PrimaryPart = body

	-- Eyes: two white spheres with dark pupils on the +Z face. Characters
	-- with EyeColor get glowing eyes in that color instead.
	local eyeColor = entry.EyeColor
	local eyeWhite = eyeColor and Color3.fromRGB(eyeColor[1], eyeColor[2], eyeColor[3])
		or Color3.fromRGB(252, 252, 252)
	local eyeMaterial = eyeColor and Enum.Material.Neon or Enum.Material.SmoothPlastic
	local eyeX = bodySize[1] * 0.22
	local eyeY = bodySize[2] * 0.12
	local eyeZ = bodySize[3] / 2 - 0.04
	for _, side in ipairs({ -1, 1 }) do
		local eye = makePart("Eye", "Sphere", { 0.34, 0.4, 0.24 }, eyeWhite, eyeMaterial)
		eye.Position = body.Position + Vector3.new(side * eyeX, eyeY, eyeZ)
		eye.Parent = model
		weldTo(eye, body)
		if not eyeColor then
			local pupil = makePart("Pupil", "Sphere", { 0.17, 0.2, 0.12 }, Color3.fromRGB(20, 20, 26), Enum.Material.SmoothPlastic)
			pupil.Position = body.Position + Vector3.new(side * eyeX, eyeY, eyeZ + 0.1)
			pupil.Parent = model
			weldTo(pupil, body)
		end
	end

	-- Recipe parts, positioned relative to the body centre.
	if entry.Parts then
		for _, recipe in ipairs(entry.Parts) do
			local part = makePart(
				recipe.Name,
				recipe.Shape,
				recipe.Size,
				toColor(recipe.Color, entry),
				toMaterial(recipe.Material)
			)
			if recipe.Transparency then
				part.Transparency = recipe.Transparency
			end
			local offset = recipe.Offset or { 0, 0, 0 }
			part.Position = body.Position + Vector3.new(offset[1], offset[2], offset[3])
			if recipe.Rotation then
				part.Rotation = Vector3.new(recipe.Rotation[1], recipe.Rotation[2], recipe.Rotation[3])
			end
			part.Parent = model
			weldTo(part, body)
		end
	end

	-- Epic and above get a soft glow so they read as special from a distance.
	local rarityRank = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythic = 6 }
	if (rarityRank[entry.Rarity] or 1) >= 4 then
		local light = Instance.new("PointLight")
		light.Name = "RarityGlow"
		light.Brightness = 1.2
		light.Range = 9
		local rc = entry.Accent
		light.Color = Color3.fromRGB(rc[1], rc[2], rc[3])
		light.Parent = body
		local highlight = Instance.new("Highlight")
		highlight.Name = "RarityHighlight"
		highlight.FillTransparency = 0.88
		highlight.OutlineTransparency = 0.35
		highlight.FillColor = light.Color
		highlight.OutlineColor = light.Color
		highlight.Parent = model
	end

	-- Floating name tag: name, rarity and income, readable in screenshots.
	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.new(5, 0, 1.6, 0)
	tag.StudsOffset = Vector3.new(0, bodySize[2] / 2 + 1.1, 0)
	tag.AlwaysOnTop = false
	tag.MaxDistance = 90
	tag.Adornee = body
	tag.Parent = model

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.35
	nameLabel.Text = entry.Name
	nameLabel.Parent = tag

	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "SubLabel"
	subLabel.Size = UDim2.new(1, 0, 0.45, 0)
	subLabel.Position = UDim2.new(0, 0, 0.55, 0)
	subLabel.BackgroundTransparency = 1
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextScaled = true
	subLabel.TextStrokeTransparency = 0.35
	subLabel.Text = entry.Rarity .. "  •  $" .. entry.Income .. "/s"
	subLabel.Parent = tag

	model:SetAttribute("EntryId", entry.Id)
	model:SetAttribute("Rarity", entry.Rarity)
	model:SetAttribute("BaseIncome", entry.Income)

	return model
end

return BrainrotData
