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

--[[-------------------------------------------------------------------------
This function indicates if the player music's is rejected or not.
True => accepted
False => rejected (URL not whitelisted)
---------------------------------------------------------------------------]]
net.Receive("Music_SendSong", function()
	local validation = net.ReadBool() -- true if the URL is whitelisted, false if not.
	if validation then -- If the URL is whitelisted, we can show the music player.
        local musicData = net.ReadTable() -- We get the music informations
        StarnixMusic.musicInformations = musicData-- We save the music informations in a global variable.
		if IsValid(frame) then frame:Close() end -- If not already closed, we close the music menu.
		LocalPlayer():PrintMessage(HUD_PRINTTALK, language.GetPhrase("music.musicLaunched"))
        StarnixMusic.IsPlaying = true
        StarnixMusic.drawHUD()
	else
		LocalPlayer():PrintMessage(HUD_PRINTTALK, language.GetPhrase("music.urlNotWhitelisted"))
	end
end)

--[[-------------------------------------------------------------------------
This function is called when the player stops the music.
---------------------------------------------------------------------------]]
net.Receive("Music_StopSong", function()
    LocalPlayer():PrintMessage(HUD_PRINTTALK, language.GetPhrase("music.musicStopped"))
    StarnixMusic.IsPlaying = false
    StarnixMusic.drawHUD()
end)

--[[-------------------------------------------------------------------------
This function is called when the player pauses the music.
---------------------------------------------------------------------------]]
net.Receive("Music_PauseSong", function()
    LocalPlayer():PrintMessage(HUD_PRINTTALK, language.GetPhrase("music.musicPaused"))
end)

net.Receive("Music_GetMusicTime", function()
    local timeMusic = GLocalMusic.GetTime()
    if GLocalMusic.IsValidSong() and timeMusic then -- If the music is playing, we send the time to the server.
        net.Start("Music_GetMusicTime")
            net.WriteBool(true)
            net.WriteFloat(timeMusic)
        net.SendToServer()
    else -- If the music is not playing, we send false and no float to the server.
        net.Start("Music_GetMusicTime")
            net.WriteBool(false)
        net.SendToServer()
    end
end)

--[[-------------------------------------------------------------------------
Function to request a specific client convar
---------------------------------------------------------------------------]]
net.Receive("Music_GetRequestConvar", function()
    local whichConvar = net.ReadString()
    local convarValue = GetConVarString(whichConvar)
    net.Start("Music_GetRequestConvar")
        net.WriteString(convarValue)
    net.SendToServer()
end)