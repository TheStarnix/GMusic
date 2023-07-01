--[[
        StarnixMusic - A music menu handle for the GMusic library addon on Garry's Mod
    
        StarnixMusic is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation.
    
        StarnixMusic is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
    
        You should have received a copy of the GNU General Public License
        along with StarnixMusic. If not] =see <http://www.gnu.org/licenses/>.
]]--

--[[-------------------------------------------------------------------------
Language: English
---------------------------------------------------------------------------]]
StarnixMusic.Language = {}
if CLIENT then
        StarnixMusic.Language["music.hud.music"] = "Actually playing:"
        StarnixMusic.Language["music.hud.time"] = "Actually playing:"
        StarnixMusic.Language["music.menu.urlPlaceholder"] = "Your coolest music !"
        StarnixMusic.Language["music.menu.urlLabel"] = "Url of the Music"
        StarnixMusic.Language["music.menu.request"] ="Create !"
        StarnixMusic.Language["music.menu.addallplayers"] ="STAFF: Add all players ?"
        StarnixMusic.Language["music.menu.change"] ="Change !"
        StarnixMusic.Language["music.menu.stop"] ="Stop the music"
        StarnixMusic.Language["music.menu.pause"] ="Pause the music"
        StarnixMusic.Language["music.menu.urlError"] ="Please give a valid URL."
        StarnixMusic.Language["music.menu.nameError"] ="Please give a valid music name."
        StarnixMusic.Language["music.menu.Error"] ="Error"
        StarnixMusic.Language["music.menu.Understood"] ="OK"
        StarnixMusic.Language["music.urlNotWhitelisted"] ="The URL seems to not be whitelisted by the server."
        StarnixMusic.Language["music.musicStopped"] ="Music stopped !"
        StarnixMusic.Language["music.musicPaused"] ="Music paused !"
        StarnixMusic.Language["music.menu.changeVolume"] ="Change volume"
        StarnixMusic.Language["music.menu.cooldownChange"] ="Before changing again, please wait : "
        StarnixMusic.Language["music.menu.loopBlockStreamed"] ="The music you choose is streamed, so you can't loop it. To loop it] =please choose a direct download hosting like Discord/Dropbox."
        StarnixMusic.Language["music.hud.looping"] ="The music will loop."
        StarnixMusic.Language["music.hud.notLooping"] ="The music won't loop."
        StarnixMusic.Language["music.hud.choosenBy"] ="Music choosen by: "
        StarnixMusic.Language["music.menu.titleMusic"] ="Title of the music"
        StarnixMusic.Language["music.menu.usersTitle"] ="Suscribers managements" 
        StarnixMusic.Language["music.menu.wl.remove"] ="Remove"
        StarnixMusic.Language["music.menu.confirmationDelete"] ="Delete Confirmation"
        StarnixMusic.Language["music.menu.confirmationDeleteText"] ="Are you sure you want to remove " .. "%s" .. " from the whitelist ?"
        StarnixMusic.Language["music.menu.confirmationYes"] ="Yes"
        StarnixMusic.Language["music.menu.confirmationNo"] ="No"
        StarnixMusic.Language["music.menu.wl.selectPly"] ="Select a player"
        StarnixMusic.Language["music.menu.wl.add"] ="Add"
        StarnixMusic.Language["music.menu.admin.force"] ="Force the player to be added to the whitelist"
        StarnixMusic.Language["music.menu.popup.musicAdd.title"] ="Music group"
        StarnixMusic.Language["music.menu.popup.musicAdd.text"] =" is inviting you to listen "
        StarnixMusic.Language["music.menu.admin.title"] ="Admin panel"
        StarnixMusic.Language["music.menu.admin.url"] ="URL of the music"
        StarnixMusic.Language["music.menu.admin.name"] ="Name of the music"
        StarnixMusic.Language["music.menu.admin.loop"] ="Looping state"
        StarnixMusic.Language["music.menu.admin.volume"] ="Volume"
        StarnixMusic.Language["music.menu.admin.countusers"] ="Followers"
        StarnixMusic.Language["music.menu.admin.delete"] ="Delete"
        StarnixMusic.Language["music.menu.admin.edit"] ="Edit Menu"
        StarnixMusic.Language["music.menu.wl.addall"] ="Tous ajouter"
        StarnixMusic.Language["music.menu.admin.empty"] ="No music found."
        StarnixMusic.Language["music.menu.admin.pauseperm"] ="Can everyone pause the music ?"
        StarnixMusic.Language["music.config.AcceptMusics"] ="Accept music requests ?"
        StarnixMusic.Language["music.menu.wl.removemsg1"] ="You have removed "
        StarnixMusic.Language["music.menu.wl.removemsg2"] =" from the whitelist."

        StarnixMusic.Language["music.menu.perms.loop"] = "Enable loop ?"
        StarnixMusic.Language["music.menu.perms.time"] = "Can everyone rewind ?"
        StarnixMusic.Language["music.menu.perms.changemusic"] = "Can everyone change the music ?"
        StarnixMusic.Language["music.menu.perms.changetitle"] = "Can everyone change the title of the music ?"
        StarnixMusic.Language["music.menu.perms.addply"] = "Can everyone add players ?"
        StarnixMusic.Language["music.menu.perms.rmply"] = "Can everyone remove players ?"
        StarnixMusic.Language["music.menu.perms.pause"] = "Can everyone pause the music ?"

else
        StarnixMusic.Language["music.handle.nomusic"] = "You don't have any music playing"
        StarnixMusic.Language["music.wl.wait"] = "You have to wait before adding this player again."
        StarnixMusic.Language["music.wl.desactivated"] = "This player has desactivated music requests."
        StarnixMusic.Language["music.play.notplaying"] ="This music isn't playing anymore."
        StarnixMusic.Language["music.play.already"] ="This player is already listening the music."
        StarnixMusic.Language["music.change.url"] = "The URL has been changed."
        StarnixMusic.Language["music.change.url.notwl"] = "The URL isn't whitelisted or you don't have the permission."
        StarnixMusic.Language["music.wl.refused"] = "The player has refused your request."
        StarnixMusic.Language["music.cmd.available"] = "Available commands:"
        StarnixMusic.Language["music.cmd.stop"] = "Stop current music"
        StarnixMusic.Language["music.cmd.pause"] = "Pause current music"
        StarnixMusic.Language["music.cmd.start"] = "Play music"
        StarnixMusic.Language["music.cmd.volume"] = "Change volume of the music"
        StarnixMusic.Language["music.cmd.loop"] = "Change loop of the music"
        StarnixMusic.Language["music.cmd.title"] = "Change title of the music"
        StarnixMusic.Language["music.cmd.wl"] = "Add a player to the music"
        StarnixMusic.Language["music.cmd.startall"] = "Play music with all players"
        StarnixMusic.Language["music.cmd.startallnoperms"] = "Play music with all players and players can't interact with it"
        StarnixMusic.Language["music.cmd.startnoperms"] = "Play music and players can't interact with it"
        StarnixMusic.Language["music.noperms"] = "You don't have the permissions to do that."
        StarnixMusic.Language["music.change.nourl"] ="You have to give a valid URL."
        StarnixMusic.Language["music.wl.notconnected"] ="The player isn't connected to the server."
        StarnixMusic.Language["music.wl.already"] ="This player is already listening the music."
        StarnixMusic.Language["music.wl.canturself"] ="You can't add yourself to the whitelist."
        StarnixMusic.Language["music.wl.alreadypending"] ="This player has already a pending request."
        StarnixMusic.Language["music.wl.notaccepted"] ="This player doesn't accept music requests."
        StarnixMusic.Language["music.wl.sent"] ="The request has been sent."
end
