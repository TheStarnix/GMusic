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