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

local rootDir = "starnixmusic"
ListCurrentsMusics = {}
local function AddFile(File, dir)
    print(string.lower(File))
    local fileSide = string.lower(string.Left(File , 3))

    if SERVER and fileSide == "sv_" then
        include(dir..File)
        print("[AUTOLOAD] SV INCLUDE: " .. File)
    elseif fileSide == "sh_" then
        if SERVER then 
            AddCSLuaFile(dir..File)
            print("[AUTOLOAD] SH ADDCS: " .. File)
        end
        include(dir..File)
        print("[AUTOLOAD] SH INCLUDE: " .. File)
    elseif fileSide == "cl_" then
        if SERVER then 
            AddCSLuaFile(dir..File)
            print("[AUTOLOAD] CL ADDCS: " .. File)
        elseif CLIENT then
            include(dir..File)
            print("[AUTOLOAD] CL INCLUDE: " .. File)
        end
    end
end

local function IncludeDir(dir, path)
    dir = dir .. "/"
    local File, Directory = file.Find(dir.."*", path)
    for k, v in ipairs(File) do
        if string.EndsWith(v, ".lua") then
            AddFile(v, dir)
        end
    end
    
    for k, v in ipairs(Directory) do
        if v ~= "autorun" then
            print("[AUTOLOAD] Directory: " .. v)
            IncludeDir(dir..v, path)
        end
    end

end

print("========== StarnixMusic: Loading ==========")
IncludeDir(rootDir, "LUA")
IncludeDir("libraries/gmusiclib", "LUA")
print("========== Loading finished. ==========")

