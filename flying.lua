-- CONFIG
_G.IconImageId = "119077940443302"
local speed = 50

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local flying = false
local bv, bg, flyConn

local function startFly()
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.Parent = hrp

    hum.PlatformStand = true
    flyConn = RunService.RenderStepped:Connect(function()
        local move = hum.MoveDirection
        bv.Velocity = (workspace.CurrentCamera.CFrame.LookVector * move.Z +
                       workspace.CurrentCamera.CFrame.RightVector * move.X +
                       Vector3.new(0, move.Y, 0)) * speed
        bg.CFrame = workspace.CurrentCamera.CFrame
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    hum.PlatformStand = false
end

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Position = UDim2.new(0.05,0,0.3,0)
frame.Size = UDim2.new(0,200,0,90)
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.BorderColor3 = Color3.new(1,1,1)
frame.Active = true
frame.Draggable = true

local icon = Instance.new("ImageLabel", frame)
icon.Size = UDim2.new(0,40,0,40)
icon.Position = UDim2.new(0,5,0.5,-20)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://".._G.IconImageId

local flyBtn = Instance.new("TextButton", frame)
flyBtn.Size = UDim2.new(1,-50,1,0)
flyBtn.Position = UDim2.new(0,50,0,0)
flyBtn.Text = "FLY : OFF"
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.BackgroundTransparency = 1

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "FLY : ON" or "FLY : OFF"
    if flying then startFly() else stopFly() end
end)
