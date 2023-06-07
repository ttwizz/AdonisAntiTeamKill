--[[

    "Adonis Anti Team Kill" is a utility that simplifies the work of moderators of RolePlay games. The system has a wide functionality and convenient configuration, thereby standing out from other competitors. "Adonis Anti Team Kill" works exclusively in conjunction with "Adonis Administration System", being an excellent addition. If you have any questions or suggestions, please contact me by email "moderkascriptsltd@gmail.com". Have a nice day!
    Copyright (C) 2023 ttwiz_z

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

--]]


local DATA_STORE_KEY = "0203fad5582eaec9c5e02ff5d0c73ee3bebdc9b2e35daec58a"
local UNBLOCKING_COMMAND = "!unblock"
local DEFAULT_TEAM = "Team"
local KILL_INSTEAD_OF_RESPAWN = false
local WARNING_TIME_MINUTES = 20
local BLOCKING_TIME_MINUTES = 20

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local OldTeamDataStore = game:GetService("DataStoreService"):GetDataStore("OldTeamDataStore", tostring(DATA_STORE_KEY) or "0203fad5582eaec9c5e02ff5d0c73ee3bebdc9b2e35daec58a")
local Teams = game:GetService("Teams")
local Debris = game:GetService("Debris")

_G.BlockedPlayersList = {}

function Initialize()
    local GetBlockedPlayersList = Instance.new("RemoteFunction", ReplicatedStorage)
    GetBlockedPlayersList.Name = "GetBlockedPlayersList"
    GetBlockedPlayersList.OnServerInvoke = function(Player)
        return table.find(_G.BlockedPlayersList, Player.UserId)
    end
    Players.PlayerAdded:Connect(function(Player)
        local OldTeam = Instance.new("StringValue", Player)
        OldTeam.Name = "OldTeam"
        local Data, NewPlayer = pcall(function()
            OldTeam.Value = tostring(OldTeamDataStore:GetAsync(Player.UserId))
        end)
        if NewPlayer then
            OldTeam.Value = "__NONE__"
        elseif Data then
            if OldTeam.Value ~= "__NONE__" and not table.find(_G.BlockedPlayersList, Player.UserId) then
                table.insert(_G.BlockedPlayersList, Player.UserId)
                delay(tonumber(BLOCKING_TIME_MINUTES * 60) or 1200, function()
                    if table.find(_G.BlockedPlayersList, Player.UserId) then
                        table.remove(_G.BlockedPlayersList, table.find(_G.BlockedPlayersList, Player.UserId))
                    end
                    if Player and Player:FindFirstChild("Warned") and Player:FindFirstChild("Warned").Value then
                        Player:WaitForChild("Warned", math.huge).Value = false
                    end
                    if Player and Player:FindFirstChild("OldTeam") and Player:FindFirstChild("OldTeam").Value ~= "__NONE__" then
                        local Team = Teams:FindFirstChild(Player:FindFirstChild("OldTeam").Value)
                        if Team and typeof(Team) == "Instance" and Team:IsA("Team") and Player.Team and Player.Team ~= Team then
                            Player.Team = Team
                            if KILL_INSTEAD_OF_RESPAWN then
                                local Character = Player.Character
                                if Character then
                                    if Character:FindFirstChild("UpperTorso") then
                                        Debris:AddItem(Character:FindFirstChild("UpperTorso"), 0)
                                    elseif Character:FindFirstChild("Head") then
                                        Debris:AddItem(Character:FindFirstChild("Head"), 0)
                                    else
                                        Player:LoadCharacter()
                                    end
                                else
                                    Player:LoadCharacter()
                                end
                            else
                                Player:LoadCharacter()
                            end
                            Player:WaitForChild("OldTeam", math.huge).Value = "__NONE__"
                        end
                    end
                end)
            end
        end
        OldTeam:GetPropertyChangedSignal("Value"):Connect(function()
            pcall(function()
                OldTeamDataStore:SetAsync(Player.UserId, tostring(OldTeam.Value))
            end)
        end)
        local Warned = Instance.new("BoolValue", Player)
        Warned.Name = "Warned"
        if table.find(_G.BlockedPlayersList, Player.UserId) then
            Warned.Value = true
        else
            Warned.Value = false
        end
        Player.Chatted:Connect(function(Message)
            if _G.Adonis.CheckAdmin(Player) then
                local Argument = string.split(Message, " ")
                if Argument and Argument[1] and Argument[2] then
                    local Command = string.lower(Argument[1])
                    local UnblockingCommand = string.lower(tostring(UNBLOCKING_COMMAND) or "!unblock")
                    local UserId = tonumber(Argument[2]) or 1
                    local Violator = Players:GetPlayerByUserId(UserId)
                    if Command == UnblockingCommand and table.find(_G.BlockedPlayersList, UserId) then
                        table.remove(_G.BlockedPlayersList, table.find(_G.BlockedPlayersList, UserId))
                        if Violator and Violator:FindFirstChild("Warned") and Violator:FindFirstChild("Warned").Value then
                            Violator:WaitForChild("Warned", math.huge).Value = false
                        end
                        if Violator and Violator:FindFirstChild("OldTeam") and Violator:FindFirstChild("OldTeam").Value ~= "__NONE__" then
                            local Team = Teams:FindFirstChild(Violator:FindFirstChild("OldTeam").Value)
                            if Team and typeof(Team) == "Instance" and Team:IsA("Team") and Violator.Team and Violator.Team ~= Team then
                                Violator.Team = Team
                                if KILL_INSTEAD_OF_RESPAWN then
                                    local ViolatorCharacter = Violator.Character
                                    if ViolatorCharacter then
                                        if ViolatorCharacter:FindFirstChild("UpperTorso") then
                                            Debris:AddItem(ViolatorCharacter:FindFirstChild("UpperTorso"), 0)
                                        elseif ViolatorCharacter:FindFirstChild("Head") then
                                            Debris:AddItem(ViolatorCharacter:FindFirstChild("Head"), 0)
                                        else
                                            Violator:LoadCharacter()
                                        end
                                    else
                                        Violator:LoadCharacter()
                                    end
                                else
                                    Violator:LoadCharacter()
                                end
                                Violator:WaitForChild("OldTeam", math.huge).Value = "__NONE__"
                            end
                        end
                    end
                end
            end
        end)
        Player.CharacterAdded:Connect(function(Character)
            task.spawn(function()
                while task.wait(1) do
                    local Team = Teams:FindFirstChild(tostring(DEFAULT_TEAM) or "Team")
                    if Team and typeof(Team) == "Instance" and Team:IsA("Team") and Player.Team and Player.Team ~= Team and table.find(_G.BlockedPlayersList, Player.UserId) then
                        Player.Team = Team
                        if KILL_INSTEAD_OF_RESPAWN then
                            if Character:FindFirstChild("UpperTorso") then
                                Debris:AddItem(Character:FindFirstChild("UpperTorso"), 0)
                            elseif Character:FindFirstChild("Head") then
                                Debris:AddItem(Character:FindFirstChild("Head"), 0)
                            else
                                Player:LoadCharacter()
                            end
                        else
                            Player:LoadCharacter()
                        end
                    end
                end
            end)
            local Humanoid = Character:WaitForChild("Humanoid", math.huge)
            Humanoid.Died:Connect(function()
                for _, Child in next, Humanoid:GetChildren() do
                    if Child:IsA("ObjectValue") and Child.Value and typeof(Child.Value) == "Instance" and Child.Value:IsA("Player") and Players:FindFirstChild(Child.Value.Name) and Child.Value.UserId and Child.Value:FindFirstChild("Warned") and Child.Value:FindFirstChild("Warned"):IsA("BoolValue") and Child.Value:FindFirstChild("OldTeam") and Child.Value:FindFirstChild("OldTeam"):IsA("StringValue") and Player.Team and Child.Value.Team and Player.Team == Child.Value.Team and not _G.Adonis.CheckAdmin(Child.Value) then
                        local Violator = Child.Value
                        if not Violator:FindFirstChild("Warned").Value then
                            Violator:WaitForChild("Warned", math.huge).Value = true
                            delay(tonumber(WARNING_TIME_MINUTES * 60) or 1200, function()
                                if Violator and Violator:FindFirstChild("Warned") and Violator:FindFirstChild("Warned").Value then
                                    Violator:WaitForChild("Warned", math.huge).Value = false
                                end
                            end)
                        else
                            if not table.find(_G.BlockedPlayersList, Violator.UserId) then
                                Violator:WaitForChild("OldTeam", math.huge).Value = Violator.Team.Name
                                table.insert(_G.BlockedPlayersList, Violator.UserId)
                                delay(tonumber(BLOCKING_TIME_MINUTES * 60) or 1200, function()
                                    if table.find(_G.BlockedPlayersList, Violator.UserId) then
                                        table.remove(_G.BlockedPlayersList, table.find(_G.BlockedPlayersList, Violator.UserId))
                                    end
                                    if Violator and Violator:FindFirstChild("Warned") and Violator:FindFirstChild("Warned").Value then
                                        Violator:WaitForChild("Warned", math.huge).Value = false
                                    end
                                    if Violator and Violator:FindFirstChild("OldTeam") and Violator:FindFirstChild("OldTeam").Value ~= "__NONE__" then
                                        local Team = Teams:FindFirstChild(Violator:FindFirstChild("OldTeam").Value)
                                        if Team and typeof(Team) == "Instance" and Team:IsA("Team") and Violator.Team and Violator.Team ~= Team then
                                            Violator.Team = Team
                                            if KILL_INSTEAD_OF_RESPAWN then
                                                local ViolatorCharacter = Violator.Character
                                                if ViolatorCharacter then
                                                    if ViolatorCharacter:FindFirstChild("UpperTorso") then
                                                        Debris:AddItem(ViolatorCharacter:FindFirstChild("UpperTorso"), 0)
                                                    elseif ViolatorCharacter:FindFirstChild("Head") then
                                                        Debris:AddItem(ViolatorCharacter:FindFirstChild("Head"), 0)
                                                    else
                                                        Violator:LoadCharacter()
                                                    end
                                                else
                                                    Violator:LoadCharacter()
                                                end
                                            else
                                                Violator:LoadCharacter()
                                            end
                                            Violator:WaitForChild("OldTeam", math.huge).Value = "__NONE__"
                                        end
                                    end
                                end)
                            end
                        end
                        return
                    end
                end
            end)
        end)
    end)
end

task.spawn(function()
    warn(string.reverse("\33\100\101\122\105\108\97\105\116\105\110\105\32\49\56\48\50\35\122\95\122\105\119\116\116\32\121\66\32\108\108\105\75\32\109\97\101\84\32\105\116\110\65\32\115\105\110\111\100\65"))
end)

pcall(Initialize)