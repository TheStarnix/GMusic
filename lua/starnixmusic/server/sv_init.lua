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
NETWORKING 
]]---------------------------------------------------------------------------
util.AddNetworkString("Music_OpenMenu")
util.AddNetworkString("Music_SendSong")
util.AddNetworkString("Music_Request")
util.AddNetworkString("Music_StopSong")
util.AddNetworkString("Music_PauseSong")
util.AddNetworkString("Music_ChangeVolume")
util.AddNetworkString("Music_ChangeTime")
util.AddNetworkString("Music_MenuGetWhitelisted")
util.AddNetworkString("Music_MenuWLAddPlayer")
util.AddNetworkString("Music_MenuWLAddAllPlayer")
util.AddNetworkString("Music_MenuWLRemovePlayer")
util.AddNetworkString("Music_WLPopup")
util.AddNetworkString("Music_MenuGetAllSongs")
util.AddNetworkString("Music_MenuChangeSongSettings")
util.AddNetworkString("Music_MenuForceStopSong")
util.AddNetworkString("Music_WLAcceptation")
util.AddNetworkString("Music_GetMusicTime")
util.AddNetworkString("Music_GetRequestConvar")