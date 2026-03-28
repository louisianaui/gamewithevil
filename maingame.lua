local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(newchar)
    character = newchar
    repeat task.wait() until character:FindFirstChild("HumanoidRootPart")
end)

local espobjects = {}

local function createesp(object, color, name, outlinecolor)
    if espobjects[object] then return end
    local adorneePart = object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Torso") or object:FindFirstChild("Head") or object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
    if not adorneePart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ObsidianESP"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = outlinecolor or color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = Library.ScreenGui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ObsidianLabel"
    billboard.Adornee = adorneePart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = Library.ScreenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = color
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.Parent = billboard

    espobjects[object] = { highlight = highlight, billboard = billboard, label = label, type = name, object = object }
end

local function removeesp(object)
    if espobjects[object] then
        local esp = espobjects[object]
        if esp.highlight then esp.highlight:Destroy() end
        if esp.billboard then esp.billboard:Destroy() end
        espobjects[object] = nil
    end
end

local function clearesp()
    for object, _ in pairs(espobjects) do
        removeesp(object)
    end
end

Library.ForceCheckbox = false 
Library.ShowToggleFrameInKeybinds = true 

local Window = Library:CreateWindow({
    Title = "game with evil",
    Center = true,
    AutoShow = true,
    Resizable = true,
    NotifySide = "Right",
    ShowCustomCursor = true,
    MobileButtonsSide = "Right"
})

local Tabs = {
    Main = Window:AddTab("Main Menu", "user"),
    Visuals = Window:AddTab("Visuals", "scan-eye"),
    Misc = Window:AddTab("Misc", "package"),
    Settings = Window:AddTab("UI Settings", "settings")
}

local DraggableLabel = Library:AddDraggableLabel("game with evil")

local function ApplyTransparency()
    local Main = Library.ScreenGui:FindFirstChild("Main")
    if not Main then return end
    
    Main.Transparency = 0.3
    if Main:FindFirstChild("ScrollingFrame") then Main.ScrollingFrame.Transparency = 0.3 end
    if Main:FindFirstChild("Container") then Main.Container.Transparency = 1 end
    
    for _, v in Main:GetChildren() do
        if v:IsA("Frame") and v.AnchorPoint == Vector2.new(0, 1) then
            v.Visible = false
        end
        if v:IsA("Frame") and v.Size == UDim2.new(1, 0, 0, 1) and v.Position.Y.Offset == -20 then
            v.Visible = false
        end
        if v.Name == "Container" or v:IsA("ScrollingFrame") then
            v.Size = UDim2.new(v.Size.X.Scale, v.Size.X.Offset, 1, -49)
        end
        if v:IsA("Frame") and v:FindFirstChild("Frame") then
            v.Transparency = 1
            v.Frame.Transparency = 1
        end
    end
end

local Info = { Client = { DeltaTimeSamples = {} } }
local function UpdateFPSLabel()
    local TotalDelta = 0
    for _, v in Info.Client.DeltaTimeSamples do TotalDelta += v end
    local Framerate = #Info.Client.DeltaTimeSamples > 0 and 1 / (TotalDelta / #Info.Client.DeltaTimeSamples) or 0
    local Ping = math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    DraggableLabel:SetText(string.format("game with evil | %i fps | %i ms", math.floor(Framerate), Ping))
end

RunService.RenderStepped:Connect(function(DeltaTime)
    table.insert(Info.Client.DeltaTimeSamples, DeltaTime)
    if #Info.Client.DeltaTimeSamples > 30 then table.remove(Info.Client.DeltaTimeSamples, 1) end
    if Toggles.ShowFPSLabel and Toggles.ShowFPSLabel.Value then UpdateFPSLabel() end

    if Toggles.VE_EnableESP and Toggles.VE_EnableESP.Value then
        local showObjectives = Toggles.VE_ObjectiveESP and Toggles.VE_ObjectiveESP.Value
        
        pcall(function()
            local objectiveFolder = Workspace:FindFirstChild("Live")
            objectiveFolder = objectiveFolder and objectiveFolder:FindFirstChild("Map")
            objectiveFolder = objectiveFolder and objectiveFolder:FindFirstChild("MapModel")
            objectiveFolder = objectiveFolder and objectiveFolder:FindFirstChild("ActiveObjectives")
            
            if objectiveFolder then
                if showObjectives then
                    local function scan(parent)
                        for _, obj in pairs(parent:GetChildren()) do
                            if obj:IsA("Model") or obj:IsA("BasePart") then
                                local done = obj:GetAttribute("DoneCompletions")
                                local max = obj:GetAttribute("MaxCompletions")
                                
                                local isHidden = false
                                if obj:IsA("BasePart") then
                                    isHidden = (obj.Transparency >= 1)
                                elseif obj:IsA("Model") then
                                    local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                    if p and p.Transparency >= 1 then isHidden = true end
                                end
                                
                                if (done and max and done >= max) or isHidden then
                                    removeesp(obj)
                                else
                                    pcall(function()
                                        local att = obj:FindFirstChild("attachment")
                                        local prompt = att and (att:FindFirstChild("prompt") or att:FindFirstChildWhichIsA("ProximityPrompt"))
                                        if prompt and prompt:IsA("ProximityPrompt") then
                                            prompt.HoldDuration = 0
                                        end
                                    end)
                                    
                                    local label = obj.Name
                                    if done and max then
                                        label = label .. " [" .. done .. "/" .. max .. "]"
                                    end
                                    
                                    if espobjects[obj] then
                                        espobjects[obj].label.Text = label
                                    else
                                        createesp(obj, Color3.fromRGB(255, 255, 0), label)
                                    end
                                end
                            elseif obj:IsA("Folder") or obj:IsA("Configuration") then
                                scan(obj)
                            end
                        end
                    end
                    scan(objectiveFolder)
                else
                    for _, obj in pairs(objectiveFolder:GetDescendants()) do
                        removeesp(obj)
                    end
                end
            end
        end)

        if Toggles.VE_PlayerESP and Toggles.VE_PlayerESP.Value then
            local playersFolder = Workspace:FindFirstChild("Players")
            local function handleChar(char, p)
                if char and char:IsA("Model") and char ~= character and char:FindFirstChild("HumanoidRootPart") then
                    local abilities = char:FindFirstChild("Abilities")
                    if abilities then
                        local count = #abilities:GetChildren()
                        local color, name = nil, nil
                        local displayName = char:GetAttribute("Username") or (p and (p:GetAttribute("Username") or p.Name)) or char.Name
                        
                        if count >= 4 then
                            color = Color3.fromRGB(255, 50, 50)
                            name = "Killer " .. displayName
                        elseif count == 2 or count == 3 then
                            color = Color3.fromRGB(50, 255, 50)
                            name = "Survivor " .. displayName
                        end
                        
                        if color then
                            if espobjects[char] then
                                espobjects[char].label.Text = name
                                espobjects[char].label.TextColor3 = color
                                espobjects[char].highlight.FillColor = color
                                espobjects[char].highlight.OutlineColor = color
                            else
                                createesp(char, color, name)
                            end
                        else
                            removeesp(char)
                        end
                    else
                        removeesp(char)
                    end
                end
            end

            if playersFolder then
                for _, folder in pairs(playersFolder:GetChildren()) do
                    if folder:IsA("Folder") then
                        for _, char in pairs(folder:GetChildren()) do
                            local p = game:GetService("Players"):GetPlayerFromCharacter(char)
                            handleChar(char, p)
                        end
                    end
                end
            end

            for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                if p ~= player and p.Character then
                    handleChar(p.Character, p)
                end
            end
        else
            for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                if p.Character then removeesp(p.Character) end
            end
            local playersFolder = Workspace:FindFirstChild("Players")
            if playersFolder then
                for _, obj in pairs(playersFolder:GetDescendants()) do
                    if obj:IsA("Model") then removeesp(obj) end
                end
            end
        end
    else
        if next(espobjects) then clearesp() end
    end
end)

local SettingsTab = Tabs.Settings
local ThemeGroup = SettingsTab:AddLeftGroupbox("Theme")
local MenuGroup = SettingsTab:AddRightGroupbox("Menu")

MenuGroup:AddButton("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
end)
MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind

MenuGroup:AddToggle("ShowFPSLabel", { Text = "Show FPS Label", Default = false })
MenuGroup:AddToggle("ShowKeybinds", { Text = "Show Keybinds", Default = false })

Toggles.ShowFPSLabel:OnChanged(function() DraggableLabel:SetVisible(Toggles.ShowFPSLabel.Value) end)
Toggles.ShowKeybinds:OnChanged(function() Library.KeybindFrame.Visible = Toggles.ShowKeybinds.Value end)

ContextActionService:BindActionAtPriority("DisableRightShiftShiftLock", function()
    return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1000, Enum.KeyCode.RightShift)

local CharGroup = Tabs.Main:AddLeftGroupbox("Character")
CharGroup:AddToggle("MC_InfiniteStamina", { Text = "Infinite Stamina", Default = false })

Toggles.MC_InfiniteStamina:OnChanged(function(v)
    if not v then return end
    pcall(function()
        if character then
            character:SetAttribute("MaxStamina", 6767)
            character:SetAttribute("StaminaDrain", 0)
            character:SetAttribute("Stamina", 6767)
            character:SetAttribute("StaminaGain", 6767)
        end
    end)
end)

local KillGroup = Tabs.Main:AddLeftGroupbox("Combat")
KillGroup:AddDropdown("MC_KillTarget", { Values = {}, Text = "Select Target", Multi = false })
KillGroup:AddToggle("MC_KillEnabled", { Text = "Kill Target", Default = false })

local function updateKillTargets()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    Options.MC_KillTarget:SetValues(names)
end

game.Players.PlayerAdded:Connect(updateKillTargets)
game.Players.PlayerRemoving:Connect(updateKillTargets)
updateKillTargets()

local AutoGroup = Tabs.Main:AddRightGroupbox("Automation")
AutoGroup:AddToggle("MG_AutoComplete", { Text = "Auto-Complete", Default = false })
AutoGroup:AddToggle("MG_GlobalAuto", { Text = "Global Range", Default = false })
AutoGroup:AddSlider("MG_CompletionDelay", { Text = "Delay", Default = 1, Min = 0.1, Max = 5, Rounding = 1, Compact = true, Suffix = "s" })

local VisualGroup = Tabs.Visuals:AddLeftGroupbox("ESP Settings")
VisualGroup:AddToggle("VE_EnableESP", { Text = "Enable ESP", Default = false })
VisualGroup:AddToggle("VE_PlayerESP", { Text = "Player ESP", Default = false })
VisualGroup:AddToggle("VE_ObjectiveESP", { Text = "Objective ESP", Default = false })

Toggles.VE_EnableESP:OnChanged(function(v)
    if not v then clearesp() end
end)
 
local MiscTab = Tabs.Misc
local BadgeGroup = MiscTab:AddLeftGroupbox("Badges")

BadgeGroup:AddButton("GATEWAY BADGE - AUTOCOMPLETE", function()
    local placeId = 71890755840747
    local scriptUrl = "https://raw.githubusercontent.com/louisianaui/gamewithevil/refs/heads/main/gateway.lua"
    
    local queue = queue_on_teleport or (syn and syn.queue_on_teleport)
    if queue then
        queue([[loadstring(game:HttpGet("]] .. scriptUrl .. [["))()]])
    end
    
    game:GetService("TeleportService"):Teleport(placeId, game:GetService("Players").LocalPlayer)
end)

BadgeGroup:AddButton("SOGGY OBBY BADGE - AUTOCOMPLETE", function()
    local placeId = 96172353717244
    local scriptUrl = "https://raw.githubusercontent.com/louisianaui/gamewithevil/refs/heads/main/soggyobby.lua"
    
    local queue = queue_on_teleport or (syn and syn.queue_on_teleport)
    if queue then
        queue([[loadstring(game:HttpGet("]] .. scriptUrl .. [["))()]])
    end
    
    game:GetService("TeleportService"):Teleport(placeId, game:GetService("Players").LocalPlayer)
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Gamewithevil")
SaveManager:SetFolder("Gamewithevil/Main")
ThemeManager:CreateThemeManager(ThemeGroup)
SaveManager:BuildConfigSection(SettingsTab)

task.spawn(function()
    repeat task.wait() until Library.ScreenGui and Library.ScreenGui:FindFirstChild("Main")
    ApplyTransparency()
end)

DraggableLabel:SetVisible(false)
Library.KeybindFrame.Visible = false

task.spawn(function()
    while true do
        if Toggles.MC_InfiniteStamina and Toggles.MC_InfiniteStamina.Value then
            pcall(function()
                if character then
                    character:SetAttribute("MaxStamina", 6767)
                    character:SetAttribute("StaminaDrain", 0)
                    character:SetAttribute("Stamina", 6767)
                    character:SetAttribute("StaminaGain", 6767)
                end
            end)
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if Toggles.MG_AutoComplete and Toggles.MG_AutoComplete.Value then
            pcall(function()
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                local activeObjectives = Workspace.Live.Map.MapModel:FindFirstChild("ActiveObjectives")
                if not activeObjectives then return end
                
                local isGlobal = Toggles.MG_GlobalAuto and Toggles.MG_GlobalAuto.Value
                
                local function process(parent)
                    for _, obj in pairs(parent:GetChildren()) do
                        if obj:IsA("Model") or obj:IsA("BasePart") then
                            local done = obj:GetAttribute("DoneCompletions")
                            local max = obj:GetAttribute("MaxCompletions")
                            
                            local isHidden = false
                            if obj:IsA("BasePart") then
                                isHidden = (obj.Transparency >= 1)
                            elseif obj:IsA("Model") then
                                local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if p and p.Transparency >= 1 then isHidden = true end
                            end
                            
                            if (not done or not max or done < max) and not isHidden then
                                local p = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                                if p then
                                    local dist = (p.Position - char.HumanoidRootPart.Position).Magnitude
                                    if isGlobal or dist < 15 then
                                        local remote = obj:FindFirstChild("Remote")
                                        if remote and (remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent")) then
                                            remote:FireServer()
                                        end
                                    end
                                end
                            end
                        elseif obj:IsA("Folder") or obj:IsA("Configuration") then
                            process(obj)
                        end
                    end
                end
                
                process(activeObjectives)
            end)
        end
        task.wait(Options.MG_CompletionDelay and Options.MG_CompletionDelay.Value or 1)
    end
end)

task.spawn(function()
    while true do
        if Toggles.MC_KillEnabled and Toggles.MC_KillEnabled.Value then
            pcall(function()
                local targetName = Options.MC_KillTarget.Value
                local targetPlayer = game.Players:FindFirstChild(targetName)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    end
                end
            end)
        end
        task.wait(0.01)
    end
end)

SaveManager:LoadAutoloadConfig()
