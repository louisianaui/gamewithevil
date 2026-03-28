local Players = game:GetService("Players")
while not Players.LocalPlayer do task.wait() end
local plr = Players.LocalPlayer

local char = plr.Character or plr.CharacterAdded:Wait()
repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
local hrp = char.HumanoidRootPart

local checkpoints = workspace:WaitForChild("Checkpoints", 5)

if checkpoints then
    task.wait(1)
    
    local leaderstats = plr:WaitForChild("leaderstats", 5)
    local stageStat = leaderstats and leaderstats:FindFirstChild("Stage")
    local startStage = stageStat and math.max(stageStat.Value, 1) or 1
    
    print("Soggy Obby: Starting from Checkpoint " .. tostring(startStage))
    
    for i = startStage, 100 do
        local checkpointName = "Checkpoint " .. tostring(i)
        local checkpoint = checkpoints:WaitForChild(checkpointName, 3)
        if checkpoint then
            print("Soggy Obby: Teleporting to " .. checkpointName)
            
            local currentChar = plr.Character or plr.CharacterAdded:Wait()
            local currentHRP = currentChar:WaitForChild("HumanoidRootPart", 3)
            
            if currentHRP then
                currentHRP.CFrame = checkpoint.CFrame
                task.wait(i >= 96 and 1 or 0.25)
            end
        else
            print("Soggy Obby: Error - " .. checkpointName .. " is missing or failed to load!")
            break
        end
    end
    print("Soggy Obby: Finished all 100 checkpoints!")
else
    print("Soggy Obby: Could not find 'Checkpoints' folder in Workspace.")
end
