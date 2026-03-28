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
    
    if firetouchinterest then
        for i = 1, (fires or 2) do
            firetouchinterest(hrp, part, 0)
            task.wait(1)
            firetouchinterest(hrp, part, 1)
            task.wait(1)
        end
    end
end

local pid = game.PlaceId

if pid == 71890755840747 then
    local light = workspace:FindFirstChild("The Light")
    if light then
        print("gateway door")
        local targetPos = Vector3.new(-9.53674316e-07, 83.5250244, -20.4998016)
        
        for _, v in pairs(light:GetChildren()) do
            if v:IsA("BasePart") and (v.Position - targetPos).Magnitude < 0.1 then
                firetouch(v)
                break
            end
        end
    end
    
    task.wait(1.5)
    
    local walls = workspace:FindFirstChild("Walls")
    if walls then
        print("secret door")
        local targetPos = Vector3.new(20.8749981, 92, -14)
        
        for _, v in pairs(walls:GetChildren()) do
            if v:IsA("BasePart") and (v.Position - targetPos).Magnitude < 0.1 then
                hrp.CFrame = v.CFrame
                task.wait(0.2)
                firetouch(v)
                break
            end
        end
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
