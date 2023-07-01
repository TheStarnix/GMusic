--- Class used to handle all the system behind the music (like timers, etc.) (SERVERSIDE)
-- @module GMusic_SV
/*
        GMusic - A music library for Garry's Mod
    
        GMusic is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation.
    
        GMusic is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
    
        You should have received a copy of the GNU General Public License
        along with GMusic. If not, see <http://www.gnu.org/licenses/>.
*/

_G.GMusic = _G.GMusic or {}
GMusic.__index = GMusic-- If a key cannot be found in an object, it will look in it's metatable's __index metamethod.
GMusic.CurrentAudios = GMusic.CurrentAudios or {} -- @field CurrentAudios Table used to store all music objects. (SERVERSIDE)

GMusic.maxID = 15 -- @field maxID Maximum number of music that can be played at the same time. (SERVERSIDE)

local GMusicCount = GMusicCount or 0

--- Return the binary value of a string.
local function b(str)
	return tonumber(str, 2)
end

-- @table tableModifications Table used to store all the modifications that can be done to a music object. (bitflag) (SERVERSIDE)
local tableModifications = { 
    url         = b"0000000001",
    playing     = b"0000000010",
    pause      = b"0000000100",
    volume      = b"0000001000",
    time        = b"0000010000",
    duration    = b"0000100000",
    whitelisted = b"0001000000",
    loop        = b"0010000000",
    creator      = b"0100000000",
    title       = b"1000000000",

    all         = b"1111111111"
}
local playersListeningMusic = playersListeningMusic or {}

-- Bits needed to send a bitflag of all the modifications
local modifications_blen = math.ceil( math.log(tableModifications.all, 2) )


--- Alloc an id to the requested music.
-- @param creator Player (player that requested the music)
-- @return number (id of the music)
local function registerID(creator)
    if GMusicCount >= GMusic.maxID then
        print("GMusic: Too many music playing at the same time. (max: "..GMusic.maxID..")")
        return nil
    else
        GMusicCount = GMusicCount + 1
        playersListeningMusic[creator] = GMusicCount -- Add the player to the list of players listening music
        return GMusicCount
    end
end

--- Free an id to the requested music ID.
-- @param id number (id of the music)
local function unregisterID(id)
    GMusicCount = GMusicCount - 1
    GMusic.CurrentAudios[id] = nil
end

--- Method that return if a player is listening a music.
-- @param player Player (player to check)
-- @return boolean (true if the player is listening a music, false if not)
function GMusic.isListeningMusic(player)
    return playersListeningMusic[player] ~= nil
end

--- Local function that send a music object to a player.
-- @param self table (music object)
-- @param player Player (player to send the music object)
local function sendMusicToPlayer(self, player)
    if not self or not player then return end -- Object or player not existing
    net.Start("GMusic_SendSong")
        net.WriteTable(self)
    net.Send(player)
end

--- Private Function to add a modification to the music object.
-- @param modification string (template in tableModifications)
-- @param self table (music object)
-- @param receiver Player (player to send the modification)
-- @return boolean (true if the modification has been added, false if not existing/error)
local function AddEdit(modification, self, receiver)
    if not modification or not self then return end -- Object not existing or modification not existing
    modification = bit.bor(self.modifications, modification) -- Add the modification to the modifications (maybe there are modifications in queue)
    
    if #self.whitelisted < 0 or not istable(self.whitelisted) then
        print("GMusic: No one can hear the music. (id: "..self.id..")")
        return false
    else
        if not receiver then -- If no receiver player is specified, we send the modification to all whitelisted players
            receiver = RecipientFilter()
            -- Iterate through the self.whitelisted to add all players to the RecipientFilter
            for k, _ in pairs(self.whitelisted) do
                receiver:AddPlayer(k)
            end
        end 

        net.Start("GMusic_Modify") -- Send the modification to the client
        net.WriteUInt(modification, modifications_blen) -- Send the modification (10 bits because modifications.all is 1111111111)

        --Here, we don't use a for bc it's more efficient to do it like this with a short tableModifications.
        if bit.band(modification, tableModifications.url) ~= 0 then -- If the modification is the URL
            net.WriteString(self.url)
        end
        if bit.band(modification, tableModifications.playing) ~= 0 then -- If the modification is the playing state
            net.WriteBool(self.playing)
        end
        if bit.band(modification, tableModifications.pause) ~= 0 then -- If the modification is the state of the music
            net.WriteBool(self.pause)
        end
        if bit.band(modification, tableModifications.volume) ~= 0 then -- If the modification is the volume
            net.WriteFloat(self.volume)
        end
        if bit.band(modification, tableModifications.time) ~= 0 then -- If the modification is the time
            net.WriteFloat(self.time)
        end
        if bit.band(modification, tableModifications.duration) ~= 0 then -- If the modification is the duration
            net.WriteFloat(self.duration)
        end
        if bit.band(modification, tableModifications.loop) ~= 0 then -- If the modification is the loop state
            net.WriteBool(self.loop)
        end
        if bit.band(modification, tableModifications.creator) ~= 0 then -- If the modification is the creator
            net.WriteString(self.creator)
        end
        if bit.band(modification, tableModifications.title) ~= 0 then -- If the modification is the title
            net.WriteString(self.title)
        end
        net.Send(receiver) -- Send the modification to whitelisted players
        return true
    end
end

--- Public Method to delete the music object.
-- @return boolean (true if the music has been deleted, false if not existing)
function GMusic:Delete()
    if not self then return false end
    self.playing = false
    AddEdit(tableModifications.playing, self, nil)
    for k, _ in pairs(self.whitelisted) do
        playersListeningMusic[k] = nil
    end
    unregisterID(self.id)
    if not self then 
        return true 
    else
        return false
    end
end

--- Local function to verify if a URL is in the whitelist.
-- @param url string (url to check)
-- @return boolean (true if the url is in the whitelist, false if not)
local function isURLInWhitelist(url)
    for k, v in pairs(GMusicConfig.whitelistedLinks) do
        if not url:match("^https://.+") or url:match("^http://.+") then return end
        if string.match(url, k) then
            if GMusicConfig.whitelistedLinksFunctionNeed[v] then
                url = GMusicConfig.whitelistedLinksFunction[v](url)
                if not url then return false end
            end
            return url
        end
    end
    return false
end

-- Public method to return if a player is a staff
-- @param player Player (player to check)
-- @return boolean (true if the player is a staff, false if not)
function GMusic.isStaff(player)
    if not player then return false end
    if GMusicConfig.staff[player:GetUserGroup()] then
        return true
    else
        return false
    end
end

--- Public Function which create the music object.
-- @param url string (url of the music)
-- @param creator Player (player who created the music)
-- @param title string (title of the music)
-- @param loop boolean (true if the music is looped, false if not)
-- @param time number (time of the music)
-- @param permissions table
-- Exceptations permissions:
-- tablePermissions["perm_time"] : true = everyone can. false = only the owner and the staff can.
-- tablePermissions["perm_changeMusic"] : true = everyone can. false = only the owner and the staff can.
-- tablePermissions["perm_changeTitle"] : true = everyone can. false = only the owner and the staff can.
-- tablePermissions["perm_addPlayers"] : true = everyone can. false = only the owner and the staff can.
-- tablePermissions["perm_rmPlayers"] : true = everyone can. false = only the owner and the staff can.
-- tablePermissions["perm_pause"] : true = everyone can. false = only the owner and the staff can.
-- @return table (music object)
function GMusic.create(url, creator, title, loop, time, tablePermissions)
    if tablePermissions == {} then return end
    local urlWhitelist = isURLInWhitelist(url)
    if not urlWhitelist then
        creator:PrintMessage(HUD_PRINTTALK, "GMusic: The URL is not in the whitelist.")
        return
    else
        url = urlWhitelist
    end
    local id = registerID(creator)
    if not id then return end
    if not time then time = 0 end
    local self = setmetatable({
        id = id,
        url = url,
        creator = creator,
        loop = loop,

        playing = true,
        pause = false,
        tablePermissions = tablePermissions,

        volume = 1,
        time = time,
        duration = 0,

        title = title,
        modifications = "0000000000",

        whitelisted = {}, -- Who can hear the music
        numberWhitelisted = 1, -- Number of players who can hear the music
    }, GMusic)
    self.whitelisted[creator] = true
    GMusic.CurrentAudios[id] = self -- Add the object to the list of current music
    sendMusicToPlayer(self, creator)
    return self
end

--- Public Method to get the object ID.
-- @return number
function GMusic:GetID()
    if not self then return end
    return self.id
end

--- Public Method to get the object with the ID.
-- @param id number (id of the object)
-- @return GMusic
function GMusic.GetByID(id)
    if not id then return end
    return GMusic.CurrentAudios[id]
end

--- Public Method to get the object URL.
-- @return string
function GMusic:GetURL()
    if not self then return end
    return self.url
end

--- Public Method to set the object URL (change the music).
-- @param ply player (the player who request the change)
-- @param url string (url of the music)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetURL(ply, url)
    if not self then return end
    if not IsValid(ply) or not IsEntity(ply) or not ply:IsPlayer() then return false end
    -- Check if the player has the permission to do that change
    if not self.tablePermissions["perm_changeMusic"] and self:GetCreator() != ply and not GMusic.isStaff(ply) then return false end
    if not isstring(url) then return false end
    local urlWhitelist = isURLInWhitelist(url)
    if not urlWhitelist then
        return false
    else
        self.url = urlWhitelist
        return AddEdit(tableModifications.url, self)
    end
end

--- Public Method to get the object creator.
-- @return Player (creator of the object)
function GMusic:GetCreator()
    if not self then return end
    return self.creator
end

--- Public Method to get the object Title.
-- @return string (title of the object)
function GMusic:GetTitle()
    if not self then return end
    return self.title
end

--- Public Method to set the object Title.
-- @param ply Player (the one who request the change)
-- @param title string (title of the object)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetTitle(ply, title)
    if not self then return end
    if not IsValid(ply) or not IsEntity(ply) or not ply:IsPlayer() then return false end
    -- Check if the player has the permission to do that change
    if not self.tablePermissions["perm_changeTitle"] and self:GetCreator() != ply and not GMusic.isStaff(ply) then return false end
    if not isstring(title) then return false end
    self.title = title
    return AddEdit(tableModifications.title, self)
end

--- Public Method to set the object creator.
-- @param creator string (creator of the object)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetCreator(creator)
    if not self then return end
    if not isstring(creator) then return false end
    self.creator = creator
    return AddEdit(tableModifications.creator, self)
end

--- Public Method to get the object loop.
-- @return boolean (true if the object is looped, false if not)
function GMusic:GetLoop()
    if not self then return end
    return self.loop
end

--- Public Method to set the object loop.
-- @param loop boolean (true if the object is looped, false if not)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetLoop(loop)
    if not self then return end
    if not isbool(loop) then return false end
    self.loop = loop
    return AddEdit(tableModifications.loop, self)
end

--- Public Method to get the object volume.
-- @return number (volume of the object)
function GMusic:GetVolume()
    if not self then return end
    return self.volume
end 

--- Public Method to set the object volume.
-- @param volume number (volume of the object)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetVolume(volume)
    if not self then return end
    if not isnumber(volume) then return false end
    self.volume = volume
    return AddEdit(tableModifications.volume, self)
end

--- Public Method that return if the music is playing.
-- @return boolean (true if the music is playing, false if not)
function GMusic:IsPlaying()
    if not self then return end
    return self.playing
end

--- Public Method that return if the music is paused.
-- @return boolean (true if the music is paused, false if not)
function GMusic:IsPaused()
    if not self then return end
    return self.pause
end

--- Public Method to set if this music is paused.
-- @param ply Player (player who want to pause the music)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:Pause(ply)
    if not self then return false end
    if not IsValid(ply) or not IsEntity(ply) or not ply:IsPlayer() then return false end
    -- Check if the player has the permission to do that change
    if not self.tablePermissions["perm_pause"] and self:GetCreator() != ply and not GMusic.isStaff(ply) then return false end
    self.pause = !self.pause
    return AddEdit(tableModifications.pause, self)
end

--- Public Method to get the length of the music.
-- @return number (length of the music)
function GMusic:GetDuration()
    if not self then return end
    return self.duration
end


--- Public Method to set the time of the music without updating for all player.
function GMusic:UpdateTime()
    if not self then return end
    local creatorMusic = self:GetCreator()
    if not IsValid(creatorMusic) then return end
    net.Start("GMusic_GetTime")
    net.Send(creatorMusic)
end

net.Receive("GMusic_SendTime", function(len, ply)
    local timeMusic = net.ReadString()
    timeMusic = tonumber(timeMusic)
    if not isnumber(timeMusic) then return end
    local musicObject = GMusic.GetPlayerMusic(ply)
    if not musicObject then return end
    musicObject.time = timeMusic
end)

--- Public Method to get the time of the music.
-- @return number (time of the music)
function GMusic:GetTime()
    if not self then return end
    return self.time
end

--- Public Method to set the time of the music.
-- @param ply Player (player who want to change the time)
-- @param time number (time of the music)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetTime(ply, time)
    if not self then return end
    if not IsValid(ply) or not IsEntity(ply) or not ply:IsPlayer() then return false end
    -- Check if the player has the permission to do that change
    if not self.tablePermissions["perm_time"] and self:GetCreator() != ply and not GMusic.isStaff(ply) then return false end
    if not isnumber(time) then return false end
    self.time = time
    return AddEdit(tableModifications.time, self)
    
end

--- Public Method to add a player to the whitelist.
-- @param ply Player (player to add)
-- @param requester Player (the player who asked the change)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:AddPlayer(ply, requester)
    if not self then return end
    if not IsValid(ply) then return false end
    if not IsValid(requester) or not IsEntity(requester) or not requester:IsPlayer() then return false end
    -- Check if the player has the permission to do that change
    if not self.tablePermissions["perm_addPlayers"] and self:GetCreator() != requester and not GMusic.isStaff(requester) then return false end
    if playersListeningMusic[ply] then 
        if not force then 
            return false 
        else
            local musicObject = GMusic.GetPlayerMusic(ply)
            if musicObject then
                musicObject:RemovePlayer(ply, musicObject:GetCreator())
            end
        end
    end -- If the player is already listening music, return false
    if not self.whitelisted[ply] then
        self.whitelisted[ply] = true
        playersListeningMusic[ply] = self.id -- Add the player to the list of players listening music
        self.numberWhitelisted = self.numberWhitelisted + 1
        sendMusicToPlayer(self, ply)
        return AddEdit(tableModifications.whitelist, self)
    else
        return false
    end
end 

--- Public Method to remove a player from the whitelist.
-- @param ply Player (player to remove)
-- @param requester Player (the player who asked the change)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:RemovePlayer(ply, requested)
    if not self then return end
    if not IsValid(ply) then return false end
    if not IsValid(requester) or not IsEntity(requester) or not requester:IsPlayer() then return false end
    -- Check if the player has the permission to do that change
    if not self.tablePermissions["perm_rmPlayers"] and self:GetCreator() != requester and not GMusic.isStaff(requester) then return false end
    if self.whitelisted then
        self.whitelisted[ply] = nil
        playersListeningMusic[ply] = nil -- Add the player to the list of players listening music
        self.numberWhitelisted = self.numberWhitelisted - 1
        self:Stop(ply)
        return AddEdit(tableModifications.whitelist, self)
    else
        return false
    end
end

--- Public function to get the music object heared by a player.
-- @param ply Player (player to get the music)
-- @return GMusic (music object)
function GMusic.GetPlayerMusic(ply)
    if not IsValid(ply) then return false end
    local idMusic = playersListeningMusic[ply]
    if idMusic then
        return GMusic.GetByID(idMusic)
    else
        return false
    end
end

--- Public function to get the number of players listening the music.
-- @return number (number of players listening the music)
function GMusic:GetNumberWhitelisted()
    if not self then return end
    return self.numberWhitelisted
end

--- Public function to stop the music.
-- @param ply Player (player who stop the music)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:Stop(ply)
    if not self then return end
    if not IsValid(ply) then return false end
    if self:GetCreator() == ply then -- If the player is the creator of the music, we stop the music for everyone.
        return self:Delete()
    else -- If the player is not the creator of the music, we stop the music only for him.
        if not self.whitelisted[ply] then 
            ply:ConCommand("stopsound")
            return false 
        else
            local temporary = self
            temporary.playing = false
            AddEdit(tableModifications.playing, temporary, ply) -- We only send the modification to the player, not all.
            self.whitelisted[ply] = nil
            playersListeningMusic[ply] = nil
            return AddEdit(tableModifications.whitelist, self, nil)
        end
    end
end

--- Public method to get whitelisted players of a music object.
-- @param startPos number (start position of the table) MUST BE A POSITIVE NUMBER & LESS THAN THE END POSITION
-- @param endPos number (end position of the table) MUST BE A POSITIVE NUMBER & MORE THAN THE START POSITION
-- @return table (table of whitelisted players)
function GMusic:GetWhitelisted(startPos, endPos)
    if not self then return end
    -- Default values if the user don't declare them.
    local lengthTable = self.numberWhitelisted
    startPos = startPos or 0
    endPos = endPos or lengthTable

    -- If the user haven't declared a limit, we return the whole table.
    if startPos == 0 and endPos == lengthTable then 
        return self.whitelisted
    end
    -- Else we check if limits are valid.
    if not isnumber(startPos) or not isnumber(endPos) then return false end
    if endPos > lengthTable then endPos = lengthTable end
    if startPos > endPos or startPos < 0 or endPos < 0 or startPos > lengthTable then return false end
    -- We return a table with the limit.
    local tableWhitelisted = {}
    local i = 0
    for k, v in pairs(self.whitelisted) do
        if i >= startPos and i <= endPos then
            tableWhitelisted[k] = true
        elseif i > endPos then
            break
        end
        i = i + 1
    end
    return tableWhitelisted
end

--- Public function to get all music objects.
-- @param startPos number (start position of the table) MUST BE A POSITIVE NUMBER & LESS THAN THE END POSITION
-- @param endPos number (end position of the table) MUST BE A POSITIVE NUMBER & MORE THAN THE START POSITION
-- @return table (table of music objects)
function GMusic.GetAll(startPos, endPos)
    -- Default values if the user don't declare them.
    local lengthTable = #GMusic.CurrentAudios
    startPos = startPos or 0
    endPos = endPos or lengthTable

    -- If the user haven't declared a limit, we return the whole table.
    if startPos == 0 and endPos == lengthTable then 
        return GMusic.CurrentAudios
    end
    -- Else we check if limits are valid.
    if not isnumber(startPos) or not isnumber(endPos) then return false end
    if endPos > lengthTable then endPos = lengthTable end
    if startPos > endPos or startPos < 0 or endPos < 0 or startPos > lengthTable then return false end
    -- We return a table with the limit.
    local tableGMusic = {}
    local i = 0
    for k, v in pairs(GMusic.CurrentAudios) do
        if i >= startPos and i <= endPos then
            table.insert(tableGMusic, v)
        elseif i > endPos then
            break
        end
        i = i + 1
    end
    return tableGMusic
end

-- Function isWhitelisted to check if a player is whitelisted in the specified music object
-- @param ply Player (player to check)
-- @return boolean (true if the player is whitelisted, false if not)
function GMusic:isWhitelisted(ply)
    if not self then return end
    if not IsValid(ply) then return false end
    if self.whitelisted then
        return self.whitelisted[ply]
    else
        return false
    end
end


-- Private function that unregisterID of disconnected players.
hook.Add("PlayerDisconnected", "GMusicLib_PlayerDisconnected", function(ply)
    if GMusic.isListeningMusic(ply) then
        -- If the player is the creator a music object, we delete it, else we remove him from the whitelist.
        local music = GMusic:GetPlayerMusic(ply)
        if not music then return end
        if music:GetCreator() == ply then
            music:Delete()
        else
            music:RemovePlayer(ply, music:GetCreator())
        end
    end
end)