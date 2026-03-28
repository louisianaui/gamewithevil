local qot = queue_on_teleport
if qot then
    qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/louisianaui/gamewithevil/refs/heads/main/gateway.lua"))()')
end

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
local hrp = char.HumanoidRootPart

local function firetouch(part)
    if not part then return end
    
    -- Physically teleport to ensure server-side collision
    hrp.CFrame = part.CFrame
    task.wait(0.1)
    
    if firetouchinterest then
        firetouchinterest(hrp, part, 0)
        task.wait(0.1)
        firetouchinterest(hrp, part, 1)
    end
end

local pid = game.PlaceId

if pid == 71890755840747 then
    local light = workspace:FindFirstChild("The Light")
    if light and light:GetChildren()[2] then
        print("gateway door")
        firetouch(light:GetChildren()[2])
    end
    
    task.wait(0.5)
    
    local walls = workspace:FindFirstChild("Walls")
    if walls and walls:GetChildren()[8] then
        print("secret door")
        firetouch(walls:GetChildren()[8])
    end

elseif pid == 94968829250525 then
    print("loaded into subplace")
    
    local pt2 = workspace:FindFirstChild("Puzzle Part Two")
    if pt2 then
        print("keys")
        if pt2:FindFirstChild("A") and pt2.A:FindFirstChild("Key1") then
            firetouch(pt2.A.Key1)
        end
        task.wait(0.5)
        if pt2:FindFirstChild("B") and pt2.B:FindFirstChild("Key2") then
            firetouch(pt2.B.Key2)
        end
        task.wait(0.5)
    end
    
    local prize = workspace:FindFirstChild("PRIZE")
    if prize and prize:FindFirstChild("inverse sphere") then
        print("got prize")
        firetouch(prize["inverse sphere"])
    end
end
