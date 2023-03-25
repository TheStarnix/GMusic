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
	PRELOAD ALL THE IMAGES
--]]-------------------------------------------------------------------------
local frameBase = Material(StarnixMusic.materialspath .. "frame_base.png")
local iconGroup = StarnixMusic.materialspath .. "icon_group.png"
local iconInfo = StarnixMusic.materialspath .. "icon_info.png"
local iconMusic = StarnixMusic.materialspath .. "icon_music.png"
local iconSettings = StarnixMusic.materialspath .. "icon_settings.png"
local iconStaff = StarnixMusic.materialspath .. "icon_staff.png"
local iconClose = StarnixMusic.materialspath .. "icon_close.png"

local BaseColor = Color(136, 136, 136)
--[[-------------------------------------------------------------------------
When the player asked to open the menu, we create the frame. (If it already exists, we do nothing)
---------------------------------------------------------------------------]]
StarnixMusic.OpenMenuFunction = function()
	if IsValid(frame) then return end
	
    --[[-------------------------------------------------------------------------
	BASE FRAME
	---------------------------------------------------------------------------]]
	frame = vgui.Create("DFrame")
	frame:SetSize(960, 540)
	frame:Center()
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame.Paint = function(s,w,h)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(frameBase)
		surface.DrawTexturedRect( StarnixMusic.RespX(0), StarnixMusic.RespY(0), 960, 540)
	end

	local text_container = vgui.Create("DPanel", frame)
	text_container:SetPos( StarnixMusic.RespX(50),0)
	text_container:SetSize(910, 54)
	text_container.Paint = nil

	frameText = vgui.Create("DLabel", text_container)
	frameText:SetPos(0,0)
	frameText:SetFont("StarMusic_Title")
	frameText:SetText("GMusic")
	frameText:SetTextColor(color_white)
	frameText:SizeToContents()
	frameText:CenterHorizontal(0.5)
	frameText:CenterVertical(0.5)


	local panelOnglets = vgui.Create( "DPanel", frame)
	panelOnglets:SetPos(0, StarnixMusic.RespY(54) ) 
	panelOnglets:SetSize( 50, 540 )
	panelOnglets.Paint = nil

	local panelContent = vgui.Create( "DPanel", frame)
	panelContent:SetPos( StarnixMusic.RespX(60), StarnixMusic.RespY(54) )
	panelContent:SetSize( 910, frame:GetTall()-panelContent:GetY() )
	panelContent.Paint = nil

	StarnixMusic.RequestMenu(panelContent)
	--[[-------------------------------------------------------------------------
    TAB - Request a music.
    ---------------------------------------------------------------------------]]
	local buttonMusic = vgui.Create("DImageButton", panelOnglets)
	buttonMusic:SetPos( 10, 20 )
	buttonMusic:SetImage(iconMusic)
	buttonMusic:SizeToContents()
	
	buttonMusic.DoClick = function()
		panelContent:Clear()
		StarnixMusic.RequestMenu(panelContent) -- We call the function that will create the content of the tab.
	end
	buttonMusic.OnCursorEntered = function()
		buttonMusic:SetColor(BaseColor)
	end
	buttonMusic.OnCursorExited = function()
		buttonMusic:SetColor(color_white)
	end
	--[[-------------------------------------------------------------------------
    TAB - GROUPS
    ---------------------------------------------------------------------------]]
	local buttonGroup = vgui.Create("DImageButton", panelOnglets)
	buttonGroup:SetPos( 10, 100 )
	buttonGroup:SetImage(iconGroup)
	buttonGroup:SizeToContents()
	
	buttonGroup.DoClick = function()
		if GLocalMusic.IsCreated() then
            StarnixMusic.drawGroups()
        end
	end
	buttonGroup.OnCursorEntered = function()
		buttonGroup:SetColor(BaseColor)
		
	end
	buttonGroup.OnCursorExited = function()
		buttonGroup:SetColor(color_white)
	end
	if not GLocalMusic.IsCreated() or LocalPlayer() ~= GLocalMusic.GetCreator() then
		buttonGroup:SetVisible(false)
	end
	--[[-------------------------------------------------------------------------
    TAB - SETTINGS
    ---------------------------------------------------------------------------]]
	local buttonSettings = vgui.Create("DImageButton", panelOnglets)
	buttonSettings:SetPos( 10, 180 )
	buttonSettings:SetImage(iconSettings)
	buttonSettings:SizeToContents()
	
	buttonSettings.DoClick = function()
		panelContent:Clear()
		StarnixMusic.ConfigMenu(panelContent)
	end
	buttonSettings.OnCursorEntered = function()
		buttonSettings:SetColor(BaseColor)
	end
	buttonSettings.OnCursorExited = function()
		buttonSettings:SetColor(color_white)
	end
	--[[-------------------------------------------------------------------------
    TAB - STAFF
    ---------------------------------------------------------------------------]]
	if StarnixMusic.adminGroups[LocalPlayer():GetUserGroup()] then
		local buttonStaff = vgui.Create("DImageButton", panelOnglets)
		buttonStaff:SetPos( 12, 260 )
		buttonStaff:SetImage(iconStaff)
		buttonStaff:SizeToContents()
		
		buttonStaff.DoClick = function()
			panelContent:Clear()
			StarnixMusic.drawManage(panelContent)
		end
		buttonStaff.OnCursorEntered = function()
			buttonStaff:SetColor(BaseColor)
		end
		buttonStaff.OnCursorExited = function()
			buttonStaff:SetColor(color_white)
		end
	end
    --[[-------------------------------------------------------------------------
    TAB - INFORMATIONS
    ---------------------------------------------------------------------------]]
	local buttonInfos = vgui.Create("DImageButton", panelOnglets)
	buttonInfos:SetPos( 10, 435 )
	buttonInfos:SetImage(iconInfo)
	buttonInfos:SizeToContents()
	
	buttonInfos.DoClick = function()
		panelContent:Clear()
		StarnixMusic.infoMenu(panelContent)
	end
	buttonInfos.OnCursorEntered = function()
		buttonInfos:SetColor(color_white)
	end
	buttonInfos.OnCursorExited = function()
		buttonInfos:SetColor(BaseColor)
	end
    --[[-------------------------------------------------------------------------
    CLOSE PANEL
    ---------------------------------------------------------------------------]]
	local closeButton = vgui.Create( "DImageButton", frame )
	closeButton:SetPos( 910, 10 )
	closeButton:SetImage(iconClose)
	closeButton:SizeToContents()
	closeButton.DoClick = function()
		frame:Close()
	end
end