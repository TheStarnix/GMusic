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

-- This is the config file for StarnixMusic. You can change the settings here. --
if not StarnixMusic then StarnixMusic = {} end

-- Who can use the staff features?
StarnixMusic.adminGroups = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["moderator"] = true,
    -- ["group"] = true,
}

StarnixMusic.cooldownSendrequest = 60 -- How long should be the cooldown to send another adding request