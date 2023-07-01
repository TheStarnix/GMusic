
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
if not GMusicConfig then GMusicConfig = {} end

GMusicConfig.whitelistedLinks = {
    ["^https://cdn%.discordapp%.com/attachments/.+%.mp3$"] = "Discord", -- Discord links
    ["^https://www%.dropbox%.com/s/.+/.+%.mp3%?dl=1$"] = "Dropbox", -- Dropbox
    ["^https://1drv%.ms/u/.+%?e=.+$"] = "OneDrive", -- OneDrive
}

GMusicConfig.whitelistedLinksFunctionNeed = {
    ["OneDrive"] = true,
}

GMusicConfig.whitelistedLinksFunction = {
    ["OneDrive"] = function(url)
        local base64url = util.Base64Encode(url)
        base64url = string.TrimRight(base64url, "=")
        base64url = string.Replace(base64url, "/", "_")
        base64url = string.Replace(base64url, "+", "-")
        return "https://api.onedrive.com/v1.0/shares/u!" .. base64url .. "/root/content"
    end,
}
GMusicConfig.staff = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["moderator"] = true,
    -- ["group"] = true,
}