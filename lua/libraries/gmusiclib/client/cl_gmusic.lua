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
    paused      = b"0000000100",
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
        
        PrintTable(informations)
    end)
    return informations

end

-- Function that receive the music.
net.Receive("GLocalMusic_SendSong", function()
    local informations = net.ReadTable()
    if not table.IsEmpty(informations) then
        GLocalMusic.CurrentAudio = CreateMusic(informations)
    end
end)  

--- Private Function to add a modification to the music object.
-- @param modification string (template in tableModifications)
-- @return boolean (true if the modification has been added, false if not existing/error)
local function AddEdit(modificationsBits, self)

    --[[
    Here, we don't use a for bc it's more efficient to do it like this with a short tableModifications.
    --]]
    if bit.band(modificationsBits, tableModifications.url) ~= 0 then -- If the modification is the URL
        self.url = net.ReadString()
    end
    if bit.band(modificationsBits, tableModifications.playing) ~= 0 then -- If the modification is the playing state
        print("Playing modification")
        self.playing = net.ReadBool()
        if self.playing and self.audioChannel and self.audioChannel:IsValid() then -- If the music is playing and the audioChannel is existing
            print("Playing music")
            self.audioChannel:Play() -- Play the music
        elseif not self.playing and self.audioChannel and self.audioChannel:IsValid() then -- If the music is not playing and the audioChannel is existing
            print("Stopping music")
            self.audioChannel:Stop() -- Stop the music
        end
    end
    if bit.band(modificationsBits, tableModifications.paused) ~= 0 then -- If the modification is the state of the music
        print("PAUSE")
        self.paused = net.ReadBool()
        if self.paused and self.audioChannel and self.audioChannel:IsValid() then -- If the music is paused and the audioChannel is existing
            self.audioChannel:Pause() -- Pause the music
        elseif not self.paused and self.audioChannel and self.audioChannel:IsValid() then -- If the music is not paused and the audioChannel is existing
            self.audioChannel:Play() -- Play the music
        end
    end
    if bit.band(modificationsBits, tableModifications.volume) ~= 0  then -- If the modification is the volume
        print("VOLUME")
        self.volume = net.ReadFloat()
        if self.audioChannel and self.audioChannel:IsValid() then -- If the audioChannel is existing
            self.audioChannel:SetVolume(self.volume) -- Set the volume
        end
    end
    if bit.band(modificationsBits, tableModifications.time) ~= 0 then -- If the modification is the time
        print("TIME")
        self.time = net.ReadFloat()
        if self.audioChannel and self.audioChannel:IsValid() then -- If the audioChannel is existing
            self.audioChannel:SetTime(self.time) -- Set the time
        end
    end
    if bit.band(modificationsBits, tableModifications.loop) ~= 0  then -- If the modification is the loop state
        self.loop = net.ReadBool()
        if self.audioChannel and self.audioChannel:IsValid() then -- If the audioChannel is existing
            self.audioChannel:EnableLooping(self.loop) -- Set the loop state
        end
    end
    if bit.band(modificationsBits, tableModifications.author) ~= 0  then -- If the modification is the author
        self.author = net.ReadString()
    end
    if bit.band(modificationsBits, tableModifications.title) ~= 0  then -- If the modification is the title
        self.title = net.ReadString()
    end
end

net.Receive("GLocalMusic_Modify", function()
    print(GLocalMusic.CurrentAudio)
    if not GLocalMusic.CurrentAudio then return end -- Object not existing
    local modificationsBits = net.ReadUInt(modifications_blen)
    if not modificationsBits then return end -- No modifications
    AddEdit(modificationsBits, GLocalMusic.CurrentAudio)
end)