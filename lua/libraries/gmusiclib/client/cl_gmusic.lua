--- Class used to handle all the system behind the music (like timers, etc.) (CLIENTSIDE)
-- @module GMusic_CL
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

_G.GLocalMusic = {}
GLocalMusic.__index = GLocalMusic-- If a key cannot be found in an object, it will look in it's metatable's __index metamethod.
GLocalMusic.CurrentAudio = {} -- @field CurrentAudio (table) (table containing the current music object) (CLIENTSIDE)

--- Function that convert a string to a binary number.
local function b(str)
	return tonumber(str, 2)
end

-- @fields tableModifications (table) (table containing all the modifications that can be done to a music) (CLIENTSIDE)
local tableModifications = { 
    url         = b"0000000001",
    playing     = b"0000000010",
    pause       = b"0000000100",
    volume      = b"0000001000",
    time        = b"0000010000",
    duration    = b"0000100000",
    whitelisted = b"0001000000",
    loop        = b"0010000000",
    creator      = b"0100000000",
    title       = b"1000000000",

    all         = b"1111111111"
}
-- @fields Bits needed to send a bitflag of all the modifications
local modifications_blen = math.ceil( math.log(tableModifications.all, 2) )

--- Function that create the music sound by using the informations given (informations are the music object).
-- @param informations table (table containing all the informations about the music)
-- @return informations (object of the music with audioChannel inside)
local function CreateMusic(informations)
    if not informations then return end
    local stream_owner = informations.creator or LocalPlayer()
    if GLocalMusic.IsCreated() then
        GLocalMusic.Stop() -- Stop the current music if there is one
    end
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
        informations.isBlockstreamed = audioChannel:IsBlockStreamed()

        audioChannel:SetVolume(informations.volume)
        
        if not informations.isBlockstreamed then
            audioChannel:EnableLooping(informations.loop)
        else -- Blockstreamed music can't be looped
            audioChannel:EnableLooping(false)
            LocalPlayer():PrintMessage(HUD_PRINTTALK, "Music is blockstreamed, looping disabled.")
        end
        
        audioChannel:Set3DEnabled(false)
        if informations.pause then
            audioChannel:Pause()
        else
            audioChannel:Play()
        end
    end)
    if informations.time != 0 and not informations.isBlockstreamed then
        timer.Simple(1, function()
            if informations.audioChannel ~= nil then
                local numberTime = tonumber(informations.time)
                if isnumber(numberTime) then
                    informations.audioChannel:SetTime(numberTime, false)
                end
            end
        end)
    end
    return informations


end

-- Function that receive the music.
net.Receive("GMusic_SendSong", function()
    local informations = net.ReadTable()
    if not table.IsEmpty(informations) then
        GLocalMusic.CurrentAudio = CreateMusic(informations)
    end
end)
net.Receive("GMusic_GetTime", function()
    if GLocalMusic.IsValidSong() then
        local timeMusic = GLocalMusic.GetTime()
        if not isnumber(timeMusic) then
            timeMusic = "0"
        else
            timeMusic = tostring(timeMusic)
        end
        net.Start("GMusic_SendTime")
            net.WriteString(timeMusic)
        net.SendToServer()
    end
end)


--- Function that return if the music is created or not by using the GLocalMusic.CurrentAudio variable.
-- @return boolean (true if the music is created, false if not)
function GLocalMusic.IsCreated()
    if GLocalMusic.CurrentAudio and next(GLocalMusic.CurrentAudio) ~= nil then -- Check if the table is empty
        return true
    else
        return false
    end
end

--- Function that return if the music is valid or not by using the GLocalMusic.CurrentAudio.audioChannel variable.
-- @return boolean (true if the music is valid, false if not)
function GLocalMusic.IsValidSong()
    if GLocalMusic.CurrentAudio and GLocalMusic.CurrentAudio.audioChannel and IsValid(GLocalMusic.CurrentAudio.audioChannel) and GLocalMusic.CurrentAudio.audioChannel:IsValid() then -- Check if the table is empty
        return true
    else
        return false
    end
end


--- Function that change the state of the music. (Playing/Stopped=>DETROYED)
-- @return boolean (true if the music has been played/stopped, false if not)
function GLocalMusic.Stop()
    if not GLocalMusic.IsValidSong() then  -- Object not existing
        RunConsoleCommand("stopsound")
        return false 
    else
        GLocalMusic.CurrentAudio.audioChannel:Stop() -- Stop the music
        GLocalMusic.CurrentAudio = nil -- Remove the audioChannel
        return true
    end 
end

--- Function that change the state of the music. (Resume/Pause)
-- @param state boolean (true if the music will be paused, false if it will be resumed)
-- @return boolean (true if the music has been paused/resumed, false if not)
function GLocalMusic.SetPause(state)
    if not GLocalMusic.IsValidSong() then return end -- Object not existing
    GLocalMusic.CurrentAudio.pause = state
    if not GLocalMusic.CurrentAudio.pause and GLocalMusic.CurrentAudio.audioChannel:IsValid() then -- If the music isn't playing and the audioChannel is existing
        GLocalMusic.CurrentAudio.audioChannel:Play() -- Play the music
    elseif GLocalMusic.CurrentAudio.pause and GLocalMusic.CurrentAudio.audioChannel:IsValid() then -- If the music is playing and the audioChannel is existing
        GLocalMusic.CurrentAudio.audioChannel:Pause() -- Stop the music
    else
        return false
    end
    return true
end

--- Function that change the url of the music. (Music will be destroyed and recreated)
-- @param url string (url of the music)
-- @return boolean (true if the url has been changed, false if not)
function GLocalMusic.SetURL(url)
    if not GLocalMusic.IsValidSong() or not url then return false end -- Object not existing
    GLocalMusic.CurrentAudio.url = url
    GLocalMusic.CurrentAudio.audioChannel:Stop() -- Stop the music
    GLocalMusic.CurrentAudio.audioChannel = nil -- Remove the audioChannel
    GLocalMusic.CurrentAudio.audioChannel = CreateMusic(GLocalMusic.CurrentAudio) -- Create a new audioChannel
    return true
end

--- Function that change the volume of the music.
-- @param volume number (volume of the music)
-- @return boolean (true if the volume has been changed, false if not)
function GLocalMusic.SetVolume(volume)
    if not GLocalMusic.IsValidSong() or not volume then return false end -- Object not existing
    GLocalMusic.CurrentAudio.volume = volume
    GLocalMusic.CurrentAudio.audioChannel:SetVolume(volume) -- Set the volume
    return true
end

--- Function that change the loop state of the music.
-- @param loop boolean (true if the music will loop, false if not)
-- @return boolean (true if the loop state has been changed, false if not)
function GLocalMusic.SetLoop(loop)
    if not GLocalMusic.IsValidSong() or not loop then return false end -- Object not existing
    if GLocalMusic.CurrentAudio.isBlockstreamed then
        LocalPlayer():PrintMessage(HUD_PRINTTALK, "Music is blockstreamed, looping disabled.")
        return false
    end
    GLocalMusic.CurrentAudio.loop = loop
    GLocalMusic.CurrentAudio.audioChannel:EnableLooping(loop) -- Set the loop state
    return true
end

--- Function that change the time of the music.
-- @param time number (time of the music in SECONDS)
-- @return boolean (true if the time has been changed, false if not)
function GLocalMusic.SetTime(time)
    if not GLocalMusic.IsValidSong() or not time then return false end -- Object not existing
    if GLocalMusic.CurrentAudio.isBlockstreamed then
        LocalPlayer():PrintMessage(HUD_PRINTTALK, "Music is blockstreamed, time can't be changed.")
        return false
    end
    GLocalMusic.CurrentAudio.time = time
    GLocalMusic.CurrentAudio.audioChannel:SetTime(time) -- Set the time
    return true
end

--- Function that change the creator of the music.
-- @param creator string (creator of the music)
-- @return boolean (true if the creator has been changed, false if not)
function GLocalMusic.SetCreator(creator)
    if not GLocalMusic.IsValidSong() or not creator then return false end -- Object not existing
    GLocalMusic.CurrentAudio.creator = creator
    return true
end

--- Function that get the creator of the music.
-- @return string (creator of the music)
function GLocalMusic.GetCreator()
    if not GLocalMusic.IsValidSong() then return false end -- Object not existing
    return GLocalMusic.CurrentAudio.creator
end

--- Function that change the title of the music.
-- @param title string (title of the music)
-- @return boolean (true if the title has been changed, false if not)
function GLocalMusic.SetTitle(title)
    if not GLocalMusic.IsValidSong() or not title then return false end -- Object not existing
    GLocalMusic.CurrentAudio.title = title
    return true
end

--- Function that get the title of the music.
-- @return string (title of the music)
function GLocalMusic.GetTitle()
    if not GLocalMusic.IsValidSong() then return "" end -- Object not existing
    return GLocalMusic.CurrentAudio.title
end

--- Function that return the current time of the music.
-- @return number (time of the music in SECONDS)
function GLocalMusic.GetTime()
    if not GLocalMusic.IsValidSong() or not GLocalMusic.CurrentAudio.audioChannel then return 0 end -- Object not existing
    return GLocalMusic.CurrentAudio.audioChannel:GetTime()
end

--- Function that return the duration of the music.
-- @return number (duration of the music in SECONDS)
function GLocalMusic.GetDuration()
    if not GLocalMusic.IsValidSong() or not GLocalMusic.CurrentAudio.audioChannel then return 0 end -- Object not existing
    return GLocalMusic.CurrentAudio.audioChannel:GetLength()
end

--- Function that return the current volume of the music.
-- @return number (volume of the music) (0 if the music is not created)
function GLocalMusic.GetVolume()
    if not GLocalMusic.IsValidSong() then return 0 end -- Object not existing
    return GLocalMusic.CurrentAudio.volume
end

--- Function that return the current loop state of the music.
-- @return boolean (true if the music is looping, false if not)
function GLocalMusic.GetLoop()
    if not GLocalMusic.IsValidSong() then return false end -- Object not existing
    return GLocalMusic.CurrentAudio.loop
end

--- Function that return if the music is paused or not.
-- @return boolean (true if the music is paused, false if paused)
function GLocalMusic.IsPaused()
    if not GLocalMusic.IsValidSong() then return false end -- Object not existing
    return GLocalMusic.CurrentAudio.pause
end

--- Private Function to add a modification to the music object.
-- @param modificationsBits number (cf. tableModifications)
-- @return boolean (true if the modification has been added, false if not existing/error)
local function AddEdit(modificationsBits)

    --[[
    Here, we don't use a for bc it's more efficient to do it like this with a short tableModifications.
    --]]
    if bit.band(modificationsBits, tableModifications.url) ~= 0 then -- If the modification is the URL
        local editUrl = net.ReadString()
        GLocalMusic.SetURL(editUrl)
    end
    if bit.band(modificationsBits, tableModifications.playing) ~= 0 then -- If the modification is the playing state
        GLocalMusic.Stop()
    end
    if bit.band(modificationsBits, tableModifications.pause) ~= 0 then -- If the modification is the state of the music
        local editPause = net.ReadBool()
        GLocalMusic.SetPause(editPause)
    end
    if bit.band(modificationsBits, tableModifications.volume) ~= 0  then -- If the modification is the volume
        local editVolume = net.ReadFloat()
        GLocalMusic.SetVolume(editVolume)
    end
    if bit.band(modificationsBits, tableModifications.time) ~= 0 then -- If the modification is the time
        local editTime = net.ReadFloat()
        GLocalMusic.SetTime(editTime)
    end
    if bit.band(modificationsBits, tableModifications.loop) ~= 0  then -- If the modification is the loop state
        local editLoop = net.ReadBool()
        GLocalMusic.SetLoop(editLoop)
    end
    if bit.band(modificationsBits, tableModifications.creator) ~= 0  then -- If the modification is the creator
        local editCreator = net.ReadString()
        GLocalMusic.SetCreator(editCreator)
    end
    if bit.band(modificationsBits, tableModifications.title) ~= 0  then -- If the modification is the title
        local editTitle = net.ReadString()
        GLocalMusic.SetTitle(editTitle)
    end
end

net.Receive("GMusic_Modify", function()
    if not GLocalMusic.CurrentAudio then return end -- Object not existing
    local modificationsBits = net.ReadUInt(modifications_blen)
    if not modificationsBits then return end -- No modifications
    AddEdit(modificationsBits)
end)
