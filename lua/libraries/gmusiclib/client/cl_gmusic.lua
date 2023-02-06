--- Class used to handle all the system behind the music (like timers, etc.) (CLIENTSIDE)
-- @module GLocalMusic
_G.GLocalMusic = {}
GLocalMusic.__index = GLocalMusic-- If a key cannot be found in an object, it will look in it's metatable's __index metamethod.
GLocalMusic.CurrentAudio = {}

local function b(str)
	return tonumber(str, 2)
end

local tableModifications = { 
    url         = b"0000000001",
    playing     = b"0000000010",
    pause       = b"0000000100",
    volume      = b"0000001000",
    time        = b"0000010000",
    duration    = b"0000100000",
    whitelisted = b"0001000000",
    loop        = b"0010000000",
    author      = b"0100000000",
    title       = b"1000000000",

    all         = b"1111111111"
}
-- Bits needed to send a bitflag of all the modifications
local modifications_blen = math.ceil( math.log(tableModifications.all, 2) )

local function CreateMusic(informations)
    if not informations then return end
    local stream_owner = informations.creator or LocalPlayer()
    print("music")
    -- Play the music
    local flags = "noblock noplay"
    sound.PlayURL(informations.url, flags, function(audioChannel, errorID, errorName)
        if errorID then
            LocalPlayer():PrintMessage(HUD_PRINTTALK, "Error playing music: " .. errorName)
            return
        end

        --[[
        SETTING UP THE AUDIOCHANNEL
        --]]
        informations.audioChannel = audioChannel
        informations.length = audioChannel:GetLength()
        informations.fileName = audioChannel:GetFileName()

        audioChannel:SetVolume(informations.volume)
        audioChannel:EnableLooping(informations.loop)
        audioChannel:EnableLooping(informations.loop)
        audioChannel:Set3DEnabled(false)
        audioChannel:Play()
        
    end)
    return informations

end

-- Function that receive the music.
net.Receive("GMusic_SendSong", function()
    local informations = net.ReadTable()
    print("Reçu OK")
    if not table.IsEmpty(informations) then
        print("Pas infos")
        GLocalMusic.CurrentAudio = CreateMusic(informations)
    end
end)  


--- Function that change the state of the music. (Playing/Stopped=>DETROYED)
-- @param self GLocalMusic (object of the music)
-- @return boolean (true if the music has been played/stopped, false if not)
function GLocalMusic:Stop(self)
    print("Appelé")
    if not self or not self.audioChannel or not self.audioChannel:IsValid() then  -- Object not existing
        RunConsoleCommand("stopsound")
        return false 
    else
        self.audioChannel:Stop() -- Stop the music
        print("Stop")
        return true
    end 
end

--- Function that change the state of the music. (Resume/Pause)
-- @param self GLocalMusic (object of the music)
-- @param state boolean (true if the music will be paused, false if it will be resumed)
-- @return boolean (true if the music has been paused/resumed, false if not)
function GLocalMusic:SetPause(self, state)
    if not self or not self.audioChannel then return end -- Object not existing
    if not self.pause and self.audioChannel:IsValid() then -- If the music isn't playing and the audioChannel is existing
        self.audioChannel:Play() -- Play the music
        print("Play")
    elseif self.pause and self.audioChannel:IsValid() then -- If the music is playing and the audioChannel is existing
        self.audioChannel:Pause() -- Stop the music
        print("Stop")
    else
        print("Error")
        return false
    end
    return true
end

--- Function that change the url of the music. (Music will be destroyed and recreated)
-- @param self GLocalMusic (object of the music)
-- @param url string (url of the music)
-- @return boolean (true if the url has been changed, false if not)
function GLocalMusic:SetURL(self, url)
    if not self or not self.audioChannel or not url then return false end -- Object not existing
    self.url = url
    self.audioChannel:Stop() -- Stop the music
    self.audioChannel = nil -- Remove the audioChannel
    self.audioChannel = CreateMusic(self) -- Create a new audioChannel
    return true
end

--- Function that change the volume of the music.
-- @param self GLocalMusic (object of the music)
-- @param volume number (volume of the music)
-- @return boolean (true if the volume has been changed, false if not)
function GLocalMusic:SetVolume(self, volume)
    if not self or not self.audioChannel or not volume then return false end -- Object not existing
    print("Volume: " .. volume)
    self.volume = volume
    self.audioChannel:SetVolume(volume) -- Set the volume
    return true
end

--- Function that change the loop state of the music.
-- @param self GLocalMusic (object of the music)
-- @param loop boolean (true if the music will loop, false if not)
-- @return boolean (true if the loop state has been changed, false if not)
function GLocalMusic:SetLoop(self, loop)
    if not self or not self.audioChannel or not loop then return false end -- Object not existing
    self.loop = loop
    self.audioChannel:EnableLooping(loop) -- Set the loop state
    return true
end

--- Function that change the time of the music.
-- @param self GLocalMusic (object of the music)
-- @param time number (time of the music in SECONDS)
-- @return boolean (true if the time has been changed, false if not)
function GLocalMusic:SetTime(self, time)
    if not self or not self.audioChannel or not time then return false end -- Object not existing
    self.time = time
    self.audioChannel:SetTime(time) -- Set the time
    return true
end

--- Function that change the author of the music.
-- @param self GLocalMusic (object of the music)
-- @param author string (author of the music)
-- @return boolean (true if the author has been changed, false if not)
function GLocalMusic:SetAuthor(self, author)
    if not self or not author then return false end -- Object not existing
    self.author = author
    return true
end

--- Function that change the title of the music.
-- @param self GLocalMusic (object of the music)
-- @param title string (title of the music)
-- @return boolean (true if the title has been changed, false if not)
function GLocalMusic:SetTitle(self, title)
    if not self or not title then return false end -- Object not existing
    self.title = title
    return true
end

--- Private Function to add a modification to the music object.
-- @param self GLocalMusic (object of the music)
-- @param modificationBits number (cf. tableModifications)
-- @return boolean (true if the modification has been added, false if not existing/error)
local function AddEdit(self, modificationsBits)

    --[[
    Here, we don't use a for bc it's more efficient to do it like this with a short tableModifications.
    --]]
    if bit.band(modificationsBits, tableModifications.url) ~= 0 then -- If the modification is the URL
        self.url = net.ReadString()
        GLocalMusic:SetURL(self,self.url)
    end
    if bit.band(modificationsBits, tableModifications.playing) ~= 0 then -- If the modification is the playing state
        print("Playing modification")
        self.playing = net.ReadBool()
        GLocalMusic:Stop(self)
    end
    if bit.band(modificationsBits, tableModifications.pause) ~= 0 then -- If the modification is the state of the music
        print("PAUSE")
        self.pause = net.ReadBool()
        GLocalMusic:SetPause(self,self.pause)
    end
    if bit.band(modificationsBits, tableModifications.volume) ~= 0  then -- If the modification is the volume
        print("VOLUME")
        self.volume = net.ReadFloat()
        GLocalMusic:SetVolume(self,self.volume)
    end
    if bit.band(modificationsBits, tableModifications.time) ~= 0 then -- If the modification is the time
        print("TIME")
        self.time = net.ReadFloat()
        GLocalMusic:SetTime(self,self.time)
    end
    if bit.band(modificationsBits, tableModifications.loop) ~= 0  then -- If the modification is the loop state
        self.loop = net.ReadBool()
        GLocalMusic:SetLoop(self,self.loop)
    end
    if bit.band(modificationsBits, tableModifications.author) ~= 0  then -- If the modification is the author
        self.author = net.ReadString()
        GLocalMusic:SetAuthor(self,self.author)
    end
    if bit.band(modificationsBits, tableModifications.title) ~= 0  then -- If the modification is the title
        self.title = net.ReadString()
        GLocalMusic:SetTitle(self,self.title)
    end
end

net.Receive("GMusic_Modify", function()
    if not GLocalMusic.CurrentAudio then return end -- Object not existing
    local modificationsBits = net.ReadUInt(modifications_blen)
    if not modificationsBits then return end -- No modifications
    AddEdit(GLocalMusic.CurrentAudio, modificationsBits)
end)
