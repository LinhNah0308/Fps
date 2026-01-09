-- ================= CONFIG =================
local CONFIG = {
    IconImageId = _G.IconImageId
        and ("rbxassetid://" .. tostring(_G.IconImageId))
        or "rbxassetid://1234567890", -- icon mặc định nếu không truyền

    DefaultSpeed = 50,
    MinSpeed = 10,
    MaxSpeed = 500,
}

-- ================= SERVICES =================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- ================= STATE =================
local flying = false
local noclip = false
local speed = CONFIG.DefaultSpeed
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
local function startFly()
    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)

    hum.PlatformStand = true
    if noclip then setNoclip(true) end

    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

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
main.Size = UDim2.fromScale(0.25,0.28)
main.Position = UDim2.fromScale(0.05,0.32)
main.BackgroundColor3 = Color3.new(0,0,0)
main.BorderColor3 = Color3.new(1,1,1)
main.BorderSizePixel = 2
main.Active = true
main.Draggable = true

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0,6)

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
local flyBox = box(40)

local icon = Instance.new("ImageLabel", flyBox)
icon.Size = UDim2.new(0,26,0,26)
icon.Position = UDim2.new(0,6,0.5,-13)
icon.BackgroundTransparency = 1
icon.Image = CONFIG.IconImageId

local flyBtn = Instance.new("TextButton", flyBox)
flyBtn.Size = UDim2.new(1,-40,1,0)
flyBtn.Position = UDim2.new(0,40,0,0)
flyBtn.BackgroundTransparency = 1
flyBtn.Text = "FLY : OFF"
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextScaled = true

-- SPEED
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

-- ================= EVENTS =================
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "FLY : ON" or "FLY : OFF"
    if flying then startFly() else stopFly() end
end)

speedInput.FocusLost:Connect(function()
    local v = tonumber(speedInput.Text)
    if v then
        speed = math.clamp(v, CONFIG.MinSpeed, CONFIG.MaxSpeed)
    end
    speedInput.Text = tostring(speed)
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "NOCLIP : ON" or "NOCLIP : OFF"
    if flying then setNoclip(noclip) end
end)
