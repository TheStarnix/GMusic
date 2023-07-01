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
            local isValidRequest = musicObject:AddPlayer(v,ply)
            if isValidRequest == false then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.noperms"])
                return false 
            end
        end
    end
end

--[[-------------------------------------------------------------------------
Function called when a player want to create a music with the MENU.
---------------------------------------------------------------------------]]
net.Receive("Music_SendSong", function(len, ply)
    local url = net.ReadString() -- We store the url of the music.
    local name = net.ReadString() -- We store the name of the music.
    local tablePermissions = {}
    local looping = net.ReadBool() -- We store the choice of the player. Here, if the player want to loop the music or not.
    tablePermissions["perm_time"] = net.ReadBool()
    tablePermissions["perm_changeMusic"] = net.ReadBool()
    tablePermissions["perm_changeTitle"] = net.ReadBool()
    tablePermissions["perm_addPlayers"] = net.ReadBool()
    tablePermissions["perm_rmPlayers"] = net.ReadBool()
    tablePermissions["perm_pause"] = net.ReadBool()
    local isEveryoneAdded = net.ReadBool() -- We store the choice of the player. Here, if the player want to add all players.
    local musicObject = GMusic.GetPlayerMusic(ply)
    if isEveryoneAdded and not StarnixMusic.adminGroups[ply:GetUserGroup()] then
        isEveryoneAdded = false
    end
    if musicObject then
        if musicObject:GetCreator() == ply then
            if musicObject:GetTitle() != name then
                local validRequest = musicObject:SetTitle(ply, name)
                if validRequest == false then
                    ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.noperms"])
                end
            end
            if musicObject:GetLoop() != looping then
                musicObject:SetLoop(looping)
            end
            if musicObject:GetURL() != url then
                local validRequest = musicObject:SetURL(ply, url)
                if validRequest == false then
                    ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.noperms"])
                end
            end
        else
            musicObject:Stop(ply)
            GMusic.create(url, ply, name, looping, 0, tablePermissions)
        end

    else
        if not url or not name or not ply then return end
        GMusic.create(url, ply, name, looping, 0, canEveryonePause)
    end

    if isEveryoneAdded then
        addAllPlayers(ply)
    end
end)

net.Receive("Music_StopSong", function(len, ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        musicObject:Stop(ply)
    else
        ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
    end
end)

net.Receive("Music_PauseSong", function(len, ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        musicObject:Pause(ply)
    else
        ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
    end
end)

net.Receive("Music_ChangeVolume", function(len, ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        local volume = net.ReadFloat()
        musicObject:SetVolume(volume)
    else
        ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
    end
end)

net.Receive("Music_ChangeTime", function(len, ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        local time = net.ReadFloat()
        musicObject:SetTime(ply, time)
    else
        ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
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
            net.WriteBool(false)  -- We send false to tell the client that we sent a table of players.
            net.WriteTable(data)
            net.WriteUInt(maxPlyWhitelisted, 8)
        net.Send(ply)
    else
        ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
    end
end) 

net.Receive("Music_MenuWLRemovePlayer", function(len,ply)
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        local target = net.ReadEntity()
        musicObject:RemovePlayer(target, ply)
        local data = musicObject:GetWhitelisted()
        local maxPlyWhitelisted = musicObject:GetNumberWhitelisted()
        net.Start("Music_MenuGetWhitelisted")
            net.WriteBool(false)  -- We send false to tell the client that we sent a table of players.
            net.WriteTable(data)
            net.WriteUInt(maxPlyWhitelisted, 8)
        net.Send(ply)
    else
        ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
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
            musicObject:AddPlayer(target, ply)
            local data = musicObject:GetWhitelisted()
            net.Start("Music_MenuGetWhitelisted")
                net.WriteBool(true) -- We send true to tell the client that we only added one player.
                net.WriteEntity(target)
            net.Send(ply)
        elseif StarnixMusic.MusicPendingWhitelist[musicObject.id] and StarnixMusic.MusicPendingWhitelist[musicObject.id][target] then -- We check the cooldown to prevent spamming requests.
            if CurTime() < StarnixMusic.MusicPendingWhitelist[musicObject.id][target] then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.wait"])
            end
        else
            if not target then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.notconnected"])
                return ""
            elseif target == ply then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.canturself"])
                return ""
            elseif StarnixMusic.ListPlayersPending[target] or (StarnixMusic.MusicPendingWhitelist[musicObject.id] and StarnixMusic.MusicPendingWhitelist[musicObject.id][target]) then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.alreadypending"])
                return ""
            elseif musicObject:isWhitelisted(target) then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.already"])
                return ""
            elseif StarnixMusic.blockRequestPlayers[target] then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.notaccepted"])
                return ""
            else
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
            end
        end
    else    
        ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
    end
end)

net.Receive("Music_WLPopup", function(len,target)
    local ply = net.ReadEntity()
    local musicObject = GMusic.GetPlayerMusic(ply)
    if musicObject then
        musicObject:AddPlayer(target, musicObject:GetCreator())
    else
        target:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.play.notplaying"])
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
        local validRequest = musicObject:SetTitle(ply, editedValue)
        if validRequest == false then
            ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.noperms"])
        end

    elseif bit.band(editionToMake, tableModifications.url) ~= 0 then
        if musicObject:SetURL(ply, editedValue) then
            ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.change.url"])
        else
            ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.change.url.notwl"])
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
        musicObject:AddPlayer(ply, musicObject:GetCreator())
        StarnixMusic.MusicPendingWhitelist[musicObject.id][ply] = nil
        StarnixMusic.ListPlayersPending[ply] = nil
    else
        ownerEntity:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.refused"])
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

hook.Add( "PlayerSay", "Music_PendingMusic", function( ply, text )
	if (string.sub(text, 1, 6) == "!music") then
        if(text == "!music") then
            ply:PrintMessage(HUD_PRINTTALK, "== GMUSIC ==")
            ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.cmd.available"])
            ply:PrintMessage(HUD_PRINTTALK, "!music stop:" .. StarnixMusic.Language["music.cmd.stop"])
            ply:PrintMessage(HUD_PRINTTALK, "!music start {url}:" .. StarnixMusic.Language["music.cmd.start"])
            ply:PrintMessage(HUD_PRINTTALK, "!music pause:" .. StarnixMusic.Language["music.cmd.pause"])
            ply:PrintMessage(HUD_PRINTTALK, "!music volume {0-3}:" .. StarnixMusic.Language["music.cmd.volume"])
            ply:PrintMessage(HUD_PRINTTALK, "!music loop {true/false}:" .. StarnixMusic.Language["music.cmd.loop"])
            ply:PrintMessage(HUD_PRINTTALK, "!music title {title}:" .. StarnixMusic.Language["music.cmd.title"])
            ply:PrintMessage(HUD_PRINTTALK, "!music whitelist {pseudo}:" .. StarnixMusic.Language["music.cmd.wl"])
            ply:PrintMessage(HUD_PRINTTALK, "(ADMIN) !music startall {url}:" .. StarnixMusic.Language["music.cmd.startall"])
            ply:PrintMessage(HUD_PRINTTALK, "(ADMIN) !music startallnoperms {url}:" .. StarnixMusic.Language["music.cmd.startallnoperms"])
            ply:PrintMessage(HUD_PRINTTALK, "(ADMIN) !music startnoperms {url}:" .. StarnixMusic.Language["music.cmd.startnoperms"])
            ply:PrintMessage(HUD_PRINTTALK, "== GMUSIC ==")
        elseif (text == "!music stop") then
            local musicObject = GMusic.GetPlayerMusic(ply)
            if musicObject then
                musicObject:Delete()
            else
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
            end
        elseif(text == "!music pause") then
            local musicObject = GMusic.GetPlayerMusic(ply)
            if musicObject then
                musicObject:Pause(ply)
            else
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
            end
        elseif (string.sub(text, 1, 22) == "!music startallnoperms") then
            if not ply:IsAdmin() then 
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.noperms"])
                return "" 
            end
            local url = string.sub(text, 24)
            if url == "" then return "" end
            local musicObject = GMusic.GetPlayerMusic(v)
            if musicObject then
                musicObject:Delete()
            end
            local musicObject = GMusic.create(url, ply, "", true, 0, false)
            if not musicObject then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.change.url.notwl"])
            else
                addAllPlayers(ply)                
            end
        elseif (string.sub(text, 1, 19) == "!music startnoperms") then
            if not ply:IsAdmin() then return "" end
            local url = string.sub(text, 21)
            if url == "" then return "" end
            local musicObject = GMusic.GetPlayerMusic(v)
            if musicObject then
                musicObject:Delete()
            end
            local musicObject = GMusic.create(url, ply, "", true, 0, false)
            if not musicObject then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.change.url.notwl"])
            end
        elseif (string.sub(text, 1, 15) == "!music startall") then
            if not ply:IsAdmin() then 
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.noperms"])
                return "" 
            end
            local url = string.sub(text, 17)
            if not url or url == "" then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.change.nourl"])
                return "" 
            end
            local musicObject = GMusic.GetPlayerMusic(v)
            if musicObject then
                musicObject:Delete()
            end
            local musicObject = GMusic.create(url, ply, "", true, 0, true)
            if not musicObject then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.change.url.notwl"])
            else
                addAllPlayers(ply)                
            end
        elseif (string.sub(text, 1, 12) == "!music start") then
            local url = string.sub(text, 14)
            if url == "" then return "" end
            local musicObject = GMusic.GetPlayerMusic(ply)
            if musicObject then
                musicObject:Delete()
            end
            
            local musicObject = GMusic.create(url, ply, "", true, 0, true)
            if not musicObject then
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.change.url.notwl"])
            end
        elseif (text == "!music pause") then
            local musicObject = GMusic.GetPlayerMusic(ply)
            if musicObject then
                musicObject:Pause()
            else
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
            end
        elseif (string.sub(text, 1, 13) == "!music volume") then
            local volume = tonumber(string.sub(text, 15))
            if not volume then return "" end
            local musicObject = GMusic.GetPlayerMusic(ply)
            if musicObject then
                musicObject:SetVolume(volume)
            else
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
            end
        elseif (string.sub(text, 1, 11) == "!music loop") then
            local loop = tobool(string.sub(text, 13))

            if loop == nil then return "" end
            local musicObject = GMusic.GetPlayerMusic(ply)
            if musicObject then
                musicObject:SetLoop(loop)
            else
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
            end
        elseif (string.sub(text, 1, 12) == "!music title") then
            local title = string.sub(text, 14)
            if title == "" then return "" end
            local musicObject = GMusic.GetPlayerMusic(ply)
            if musicObject then
                local validrequest = musicObject:SetTitle(ply, title)
                if validRequest == false then
                    ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.noperms"])
                end
            else
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
            end
        elseif (string.sub(text, 1, 16) == "!music whitelist") then
            local pseudo = string.sub(text, 18)
            if pseudo == "" then return "" end
            local musicObject = GMusic.GetPlayerMusic(ply)
            if musicObject then
                local target = nil
                for k,v in pairs(player.GetAll()) do
                    if string.find(string.lower(v:Nick()), string.lower(pseudo)) then
                        target = v
                        break
                    end
                end
                if not target then
                    ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.notconnected"])
                    return ""
                elseif target == ply then
                    ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.canturself"])
                    return ""
                elseif StarnixMusic.ListPlayersPending[target] or (StarnixMusic.MusicPendingWhitelist[musicObject.id] and StarnixMusic.MusicPendingWhitelist[musicObject.id][target]) then
                    ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.alreadypending"])
                    return ""
                elseif musicObject:isWhitelisted(target) then
                    ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.already"])
                    return ""
                elseif StarnixMusic.blockRequestPlayers[target] then
                    ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.notaccepted"])
                    return ""
                else
                    net.Start("Music_WLPopup")
                        net.WriteEntity(ply) -- The name of the player who want to add the target.
                        net.WriteString(musicObject:GetTitle()) -- The name of the music.
                    net.Send(target)
                    if not StarnixMusic.MusicPendingWhitelist[musicObject.id] then
                        StarnixMusic.MusicPendingWhitelist[musicObject.id] = {}
                    end
                    StarnixMusic.MusicPendingWhitelist[musicObject.id][target] = CurTime()+StarnixMusic.cooldownSendrequest
                    StarnixMusic.ListPlayersPending[target] = true
                    ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.wl.sent"])
                end

            else
                ply:PrintMessage(HUD_PRINTTALK, StarnixMusic.Language["music.handle.nomusic"])
            end
        end
        return ""
	end

end )