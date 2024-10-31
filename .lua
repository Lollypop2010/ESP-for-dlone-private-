local function API_Check()
    if Drawing == nil then
        return "No"
    else
        return "Yes"
    end
end

local Find_Required = API_Check()

if Find_Required == "No" then
    print("Exunys Developer: Boxes script could not be loaded because your exploit is unsupported.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Typing = false

_G.SendNotifications = false
_G.DefaultSettings = false

_G.TeamCheck = false
_G.SquaresVisible = true
_G.SquareColor = Color3.fromRGB(199, 21, 133)
_G.SquareThickness = 1
_G.SquareFilled = false
_G.SquareTransparency = 0.7

_G.HeadESPEnabled = true
_G.HeadColor = Color3.fromRGB(199,21,133)
_G.HeadThickness = 1
_G.HeadTransparency = 0.7
_G.HeadRadius = 7

_G.SkeletonESPEnabled = true     -- Enable Skeleton ESP
_G.SkeletonColor = Color3.fromRGB(199,21,133)
_G.SkeletonThickness = 1

_G.TracerESPEnabled = true       -- Enable Tracer ESP
_G.TracerColor = Color3.fromRGB(199,21,133)
_G.TracerThickness = 1

_G.HeadOffset = Vector3.new(0, 0.5, 0)
_G.LegsOffset = Vector3.new(0, 3, 0)
_G.DisableKey = Enum.KeyCode.Q

local function CreateESP()
    for _, v in next, Players:GetPlayers() do
        if v ~= LocalPlayer and v.Character then
            if v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid").Health > 0 then
                -- Square ESP
                local Square = Drawing.new("Square")
                Square.Thickness = _G.SquareThickness
                Square.Transparency = _G.SquareTransparency
                Square.Color = _G.SquareColor
                Square.Filled = _G.SquareFilled

                -- Head ESP
                local HeadCircle = Drawing.new("Circle")
                HeadCircle.Thickness = _G.HeadThickness
                HeadCircle.Transparency = _G.HeadTransparency
                HeadCircle.Color = _G.HeadColor
                HeadCircle.Radius = _G.HeadRadius

                -- Tracer ESP
                local Tracer = Drawing.new("Line")
                Tracer.Thickness = _G.TracerThickness
                Tracer.Color = _G.TracerColor

                -- Skeleton ESP Lines
                local SkeletonLines = {}
                for i = 1, 10 do
                    local line = Drawing.new("Line")
                    line.Color = _G.SkeletonColor
                    line.Thickness = _G.SkeletonThickness
                    table.insert(SkeletonLines, line)
                end

                RunService.RenderStepped:Connect(function()
                    if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local Victim_HumanoidRootPart, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                        local Victim_Head = Camera:WorldToViewportPoint(v.Character.Head.Position + _G.HeadOffset)
                        local Victim_Legs = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position - _G.LegsOffset)

                        -- Square ESP Visibility
                        if OnScreen and _G.SquaresVisible then
                            Square.Size = Vector2.new(2000 / Victim_HumanoidRootPart.Z, Victim_Head.Y - Victim_Legs.Y)
                            Square.Position = Vector2.new(Victim_HumanoidRootPart.X - Square.Size.X / 2, Victim_HumanoidRootPart.Y - Square.Size.Y / 2)
                            Square.Visible = not _G.TeamCheck or v.Team ~= LocalPlayer.Team
                        else
                            Square.Visible = false
                        end

                        -- Head ESP Visibility
                        if _G.HeadESPEnabled and OnScreen then
                            HeadCircle.Position = Vector2.new(Victim_Head.X, Victim_Head.Y)
                            HeadCircle.Visible = not _G.TeamCheck or v.Team ~= LocalPlayer.Team
                        else
                            HeadCircle.Visible = false
                        end

                        -- Tracer ESP
                        if _G.TracerESPEnabled and OnScreen then
                            Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            Tracer.To = Vector2.new(Victim_HumanoidRootPart.X, Victim_HumanoidRootPart.Y)
                            Tracer.Visible = true
                        else
                            Tracer.Visible = false
                        end

                        -- Skeleton ESP
                        if _G.SkeletonESPEnabled and OnScreen then
                            local bodyParts = {
                                v.Character.Head,
                                v.Character.UpperTorso,
                                v.Character.LowerTorso,
                                v.Character.LeftUpperLeg,
                                v.Character.RightUpperLeg,
                                v.Character.LeftLowerLeg,
                                v.Character.RightLowerLeg,
                                v.Character.LeftUpperArm,
                                v.Character.RightUpperArm,
                                v.Character.LeftLowerArm,
                                v.Character.RightLowerArm
                            }
                            for i = 1, #bodyParts - 1 do
                                if bodyParts[i] and bodyParts[i + 1] then
                                    local Part1Pos = Camera:WorldToViewportPoint(bodyParts[i].Position)
                                    local Part2Pos = Camera:WorldToViewportPoint(bodyParts[i + 1].Position)
                                    SkeletonLines[i].From = Vector2.new(Part1Pos.X, Part1Pos.Y)
                                    SkeletonLines[i].To = Vector2.new(Part2Pos.X, Part2Pos.Y)
                                    SkeletonLines[i].Visible = true
                                end
                            end
                        else
                            for _, line in pairs(SkeletonLines) do
                                line.Visible = false
                            end
                        end
                    else
                        Square.Visible = false
                        HeadCircle.Visible = false
                        Tracer.Visible = false
                        for _, line in pairs(SkeletonLines) do
                            line.Visible = false
                        end
                    end
                end)

                Players.PlayerRemoving:Connect(function(Player)
                    if Player == v then
                        Square.Visible = false
                        HeadCircle.Visible = false
                        Tracer.Visible = false
                        for _, line in pairs(SkeletonLines) do
                            line.Visible = false
                        end
                    end
                end)
            end
        end
    end
end

-- Toggle visibility and settings initialization
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == _G.DisableKey and not Typing then
        _G.SquaresVisible = not _G.SquaresVisible
    end
end)

local Success, Errored = pcall(function()
    CreateESP()
end)

if not Success then
    warn("The boxes script encountered an error during loading.")
end
