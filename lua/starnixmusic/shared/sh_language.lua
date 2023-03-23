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
Language: English
---------------------------------------------------------------------------]]
if CLIENT then
        language.Add("music.hud.music", "Actually playing:")
        language.Add("music.hud.time", "Rewind to a specific time")
        language.Add("music.menu.urlPlaceholder", "Your coolest music !")
        language.Add("music.menu.urlLabel", "Url of the Music")
        language.Add("music.menu.loopLabelYes", "Loop enabled")
        language.Add("music.menu.loopLabelNo", "Loop disabled")
        language.Add("music.menu.request", "Create !")
        language.Add("music.menu.change", "Change !")
        language.Add("music.menu.stop", "Stop the music")
        language.Add("music.menu.pause", "Pause the music")
        language.Add("music.menu.urlError", "Please give a valid URL.")
        language.Add("music.menu.nameError", "Please give a valid music name.")
        language.Add("music.menu.Error", "Error")
        language.Add("music.menu.Understood", "OK")
        language.Add("music.musicLaunched", "Music launched !!")
        language.Add("music.urlNotWhitelisted", "The URL seems to not be whitelisted by the server.")
        language.Add("music.musicStopped", "Music stopped !")
        language.Add("music.musicPaused", "Music paused !")
        language.Add("music.menu.changeVolume", "Change the volume")
        language.Add("music.menu.cooldownChange", "Before changing again, please wait : ")
        language.Add("music.menu.loopBlockStreamed", "The music you choose is streamed, so you can't loop it. To loop it, please choose a direct download hosting like Discord/Dropbox.")
        language.Add("music.hud.looping", "The music will loop.")
        language.Add("music.hud.notLooping", "The music won't loop.")
        language.Add("music.hud.choosenBy", "Music choosen by: ")
        language.Add("music.menu.titleMusic", "Title of the music")
        language.Add("music.menu.usersTitle", "Suscribers managements") 
        language.Add("music.menu.wl.remove", "Remove")
        language.Add("music.menu.confirmationDelete", "Delete Confirmation")
        language.Add("music.menu.confirmationDeleteText", "Are you sure you want to remove " .. "%s" .. " from the whitelist ?")
        language.Add("music.menu.confirmationYes", "Yes")
        language.Add("music.menu.confirmationNo", "No")
        language.Add("music.menu.wl.selectPly", "Select a player")
        language.Add("music.menu.wl.add", "Add")
        language.Add("music.menu.admin.force", "Force the player to be added to the whitelist")
        language.Add("music.menu.popup.musicAdd.title", "Music group")
        language.Add("music.menu.popup.musicAdd.text", " is inviting you to listen ")
        language.Add("music.menu.admin.title", "Admin panel")
        language.Add("music.menu.admin.url", "URL of the music")
        language.Add("music.menu.admin.name", "Name of the music")
        language.Add("music.menu.admin.loop", "Looping state")
        language.Add("music.menu.admin.volume", "Volume")
        language.Add("music.menu.admin.countusers", "Followers")
        language.Add("music.menu.admin.delete", "Delete")
        language.Add("music.menu.admin.edit", "Edit Menu")
        language.Add("music.menu.wl.addall", "Tous ajouter")
        language.Add("music.menu.admin.empty", "No music found.")
        language.Add("music.menu.admin.pauseperm", "Can everyone pause the music ?")
        language.Add("music.config.AcceptMusics", "Accept music requests ?")

end
