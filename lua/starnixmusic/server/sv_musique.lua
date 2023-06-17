/*
        StarnixMusic - A music menu handle for the GMusic library addon on Garry's Mod
    
        StarnixMusic is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation.
    
        StarnixMusic is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
    
        You should have received a copy of the GNU General Public License
        along with StarnixMusic. If not, see <http://www.gnu.org/licenses/>.
*/

StarnixMusic = StarnixMusic or {}
StarnixMusic.MusicPendingWhitelist = {}
StarnixMusic.ListPlayersPending = {}
StarnixMusic.blockRequestPlayers = {}

--- Return the binary value of a string.
local function b(str)
	return tonumber(str, 2)
end

-- @table tableModifications Table used to store all the modifications that can be done to a music object. (bitflag) (SERVERSIDE)
local tableModifications = { 
    title       = b"0000000001",
    url         = b"0000000010",
    loop        = b"0000000100",
    volume      = b"0000001000",
}

function addAllPlayers(ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if not musicObject then return end
    local whitelistedOnMusic = musicObject:GetWhitelisted()
    if not whitelistedOnMusic then return end
    if not StarnixMusic.adminGroups[ply:GetUserGroup()] then return end
    local filterWhitelist = RecipientFilter()
    for k,v in ipairs(player.GetAll()) do
        if v ~= entityOwner and not whitelistedOnMusic[v] then
            filterWhitelist:AddPlayer(v)
            musicObject:AddPlayer(v)
        end
    end
    net.Start("Music_SendSong")
        net.WriteBool(true)
        net.WriteTable(musicObject)
    net.Send(filterWhitelist)
end

--[[-------------------------------------------------------------------------
Function called when a player want to create a music with the MENU.
---------------------------------------------------------------------------]]
net.Receive("Music_SendSong", function(len, ply)
    local url = net.ReadString() -- We store the url of the music.
    local name = net.ReadString() -- We store the name of the music.
    local looping = net.ReadBool() -- We store the choice of the player. Here, if the player want to loop the music or not.
    local canEveryonePause = net.ReadBool() -- We store the choice of the player. Here, if the player want to allow everyone to pause the music or not.
    local isEveryoneAdded = net.ReadBool() -- We store the choice of the player. Here, if the player want to add all players.
    local musicObject = GMusic.GetPlayerMusic(ply)
    local DataTable = nil
    if musicObject then
        if musicObject:GetCreator() == ply then
            if not url then url = musicObject:GetURL() end
            if not name then name = musicObject:GetTitle() end
            if not looping then looping = musicObject:GetLoop() end
            musicObject:SetURL(url)
            musicObject:SetTitle(name)
            musicObject:SetLoop(looping)
            DataTable = musicObject
        else
            musicObject:Stop(ply)
            DataTable = GMusic.create(url, ply, name, looping, 0, canEveryonePause)
        end

    else
        if not url or not name or not ply then return end
        DataTable = GMusic.create(url, ply, name, looping, 0, canEveryonePause)
    end
    if canEveryonePause and not StarnixMusic.adminGroups[ply:GetUserGroup()] then
        canEveryonePause = false
    end
    net.Start("Music_SendSong") -- We send a net message to the client in order to tell that the music is created.
    if DataTable then 
        net.WriteBool(true) -- Is the music object valid ?
        net.WriteTable(DataTable)-- We send the music object to the client (for the HUD).
    else
        net.WriteBool(false) -- Is the music object valid ?
        net.WriteTable({})
    end
    net.Send(ply) 
    if isEveryoneAdded then
        addAllPlayers(ply)
    end
end)

net.Receive("Music_StopSong", function(len, ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        musicObject:Stop(ply)
        net.Start("Music_StopSong")
        net.Send(ply)
        local ownerOfTheSong = musicObject:GetCreator()
        if ownerOfTheSong == ply then
            StarnixMusic.MusicPendingWhitelist[musicObject.id] = nil
            
        end
    else
        ply:PrintMessage(HUD_PRINTTALK, "You don't have any music playing.")
    end
end)

net.Receive("Music_PauseSong", function(len, ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        musicObject:Pause(ply)
    else
        ply:PrintMessage(HUD_PRINTTALK, "You don't have any music playing.")
    end
end)

net.Receive("Music_ChangeVolume", function(len, ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        local volume = net.ReadFloat()
        musicObject:SetVolume(volume)
    else
        ply:PrintMessage(HUD_PRINTTALK, "You don't have any music playing.")
    end
end)

net.Receive("Music_ChangeTime", function(len, ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        local time = net.ReadFloat()
        musicObject:SetTime(ply, time)
    else
        ply:PrintMessage(HUD_PRINTTALK, "You don't have any music playing.")
    end
end)

net.Receive("Music_MenuGetWhitelisted", function(len,ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if not musicObject then return end
    if ply ~= musicObject:GetCreator() then return end 
    local index_startPos = net.ReadUInt(8)
    local index_endPos = net.ReadUInt(8)
    if musicObject then
        local data = musicObject:GetWhitelisted(index_startPos, index_endPos)
        if not data then return end
        local maxPlyWhitelisted = musicObject:GetNumberWhitelisted()
        net.Start("Music_MenuGetWhitelisted")
            net.WriteTable(data)
            net.WriteUInt(maxPlyWhitelisted, 8)
        net.Send(ply)
    else
        ply:PrintMessage(HUD_PRINTTALK, "You don't have any music playing.")
    end
end) 

net.Receive("Music_MenuWLRemovePlayer", function(len,ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        local target = net.ReadEntity()
        musicObject:RemovePlayer(target)
        local data = musicObject:GetWhitelisted()
        local maxPlyWhitelisted = musicObject:GetNumberWhitelisted()
        net.Start("Music_MenuGetWhitelisted")
            net.WriteTable(data)
            net.WriteUInt(maxPlyWhitelisted, 8)
        net.Send(ply)
        net.Start("Music_StopSong")
        net.Send(target)
    else
        ply:PrintMessage(HUD_PRINTTALK, "You don't have any music playing.")
    end
end)

net.Receive("Music_MenuWLAddPlayer", function(len,ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        local target = net.ReadEntity()
        local forceAdded = net.ReadBool()
        if StarnixMusic.adminGroups[ply:GetUserGroup()] and forceAdded then -- BYPASS THE CONFIRMATION POPUP AND DIRECTLY ADD THE PLAYER
            if GMusic.isListeningMusic(target) then -- if he's listening a music we stop it.
                local musicObjectTarget = GMusic.GetPlayerMusic(target)
                musicObjectTarget:Stop(target)
            end
            musicObject:AddPlayer(target)
            net.Start("Music_SendSong")
                net.WriteBool(true)
                net.WriteTable(musicObject)
            net.Send(target)
            local data = musicObject:GetWhitelisted()
            net.Start("Music_MenuGetWhitelisted")
                net.WriteTable(data)
            net.Send(ply)
        elseif StarnixMusic.MusicPendingWhitelist[musicObject.id] and StarnixMusic.MusicPendingWhitelist[musicObject.id][target] then -- We check the cooldown to prevent spamming requests.
            if CurTime() < StarnixMusic.MusicPendingWhitelist[musicObject.id][target] then
                ply:PrintMessage(HUD_PRINTTALK, "You have to wait before adding this player again.")
            end
        else
            if StarnixMusic.blockRequestPlayers[ply] then -- We check if the player has desactivated music requests.
                ply:PrintMessage(HUD_PRINTTALK, "This player has desactivated music requests.")
            elseif not GMusic.isListeningMusic(target) then -- We check if the target is listening to music.
                -- Send the confirmation POPUP
                net.Start("Music_WLPopup")
                    net.WriteEntity(ply) -- The name of the player who want to add the target.
                    net.WriteString(musicObject:GetTitle()) -- The name of the music.
                net.Send(target)
                if not StarnixMusic.MusicPendingWhitelist[musicObject.id] then
                    StarnixMusic.MusicPendingWhitelist[musicObject.id] = {}
                end
                StarnixMusic.MusicPendingWhitelist[musicObject.id][target] = CurTime()+StarnixMusic.cooldownSendrequest
                StarnixMusic.ListPlayersPending[target] = true
            else
                ply:PrintMessage(HUD_PRINTTALK, "This player is already listening to music.")
            end
        end
    else    
        ply:PrintMessage(HUD_PRINTTALK, "You don't have any music playing.")
    end
end)

net.Receive("Music_WLPopup", function(len,target)
    local ply = net.ReadEntity()
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        musicObject:AddPlayer(target)
        net.Start("Music_SendSong")
            net.WriteBool(true)
            net.WriteTable(musicObject)
        net.Send(target)
    else
        target:PrintMessage(HUD_PRINTTALK, "The music isn't playing anymore.")
    end
end)

net.Receive("Music_MenuGetAllSongs", function(len, ply)
    local index_startPos = net.ReadUInt(8)
    local index_endPos = net.ReadUInt(8)
    local data = GMusic.GetAll(index_startPos, index_endPos)
    if not data then return end
    net.Start("Music_MenuGetAllSongs")
        net.WriteTable(data)
    net.Send(ply)

end)

net.Receive("Music_MenuChangeSongSettings", function(len, ply)
    local target = net.ReadEntity()
    local editionToMake = net.ReadString()
    local editedValue = net.ReadString()
    if not IsValid(target) or not editionToMake or not editedValue then return end
    local musicObject = GMusic.GetPlayerMusic(target)
    if not musicObject then return end

    if not StarnixMusic.adminGroups[ply:GetUserGroup()] then return end

    if bit.band(editionToMake, tableModifications.title) ~= 0 then
        musicObject:SetTitle(editedValue)
    elseif bit.band(editionToMake, tableModifications.url) ~= 0 then
        if musicObject:SetURL(editedValue) then
            ply:PrintMessage(HUD_PRINTTALK, "The URL has been changed.")
        else
            ply:PrintMessage(HUD_PRINTTALK, "The URL isn't whitelisted.")
        end
    elseif bit.band(editionToMake, tableModifications.loop) ~= 0 then
        local editedValue = tobool(editedValue)
        if editedValue == nil then return end
        musicObject:SetLoop(editedValue)
    elseif bit.band(editionToMake, tableModifications.volume) ~= 0 then
        local editedValue = tonumber(editedValue)
        if not editedValue then return end
        musicObject:SetVolume(editedValue)
    end
end)

net.Receive("Music_MenuForceStopSong", function(len, ply)
    local target = net.ReadEntity()
    if not IsValid(target) then return end
    if not StarnixMusic.adminGroups[ply:GetUserGroup()] then return end
    local musicObject = GMusic.GetPlayerMusic(target)
    if not musicObject then return end
    musicObject:Delete()
end)

net.Receive("Music_WLAcceptation", function(len,ply)
    local accept = net.ReadBool()
    local ownerEntity = net.ReadEntity()
    if not IsEntity(ownerEntity) then return end
    local musicObject = GMusic.GetPlayerMusic(ownerEntity)
    if not musicObject or accept == nil then return end
    if not StarnixMusic.MusicPendingWhitelist[musicObject.id] or not  StarnixMusic.MusicPendingWhitelist[musicObject.id][ply] then return end
    if accept then
        musicObject:AddPlayer(ply)
        net.Start("Music_SendSong")
            net.WriteBool(true)
            net.WriteTable(musicObject)
        net.Send(ply)
        StarnixMusic.MusicPendingWhitelist[musicObject.id][ply] = nil
        StarnixMusic.ListPlayersPending[ply] = nil
    else
        ownerEntity:PrintMessage(HUD_PRINTTALK, "The player has refused your request.")
    end
end)

net.Receive("Music_MenuWLAddAllPlayer", function(len, ply)
    addAllPlayers(ply)
end)

hook.Add("PlayerDisconnected", "Music_PlayerDisconnected", function(ply)
    if StarnixMusic.ListPlayersPending[ply] then
        StarnixMusic.ListPlayersPending[ply] = nil
        for k,v in pairs(StarnixMusic.MusicPendingWhitelist) do
            if v[ply] then
                v[ply] = nil
            end
        end
    end
end)

net.Receive("Music_GetRequestConvar", function(len, ply)
    local isAcceptingRequest = net.ReadBool()
    if isAcceptingRequest == nil then return end
    if not isAcceptingRequest and not StarnixMusic.blockRequestPlayers[ply] then
        StarnixMusic.blockRequestPlayers[ply] = true
    elseif isAcceptingRequest and StarnixMusic.blockRequestPlayers[ply] then 
        StarnixMusic.blockRequestPlayers[ply] = nil
    end
end)