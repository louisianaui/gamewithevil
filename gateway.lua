local qot = queue_on_teleport
if qot then
    qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/louisianaui/gamewithevil/refs/heads/main/gateway.lua"))()')
end

local Players = game:GetService("Players")
while not Players.LocalPlayer do task.wait() end
local plr = Players.LocalPlayer

local char = plr.Character or plr.CharacterAdded:Wait()

repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
local hrp = char.HumanoidRootPart

local function firetouch(part, fires)
    if not part then return end
    
    -- Bring the part to the player safely
    local oldCFrame = part.CFrame
    part.CFrame = hrp.CFrame
    
    if firetouchinterest then
        for i = 1, (fires or 2) do
            firetouchinterest(hrp, part, 0)
            task.wait(1)
            firetouchinterest(hrp, part, 1)
            task.wait(1)
        end
    end
    
    -- Optional: put it back
    part.CFrame = oldCFrame
end

local pid = game.PlaceId

if pid == 71890755840747 then
    local light = workspace:FindFirstChild("The Light")
    if light then
        print("gateway door")
        for _, v in pairs(light:GetChildren()) do
            if v:IsA("BasePart") then
                firetouch(v)
            end
        end
    end
    
    task.wait(1.5)
    
    local walls = workspace:FindFirstChild("Walls")
    if walls and walls:GetChildren()[8] then
        print("secret door")
        firetouch(walls:GetChildren()[8])
    end

elseif pid == 94968829250525 then
    print("loaded into subplace")
    
    local pt2 = workspace:WaitForChild("Puzzle Part Two", 10)
    task.wait(1)
    
    if pt2 then
        print("keys")
        if pt2:WaitForChild("A", 5) and pt2.A:WaitForChild("Key1", 5) then
            firetouch(pt2.A.Key1)
        end
        task.wait(0.5)
        if pt2:WaitForChild("B", 5) and pt2.B:WaitForChild("Key2", 5) then
            firetouch(pt2.B.Key2)
        end
        task.wait(0.5)
    end
    
    local prize = workspace:WaitForChild("PRIZE", 5)
    if prize and prize:WaitForChild("inverse sphere", 5) then
        print("got prize")
        firetouch(prize["inverse sphere"])
    end
end
