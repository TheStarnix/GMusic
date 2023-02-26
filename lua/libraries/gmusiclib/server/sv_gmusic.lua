--- Class used to handle all the system behind the music (like timers, etc.) (SERVERSIDE)
-- @module GMusic
_G.GMusic = {}
GMusic.__index = GMusic-- If a key cannot be found in an object, it will look in it's metatable's __index metamethod.
GMusic.CurrentAudios = {} -- @field CurrentAudios Table used to store all music objects. (SERVERSIDE)

GMusic.maxID = 5 -- @field maxID Maximum number of music that can be played at the same time. (SERVERSIDE)
local GMusicCount = 0

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
    author      = b"0100000000",
    title       = b"1000000000",

    all         = b"1111111111"
}
local playersListeningMusic = {}

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

--- Local function that check if a player is listening a music.
-- @param player Player (player to check)
-- @return boolean (true if the player is listening a music, false if not)
local function isListeningMusic(player)
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
            print("URL OK")
            print(tableModifications.url)
            net.WriteString(self.url)
        end
        if bit.band(modification, tableModifications.playing) ~= 0 then -- If the modification is the playing state
            print("PLAYING OK")
            print(tableModifications.playing)
            net.WriteBool(self.playing)
        end
        if bit.band(modification, tableModifications.pause) ~= 0 then -- If the modification is the state of the music
            print("PAUSE OK")
            print(tableModifications.pause)
            net.WriteBool(self.pause)
        end
        if bit.band(modification, tableModifications.volume) ~= 0 then -- If the modification is the volume
            print("VOLUME OK")
            print(tableModifications.volume)
            net.WriteFloat(self.volume)
        end
        if bit.band(modification, tableModifications.time) ~= 0 then -- If the modification is the time
            print("TIME OK")
            print(tableModifications.time)
            net.WriteFloat(self.time)
        end
        if bit.band(modification, tableModifications.duration) ~= 0 then -- If the modification is the duration
            print("DURATION OK")
            print(tableModifications.duration)
            net.WriteFloat(self.duration)
        end
        if bit.band(modification, tableModifications.loop) ~= 0 then -- If the modification is the loop state
            print("LOOP OK")
            print(tableModifications.loop)
            net.WriteBool(self.loop)
        end
        if bit.band(modification, tableModifications.author) ~= 0 then -- If the modification is the author
            print("AUTHOR OK")
            net.WriteString(self.author)
        end
        if bit.band(modification, tableModifications.title) ~= 0 then -- If the modification is the title
            print("TITLE OK")
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
    PrintTable(self)
    if self.playing then
        self.playing = false
        AddEdit(tableModifications.playing, self, nil)
    end
    unregisterID(self.id)
    return true -- Return true if the music has been deleted
end

--- Public Function which create the music object.
-- @param url string (url of the music)
-- @param creator Player (player who created the music)
-- @param title string (title of the music)
-- @param author string (author of the music)
-- @param loop boolean (true if the music is looped, false if not)
-- @return table (music object)
function GMusic.create(url, creator, title, author, loop)
    local id = registerID(creator)
    if not id then return end
    local self = setmetatable({
        id = id,
        url = url,
        creator = creator,
        loop = loop,

        playing = true,
        pause = false,

        volume = 1,
        time = 0,
        duration = 0,

        title = title,
        author = author,
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
    return self.url
end

--- Public Method to set the object URL (change the music).
-- @param url string (url of the music)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetURL(url)
    if not isstring(url) then return false end
    --TODO: Check if the URL is inside a whitelist AND complete the function.
end

--- Public Method to get the object creator.
-- @return Player (creator of the object)
function GMusic:GetCreator()
    return self.creator
end

--- Public Method to get the object Title.
-- @return string (title of the object)
function GMusic:GetTitle()
    return self.title
end

--- Public Method to set the object Title.
-- @param title string (title of the object)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetTitle(title)
    if not isstring(title) then return false end
    self.title = title
    return AddEdit(tableModifications.title, self)
end

--- Public Method to get the object author.
-- @return string (author of the object)
function GMusic:GetAuthor()
    return self.author
end

--- Public Method to set the object author.
-- @param author string (author of the object)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetAuthor(author)
    if not isstring(author) then return false end
    self.author = author
    return AddEdit(tableModifications.author, self)
end

--- Public Method to get the object loop.
-- @return boolean (true if the object is looped, false if not)
function GMusic:GetLoop()
    return self.loop
end

--- Public Method to set the object loop.
-- @param loop boolean (true if the object is looped, false if not)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetLoop(loop)
    if not isbool(loop) then return false end
    self.loop = loop
    return AddEdit(tableModifications.loop, self)
end

--- Public Method to get the object volume.
-- @return number (volume of the object)
function GMusic:GetVolume()
    return self.volume
end 

--- Public Method to set the object volume.
-- @param volume number (volume of the object)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetVolume(volume)
    if not isnumber(volume) then return false end
    self.volume = volume
    return AddEdit(tableModifications.volume, self)
end

--- Public Method that return if the music is playing.
-- @return boolean (true if the music is playing, false if not)
function GMusic:IsPlaying()
    return self.playing
end

--- Public Method that return if the music is paused.
-- @return boolean (true if the music is paused, false if not)
function GMusic:IsPaused()
    return self.pause
end

--- Public Method to set if this music is paused.
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:Pause()
    if not self then return false end
    self.pause = !self.pause
    return AddEdit(tableModifications.pause, self)
end

--- Public Method to get the length of the music.
-- @return number (length of the music)
function GMusic:GetDuration()
    return self.duration
end


--- Public Method to get the time of the music.
-- @return number (time of the music)
function GMusic:GetTime()
    return self.time
end

--- Public Method to set the time of the music.
-- @param time number (time of the music)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:SetTime(time)
    if not isnumber(time) then return false end
    self.time = time
    return AddEdit(tableModifications.time, self)
end

--- Public Method to add a player to the whitelist.
-- @param ply Player (player to add)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:AddPlayer(ply)
    if not IsValid(ply) then return false end
    if not self.whitelisted[ply] then
        self.whitelisted[ply] = true
        playersListeningMusic[ply] = self.id -- Add the player to the list of players listening music
        self.numberWhitelisted = self.numberWhitelisted + 1
        return AddEdit(tableModifications.whitelist, self)
    else
        return false
    end
end 

--- Public Method to remove a player from the whitelist.
-- @param ply Player (player to remove)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:RemovePlayer(ply)
    if not IsValid(ply) then return false end
    if self.whitelisted then
        self.whitelisted[ply] = nil
        playersListeningMusic[ply] = nil -- Add the player to the list of players listening music
        self.numberWhitelisted = self.numberWhitelisted - 1
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
    return self.numberWhitelisted
end

--- Public function to stop the music.
-- @param playing boolean (true if the music is playing, false if not)
-- @return boolean (true if the modification has been added, false if not existing/error)
function GMusic:Stop(ply)
    if self:GetCreator() == ply then -- If the player is the creator of the music, we stop the music for everyone.
        return self:Delete()
    else -- If the player is not the creator of the music, we stop the music only for him.
        local temporary = self
        temporary.playing = false
        AddEdit(tableModifications.playing, temporary, ply) -- We only send the modification to the player, not all.
        self.whitelisted[ply] = nil
        return AddEdit(tableModifications.whitelist, self, nil)
    end
end

--- Public method to get whitelisted players of a music object.
-- @param startPos number (start position of the table) MUST BE A POSITIVE NUMBER & LESS THAN THE END POSITION
-- @param endPos number (end position of the table) MUST BE A POSITIVE NUMBER & MORE THAN THE START POSITION
-- @return table (table of whitelisted players)
function GMusic:GetWhitelisted(startPos, endPos)
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
    if startPos > endPos or startPos < 0 or endPos < 0 or startPos > lengthTable then return false end
    -- We return a table with the limit.
    local tableWhitelisted = {}
    local i = 0
    for k, v in pairs(self.whitelisted) do
        if i >= startPos and i <= endPos then
            table.insert(tableWhitelisted, k)
        elseif i > endPos then
            break
        end
        i = i + 1
    end
    return tableWhitelisted
end

--- Private function that unregisterID of disconnected players.
hook.Add("PlayerDisconnected", "GMusicLib_PlayerDisconnected", function(ply)
    if isListeningMusic(ply) then
        -- If the player is the creator a music object, we delete it, else we remove him from the whitelist.
        local music = GMusic:GetPlayerMusic(ply)
        if not music then return end
        if music:GetCreator() == ply then
            music:Delete()
        else
            music:RemovePlayer(ply)
        end
    end
end)