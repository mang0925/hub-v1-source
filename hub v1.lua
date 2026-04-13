-- =========================
-- Whitelist Check
-- =========================
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local lp = player  -- Alias for compatibility

local Whitelist = {
    "personne",
    "MANGGO_497",
    "99night_072",
    "sogane1234",
    "MANGOAT090",
    "sadowyoni_ytb",
    "Lz_49k6",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne",
    "personne"
}

local function isWhitelisted(name)
    name = name:lower()
    for _, v in ipairs(Whitelist) do
        if name == v:lower() then
            return true
        end
    end
    return false
end

if not isWhitelisted(player.Name) and not isWhitelisted(player.DisplayName) then
    player:Kick("Not whitelisted")
    return
end
local TOGGLE_FRIENDS_KEYBIND = Enum.KeyCode.F  
local AUTO_BLOCK_KEYBIND = Enum.KeyCode.C      

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local OFF_TEXTURE = "rbxassetid://110783679426495"
local ON_TEXTURE = "rbxassetid://110507824065923"

local HAS_GETCONNECTIONS = false
pcall(function()
	HAS_GETCONNECTIONS = typeof(getconnections) == "function"
end)

local RemoteIndex = {}
local RemoteObjects = {}

local children = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):GetChildren()
for i, obj in ipairs(children) do
	if obj:IsA("RemoteEvent") then
		local nextIndex = i + 1
		local nextObj = children[nextIndex]
		if nextObj then
			RemoteIndex[obj.Name] = nextIndex
			RemoteObjects[nextIndex] = nextObj
		end
	end
end

local function fireRemote(name, ...)
	local index = RemoteIndex[name]
	if index then
		local remote = RemoteObjects[index]
		if remote then
			remote:FireServer(...)
			return true
		end
	end
	return false
end

local myBaseFriendPanel = nil
local toggleButton = nil
local blockButton = nil
local isUnlocked = false

local trackedPanels = {}
local billboardFolder = Instance.new("Folder")
billboardFolder.Name = "FriendPanelESPs"
billboardFolder.Parent = playerGui

local function isEmptyBase(friendPanelModel)
	if not friendPanelModel or not friendPanelModel.Parent then return false end
	
	local plotFolder = friendPanelModel.Parent
	local plotSign = plotFolder:FindFirstChild("PlotSign", true)
	if not plotSign then return false end
	
	for _, descendant in pairs(plotSign:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			local text = string.lower(descendant.Text or "")
			if text:find("empty") and text:find("base") then
				return true
			end
		end
	end
	
	return false
end

local function createESP(friendPanelModel, text, color)
	local main = friendPanelModel:FindFirstChild("Main")
	if not main or not main:IsA("BasePart") then return end
	
	local existingESP = billboardFolder:FindFirstChild("ESP_" .. friendPanelModel:GetDebugId())
	if existingESP then
		existingESP:Destroy()
	end
	
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "ESP_" .. friendPanelModel:GetDebugId()
	billboardGui.Adornee = main
	billboardGui.Size = UDim2.new(0, 240, 0, 60)
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.MaxDistance = 1e6
	billboardGui.Parent = billboardFolder
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextScaled = true
	textLabel.TextStrokeTransparency = 0
	textLabel.TextColor3 = color
	textLabel.Text = text
	textLabel.Parent = billboardGui
	
	return billboardGui
end

local function updateESP(friendPanelModel, imageElement)
	if not imageElement or not friendPanelModel then return end
	if isEmptyBase(friendPanelModel) then return end
	
	local data = trackedPanels[friendPanelModel]
	if not data then return end
	
	local imageId = imageElement.Image
	
	if data.billboard then
		pcall(function()
			data.billboard:Destroy()
		end)
		data.billboard = nil
	end
	
	if imageId == OFF_TEXTURE then
		data.billboard = createESP(friendPanelModel, "OFF", Color3.fromRGB(255, 0, 0))
	elseif imageId == ON_TEXTURE then
		data.billboard = createESP(friendPanelModel, "ON", Color3.fromRGB(0, 255, 0))
	end
end

local function scanFriendPanel(friendPanelModel)
	if trackedPanels[friendPanelModel] then return end
	
	local function attemptScan()
		if trackedPanels[friendPanelModel] then return true end
		
		local main = friendPanelModel:FindFirstChild("Main")
		if not main then return false end
		
		local surfaceGui = main:FindFirstChildWhichIsA("SurfaceGui")
		if not surfaceGui then return false end
		
		local maxWait = 0
		while #surfaceGui:GetDescendants() < 3 and maxWait < 60 do
			task.wait(0.03)
			maxWait = maxWait + 1
		end
		
		for _, guiElement in pairs(surfaceGui:GetDescendants()) do
			if guiElement:IsA("ImageLabel") or guiElement:IsA("ImageButton") then
				local imageId = guiElement.Image
				
				if imageId == OFF_TEXTURE or imageId == ON_TEXTURE then
					if trackedPanels[friendPanelModel] then return true end
					
					trackedPanels[friendPanelModel] = {
						imageElement = guiElement,
						billboard = nil
					}
					
					guiElement:GetPropertyChangedSignal("Image"):Connect(function()
						updateESP(friendPanelModel, guiElement)
					end)
					
					updateESP(friendPanelModel, guiElement)
					return true
				end
			end
		end
		
		return false
	end
	
	if attemptScan() then return end
	
	task.spawn(function()
		local retryDelays = {0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.75, 1, 1.5, 2}
		for _, delay in ipairs(retryDelays) do
			task.wait(delay)
			if trackedPanels[friendPanelModel] then return end
			if attemptScan() then return end
		end
		
		for i = 1, 10 do
			task.wait(1)
			if trackedPanels[friendPanelModel] then return end
			if attemptScan() then return end
		end
	end)
end

local function instantScan()
	local found = 0
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj.Name == "FriendPanel" and obj:IsA("Model") then
			found = found + 1
			task.spawn(function()
				scanFriendPanel(obj)
			end)
		end
	end
	return found
end

local function deepScan()
	task.spawn(function()
		for i = 1, 15 do
			local count = instantScan()
			task.wait(0.3)
		end
	end)
end

local function continuousScan()
	task.spawn(function()
		while true do
			task.wait(1.5)
			instantScan()
		end
	end)
end

local function findMyBasePlot()
	local visibleBillboards = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BillboardGui") and obj.Enabled then
			for _, child in ipairs(obj:GetDescendants()) do
				if child:IsA("TextLabel") and child.Visible then
					if string.upper(child.Text) == "YOUR BASE" and child.TextTransparency < 1 then
						table.insert(visibleBillboards, obj)
					end
				end
			end
		end
	end
	
	if #visibleBillboards > 1 and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local closest, closestDist
			for _, billboard in ipairs(visibleBillboards) do
				local pos
				if billboard.Parent and billboard.Parent:IsA("BasePart") then
					pos = billboard.Parent.Position
				elseif billboard.Parent and billboard.Parent:IsA("Model") then
					local part = billboard.Parent:FindFirstChildWhichIsA("BasePart", true)
					if part then pos = part.Position end
				end
				if pos then
					local dist = (pos - root.Position).Magnitude
					if not closest or dist < closestDist then
						closestDist = dist
						closest = billboard
					end
				end
			end
			if closest then return closest end
		end
	end
	return visibleBillboards[1]
end

local function getMyBasePlotModel()
	local billboard = findMyBasePlot()
	if not billboard then return nil end
	
	local current = billboard.Parent
	while current do
		if current.Parent and current.Parent.Name == "Plots" then
			return current
		end
		current = current.Parent
	end
	return nil
end

local function findMyFriendPanel()
	local myPlot = getMyBasePlotModel()
	if not myPlot then return nil end
	
	for _, obj in pairs(myPlot:GetDescendants()) do
		if obj.Name == "FriendPanel" and obj:IsA("Model") then
			return obj
		end
	end
	return nil
end

local function getCurrentStatus()
	myBaseFriendPanel = findMyFriendPanel()
	if not myBaseFriendPanel then return false end
	
	local main = myBaseFriendPanel:FindFirstChild("Main")
	if not main then return false end
	
	local surfaceGui = main:FindFirstChildWhichIsA("SurfaceGui")
	if not surfaceGui then return false end
	
	for _, guiElement in pairs(surfaceGui:GetDescendants()) do
		if guiElement:IsA("ImageLabel") or guiElement:IsA("ImageButton") then
			local imageId = guiElement.Image
			if imageId == ON_TEXTURE then
				return true
			elseif imageId == OFF_TEXTURE then
				return false
			end
		end
	end
	
	return false
end

local function updateButtonAppearance()
	isUnlocked = getCurrentStatus()
	
	if isUnlocked then
		toggleButton.BackgroundColor3 = Color3.fromRGB(120, 70, 140)
		toggleButton.Text = "Friends: UNLOCKED"
	else
		toggleButton.BackgroundColor3 = Color3.fromRGB(225, 140, 255)
		toggleButton.Text = "Friends: LOCKED"
	end
end

local function setupMonitoring()
	task.spawn(function()
		local maxRetries = 40
		local retryCount = 0
		
		while retryCount < maxRetries do
			myBaseFriendPanel = findMyFriendPanel()
			if myBaseFriendPanel then break end
			retryCount = retryCount + 1
			task.wait(0.15)
		end
		
		if not myBaseFriendPanel then
			task.wait(0.5)
			return setupMonitoring()
		end
		
		local main = myBaseFriendPanel:FindFirstChild("Main")
		if not main then 
			task.wait(0.3)
			return setupMonitoring()
		end
		
		local surfaceGui = main:FindFirstChildWhichIsA("SurfaceGui")
		local waitCount = 0
		while not surfaceGui and waitCount < 40 do
			task.wait(0.04)
			surfaceGui = main:FindFirstChildWhichIsA("SurfaceGui")
			waitCount = waitCount + 1
		end
		
		if not surfaceGui then 
			task.wait(0.3)
			return setupMonitoring()
		end
		
		waitCount = 0
		while #surfaceGui:GetDescendants() < 3 and waitCount < 40 do
			task.wait(0.04)
			waitCount = waitCount + 1
		end
		
		for _, guiElement in pairs(surfaceGui:GetDescendants()) do
			if guiElement:IsA("ImageLabel") or guiElement:IsA("ImageButton") then
				local imageId = guiElement.Image
				if imageId == ON_TEXTURE or imageId == OFF_TEXTURE then
					guiElement:GetPropertyChangedSignal("Image"):Connect(function()
						updateButtonAppearance()
					end)
					break
				end
			end
		end
		
		updateButtonAppearance()
	end)
end

local clickIndicator = nil

local function getClosestPlayer()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	
	if humanoidRootPart then
		local closestPlayer = nil
		local shortestDistance = math.huge
		
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character then
				local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
					if distance < shortestDistance then
						shortestDistance = distance
						closestPlayer = p
					end
				end
			end
		end
		
		if closestPlayer then return closestPlayer end
	end
	
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			return p
		end
	end
	
	return nil
end

local function findBlockButton(parent)
	if not parent then return nil end
	
	local promptOverlay = parent:FindFirstChild("promptOverlay")
	if promptOverlay then
		for _, descendant in pairs(promptOverlay:GetDescendants()) do
			if (descendant:IsA("TextButton") or descendant:IsA("ImageButton")) and descendant.Visible and descendant.Active then
				local name = descendant.Name:lower()
				if name:find("block") or name:find("confirm") or name:find("yes") or name:find("ok") or name:find("accept") then
					return descendant
				end
				
				if descendant:IsA("TextButton") then
					local text = descendant.Text:lower()
					if text:find("block") or text:find("yes") or text:find("confirm") then
						return descendant
					end
				end
			end
		end
	end
	
	for _, descendant in pairs(parent:GetDescendants()) do
		if (descendant:IsA("TextButton") or descendant:IsA("ImageButton")) and descendant.Visible and descendant.Active then
			local name = descendant.Name:lower()
			if name:find("block") or name:find("confirm") or name:find("yes") or name:find("ok") or name:find("accept") then
				return descendant
			end
			
			if descendant:IsA("TextButton") then
				local text = descendant.Text:lower()
				if text:find("block") or text:find("yes") or text:find("confirm") then
					return descendant
				end
			end
		end
	end
	
	return nil
end

local function autoClickBlockButton()
	task.spawn(function()
		local maxAttempts = 300
		local attempts = 0
		local buttonFound = false
		
		local originalBehavior = UserInputService.MouseBehavior
		local originalIconEnabled = UserInputService.MouseIconEnabled
		
		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
		
		task.wait(0.001)
		
		while attempts < maxAttempts do
			attempts = attempts + 1
			
			local blockBtn = findBlockButton(CoreGui)
			
			if blockBtn then
				buttonFound = true
				local absPos = blockBtn.AbsolutePosition
				local absSize = blockBtn.AbsoluteSize
				
				local centerX = math.floor(absPos.X + (absSize.X / 2) + 0.5)
				local centerY = math.floor(absPos.Y + (absSize.Y / 2) + 0.5)
				
				if clickIndicator then
					clickIndicator.Position = UDim2.new(0, centerX - 10, 0, centerY - 10)
					clickIndicator.Visible = true
				end
				
				local VirtualInputManager = game:GetService("VirtualInputManager")
				
				if HAS_GETCONNECTIONS then
					task.spawn(function()
						for i = 1, 30 do
							pcall(function()
								for _, connection in pairs(getconnections(blockBtn.MouseButton1Click)) do
									connection:Fire()
								end
								for _, connection in pairs(getconnections(blockBtn.Activated)) do
									connection:Fire()
								end
								for _, connection in pairs(getconnections(blockBtn.MouseButton1Down)) do
									connection:Fire()
								end
								for _, connection in pairs(getconnections(blockBtn.MouseButton1Up)) do
									connection:Fire()
								end
							end)
						end
					end)
				end
				
				task.spawn(function()
					for i = 1, 20 do
						VirtualInputManager:SendMouseMoveEvent(centerX, centerY, game)
						VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
						VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
					end
				end)
				
				task.spawn(function()
					for i = 1, 15 do
						pcall(function()
							blockBtn.MouseButton1Down:Fire()
							blockBtn.MouseButton1Up:Fire()
							blockBtn.MouseButton1Click:Fire()
						end)
					end
				end)
				
				task.wait(0.005)
				
				if clickIndicator then
					clickIndicator.Visible = false
				end
				
				task.wait(0.005)
				pcall(function()
					UserInputService.MouseBehavior = originalBehavior
					UserInputService.MouseIconEnabled = originalIconEnabled
				end)
				
				break
			end
			
			task.wait(0.001)
		end
		
		if not buttonFound or attempts >= maxAttempts then
			pcall(function()
				UserInputService.MouseBehavior = originalBehavior
				UserInputService.MouseIconEnabled = originalIconEnabled
			end)
		end
	end)
end

local function monitorForPrompt()
	local isSearching = false
	
	RunService.RenderStepped:Connect(function()
		if not isSearching then
			local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
			if promptGui then
				local overlay = promptGui:FindFirstChild("promptOverlay")
				if overlay and overlay.Visible then
					for _, desc in pairs(overlay:GetDescendants()) do
						if desc:IsA("TextLabel") and desc.Visible then
							local text = desc.Text:lower()
							if text:find("block") then
								isSearching = true
								autoClickBlockButton()
								task.wait(0.05)
								isSearching = false
								break
							end
						end
					end
				end
			end
		end
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PSHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleFriendsButton"
toggleButton.Size = UDim2.new(0, 200, 0, 50)
toggleButton.Position = UDim2.new(0.5, -210, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggleButton.Text = "Friends: LOCKED"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

blockButton = Instance.new("TextButton")
blockButton.Name = "BlockButton"
blockButton.Size = UDim2.new(0, 200, 0, 50)
blockButton.Position = UDim2.new(0.5, 10, 0.1, 0)
blockButton.BackgroundColor3 = Color3.fromRGB(120, 70, 140)
blockButton.Text = "Block Closest"
blockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
blockButton.TextSize = 18
blockButton.Font = Enum.Font.GothamBold
blockButton.Parent = screenGui

local blockCorner = Instance.new("UICorner")
blockCorner.CornerRadius = UDim.new(0, 8)
blockCorner.Parent = blockButton

clickIndicator = Instance.new("Frame")
clickIndicator.Name = "ClickIndicator"
clickIndicator.Size = UDim2.new(0, 20, 0, 20)
clickIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
clickIndicator.BorderSizePixel = 2
clickIndicator.BorderColor3 = Color3.fromRGB(255, 255, 255)
clickIndicator.Visible = false
clickIndicator.ZIndex = 10000
clickIndicator.Parent = screenGui

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0)
indicatorCorner.Parent = clickIndicator

toggleButton.MouseButton1Click:Connect(function()
	fireRemote("RE/PlotService/ToggleFriends")
	
	toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
	task.wait(0.2)
	
	task.wait(0.3)
	updateButtonAppearance()
end)

blockButton.MouseButton1Click:Connect(function()
	local closestPlayer = getClosestPlayer()
	
	if closestPlayer then
		local success = pcall(function()
			game:GetService("StarterGui"):SetCore("PromptBlockPlayer", closestPlayer)
		end)
		
		if success then
			blockButton.Text = "Blocking..."
			blockButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
			autoClickBlockButton()
			task.wait(0.15)
			blockButton.Text = "Block Closest"
			blockButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		end
	else
		blockButton.Text = "No Players"
		blockButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
		task.wait(0.15)
		blockButton.Text = "Block Closest"
		blockButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	local focusedTextBox = UserInputService:GetFocusedTextBox()
	if focusedTextBox then return end
	
	if input.KeyCode == TOGGLE_FRIENDS_KEYBIND then
		fireRemote("RE/PlotService/ToggleFriends")
		
		toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
		task.wait(0.2)
		
		task.wait(0.3)
		updateButtonAppearance()
	elseif input.KeyCode == AUTO_BLOCK_KEYBIND then
		local closestPlayer = getClosestPlayer()
		
		if closestPlayer then
			local success = pcall(function()
				game:GetService("StarterGui"):SetCore("PromptBlockPlayer", closestPlayer)
			end)
			
			if success then
				blockButton.Text = "Blocking..."
				blockButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
				autoClickBlockButton()
				task.wait(0.15)
				blockButton.Text = "Block Closest"
				blockButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
			end
		else
			blockButton.Text = "No Players"
			blockButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
			task.wait(0.15)
			blockButton.Text = "Block Closest"
			blockButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		end
	end
end)

monitorForPrompt()

task.spawn(function()
	updateButtonAppearance()
	task.wait(0.1)
	updateButtonAppearance()
	task.wait(0.15)
	updateButtonAppearance()
	task.wait(0.2)
	updateButtonAppearance()
	task.wait(0.25)
	setupMonitoring()
end)

task.spawn(function()
	for i = 1, 40 do
		updateButtonAppearance()
		task.wait(0.2)
	end
end)

task.spawn(function()
	task.wait(8)
	while true do
		task.wait(2)
		updateButtonAppearance()
	end
end)

continuousScan()

task.spawn(function()
	instantScan()
	task.wait(0.3)
	deepScan()
	task.wait(0.5)
	instantScan()
	task.wait(2)
	deepScan()
end)

Workspace.DescendantAdded:Connect(function(obj)
	if obj.Name == "FriendPanel" and obj:IsA("Model") then
		if trackedPanels[obj] then return end
		
		task.spawn(function()
			scanFriendPanel(obj)
		end)
		
		task.spawn(function()
			local retryDelays = {0.05, 0.1, 0.2, 0.4, 0.7, 1, 1.5, 2.5, 4, 6}
			for _, delay in ipairs(retryDelays) do
				task.wait(delay)
				if trackedPanels[obj] then break end
				scanFriendPanel(obj)
			end
		end)
	end
end)

Workspace.DescendantRemoving:Connect(function(obj)
	if trackedPanels[obj] then
		if trackedPanels[obj].billboard then
			pcall(function()
				trackedPanels[obj].billboard:Destroy()
			end)
		end
		trackedPanels[obj] = nil
	end
end)

task.spawn(function()
	while true do
		task.wait(5)
		
		for panel, data in pairs(trackedPanels) do
			if not panel.Parent then
				if data.billboard then 
					pcall(function()
						data.billboard:Destroy()
					end)
				end
				trackedPanels[panel] = nil
			end
		end
		
		local seenPanels = {}
		for _, billboard in pairs(billboardFolder:GetChildren()) do
			if billboard:IsA("BillboardGui") then
				local adornee = billboard.Adornee
				if adornee then
					local panelModel = adornee.Parent
					if panelModel and panelModel.Name == "FriendPanel" then
						local panelId = panelModel:GetDebugId()
						if seenPanels[panelId] then
							pcall(function()
								billboard:Destroy()
							end)
						else
							seenPanels[panelId] = true
						end
					end
				else
					pcall(function()
						billboard:Destroy()
					end)
				end
			end
		end
	end
end)
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local waypoints = {}
local isPlaying = false
local bestPetModel = nil
local selectedPetModel = nil

local playerBaseModel = nil
local playerBaseCached = false

local spawnerHeight = nil

local detectedPets = {}

local originalSizes = {}

local function crunchBody()
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part ~= humanoidRootPart then
			originalSizes[part] = part.Size
			part.Size = Vector3.new(0.1, 0.1, 0.1)
		end
	end
end

local function restoreBody()
	for part, originalSize in pairs(originalSizes) do
		if part and part.Parent then
			part.Size = originalSize
		end
	end
	originalSizes = {}
end

local greenPartsCache = {}
local greenPartsCacheTime = 0

local function findClosestGreenPart(fromPosition)
	if tick() - greenPartsCacheTime > 5 then
		greenPartsCache = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				local color = obj.Color
				if math.floor(color.R * 255) == 0 and math.floor(color.G * 255) == 195 and math.floor(color.B * 255) == 0 then
					table.insert(greenPartsCache, obj)
				end
			end
		end
		greenPartsCacheTime = tick()
	end
	
	local closestPart = nil
	local closestDistance = math.huge
	
	for _, obj in ipairs(greenPartsCache) do
		if obj and obj.Parent then
			local distance = (obj.Position - fromPosition).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				closestPart = obj
			end
		end
	end
	
	return closestPart
end

local function checkObstacleAbove(fromPosition, maxDistance)
	maxDistance = maxDistance or 50
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {character}
	
	local rayDirection = Vector3.new(0, maxDistance, 0)
	local raycastResult = workspace:Raycast(fromPosition, rayDirection, raycastParams)
	
	if raycastResult then
		return true, raycastResult.Position, raycastResult.Distance
	end
	
	return false, nil, nil
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VsterCarpetTPGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 320)        -- Encore plus petit
mainFrame.Position = UDim2.new(1, -240, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 14, 38)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local purpleBorder = Instance.new("UIStroke")
purpleBorder.Color = Color3.fromRGB(200, 110, 255)
purpleBorder.Thickness = 2.5
purpleBorder.Parent = mainFrame

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Titre très compact
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 26)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 14, 38)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -12, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "YZK TP BEST"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

-- Target compact
local targetFrame = Instance.new("Frame")
targetFrame.Size = UDim2.new(1, -14, 0, 36)
targetFrame.Position = UDim2.new(0, 7, 0, 32)
targetFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
targetFrame.Parent = mainFrame
Instance.new("UICorner", targetFrame).CornerRadius = UDim.new(0, 6)

local targetLabel = Instance.new("TextLabel")
targetLabel.Name = "TargetLabel"
targetLabel.Size = UDim2.new(1, -10, 1, 0)
targetLabel.Position = UDim2.new(0, 5, 0, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "None Selected"
targetLabel.TextColor3 = Color3.fromRGB(255, 215, 85)
targetLabel.TextSize = 12
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.TextTruncate = Enum.TextTruncate.AtEnd
targetLabel.Parent = targetFrame

-- Bouton TP
local tpButton = Instance.new("TextButton")
tpButton.Name = "TpButton"
tpButton.Size = UDim2.new(1, -14, 0, 28)
tpButton.Position = UDim2.new(0, 7, 0, 74)
tpButton.BackgroundColor3 = Color3.fromRGB(120, 70, 140)
tpButton.Text = "Teleport (Z)"
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.TextSize = 13
tpButton.Font = Enum.Font.GothamBold
tpButton.Parent = mainFrame
Instance.new("UICorner", tpButton).CornerRadius = UDim.new(0, 6)

-- Scroll list (très serrée)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "PetList"
scrollFrame.Size = UDim2.new(1, -14, 1, -112)
scrollFrame.Position = UDim2.new(0, 7, 0, 108)
scrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 95)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

local function parseMoney(text)
	text = string.lower(text or "")
	local num = tonumber(text:match("[%d%.]+")) or 0
	if text:find("k") then
		num *= 1e3
	elseif text:find("m") then
		num *= 1e6
	elseif text:find("b") then
		num *= 1e9
	elseif text:find("t") then
		num *= 1e12
	end
	return num
end

local function formatMoney(value)
	if value >= 1e12 then
		return string.format("$%.2fT/s", value / 1e12)
	elseif value >= 1e9 then
		return string.format("$%.2fB/s", value / 1e9)
	elseif value >= 1e6 then
		return string.format("$%.2fM/s", value / 1e6)
	elseif value >= 1e3 then
		return string.format("$%.2fK/s", value / 1e3)
	else
		return string.format("$%.2f/s", value)
	end
end

local billboardCache = nil
local billboardCacheTime = 0

local function findBaseBillboard()
	if tick() - billboardCacheTime < 30 and billboardCache then
		return billboardCache
	end
	
	local visibleBillboards = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BillboardGui") and obj.Enabled then
			for _, child in ipairs(obj:GetDescendants()) do
				if child:IsA("TextLabel") and child.Visible then
					if string.upper(child.Text) == "YOUR BASE" and child.TextTransparency < 1 then
						table.insert(visibleBillboards, obj)
					end
				end
			end
		end
	end
	
	if #visibleBillboards > 1 and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local closest, closestDist
			for _, billboard in ipairs(visibleBillboards) do
				local pos
				if billboard.Parent and billboard.Parent:IsA("BasePart") then
					pos = billboard.Parent.Position
				elseif billboard.Parent and billboard.Parent:IsA("Model") then
					local part = billboard.Parent:FindFirstChildWhichIsA("BasePart", true)
					if part then
						pos = part.Position
					end
				end
				
				if pos then
					local dist = (pos - root.Position).Magnitude
					if not closest or dist < closestDist then
						closestDist = dist
						closest = billboard
					end
				end
			end
			
			if closest then
				billboardCache = closest
				billboardCacheTime = tick()
				return closest
			end
		end
	end
	
	if visibleBillboards[1] then
		billboardCache = visibleBillboards[1]
		billboardCacheTime = tick()
	end
	
	return visibleBillboards[1]
end

local function findPlayerBase()
	if playerBaseCached then return end
	
	local billboard = findBaseBillboard()
	if billboard then
		local baseModel = billboard.Parent
		if baseModel then
			local parentModel = baseModel.Parent
			if parentModel and (parentModel:IsA("Model") or parentModel:IsA("Folder")) then
				playerBaseModel = parentModel
				playerBaseCached = true
				return
			end
			if baseModel:IsA("Model") or baseModel:IsA("Folder") then
				playerBaseModel = baseModel
				playerBaseCached = true
				return
			end
		end
	end
end

local function findPlayerSpawner()
	local fallbackHeight = humanoidRootPart.Position.Y
	
	if playerBaseModel then
		for _, obj in ipairs(playerBaseModel:GetChildren()) do
			if obj:IsA("Model") and (obj.Name == "Spawner" or obj.Name:lower():find("spawn")) then
				local spawnerPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
				if spawnerPart then
					return spawnerPart.Position.Y
				end
			end
		end
	end
	
	return fallbackHeight
end

local function updateSpawnerHeight()
	spawnerHeight = findPlayerSpawner()
end

local plotsCache = {}
local plotsCacheTime = 0

local function findAllPlots()
	if tick() - plotsCacheTime < 60 and #plotsCache > 0 then
		return plotsCache
	end
	
	plotsCache = {}
	
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and (obj.Name:lower():find("plot") or obj.Name:lower():find("base")) then
			for _, part in ipairs(obj:GetDescendants()) do
				if part:IsA("BasePart") then
					table.insert(plotsCache, part)
				end
			end
		end
	end
	
	plotsCacheTime = tick()
	return plotsCache
end

local function isPetNearPlayerBase(petPart)
	if not petPart or not playerBaseModel then return false end
	
	if petPart:IsDescendantOf(playerBaseModel) then
		return true
	end
	
	for _, basePart in ipairs(playerBaseModel:GetDescendants()) do
		if basePart:IsA("BasePart") then
			local distance = (basePart.Position - petPart.Position).Magnitude
			if distance <= 15 then
				return true
			end
		end
	end
	
	return false
end

local function isPetNearAnyPlot(petPart)
	if not petPart then return false end
	
	local allPlots = findAllPlots()
	
	for _, plotPart in ipairs(allPlots) do
		local distance = (plotPart.Position - petPart.Position).Magnitude
		if distance <= 23 then
			return true
		end
	end
	
	return false
end

task.spawn(function()
	findPlayerBase()
	updateSpawnerHeight()
	
	while true do
		task.wait(30)
		if playerBaseCached then
			updateSpawnerHeight()
		else
			findPlayerBase()
		end
	end
end)

local function findAllPetsInDebris()
	local results = {}
	
	local debrisFolder = workspace:FindFirstChild("Debris")
	if not debrisFolder then
		return results
	end
	
	for _, obj in ipairs(debrisFolder:GetChildren()) do
		if obj:IsA("BasePart") then
			local displayNameLabel = nil
			local generationLabel = nil
			
			for _, child in ipairs(obj:GetChildren()) do
				if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
					for _, label in ipairs(child:GetChildren()) do
						if label:IsA("TextLabel") then
							local labelName = label.Name
							if labelName == "DisplayName" then
								displayNameLabel = label
							elseif labelName == "Generation" then
								generationLabel = label
							end
						end
					end
				end
			end
			
			if displayNameLabel and generationLabel then
				local displayName = displayNameLabel.Text or "Unknown"
				local generation = generationLabel.Text or "0"
				local value = parseMoney(generation)
				
				if not isPetNearPlayerBase(obj) and isPetNearAnyPlot(obj) and obj.Position.Y <= 10 then
					table.insert(results, {
						part = obj,
						displayName = displayName,
						generation = generation,
						value = value
					})
				end
			end
		end
	end
	
	return results
end

local function updateTargetDisplay()
	local targetPet = selectedPetModel
	
	if targetPet and detectedPets[targetPet] then
		local petData = detectedPets[targetPet]
		targetLabel.Text = petData.name .. " - " .. formatMoney(petData.value)
		targetLabel.TextColor3 = Color3.fromRGB(170, 130, 255)
		return
	end
	
	if bestPetModel and detectedPets[bestPetModel] then
		local petData = detectedPets[bestPetModel]
		targetLabel.Text = petData.name .. " - " .. formatMoney(petData.value)
		targetLabel.TextColor3 = Color3.fromRGB(85, 255, 127)
		return
	end
	
	targetLabel.Text = "None Selected"
	targetLabel.TextColor3 = Color3.fromRGB(150, 150, 155)
end

local function updatePetListGUI(petList)
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	table.sort(petList, function(a, b)
		return a.value > b.value
	end)
	
	for i, petData in ipairs(petList) do
		local entry = Instance.new("TextButton")
		entry.Name = "PetEntry_" .. i
		entry.Size = UDim2.new(1, -10, 0, isMobile and 28 or 35)
		entry.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(35, 35, 40) or Color3.fromRGB(30, 30, 35)
		entry.BorderSizePixel = 0
		entry.LayoutOrder = i
		entry.AutoButtonColor = false
		entry.Text = ""
		entry.Parent = scrollFrame
		
		local isTarget = (selectedPetModel == petData.part) or (not selectedPetModel and bestPetModel == petData.part)
		
		if isTarget then
			entry.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
		end
		
		local entryCorner = Instance.new("UICorner")
		entryCorner.CornerRadius = UDim.new(0, 4)
		entryCorner.Parent = entry
		
		local rankLabel = Instance.new("TextLabel")
		rankLabel.Size = UDim2.new(0, isMobile and 20 or 25, 1, 0)
		rankLabel.Position = UDim2.new(0, 5, 0, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.Text = "#" .. i
		rankLabel.TextColor3 = Color3.fromRGB(150, 150, 155)
		rankLabel.TextSize = isMobile and 10 or 12
		rankLabel.Font = Enum.Font.GothamBold
		rankLabel.TextXAlignment = Enum.TextXAlignment.Left
		rankLabel.Parent = entry
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.5, isMobile and -28 or -35, 1, 0)
		nameLabel.Position = UDim2.new(0, isMobile and 25 or 30, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = petData.displayName
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = isMobile and 9 or 11
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.Parent = entry
		
		local valueLabel = Instance.new("TextLabel")
		valueLabel.Size = UDim2.new(0.5, -5, 1, 0)
		valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text = formatMoney(petData.value)
		valueLabel.TextColor3 = i == 1 and Color3.fromRGB(200, 110, 255) or Color3.fromRGB(200, 110, 255)
		valueLabel.TextSize = isMobile and 9 or 11
		valueLabel.Font = Enum.Font.GothamBold
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.Parent = entry
		
		entry.MouseButton1Click:Connect(function()
			selectedPetModel = petData.part
			updateTargetDisplay()
			updatePetListGUI(petList)
		end)
		
		entry.MouseEnter:Connect(function()
			if not isTarget then
				entry.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
			end
		end)
		
		entry.MouseLeave:Connect(function()
			if not isTarget then
				entry.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(35, 35, 40) or Color3.fromRGB(30, 30, 35)
			end
		end)
	end
	
	local contentSize = listLayout.AbsoluteContentSize
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 10)
end

local function updateBestPet()
	detectedPets = {}
	local allPets = findAllPetsInDebris()
	
	local bestValue = -math.huge
	bestPetModel = nil
	
	for _, petData in ipairs(allPets) do
		detectedPets[petData.part] = {
			name = petData.displayName,
			value = petData.value,
			part = petData.part
		}
		
		if petData.value > bestValue then
			bestValue = petData.value
			bestPetModel = petData.part
		end
	end
	
	updatePetListGUI(allPets)
	updateTargetDisplay()
end

task.spawn(function()
	while true do
		updateBestPet()
		task.wait(3)
	end
end)

local function clearWaypoints()
	for _, waypoint in ipairs(waypoints) do
		if waypoint.marker then
			waypoint.marker:Destroy()
		end
	end
	waypoints = {}
end

local function createPathToPet()
	local targetPet = selectedPetModel or bestPetModel
	
	if not targetPet then
		return false, "No target selected!"
	end
	
	local targetPart = targetPet
	if not targetPart then
		return false, "Can't find pet location!"
	end
	
	clearWaypoints()
	
	local startPos = humanoidRootPart.Position
	local endPos = targetPart.Position
	
	table.insert(waypoints, {position = startPos + Vector3.new(0, 3, 0), marker = nil})
	
	local hasObstacle, obstaclePos, obstacleDistance = checkObstacleAbove(startPos, 50)
	
	if hasObstacle then
		local greenPart1 = findClosestGreenPart(startPos)
		if greenPart1 then
			local elevatedPos = greenPart1.Position + Vector3.new(0, math.min(9, greenPart1.Size.Y/2 + 5), 0)
			table.insert(waypoints, {position = elevatedPos, marker = nil})
		end
	end
	
	local greenPart2 = findClosestGreenPart(endPos)
	if greenPart2 then
		local elevatedPos = greenPart2.Position + Vector3.new(0, math.min(9, greenPart2.Size.Y/2 + 5), 0)
		table.insert(waypoints, {position = elevatedPos, marker = nil})
	end
	
	local finalPos = Vector3.new(endPos.X, 4, endPos.Z)
	table.insert(waypoints, {position = finalPos, marker = nil})
	
	return true, string.format("%d waypoints created", #waypoints)
end

local function doTeleport()
	if isPlaying then return end
	
	local success, message = createPathToPet()
	
	if success then
		isPlaying = true
		tpButton.BackgroundColor3 = Color3.fromRGB(140, 70, 255)
		tpButton.Text = isMobile and "TPing..." or "Teleporting..."
		
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			local carpet = backpack:FindFirstChild("Flying Carpet")
			if carpet and character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid:EquipTool(carpet)
				end
			end
		end
		
		crunchBody()
		
		for i, waypoint in ipairs(waypoints) do
			if waypoint and waypoint.position then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					local maxHealth = humanoid.MaxHealth
					local currentHealth = humanoid.Health
					
					humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					
					humanoidRootPart.CFrame = CFrame.new(waypoint.position)
					
					if humanoid.Health < currentHealth then
						humanoid.Health = currentHealth
					end
				else
					humanoidRootPart.CFrame = CFrame.new(waypoint.position)
				end
				
				if i == #waypoints then
					restoreBody()
				end
				
				task.wait(0.1)
			end
		end
		
		restoreBody()
		
		task.wait(0.1)
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		end
		
		isPlaying = false
		tpButton.BackgroundColor3 = Color3.fromRGB(140, 70, 255)
		tpButton.Text = isMobile and "Teleport (Z)" or "Teleport to Target (Z)"
		clearWaypoints()
	end
end

tpButton.MouseButton1Click:Connect(function()
	doTeleport()
end)

tpButton.MouseEnter:Connect(function()
	if not isPlaying then
		tpButton.BackgroundColor3 = Color3.fromRGB(140, 70, 255)
	end
end)

tpButton.MouseLeave:Connect(function()
	if not isPlaying then
		tpButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	local focusedTextBox = UserInputService:GetFocusedTextBox()
	if focusedTextBox then return end
	
	if input.KeyCode == Enum.KeyCode.Z then
		doTeleport()
	end
end)

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	updateSpawnerHeight()
	originalSizes = {}
end)
-- ====================== YZK V1 - VERSION FINALE (Drag + Speed Boost + Instant Grab OK) ======================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Nettoyage
for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name:find("YZK") or v.Name:find("ChilliLibUI") or v.Name:find("YZK_SpeedUI") or v.Name:find("YZK_AutoGrabUI") then
        v:Destroy()
    end
end

local function getGuiParent()
    if gethui then return gethui() else return CoreGui end
end

local COLORS = {
    Darkest = Color3.fromRGB(13, 8, 28),
    Dark = Color3.fromRGB(18, 12, 35),
    Medium = Color3.fromRGB(28, 18, 52),
    Accent = Color3.fromRGB(170, 80, 255),
    Neon = Color3.fromRGB(200, 110, 255),
    White = Color3.fromRGB(245, 245, 255),
    Red = Color3.fromRGB(255, 85, 85)
}

-- ====================== CHILLI INTERFACE ======================
local function CreateWindow(options)
    local settings = { Title = options.Title or "YZK V1", Size = UDim2.fromOffset(360, 290) }
    local MainGUI = Instance.new("ScreenGui")
    MainGUI.Name = "ChilliLibUI"
    MainGUI.ResetOnSpawn = false
    MainGUI.Parent = getGuiParent()

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainBase"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0)
    MainFrame.Position = UDim2.fromScale(0.5, 0.25)
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.BackgroundColor3 = COLORS.Darkest
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Parent = MainGUI

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 22)

    local UIGradient = Instance.new("UIGradient", MainFrame)
    UIGradient.Rotation = 40
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Dark),
        ColorSequenceKeypoint.new(0.5, COLORS.Medium),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 20, 70))
    })

    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = COLORS.Neon
    Stroke.Thickness = 2.2
    Stroke.Transparency = 0.45

    TweenService:Create(MainFrame, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = settings.Size}):Play()

    -- TopBar
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 14, 38)
    TopBar.BackgroundTransparency = 0.25
    TopBar.Size = UDim2.new(1, -16, 0, 32)
    TopBar.Position = UDim2.new(0, 8, 0, 8)
    TopBar.Active = true
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

    local TitleLabel = Instance.new("TextLabel", TopBar)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, -110, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.Text = settings.Title
    TitleLabel.TextSize = 17
    TitleLabel.TextColor3 = COLORS.White
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local MinimizeButton = Instance.new("TextButton", TopBar)
    MinimizeButton.Size = UDim2.fromOffset(26, 26)
    MinimizeButton.Position = UDim2.new(1, -68, 0.5, -13)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    MinimizeButton.Text = "−"
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 20
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 215, 100)
    Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 8)

    local CloseButton = Instance.new("TextButton", TopBar)
    CloseButton.Size = UDim2.fromOffset(26, 26)
    CloseButton.Position = UDim2.new(1, -36, 0.5, -13)
    CloseButton.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    CloseButton.Text = "×"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.TextColor3 = COLORS.Red
    Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

    local isMinimized = false
    local originalSize = settings.Size
    local function ToggleMinimize()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(360, 52)}):Play()
            MinimizeButton.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = originalSize}):Play()
            MinimizeButton.Text = "−"
        end
    end
    MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.delay(0.32, function() MainGUI:Destroy() end)
    end)

    -- Drag
    local dragging = false
    local dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Container
    local Container = Instance.new("ScrollingFrame", MainFrame)
    Container.Size = UDim2.new(1, -20, 1, -52)
    Container.Position = UDim2.new(0, 10, 0, 46)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 5
    Container.ScrollBarImageColor3 = COLORS.Neon
    Container.ScrollBarImageTransparency = 0.4

    local UIListLayout = Instance.new("UIListLayout", Container)
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function AddToggle(name, defaultState, callback)
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(1, 0, 0, 42)
        ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(140, 70, 255) or Color3.fromRGB(32, 24, 52)
        ToggleButton.Text = " " .. name
        ToggleButton.TextColor3 = COLORS.White
        ToggleButton.Font = Enum.Font.GothamSemibold
        ToggleButton.TextSize = 16
        ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
        ToggleButton.BackgroundTransparency = 0
        ToggleButton.AutoButtonColor = false
        ToggleButton.Active = true
        ToggleButton.Parent = Container
        Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 12)

        local status = Instance.new("TextLabel", ToggleButton)
        status.Size = UDim2.new(0, 70, 1, 0)
        status.Position = UDim2.new(1, -80, 0, 0)
        status.BackgroundTransparency = 1
        status.Text = defaultState and "ON" or "OFF"
        status.TextColor3 = defaultState and Color3.fromRGB(140, 255, 180) or Color3.fromRGB(255, 120, 120)
        status.Font = Enum.Font.GothamBold
        status.TextSize = 15
        status.TextXAlignment = Enum.TextXAlignment.Right

        local isOn = defaultState or false
        ToggleButton.MouseButton1Click:Connect(function()
            isOn = not isOn
            if isOn then
                ToggleButton.BackgroundColor3 = Color3.fromRGB(140, 70, 255)
                status.Text = "ON"
                status.TextColor3 = Color3.fromRGB(140, 255, 180)
            else
                ToggleButton.BackgroundColor3 = Color3.fromRGB(32, 24, 52)
                status.Text = "OFF"
                status.TextColor3 = Color3.fromRGB(255, 120, 120)
            end
            if callback then callback(isOn) end
        end)
    end

    return { AddToggle = AddToggle, Show = function() MainFrame.Visible = true end }
end

local myWindow = CreateWindow({Title = "YZK V1"})
myWindow.Show()

-- ====================== FONCTIONS ======================
local states = {Dark=false, Unwalk=false, XRay=false, FPSBoost=false, InfJump=false, ESP=false}
local darkModeConnection = nil
local originalLight = {}
local espHighlights = {}
local fpsConns = {}
local savedAnimate = nil
local VIOLET = Color3.fromRGB(180, 80, 255)

local function DarkMode(state)
    states.Dark = state
    if state then
        originalLight = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart
        }
        if darkModeConnection then darkModeConnection:Disconnect() end
        darkModeConnection = RunService.RenderStepped:Connect(function()
            if states.Dark then
                Lighting.Brightness = 1.2
                Lighting.ClockTime = 20.5
                Lighting.Ambient = Color3.fromRGB(95,100,120)
                Lighting.OutdoorAmbient = Color3.fromRGB(95,100,120)
                Lighting.FogEnd = 100000
                Lighting.FogStart = 100000
            end
        end)
    else
        if darkModeConnection then darkModeConnection:Disconnect() darkModeConnection = nil end
        for k,v in pairs(originalLight) do pcall(function() Lighting[k] = v end) end
    end
end

-- ====================== XRAY OPTIMISÉ ======================
local xrayDescendantConn = nil
local XRAY_TRANSPARENCY = 0.65
local xrayParts = {}
local function isIgnored(part)
    if not part or not part:IsA("BasePart") then return true end
    local parent = part.Parent
    while parent do
        if parent.Name == "Laser" then return true end
        parent = parent.Parent
    end
    return false
end
local function applyXRayToPart(part)
    if isIgnored(part) then return end
    if not xrayParts[part] then
        xrayParts[part] = part.LocalTransparencyModifier
        part.LocalTransparencyModifier = XRAY_TRANSPARENCY
    end
end
local function removeAllXRay()
    for part, original in pairs(xrayParts) do
        if part and part.Parent then
            part.LocalTransparencyModifier = original
        end
    end
    xrayParts = {}
end
local function XRay(state)
    states.XRay = state
    if state then
        removeAllXRay()
        local plotsFolder = Workspace:FindFirstChild("Plots")
        if plotsFolder then
            for _, obj in ipairs(plotsFolder:GetDescendants()) do applyXRayToPart(obj) end
        end
        local animalPodiums = Workspace:FindFirstChild("AnimalPodiums")
        if animalPodiums then
            for _, podium in ipairs(animalPodiums:GetChildren()) do
                local base = podium:FindFirstChild("Base")
                if base then
                    for _, child in ipairs(base:GetChildren()) do
                        if child.Name ~= "Spawn" then
                            for _, descendant in ipairs(child:GetDescendants()) do
                                applyXRayToPart(descendant)
                            end
                        end
                    end
                end
            end
        end
        if not xrayDescendantConn then
            xrayDescendantConn = Workspace.DescendantAdded:Connect(function(desc)
                if states.XRay then applyXRayToPart(desc) end
            end)
        end
    else
        if xrayDescendantConn then xrayDescendantConn:Disconnect() xrayDescendantConn = nil end
        removeAllXRay()
    end
end

local function Unwalk(state)
    states.Unwalk = state
    local char = LocalPlayer.Character
    if not char then return end
    if state then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then for _,t in hum:GetPlayingAnimationTracks() do t:Stop() end end
        local animate = char:FindFirstChild("Animate")
        if animate then savedAnimate = animate:Clone() animate:Destroy() end
    else
        if savedAnimate and char then savedAnimate:Clone().Parent = char savedAnimate = nil end
    end
end

local function UpdateESPForCharacter(char)
    if not char or char == LocalPlayer.Character then return end
    local old = char:FindFirstChild("YZK_ESP")
    if old then old:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Name = "YZK_ESP"
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(80,30,120)
    hl.FillTransparency = 0.5
    hl.OutlineColor = VIOLET
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    espHighlights[char] = hl
end

local function ESP(state)
    states.ESP = state
    if state then
        for _, plr in Players:GetPlayers() do
            if plr.Character then UpdateESPForCharacter(plr.Character) end
            plr.CharacterAdded:Connect(function(c)
                if states.ESP then task.wait(0.5) UpdateESPForCharacter(c) end
            end)
        end
    else
        for _, hl in pairs(espHighlights) do if hl then hl:Destroy() end end
        espHighlights = {}
    end
end

local function applyFPS(v)
    if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
    if v:IsA("BasePart") then v.Material = Enum.Material.Plastic end
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = false end
end

local function FPSBoost(state)
    states.FPSBoost = state
    if state then
        for _,v in Workspace:GetDescendants() do applyFPS(v) end
        table.insert(fpsConns, Workspace.DescendantAdded:Connect(applyFPS))
    else
        for _,c in fpsConns do if c then c:Disconnect() end end
        fpsConns = {}
    end
end

local function InfJump(state)
    states.InfJump = state
end

UserInputService.JumpRequest:Connect(function()
    if states.InfJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.new(char.HumanoidRootPart.Velocity.X, 55, char.HumanoidRootPart.Velocity.Z)
        end
    end
end)

-- ====================== SPEED BOOST ======================
local SpeedCustomizer = {
    Enabled = false, Running = true,
    SpeedValue = 58, StealValue = 29, JumpValue = 80,
    character = nil, hrp = nil, hum = nil,
    HeartbeatConn = nil, JumpConn = nil, CharacterConn = nil,
    IsMinimized = false
}

local function setupSpeedCharacter(char)
    SpeedCustomizer.character = char
    SpeedCustomizer.hrp = char:WaitForChild("HumanoidRootPart")
    SpeedCustomizer.hum = char:WaitForChild("Humanoid")
end

local speedUI = nil

local function createSpeedUI()
    local SpeedScreenGui = Instance.new("ScreenGui")
    SpeedScreenGui.Name = "YZK_SpeedUI"
    SpeedScreenGui.ResetOnSpawn = false
    SpeedScreenGui.Parent = getGuiParent()

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "SpeedMainFrame"
    MainFrame.Size = UDim2.new(0, 270, 0, 245)
    MainFrame.Position = UDim2.new(0.5, -135, 0.4, 0)
    MainFrame.BackgroundColor3 = COLORS.Darkest
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = SpeedScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 22)

    local UIGradient = Instance.new("UIGradient", MainFrame)
    UIGradient.Rotation = 40
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Dark),
        ColorSequenceKeypoint.new(0.5, COLORS.Medium),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 20, 70))
    })

    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = COLORS.Neon
    Stroke.Thickness = 2.2
    Stroke.Transparency = 0.45

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 14, 38)
    TopBar.BackgroundTransparency = 0.25
    TopBar.Size = UDim2.new(1, -16, 0, 32)
    TopBar.Position = UDim2.new(0, 8, 0, 8)
    TopBar.Active = true
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", TopBar)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -80, 0, 32)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.Font = Enum.Font.GothamBlack
    Title.Text = "YZK Speed Boost"
    Title.TextSize = 17
    Title.TextColor3 = COLORS.White
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local MinimizeBtn = Instance.new("TextButton", TopBar)
    MinimizeBtn.Size = UDim2.fromOffset(26, 26)
    MinimizeBtn.Position = UDim2.new(1, -68, 0.5, -13)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    MinimizeBtn.Text = "−"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 20
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 215, 100)
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.fromOffset(26, 26)
    CloseBtn.Position = UDim2.new(1, -36, 0.5, -13)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = COLORS.Red
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, -20, 0, 48)
    Header.Position = UDim2.new(0, 10, 0, 54)
    Header.BackgroundColor3 = Color3.fromRGB(32, 24, 52)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

    local ToggleBtn = Instance.new("TextButton", Header)
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = COLORS.White
    ToggleBtn.TextSize = 20
    ToggleBtn.Font = Enum.Font.GothamBold

    local dragging = false
    local dragStart, startPos
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end
    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end
    local function updateDrag(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end

    TopBar.InputBegan:Connect(startDrag)
    MainFrame.InputBegan:Connect(startDrag)
    TopBar.InputEnded:Connect(endDrag)
    MainFrame.InputEnded:Connect(endDrag)
    UserInputService.InputChanged:Connect(updateDrag)

    local function createInputRow(labelText, defaultValue, yPos)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.55, 0, 0, 30)
        label.Position = UDim2.new(0, 18, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = COLORS.White
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = MainFrame

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 92, 0, 36)
        box.Position = UDim2.new(1, -110, 0, yPos)
        box.BackgroundColor3 = Color3.fromRGB(28, 18, 52)
        box.Text = tostring(defaultValue)
        box.TextColor3 = COLORS.Neon
        box.TextSize = 17
        box.Font = Enum.Font.GothamBold
        box.ClearTextOnFocus = false
        box.Parent = MainFrame
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

        local boxStroke = Instance.new("UIStroke", box)
        boxStroke.Color = COLORS.Neon
        boxStroke.Thickness = 1.5
        boxStroke.Transparency = 0.6

        return label, box
    end

    local SpeedLabel, SpeedInput = createInputRow("Speed", 58, 118)
    local StealLabel, StealInput = createInputRow("Steal Spd", 29, 158)
    local JumpLabel, JumpInput = createInputRow("Jump", 80, 198)

    ToggleBtn.MouseButton1Click:Connect(function()
        SpeedCustomizer.Enabled = not SpeedCustomizer.Enabled
        if SpeedCustomizer.Enabled then
            ToggleBtn.Text = "ON"
            Header.BackgroundColor3 = Color3.fromRGB(120, 40, 220)
        else
            ToggleBtn.Text = "OFF"
            Header.BackgroundColor3 = Color3.fromRGB(32, 24, 52)
        end
    end)

    local function validateInput(box, varName, min, max)
        box.FocusLost:Connect(function()
            local num = tonumber(box.Text)
            if num then
                num = math.clamp(num, min, max)
                box.Text = tostring(num)
                SpeedCustomizer[varName] = num
            else
                box.Text = tostring(SpeedCustomizer[varName])
            end
        end)
    end

    validateInput(SpeedInput, "SpeedValue", 1, 200)
    validateInput(StealInput, "StealValue", 1, 200)
    validateInput(JumpInput, "JumpValue", 1, 200)

    local originalSize = UDim2.new(0, 270, 0, 245)
    local minimizedSize = UDim2.new(0, 270, 0, 115)

    MinimizeBtn.MouseButton1Click:Connect(function()
        SpeedCustomizer.IsMinimized = not SpeedCustomizer.IsMinimized
        if SpeedCustomizer.IsMinimized then
            MainFrame.Size = minimizedSize
            SpeedLabel.Visible = false StealLabel.Visible = false JumpLabel.Visible = false
            SpeedInput.Visible = false StealInput.Visible = false JumpInput.Visible = false
        else
            MainFrame.Size = originalSize
            SpeedLabel.Visible = true StealLabel.Visible = true JumpLabel.Visible = true
            SpeedInput.Visible = true StealInput.Visible = true JumpInput.Visible = true
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        SpeedCustomizer.Running = false
        if SpeedCustomizer.HeartbeatConn then SpeedCustomizer.HeartbeatConn:Disconnect() end
        if SpeedCustomizer.JumpConn then SpeedCustomizer.JumpConn:Disconnect() end
        if SpeedCustomizer.CharacterConn then SpeedCustomizer.CharacterConn:Disconnect() end
        SpeedScreenGui:Destroy()
        speedUI = nil
    end)

    return SpeedScreenGui
end

local function OpenSpeedBoost(state)
    if state then
        if not speedUI then
            speedUI = createSpeedUI()
            if LocalPlayer.Character then setupSpeedCharacter(LocalPlayer.Character) end
            SpeedCustomizer.CharacterConn = LocalPlayer.CharacterAdded:Connect(setupSpeedCharacter)

            SpeedCustomizer.HeartbeatConn = RunService.Heartbeat:Connect(function()
                if not SpeedCustomizer.Running or not SpeedCustomizer.Enabled or not SpeedCustomizer.hrp or not SpeedCustomizer.hum then return end
                local moveDir = SpeedCustomizer.hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    local isSteal = SpeedCustomizer.hum.WalkSpeed < 25
                    local targetSpeed = isSteal and SpeedCustomizer.StealValue or SpeedCustomizer.SpeedValue
                    SpeedCustomizer.hrp.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * targetSpeed,
                        SpeedCustomizer.hrp.AssemblyLinearVelocity.Y,
                        moveDir.Z * targetSpeed
                    )
                end
            end)

            SpeedCustomizer.JumpConn = UserInputService.JumpRequest:Connect(function()
                if not SpeedCustomizer.Running or not SpeedCustomizer.Enabled or not SpeedCustomizer.hum or SpeedCustomizer.hum.FloorMaterial == Enum.Material.Air then return end
                SpeedCustomizer.hrp.AssemblyLinearVelocity = Vector3.new(
                    SpeedCustomizer.hrp.AssemblyLinearVelocity.X,
                    SpeedCustomizer.JumpValue,
                    SpeedCustomizer.hrp.AssemblyLinearVelocity.Z
                )
            end)
        end
    else
        if speedUI then speedUI:Destroy() speedUI = nil end
        SpeedCustomizer.Enabled = false
        if SpeedCustomizer.HeartbeatConn then SpeedCustomizer.HeartbeatConn:Disconnect() end
        if SpeedCustomizer.JumpConn then SpeedCustomizer.JumpConn:Disconnect() end
    end
end

-- ====================== INSTANT GRAB (Fenêtre plus petite) ======================
local autoGrabUI = nil

local function OpenInstantGrab(state)
    if state then
        if autoGrabUI then return end

        -- ====================== CONFIG ======================
        local CONFIG = { AUTO_STEAL_NEAREST = false }

        -- ====================== SERVICES ======================
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

        -- ====================== DATA ======================
        local AnimalsData = require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals"))

        -- ====================== VARIABLES ======================
        local allAnimalsCache = {}
        local PromptMemoryCache = {}
        local InternalStealCache = {}
        local LastTargetUID = nil
        local IsStealing = false
        local AUTO_STEAL_PROX_RADIUS = 7
        local stealConnection = nil

        -- ====================== FONCTIONS ======================
        local function getHRP()
            local char = LocalPlayer.Character
            if not char then return nil end
            return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
        end

        local function isMyBase(plotName)
            local plot = workspace.Plots:FindFirstChild(plotName)
            if not plot then return false end
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local yourBase = sign:FindFirstChild("YourBase")
                if yourBase and yourBase:IsA("BillboardGui") then
                    return yourBase.Enabled == true
                end
            end
            return false
        end

        local function scanSinglePlot(plot)
            if not plot or not plot:IsA("Model") then return end
            if isMyBase(plot.Name) then return end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then return end
            for _, podium in ipairs(podiums:GetChildren()) do
                if podium:IsA("Model") and podium:FindFirstChild("Base") then
                    local animalName = "Unknown"
                    local spawn = podium.Base:FindFirstChild("Spawn")
                    if spawn then
                        for _, child in ipairs(spawn:GetChildren()) do
                            if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                                animalName = child.Name
                                local animalInfo = AnimalsData[animalName]
                                if animalInfo and animalInfo.DisplayName then
                                    animalName = animalInfo.DisplayName
                                end
                                break
                            end
                        end
                    end
                    table.insert(allAnimalsCache, {
                        name = animalName,
                        plot = plot.Name,
                        slot = podium.Name,
                        worldPosition = podium:GetPivot().Position,
                        uid = plot.Name .. "_" .. podium.Name,
                    })
                end
            end
        end

        local function initializeScanner()
            task.wait(2)
            local plots = workspace:WaitForChild("Plots", 10)
            if not plots then return end
            for _, plot in ipairs(plots:GetChildren()) do
                if plot:IsA("Model") then scanSinglePlot(plot) end
            end
            plots.ChildAdded:Connect(function(plot)
                if plot:IsA("Model") then
                    task.wait(0.5)
                    scanSinglePlot(plot)
                end
            end)
            task.spawn(function()
                while task.wait(5) do
                    allAnimalsCache = {}
                    for _, plot in ipairs(plots:GetChildren()) do
                        if plot:IsA("Model") then scanSinglePlot(plot) end
                    end
                end
            end)
        end

        local function findProximityPromptForAnimal(animalData)
            if not animalData then return nil end
            local cachedPrompt = PromptMemoryCache[animalData.uid]
            if cachedPrompt and cachedPrompt.Parent then return cachedPrompt end
            local plot = workspace.Plots:FindFirstChild(animalData.plot)
            if not plot then return nil end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then return nil end
            local podium = podiums:FindFirstChild(animalData.slot)
            if not podium then return nil end
            local base = podium:FindFirstChild("Base")
            if not base then return nil end
            local spawn = base:FindFirstChild("Spawn")
            if not spawn then return nil end
            local attach = spawn:FindFirstChild("PromptAttachment")
            if not attach then return nil end
            for _, p in ipairs(attach:GetChildren()) do
                if p:IsA("ProximityPrompt") then
                    PromptMemoryCache[animalData.uid] = p
                    return p
                end
            end
            return nil
        end

        local function shouldSteal(animalData)
            if not animalData or not animalData.worldPosition then return false end
            local hrp = getHRP()
            if not hrp then return false end
            local currentDistance = (hrp.Position - animalData.worldPosition).Magnitude
            return currentDistance <= AUTO_STEAL_PROX_RADIUS
        end

        local function buildStealCallbacks(prompt)
            if InternalStealCache[prompt] then return end
            local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
            local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
            if ok1 and type(conns1) == "table" then
                for _, conn in ipairs(conns1) do
                    if type(conn.Function) == "function" then
                        table.insert(data.holdCallbacks, conn.Function)
                    end
                end
            end
            local ok2, conns2 = pcall(getconnections, prompt.Triggered)
            if ok2 and type(conns2) == "table" then
                for _, conn in ipairs(conns2) do
                    if type(conn.Function) == "function" then
                        table.insert(data.triggerCallbacks, conn.Function)
                    end
                end
            end
            if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) then
                InternalStealCache[prompt] = data
            end
        end

        local function executeInternalStealAsync(prompt, animalData)
            local data = InternalStealCache[prompt]
            if not data or not data.ready then return false end
            data.ready = false
            IsStealing = true
            task.spawn(function()
                if #data.holdCallbacks > 0 then
                    for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
                end
                task.wait(0.2)
                if #data.triggerCallbacks > 0 then
                    for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
                end
                task.wait(0.01)
                data.ready = true
                task.wait(0.01)
                IsStealing = false
            end)
            return true
        end

        local function attemptSteal(prompt, animalData)
            if not prompt or not prompt.Parent then return false end
            buildStealCallbacks(prompt)
            if not InternalStealCache[prompt] then return false end
            return executeInternalStealAsync(prompt, animalData)
        end

        local function getNearestAnimal()
            local hrp = getHRP()
            if not hrp then return nil end
            local nearest = nil
            local minDist = math.huge
            for _, animalData in ipairs(allAnimalsCache) do
                if isMyBase(animalData.plot) then continue end
                if animalData.worldPosition then
                    local dist = (hrp.Position - animalData.worldPosition).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = animalData
                    end
                end
            end
            return nearest
        end

        local function autoStealLoop()
            if stealConnection then stealConnection:Disconnect() end
            stealConnection = RunService.Heartbeat:Connect(function()
                if not CONFIG.AUTO_STEAL_NEAREST then return end
                if IsStealing then return end
                local targetAnimal = getNearestAnimal()
                if not targetAnimal then return end
                if not shouldSteal(targetAnimal) then return end
                if LastTargetUID ~= targetAnimal.uid then
                    LastTargetUID = targetAnimal.uid
                end
                local prompt = PromptMemoryCache[targetAnimal.uid]
                if not prompt or not prompt.Parent then
                    prompt = findProximityPromptForAnimal(targetAnimal)
                end
                if prompt then
                    attemptSteal(prompt, targetAnimal)
                end
            end)
        end

        -- ====================== INTERFACE (Fenêtre plus petite) ======================
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoStealGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = PlayerGui

        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 270, 0, 130)   -- Fenêtre rendue plus petite
        mainFrame.Position = UDim2.new(0.5, -135, 0.35, 0)
        mainFrame.BackgroundColor3 = COLORS.Darkest
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Parent = screenGui

        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 22)

        local mainGradient = Instance.new("UIGradient", mainFrame)
        mainGradient.Rotation = 40
        mainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, COLORS.Dark),
            ColorSequenceKeypoint.new(0.5, COLORS.Medium),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 20, 70))
        })

        local mainStroke = Instance.new("UIStroke", mainFrame)
        mainStroke.Color = COLORS.Neon
        mainStroke.Thickness = 2.2
        mainStroke.Transparency = 0.45

        -- Top Bar
        local topBar = Instance.new("Frame", mainFrame)
        topBar.Size = UDim2.new(1, -16, 0, 32)
        topBar.Position = UDim2.new(0, 8, 0, 8)
        topBar.BackgroundColor3 = Color3.fromRGB(20, 14, 38)
        topBar.BackgroundTransparency = 0.25
        topBar.Active = true
        Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

        local titleLabel = Instance.new("TextLabel", topBar)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, -80, 1, 0)
        titleLabel.Position = UDim2.new(0, 16, 0, 0)
        titleLabel.Font = Enum.Font.GothamBlack
        titleLabel.Text = "YZK AUTO GRAB"
        titleLabel.TextSize = 17
        titleLabel.TextColor3 = COLORS.White
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local minimizeBtn = Instance.new("TextButton", topBar)
        minimizeBtn.Size = UDim2.fromOffset(26, 26)
        minimizeBtn.Position = UDim2.new(1, -68, 0.5, -13)
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
        minimizeBtn.Text = "−"
        minimizeBtn.Font = Enum.Font.GothamBold
        minimizeBtn.TextSize = 20
        minimizeBtn.TextColor3 = Color3.fromRGB(255, 215, 100)
        Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

        local closeBtn = Instance.new("TextButton", topBar)
        closeBtn.Size = UDim2.fromOffset(26, 26)
        closeBtn.Position = UDim2.new(1, -36, 0.5, -13)
        closeBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
        closeBtn.Text = "×"
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 18
        closeBtn.TextColor3 = COLORS.Red
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

        -- Fine barre + Toggle
        local header = Instance.new("Frame", mainFrame)
        header.Size = UDim2.new(1, -20, 0, 48)
        header.Position = UDim2.new(0, 10, 0, 52)
        header.BackgroundColor3 = Color3.fromRGB(32, 24, 52)
        header.BorderSizePixel = 0
        Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

        local toggleButton = Instance.new("TextButton", header)
        toggleButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = "OFF"
        toggleButton.TextColor3 = COLORS.White
        toggleButton.TextSize = 20
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.AutoButtonColor = false

        local function updateToggleAppearance()
            if CONFIG.AUTO_STEAL_NEAREST then
                toggleButton.Text = "ON"
                header.BackgroundColor3 = Color3.fromRGB(120, 40, 220)
            else
                toggleButton.Text = "OFF"
                header.BackgroundColor3 = Color3.fromRGB(32, 24, 52)
            end
        end

        toggleButton.MouseButton1Click:Connect(function()
            CONFIG.AUTO_STEAL_NEAREST = not CONFIG.AUTO_STEAL_NEAREST
            updateToggleAppearance()
        end)

        -- Drag
        local dragging = false
        local dragStart, startPos
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        topBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        minimizeBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = not mainFrame.Visible
        end)

        closeBtn.MouseButton1Click:Connect(function()
            CONFIG.AUTO_STEAL_NEAREST = false
            screenGui:Destroy()
            autoGrabUI = nil
        end)

        autoGrabUI = screenGui

        -- Lancement
        initializeScanner()
        autoStealLoop()
        updateToggleAppearance()

    else
        if autoGrabUI then
            autoGrabUI:Destroy()
            autoGrabUI = nil
        end
    end
end

-- ====================== AJOUT DES BOUTONS ======================
myWindow.AddToggle("Dark Mode", false, DarkMode)
myWindow.AddToggle("Unwalk", false, Unwalk)
myWindow.AddToggle("XRay (Plots & Podiums)", false, XRay)
myWindow.AddToggle("FPS Boost", false, FPSBoost)
myWindow.AddToggle("Infinite Jump", false, InfJump)
myWindow.AddToggle("ESP Players", false, ESP)
myWindow.AddToggle("Speed Boost", false, OpenSpeedBoost)
myWindow.AddToggle("Instant Grab", false, OpenInstantGrab)

print("✅ YZK V1 - Instant Grab rendu plus petit")
