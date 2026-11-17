-- UI.client.luau
-- CHAOS BRAINROT: MUTATION ISLAND
-- All client interface: start screen, HUD (cash / income / gems / rebirths),
-- Collection Index panel, Rebirth + Lock buttons, event banner and toasts.
-- The client only DISPLAYS state and sends requests -- the server owns every
-- number. HUD elements keep clear of the top-left corner (Roblox's own menu
-- buttons live there).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local BrainrotData = require(Shared:WaitForChild("BrainrotData"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local eventAnnounce = Remotes:WaitForChild("EventAnnounce")
local notifyRemote = Remotes:WaitForChild("Notify")
local mutationReveal = Remotes:WaitForChild("MutationReveal")
local requestRebirth = Remotes:WaitForChild("RequestRebirth")
local requestLock = Remotes:WaitForChild("RequestLock")

local leaderstats = player:WaitForChild("leaderstats")
local cashValue = leaderstats:WaitForChild("Cash")
local gemsValue = leaderstats:WaitForChild("Gems")
local rebirthsValue = leaderstats:WaitForChild("Rebirths")

-- ---------------------------------------------------------------------------
-- Small builders
-- ---------------------------------------------------------------------------
local function corner(instance, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = instance
	return c
end

local function makeLabel(parent, name, text, size, position, options)
	options = options or {}
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Size = size
	label.Position = position
	label.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	label.BackgroundTransparency = options.BackgroundTransparency ~= nil and options.BackgroundTransparency or 1
	label.BackgroundColor3 = options.BackgroundColor3 or Color3.fromRGB(24, 20, 38)
	label.Font = options.Font or Enum.Font.GothamBold
	label.TextSize = options.TextSize or 18
	label.TextColor3 = options.TextColor3 or Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = options.TextStrokeTransparency ~= nil and options.TextStrokeTransparency or 0.55
	label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
	label.TextYAlignment = options.TextYAlignment or Enum.TextYAlignment.Center
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function makeButton(parent, name, text, size, position, color, options)
	options = options or {}
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Size = size
	button.Position = position
	button.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	button.BackgroundColor3 = color
	button.Font = Enum.Font.GothamBold
	button.TextSize = options.TextSize or 17
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextStrokeTransparency = 0.6
	button.AutoButtonColor = true
	button.Parent = parent
	corner(button, 10)
	return button
end

local function formatMoney(n)
	n = math.floor(n)
	local s = tostring(n)
	local out = ""
	while #s > 3 do
		out = "," .. s:sub(-3) .. out
		s = s:sub(1, -4)
	end
	return "$" .. s .. out
end

-- ---------------------------------------------------------------------------
-- Root GUI
-- ---------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "ChaosHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.Parent = playerGui

-- ---------------------------------------------------------------------------
-- HUD stats (top-right stack)
-- ---------------------------------------------------------------------------
local statsFrame = Instance.new("Frame")
statsFrame.Name = "Stats"
statsFrame.Size = UDim2.new(0, 230, 0, 118)
statsFrame.Position = UDim2.new(1, -14, 0, 14)
statsFrame.AnchorPoint = Vector2.new(1, 0)
statsFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 36)
statsFrame.BackgroundTransparency = 0.25
statsFrame.Parent = gui
corner(statsFrame, 12)

local cashLabel = makeLabel(statsFrame, "Cash", "$0", UDim2.new(1, -16, 0, 30), UDim2.new(0, 8, 0, 6), {
	TextSize = 22, TextColor3 = Color3.fromRGB(140, 255, 150), TextXAlignment = Enum.TextXAlignment.Right,
})
local incomeLabel = makeLabel(statsFrame, "Income", "+$0/s", UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 0, 38), {
	TextSize = 16, TextColor3 = Color3.fromRGB(190, 235, 255), TextXAlignment = Enum.TextXAlignment.Right,
})
local gemsLabel = makeLabel(statsFrame, "Gems", "Gems: 0", UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 0, 63), {
	TextSize = 16, TextColor3 = Color3.fromRGB(255, 170, 230), TextXAlignment = Enum.TextXAlignment.Right,
})
local rebirthsLabel = makeLabel(statsFrame, "Rebirths", "Rebirths: 0", UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 0, 88), {
	TextSize = 16, TextColor3 = Color3.fromRGB(255, 220, 130), TextXAlignment = Enum.TextXAlignment.Right,
})

-- ---------------------------------------------------------------------------
-- Buttons (bottom-right)
-- ---------------------------------------------------------------------------
local indexButton = makeButton(gui, "IndexButton", "COLLECTION INDEX", UDim2.new(0, 218, 0, 44), UDim2.new(1, -14, 1, -160), Color3.fromRGB(88, 64, 170), {
	AnchorPoint = Vector2.new(1, 0),
})
local rebirthButton = makeButton(gui, "RebirthButton", "REBIRTH", UDim2.new(0, 218, 0, 44), UDim2.new(1, -14, 1, -108), Color3.fromRGB(196, 120, 40), {
	AnchorPoint = Vector2.new(1, 0),
})
local lockButton = makeButton(gui, "LockButton", "LOCK BASE", UDim2.new(0, 218, 0, 44), UDim2.new(1, -14, 1, -56), Color3.fromRGB(52, 120, 180), {
	AnchorPoint = Vector2.new(1, 0),
})

-- Carrying indicator (bottom-center)
local carryingLabel = makeLabel(gui, "Carrying", "", UDim2.new(0, 420, 0, 34), UDim2.new(0.5, 0, 1, -52), {
	AnchorPoint = Vector2.new(0.5, 0), TextSize = 19, TextXAlignment = Enum.TextXAlignment.Center,
	TextColor3 = Color3.fromRGB(255, 240, 170), BackgroundTransparency = 0.3,
})
corner(carryingLabel, 10)
carryingLabel.Visible = false

-- ---------------------------------------------------------------------------
-- Event banner (top-center)
-- ---------------------------------------------------------------------------
local banner = Instance.new("Frame")
banner.Name = "EventBanner"
banner.Size = UDim2.new(0, 560, 0, 86)
banner.Position = UDim2.new(0.5, 0, 0, 16)
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.BackgroundColor3 = Color3.fromRGB(46, 24, 74)
banner.BackgroundTransparency = 0.12
banner.Visible = false
banner.Parent = gui
corner(banner, 14)
local bannerTitle = makeLabel(banner, "Title", "", UDim2.new(1, -24, 0, 38), UDim2.new(0, 12, 0, 6), {
	TextSize = 26, Font = Enum.Font.GothamBlack, TextXAlignment = Enum.TextXAlignment.Center,
	TextColor3 = Color3.fromRGB(255, 226, 130),
})
local bannerText = makeLabel(banner, "Text", "", UDim2.new(1, -24, 0, 36), UDim2.new(0, 12, 0, 44), {
	TextSize = 16, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Center,
})
local bannerToken = 0
local function showBanner(title, text, duration)
	bannerToken += 1
	local token = bannerToken
	bannerTitle.Text = title
	bannerText.Text = text
	banner.Visible = true
	banner.BackgroundTransparency = 0.12
	task.spawn(function()
		task.wait(duration or 6)
		if bannerToken == token then
			banner.Visible = false
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Toasts (right side, under the stats)
-- ---------------------------------------------------------------------------
local toastFrame = Instance.new("Frame")
toastFrame.Name = "Toasts"
toastFrame.Size = UDim2.new(0, 300, 0, 300)
toastFrame.Position = UDim2.new(1, -14, 0, 146)
toastFrame.AnchorPoint = Vector2.new(1, 0)
toastFrame.BackgroundTransparency = 1
toastFrame.Parent = gui
local toastLayout = Instance.new("UIListLayout")
toastLayout.FillDirection = Enum.FillDirection.Vertical
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Padding = UDim.new(0, 6)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
toastLayout.Parent = toastFrame

local toastCount = 0
local function showToast(text, color)
	toastCount += 1
	local toast = makeLabel(toastFrame, "Toast", text, UDim2.new(0, 296, 0, 40), UDim2.new(0, 0, 0, 0), {
		TextSize = 15, BackgroundTransparency = 0.18, TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = color or Color3.fromRGB(255, 255, 255),
	})
	toast.LayoutOrder = toastCount
	corner(toast, 9)
	task.spawn(function()
		task.wait(4.5)
		if toast and toast.Parent then
			TweenService:Create(toast, TweenInfo.new(0.4), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
			task.wait(0.45)
			if toast and toast.Parent then
				toast:Destroy()
			end
		end
	end)
end

-- Mutation reveal flash (centre screen)
local revealLabel = makeLabel(gui, "Reveal", "", UDim2.new(0, 700, 0, 60), UDim2.new(0.5, 0, 0.34, 0), {
	AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 34, Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1, TextStrokeTransparency = 1,
})
local revealToken = 0
local function showReveal(text, color)
	revealToken += 1
	local token = revealToken
	revealLabel.Text = text
	revealLabel.TextColor3 = color
	revealLabel.TextTransparency = 0
	revealLabel.TextStrokeTransparency = 0.3
	task.spawn(function()
		task.wait(2.2)
		if revealToken == token then
			TweenService:Create(revealLabel, TweenInfo.new(0.6), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Collection Index panel
-- ---------------------------------------------------------------------------
local indexPanel = Instance.new("Frame")
indexPanel.Name = "IndexPanel"
indexPanel.Size = UDim2.new(0, 640, 0, 470)
indexPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
indexPanel.AnchorPoint = Vector2.new(0.5, 0.5)
indexPanel.BackgroundColor3 = Color3.fromRGB(26, 22, 44)
indexPanel.BackgroundTransparency = 0.05
indexPanel.Visible = false
indexPanel.Parent = gui
corner(indexPanel, 16)

local indexTitle = makeLabel(indexPanel, "Title", "COLLECTION INDEX", UDim2.new(1, -90, 0, 40), UDim2.new(0, 16, 0, 8), {
	TextSize = 24, Font = Enum.Font.GothamBlack,
})
local indexClose = makeButton(indexPanel, "Close", "X", UDim2.new(0, 42, 0, 36), UDim2.new(1, -52, 0, 10), Color3.fromRGB(170, 52, 64), { TextSize = 18 })

local indexScroll = Instance.new("ScrollingFrame")
indexScroll.Name = "Grid"
indexScroll.Size = UDim2.new(1, -24, 1, -64)
indexScroll.Position = UDim2.new(0, 12, 0, 54)
indexScroll.BackgroundTransparency = 1
indexScroll.BorderSizePixel = 0
indexScroll.ScrollBarThickness = 6
indexScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
indexScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
indexScroll.Parent = indexPanel
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 142, 0, 104)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = indexScroll

local function rarityColor(rarity)
	local c = Config.RarityColors[rarity] or { 255, 255, 255 }
	return Color3.fromRGB(c[1], c[2], c[3])
end

local function refreshIndex()
	for _, child in ipairs(indexScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	local found = 0
	for i, entry in ipairs(BrainrotData.List) do
		local discovered = player:GetAttribute("Found_" .. entry.Id) == true
		if discovered then
			found += 1
		end
		local cell = Instance.new("Frame")
		cell.Name = "Cell_" .. entry.Id
		cell.LayoutOrder = (Config.RarityOrder[entry.Rarity] or 1) * 100 + i
		cell.BackgroundColor3 = discovered and Color3.fromRGB(44, 38, 66) or Color3.fromRGB(16, 14, 24)
		cell.Parent = indexScroll
		corner(cell, 10)

		local rc = rarityColor(entry.Rarity)
		makeLabel(cell, "Rarity", entry.Rarity:upper(), UDim2.new(1, -12, 0, 20), UDim2.new(0, 6, 0, 6), {
			TextSize = 12, TextColor3 = discovered and rc or Color3.fromRGB(90, 88, 104),
		})
		makeLabel(cell, "Name", discovered and entry.Name or "???", UDim2.new(1, -12, 0, 44), UDim2.new(0, 6, 0, 26), {
			TextSize = 15, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = discovered and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(90, 88, 104),
		})
		makeLabel(cell, "Income", discovered and ("$" .. entry.Income .. "/s  •  " .. entry.Zone) or "Undiscovered", UDim2.new(1, -12, 0, 20), UDim2.new(0, 6, 1, -26), {
			TextSize = 12, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(170, 220, 180),
		})
	end
	indexTitle.Text = "COLLECTION INDEX  (" .. found .. "/" .. BrainrotData.Count .. ")"
end

indexButton.MouseButton1Click:Connect(function()
	indexPanel.Visible = not indexPanel.Visible
	if indexPanel.Visible then
		refreshIndex()
	end
end)
indexClose.MouseButton1Click:Connect(function()
	indexPanel.Visible = false
end)
player.AttributeChanged:Connect(function(attributeName)
	if attributeName:sub(1, 6) == "Found_" and indexPanel.Visible then
		refreshIndex()
	end
end)

-- ---------------------------------------------------------------------------
-- Buttons -> server requests
-- ---------------------------------------------------------------------------
rebirthButton.MouseButton1Click:Connect(function()
	requestRebirth:FireServer()
end)
lockButton.MouseButton1Click:Connect(function()
	requestLock:FireServer()
end)

-- ---------------------------------------------------------------------------
-- Remote listeners
-- ---------------------------------------------------------------------------
eventAnnounce.OnClientEvent:Connect(function(_eventKey, title, message, duration)
	showBanner(title, message, duration)
end)

notifyRemote.OnClientEvent:Connect(function(text)
	showToast(text)
end)

mutationReveal.OnClientEvent:Connect(function(entryName, mutationName, multiplier)
	if mutationName and mutationName ~= "Normal" then
		local visual = Config.MutationVisuals[mutationName]
		local color = Color3.fromRGB(255, 255, 255)
		if visual and visual.Glow then
			color = Color3.fromRGB(visual.Glow[1], visual.Glow[2], visual.Glow[3])
		end
		showReveal(mutationName:upper() .. " MUTATION!", color)
		showToast(entryName .. " mutated: " .. mutationName .. " (x" .. multiplier .. " income)", color)
	else
		showToast("Deposited " .. entryName .. " on your base.")
	end
end)

-- ---------------------------------------------------------------------------
-- Live HUD refresh
-- ---------------------------------------------------------------------------
local function refreshHud()
	cashLabel.Text = formatMoney(cashValue.Value)
	gemsLabel.Text = "Gems: " .. gemsValue.Value
	rebirthsLabel.Text = "Rebirths: " .. rebirthsValue.Value
	local ips = player:GetAttribute("IncomePerSecond") or 0
	incomeLabel.Text = "+$" .. ips .. "/s"
	local carrying = player:GetAttribute("Carrying") or ""
	if carrying ~= "" then
		carryingLabel.Text = "Carrying: " .. carrying .. " -- take it to your base pad!"
		carryingLabel.Visible = true
	else
		carryingLabel.Visible = false
	end
	if cashValue.Value >= Config.RebirthRequirement then
		rebirthButton.Text = "REBIRTH READY!"
		rebirthButton.BackgroundColor3 = Color3.fromRGB(232, 148, 40)
	else
		rebirthButton.Text = "REBIRTH " .. formatMoney(cashValue.Value) .. " / " .. formatMoney(Config.RebirthRequirement)
		rebirthButton.BackgroundColor3 = Color3.fromRGB(120, 84, 44)
	end
	if player:GetAttribute("BaseLocked") then
		lockButton.Text = "BASE LOCKED (" .. (player:GetAttribute("LockSeconds") or 0) .. "s)"
		lockButton.BackgroundColor3 = Color3.fromRGB(46, 150, 90)
	else
		lockButton.Text = "LOCK BASE " .. formatMoney(Config.BaseLockPrice)
		lockButton.BackgroundColor3 = Color3.fromRGB(52, 120, 180)
	end
end

cashValue.Changed:Connect(refreshHud)
gemsValue.Changed:Connect(refreshHud)
rebirthsValue.Changed:Connect(refreshHud)
player.AttributeChanged:Connect(refreshHud)
refreshHud()

-- ---------------------------------------------------------------------------
-- Start screen
-- ---------------------------------------------------------------------------
local startScreen = Instance.new("Frame")
startScreen.Name = "StartScreen"
startScreen.Size = UDim2.new(1, 0, 1, 0)
startScreen.BackgroundColor3 = Color3.fromRGB(16, 12, 30)
startScreen.BackgroundTransparency = 0.08
startScreen.ZIndex = 10
startScreen.Parent = gui

makeLabel(startScreen, "Title", "CHAOS BRAINROT", UDim2.new(1, 0, 0, 84), UDim2.new(0, 0, 0.16, 0), {
	TextSize = 64, Font = Enum.Font.GothamBlack, TextXAlignment = Enum.TextXAlignment.Center,
	TextColor3 = Color3.fromRGB(255, 226, 130),
}).ZIndex = 11
makeLabel(startScreen, "Subtitle", "M U T A T I O N   I S L A N D", UDim2.new(1, 0, 0, 44), UDim2.new(0, 0, 0.16, 88), {
	TextSize = 30, Font = Enum.Font.GothamBlack, TextXAlignment = Enum.TextXAlignment.Center,
	TextColor3 = Color3.fromRGB(190, 150, 255),
}).ZIndex = 11
local howToLabel = makeLabel(startScreen, "HowTo",
	"Hunt wild brainrots across 4 zones. Carry them home to your base to earn cash every second.\n"
		.. "Deposit to roll mutations worth up to x35. Survive chaos events. Rebirth to unlock the Crystal Void.\n"
		.. "And watch your base -- other players can steal what you display!",
	UDim2.new(0, 760, 0, 96), UDim2.new(0.5, 0, 0.42, 0), {
		AnchorPoint = Vector2.new(0.5, 0), TextSize = 18, Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top,
	})
howToLabel.ZIndex = 11

local playButton = makeButton(startScreen, "Play", "PLAY", UDim2.new(0, 260, 0, 62), UDim2.new(0.5, 0, 0.62, 0), Color3.fromRGB(64, 178, 92), {
	AnchorPoint = Vector2.new(0.5, 0), TextSize = 26,
})
playButton.ZIndex = 11
playButton.MouseButton1Click:Connect(function()
	TweenService:Create(startScreen, TweenInfo.new(0.45), { BackgroundTransparency = 1 }):Play()
	for _, child in ipairs(startScreen:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			TweenService:Create(child, TweenInfo.new(0.45), { TextTransparency = 1 }):Play()
		end
		if child:IsA("TextButton") then
			TweenService:Create(child, TweenInfo.new(0.45), { BackgroundTransparency = 1 }):Play()
		end
	end
	task.wait(0.5)
	startScreen:Destroy()
end)
