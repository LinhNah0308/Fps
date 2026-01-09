-- CONFIG
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local flying = false
local bv, bg, flyConn

local speed = _G.FlySpeed or 50
local iconId = _G.IconImageId or "119077940443302"

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
        local cam = workspace.CurrentCamera
        -- Bay theo hướng camera full 3D
        local moveVec = cam.CFrame.LookVector
        bv.Velocity = moveVec * speed
        bg.CFrame = cam.CFrame
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

local icon = Instance.new("ImageLabel", main)
icon.Size = UDim2.new(0,40,0,40)
icon.Position = UDim2.new(0,5,0.5,-20)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://"..iconId

local flyBtn = Instance.new("TextButton", main)
flyBtn.Size = UDim2.new(1,-50,1,0)
flyBtn.Position = UDim2.new(0,50,0,0)
flyBtn.Text = "FLY : OFF"
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.BackgroundTransparency = 1
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextScaled = true

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "FLY : ON" or "FLY : OFF"
    if flying then startFly() else stopFly() end
end)
