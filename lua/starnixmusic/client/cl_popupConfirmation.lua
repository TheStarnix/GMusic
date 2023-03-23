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

local frameBase = Material(StarnixMusic.materialspath .. "frame_base.png")
local iconClose = StarnixMusic.materialspath .. "icon_close.png"
local timerBeforeClose = 10
--[[-------------------------------------------------------------------------]
We create a function to see suscribed users and manage them 
---------------------------------------------------------------------------]]
local function confirmationPopupPanel(playerRequesting, musicName)
    musicName = musicName or "??"
    local startTime = CurTime()
    
    --[[-------------------------------------------------------------------------]
    We create a panel to confirm the action of the player
    ---------------------------------------------------------------------------]]
    local confirmationPopupFrame = vgui.Create( "DFrame" )
    confirmationPopupFrame:SetPos(ScrW()+400, StarnixMusic.RespY(700)) -- Set the position of the panel
    confirmationPopupFrame:SetSize( 400, 120 ) -- Set the size of the panel
    confirmationPopupFrame:SetVisible(true)
    confirmationPopupFrame:SetDraggable(false)
    confirmationPopupFrame:ShowCloseButton(false)
    confirmationPopupFrame:SetTitle("")
    confirmationPopupFrame.Paint = function(self,w,h)
        surface.SetDrawColor(StarnixMusic.colors["grey"])
        surface.DrawRect(0,0,w,h)
    end
    confirmationPopupFrame:MoveTo(ScrW()-400, StarnixMusic.RespY(700), 1,0,-1)

    --[[-------------------------------------------------------------------------]
    TITLE CONFIRMATION
    ---------------------------------------------------------------------------]]
    local confirmationPanelTitle = vgui.Create("DLabel", confirmationPopupFrame)
    confirmationPanelTitle:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(0))
    confirmationPanelTitle:SetFont("StarMusic_Text")
    confirmationPanelTitle:SetText(language.GetPhrase("music.menu.popup.musicAdd.title"))
    confirmationPanelTitle:SetTextColor(color_white)
    confirmationPanelTitle:SizeToContents()
    confirmationPanelTitle:CenterHorizontal()

    --[[-------------------------------------------------------------------------]
    PANEL FOR THE TEXT
    ---------------------------------------------------------------------------]]
    local confirmationPanel = vgui.Create("DPanel", confirmationPopupFrame)
    confirmationPanel:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(20))
    confirmationPanel:SetSize(StarnixMusic.RespX(400), StarnixMusic.RespY(50))
    confirmationPanel.Paint = function(self,w,h)
    end

    --[[-------------------------------------------------------------------------]
    TEXT CONFIRMATION
    ---------------------------------------------------------------------------]]
    local confirmationPanelText = vgui.Create("RichText", confirmationPanel)
    confirmationPanelText:SetSize(StarnixMusic.RespX(400), StarnixMusic.RespY(50))
    confirmationPanelText:InsertColorChange(192, 57, 43,255)
    confirmationPanelText:AppendText(playerRequesting:Nick())
    confirmationPanelText:InsertColorChange(255,255,255,255)
    confirmationPanelText:AppendText(language.GetPhrase("music.menu.popup.musicAdd.text"))
    confirmationPanelText:InsertColorChange(192, 57, 43,255)
    confirmationPanelText:AppendText("'"..musicName.."'")
    confirmationPanelText:SetVerticalScrollbarEnabled(false)

    -- Ensure font and text color changes are applied
    function confirmationPanelText:PerformLayout()
        self:SetFontInternal("StarMusic_Text")
        self:SetFGColor( color_white )
    end
    
    
    --[[-------------------------------------------------------------------------]
    BUTTONS CONFIRMATION YES
    ---------------------------------------------------------------------------]]
    local confirmationPanelButtonYesColor = StarnixMusic.colors["darkblue"]
    local confirmationPanelButtonYes = vgui.Create("DButton", confirmationPopupFrame)
    confirmationPanelButtonYes:SetSize(StarnixMusic.RespX(100), StarnixMusic.RespY(25))
    confirmationPanelButtonYes:SetPos((confirmationPopupFrame:GetWide()/2)-confirmationPanelButtonYes:GetWide()-10, StarnixMusic.RespY(70))
    confirmationPanelButtonYes:SetText(language.GetPhrase("music.menu.confirmationYes"))
    confirmationPanelButtonYes:SetFont("StarMusic_Text")
    confirmationPanelButtonYes:SetTextColor(color_white)
    confirmationPanelButtonYes.Paint = function(self,w,h)
        surface.SetDrawColor(confirmationPanelButtonYesColor)
        surface.DrawRect(0,0,w,h)
    end
    confirmationPanelButtonYes.DoClick = function()
        net.Start("Music_WLAcceptation")
            net.WriteBool(true)
            net.WriteEntity(playerRequesting)
        net.SendToServer()
        confirmationPopupFrame:Close()
    end
    -- If confirmationPanelButtonYes is hovered, we change the color of the text
    confirmationPanelButtonYes.OnCursorEntered = function()
        confirmationPanelButtonYesColor = StarnixMusic.colors["green"]
    end
    confirmationPanelButtonYes.OnCursorExited = function()
        confirmationPanelButtonYesColor = StarnixMusic.colors["darkblue"]
    end

    --[[-------------------------------------------------------------------------]
    BUTTONS CONFIRMATION NO
    ---------------------------------------------------------------------------]]
    local confirmationPanelButtonNoColor = StarnixMusic.colors["darkblue"]
    local confirmationPanelButtonNo = vgui.Create("DButton", confirmationPopupFrame)
    confirmationPanelButtonNo:SetSize(StarnixMusic.RespX(100), StarnixMusic.RespY(25))
    confirmationPanelButtonNo:SetPos((confirmationPopupFrame:GetWide()/2)+10, StarnixMusic.RespY(70))
    confirmationPanelButtonNo:SetText(language.GetPhrase("music.menu.confirmationNo"))
    confirmationPanelButtonNo:SetFont("StarMusic_Text")
    confirmationPanelButtonNo:SetTextColor(color_white)
    confirmationPanelButtonNo.Paint = function(self,w,h)
        surface.SetDrawColor(confirmationPanelButtonNoColor)
        surface.DrawRect(0,0,w,h)
    end
    confirmationPanelButtonNo.DoClick = function()
        net.Start("Music_WLAcceptation")
            net.WriteBool(false)
            net.WriteEntity(playerRequesting)
        net.SendToServer()
        confirmationPopupFrame:Close()
    end
    -- If confirmationPanelButtonYes is hovered, we change the color of the text
    confirmationPanelButtonNo.OnCursorEntered = function()
        confirmationPanelButtonNoColor = StarnixMusic.colors["red"]
    end
    confirmationPanelButtonNo.OnCursorExited = function()
        confirmationPanelButtonNoColor = StarnixMusic.colors["darkblue"]
    end

    --[[-------------------------------------------------------------------------]
    PROGRESS BAR
    ---------------------------------------------------------------------------]]

    -- Draw a progress bar to show the time left before the panel closes, the progress bar will reduce its width every second until 3s
    local progressbar = vgui.Create("DPanel", confirmationPopupFrame)
    progressbar:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(100))
    progressbar:SetSize(StarnixMusic.RespX(400), StarnixMusic.RespY(20))
    local progress = 0
    progressbar.Paint = function(self,w,h)
        surface.SetDrawColor(StarnixMusic.colors["darkblue"])
        surface.DrawRect(0,0,w,h)
        if progress != nil and progress > 1 then return end
        progress = (CurTime() - startTime) / timerBeforeClose
        local progressbarWidth = w * (1 - progress)
        surface.SetDrawColor(StarnixMusic.colors["green"])
        surface.DrawRect(0,0,progressbarWidth,h)
    end

    timer.Simple(timerBeforeClose, function()
        if not IsValid(confirmationPopupFrame) then return end -- If the frame is closed, we don't need to close it again
        confirmationPopupFrame:Close()
    end)
    
    
end
net.Receive("Music_WLPopup", function()
    local ply = net.ReadEntity()
    local musicName = net.ReadString()
    confirmationPopupPanel(ply, musicName)
end)