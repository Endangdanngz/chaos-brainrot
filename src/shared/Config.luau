-- Config.luau
-- CHAOS BRAINROT: MUTATION ISLAND
-- Every economy / gameplay number lives here so the whole game can be
-- rebalanced from one file. Required by both server services and the client UI.

local Config = {}

-- ---------------------------------------------------------------------------
-- General
-- ---------------------------------------------------------------------------
Config.GameName = "CHAOS BRAINROT: MUTATION ISLAND"
Config.DataStoreName = "ChaosBrainrot_Profiles_v1"
Config.AutosaveSeconds = 120

Config.StartCash = 0
Config.StartGems = 0

-- ---------------------------------------------------------------------------
-- Collection / carrying / bases
-- ---------------------------------------------------------------------------
Config.CarryLimit = 1 -- brainrots a player can carry at once
Config.PickupRadius = 9 -- studs from a wild brainrot to pick it up
Config.DepositRadius = 11 -- studs from own deposit pad to deposit
Config.PedestalsPerBase = 10 -- display slots per player base
Config.MaxPlayersBases = 8 -- base plots built around the shore

-- Spawning per zone. Weights are relative rarity weights for that zone.
Config.ZoneSpawns = {
	Meadow = {
		Interval = 4,
		MaxWild = 8,
		Weights = { Common = 70, Uncommon = 25, Rare = 5 },
	},
	Swamp = {
		Interval = 6,
		MaxWild = 7,
		Weights = { Uncommon = 45, Rare = 38, Epic = 12, Legendary = 5 },
	},
	Ashlands = {
		Interval = 8,
		MaxWild = 6,
		Weights = { Rare = 40, Epic = 38, Legendary = 20, Mythic = 2 },
	},
	Void = {
		Interval = 10,
		MaxWild = 5,
		Weights = { Epic = 25, Legendary = 45, Mythic = 30 },
	},
}

-- Rarity ordering (low -> high), used for fallbacks and UI sorting.
Config.RarityOrder = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
}

Config.RarityColors = {
	Common = { 205, 210, 215 },
	Uncommon = { 105, 230, 130 },
	Rare = { 80, 170, 255 },
	Epic = { 185, 105, 255 },
	Legendary = { 255, 190, 40 },
	Mythic = { 255, 80, 200 },
}

-- ---------------------------------------------------------------------------
-- Mutations (rolled once, at deposit time)
-- Chance is a percentage; the table must total 100. Multiplier scales the
-- character's base income while it is displayed.
-- ---------------------------------------------------------------------------
Config.Mutations = {
	{ Name = "Normal", Chance = 70, Multiplier = 1 },
	{ Name = "Gold", Chance = 15, Multiplier = 2 },
	{ Name = "Neon", Chance = 8, Multiplier = 3 },
	{ Name = "Radioactive", Chance = 4, Multiplier = 5 },
	{ Name = "Glitched", Chance = 2, Multiplier = 8 },
	{ Name = "Cosmic", Chance = 0.8, Multiplier = 12 },
	{ Name = "Void", Chance = 0.15, Multiplier = 20 },
	{ Name = "Celestial", Chance = 0.05, Multiplier = 35 },
}

-- During a MutationStorm event every non-Normal mutation weight is
-- multiplied by this factor (weights are then renormalised).
Config.MutationStormBoost = 3

-- Visual recipe per mutation, applied by MutationService.
-- Tint = {r,g,b} forced body tint (nil keeps the character's own colors),
-- Material = forced material name (nil keeps), Glow = {r,g,b} neon glow color
-- used for accent parts + particles (nil = no glow treatment).
Config.MutationVisuals = {
	Normal = { Tint = nil, Material = nil, Glow = nil },
	Gold = { Tint = { 255, 196, 48 }, Material = "Metal", Glow = { 255, 214, 90 } },
	Neon = { Tint = nil, Material = nil, Glow = { 64, 255, 214 } },
	Radioactive = { Tint = { 132, 255, 92 }, Material = nil, Glow = { 120, 255, 70 } },
	Glitched = { Tint = { 255, 92, 246 }, Material = "Neon", Glow = { 255, 92, 246 } },
	Cosmic = { Tint = { 74, 52, 140 }, Material = nil, Glow = { 168, 120, 255 } },
	Void = { Tint = { 16, 14, 26 }, Material = "Slate", Glow = { 140, 90, 255 } },
	Celestial = { Tint = { 255, 244, 200 }, Material = "Neon", Glow = { 255, 240, 190 } },
}

-- ---------------------------------------------------------------------------
-- Economy
-- ---------------------------------------------------------------------------
Config.IncomeTickSeconds = 1

-- Rebirth: pay this much Cash (balance is reset), gain a permanent income
-- multiplier of (1 + RebirthMultiplierPer * Rebirths) and unlock Crystal Void.
Config.RebirthRequirement = 10000
Config.RebirthMultiplierPer = 0.5
Config.RebirthGemBonus = 5

-- Base lock (anti-steal shield) bought with Cash.
Config.BaseLockPrice = 250
Config.BaseLockDuration = 60 -- seconds

-- Stealing
Config.StealCooldown = 45 -- seconds between steals for one thief
Config.TagRange = 5.5 -- owner this close to the thief makes them drop the loot

-- ---------------------------------------------------------------------------
-- Chaos events
-- ---------------------------------------------------------------------------
Config.EventMinInterval = 180 -- 3 minutes
Config.EventMaxInterval = 300 -- 5 minutes
Config.MeteorShowerDuration = 45
Config.MeteorCashMin = 40
Config.MeteorCashMax = 120
Config.ToxicRainDuration = 60
Config.ToxicRainDamagePerSecond = 2
Config.MutationStormDuration = 60
Config.GravityCollapseDuration = 45
Config.LowGravity = 55 -- Workspace.Gravity during GravityCollapse (default 196.2)
Config.TreasureCashMin = 400
Config.TreasureCashMax = 900

return Config
