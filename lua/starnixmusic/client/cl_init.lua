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


if not StarnixMusic then StarnixMusic = {} end -- class StarnixMusic which contains all the functions and variables.
StarnixMusic.materialspath = "materials/starnixmusic/" -- path to the materials folder

if not ConVarExists("starnixmusic_acceptMusic") then
	CreateClientConVar("starnixmusic_acceptMusic", "true",false, false, "Accept the music requests ? (true = yes, false = no)") -- ConVar which indicates if the player accepts the music
end
StarnixMusic.colors = {} -- table containing the colors used in clientside
StarnixMusic.colors["grey"] = Color(52, 73, 94)
StarnixMusic.colors["darkgrey"] = Color(40, 55, 71)
StarnixMusic.colors["green"] = Color(46, 204, 113)
StarnixMusic.colors["background"] = Color(44, 62, 80)
StarnixMusic.colors["orange"] = Color(243, 156, 18)
StarnixMusic.colors["red"] = Color(192, 57, 43)
StarnixMusic.colors["lightblue"] = Color(63, 140, 132)
StarnixMusic.colors["darkblue"] = Color(59, 105, 117)

function StarnixMusic.RespX(x) return x/1920*ScrW() end -- Functions really useful for responsive
function StarnixMusic.RespY(y) return y/1080*ScrH() end

StarnixMusic.BlockStreamedURL = {
    "^https://youtubedl.mattjeanes.com/play%?id=.*"
}

surface.CreateFont( "StarMusic_Title", {
	font = "Bahuraksa", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 45,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "StarMusic_SubTitle", {
	font = "Dancing Script", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 35,
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "StarMusic_SubTitle_Bold", {
	font = "Dancing Script", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "StarMusic_Text", {
	font = "Alegreya Sans", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

list.Set("DesktopWindows", "StarnixMusic", {
	title = "GMusic",
	icon = "starnixmusic/logo_addon.png",
	init = function(icon, panel)
		StarnixMusic.OpenMenuFunction()
	end
})