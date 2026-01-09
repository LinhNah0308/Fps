-- CONFIG
_G.IconImageId = "119077940443302" -- nếu không hiện, sẽ fallback thành "FLY"

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- STATE
local flying = false
local noclip = false
local speed = 50
local bv, bg
local flyConn, noclipConn

-- ================= NOCLIP =================
local function setNoclip(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            for _,v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end

-- ================= FLY =================
local function startFly(dirVector)
    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)

    hum.PlatformStand = true
    if noclip then setNoclip(true) end

    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local dir = dirVector or Vector3.zero
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    setNoclip(false)
    hum.PlatformStand = false
end

-- ================= UI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,180,0,220)
main.Position = UDim2.new(0.05,0,0.3,0)
main.BackgroundColor3 = Color3.new(0,0,0)
main.BorderColor3 = Color3.new(1,1,1)
main.BorderSizePixel = 2
main.Active = true
main.Draggable = true

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0,6)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function box(h)
    local f = Instance.new("Frame", main)
    f.Size = UDim2.new(1,-10,0,h)
    f.Position = UDim2.new(0,5,0,0)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.BorderColor3 = Color3.new(1,1,1)
    f.BorderSizePixel = 1
    return f
end

-- FLY BOX
local flyBox = box(50)

local icon = Instance.new("ImageLabel", flyBox)
icon.Size = UDim2.new(0,40,0,40)
icon.Position = UDim2.new(0,5,0.5,-20)
icon.BackgroundTransparency = 1
if _G.IconImageId then
    icon.Image = "rbxassetid://".._G.IconImageId
else
    local fallback = Instance.new("TextLabel", flyBox)
    fallback.Text = "FLY"
    fallback.Size = UDim2.new(0,40,0,40)
    fallback.Position = UDim2.new(0,5,0.5,-20)
    fallback.BackgroundTransparency = 1
    fallback.TextColor3 = Color3.new(1,1,1)
    fallback.Font = Enum.Font.SourceSansBold
    fallback.TextScaled = true
end

local flyBtn = Instance.new("TextButton", flyBox)
flyBtn.Size = UDim2.new(1,-50,1,0)
flyBtn.Position = UDim2.new(0,50,0,0)
flyBtn.BackgroundTransparency = 1
flyBtn.Text = "FLY : OFF"
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextScaled = true

-- SPEED BOX
local speedBox = box(40)

local speedLabel = Instance.new("TextLabel", speedBox)
speedLabel.Size = UDim2.new(0.45,0,1,0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "SPEED"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextScaled = true

local speedInput = Instance.new("TextBox", speedBox)
speedInput.Size = UDim2.new(0.55,-6,1,-8)
speedInput.Position = UDim2.new(0.45,6,0,4)
speedInput.BackgroundColor3 = Color3.new(0,0,0)
speedInput.BorderColor3 = Color3.new(1,1,1)
speedInput.Text = tostring(speed)
speedInput.TextColor3 = Color3.new(1,1,1)
speedInput.Font = Enum.Font.SourceSans
speedInput.TextScaled = true
speedInput.ClearTextOnFocus = false

-- NOCLIP
local noclipBox = box(40)
local noclipBtn = Instance.new("TextButton", noclipBox)
noclipBtn.Size = UDim2.new(1,0,1,0)
noclipBtn.BackgroundTransparency = 1
noclipBtn.Text = "NOCLIP : OFF"
noclipBtn.TextColor3 = Color3.new(1,1,1)
noclipBtn.Font = Enum.Font.SourceSansBold
noclipBtn.TextScaled = true

-- MOBILE TOUCH BUTTONS
local touchFrame = Instance.new("Frame", gui)
touchFrame.Size = UDim2.new(0,200,0,150)
touchFrame.Position = UDim2.new(0.7,0,0.6,0)
touchFrame.BackgroundTransparency = 0.5
touchFrame.BackgroundColor3 = Color3.new(0,0,0)
touchFrame.BorderColor3 = Color3.new(1,1,1)
touchFrame.BorderSizePixel = 2

local function createTouchButton(name,pos,dir)
    local btn = Instance.new("TextButton", touchFrame)
    btn.Size = UDim2.new(0,60,0,60)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.new(0,0,0)
    btn.BorderColor3 = Color3.new(1,1,1)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansBold

    btn.TouchTap:Connect(function()
        if flying then
            startFly(dir)
        end
    end)
end

createTouchButton("UP",UDim2.new(0,70,0,0),Vector3.new(0,1,0))
createTouchButton("DOWN",UDim2.new(0,70,0,80),Vector3.new(0,-1,0))
createTouchButton("LEFT",UDim2.new(0,5,0,40),Vector3.new(-1,0,0))
createTouchButton("RIGHT",UDim2.new(0,135,0,40),Vector3.new(1,0,0))

-- ================= EVENTS =================
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "FLY : ON" or "FLY : OFF"
    if not flying then stopFly() end
end)

speedInput.FocusLost:Connect(function()
    local v = tonumber(speedInput.Text)
    if v then speed = math.clamp(v,10,500) end
    speedInput.Text = tostring(speed)
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "NOCLIP : ON" or "NOCLIP : OFF"
    if flying then setNoclip(noclip) end
end)
