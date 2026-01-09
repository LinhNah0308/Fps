-- CONFIG
_G.IconImageId = "119077940443302"
local speed = 50 -- tốc độ bay

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- STATE
local flying = false
local bv, bg
local flyConn

-- FUNCTIONS
local function startFly()
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    hum.PlatformStand = true

    flyConn = RunService.RenderStepped:Connect(function()
        -- Lấy vector từ joystick của Roblox Mobile
        local moveVec = hrp.Velocity.Unit
        bv.Velocity = moveVec * speed
        bg.CFrame = hrp.CFrame
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    hum.PlatformStand = false
end

-- UI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,180,0,80)
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

-- FLY BOX
local flyBox = Instance.new("Frame", main)
flyBox.Size = UDim2.new(1,-10,0,50)
flyBox.Position = UDim2.new(0,5,0,0)
flyBox.BackgroundColor3 = Color3.new(0,0,0)
flyBox.BorderColor3 = Color3.new(1,1,1)
flyBox.BorderSizePixel = 1

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
local speedBox = Instance.new("Frame", main)
speedBox.Size = UDim2.new(1,-10,0,40)
speedBox.Position = UDim2.new(0,5,0,56)
speedBox.BackgroundColor3 = Color3.new(0,0,0)
speedBox.BorderColor3 = Color3.new(1,1,1)
speedBox.BorderSizePixel = 1

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

-- EVENTS
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "FLY : ON" or "FLY : OFF"
    if flying then startFly() else stopFly() end
end)

speedInput.FocusLost:Connect(function()
    local v = tonumber(speedInput.Text)
    if v then speed = math.clamp(v,10,500) end
    speedInput.Text = tostring(speed)
end)
