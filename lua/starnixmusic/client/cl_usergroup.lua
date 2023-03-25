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
local materialButtonYes = Material(StarnixMusic.materialspath .. "checkmark_ok.png")
local materialButtonNo = Material(StarnixMusic.materialspath .. "checkmark_no.png")
local materialButtonPrevious = Material(StarnixMusic.materialspath .. "back_arrow.png")
local materialButtonNext = Material(StarnixMusic.materialspath .. "next_arrow.png")
local tableWhitelistedPly = {}
local maxPlayersWhitelisted = 0

local function requestUpdate(index_startPos, index_endPos)
    net.Start("Music_MenuGetWhitelisted")
        net.WriteUInt(index_startPos, 8)
        net.WriteUInt(index_endPos, 8)
    net.SendToServer()
end

--[[-------------------------------------------------------------------------]
We create a function to see suscribed users and manage them 
---------------------------------------------------------------------------]]
local function confirmationPanel(target, refreshList)
    --[[-------------------------------------------------------------------------]
    We create a panel to confirm the action of the player
    ---------------------------------------------------------------------------]]
    local confirmationPanelFrame = vgui.Create( "DFrame" )
    confirmationPanelFrame:SetPos( ScrW()/2, ScrH()/2) -- Set the position of the panel
    confirmationPanelFrame:SetSize(StarnixMusic.RespX(400), StarnixMusic.RespY(200)) -- Set the size of the panel
    confirmationPanelFrame:SetVisible(true)
    confirmationPanelFrame:SetDraggable(false)
    confirmationPanelFrame:ShowCloseButton(false)
    confirmationPanelFrame:SetTitle("")
    confirmationPanelFrame.Paint = function(self,w,h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(frameBase)
        surface.DrawTexturedRect(0,0,w,h)
    end
    confirmationPanelFrame:Center()
    confirmationPanelFrame:MakePopup()

    --[[-------------------------------------------------------------------------]
    TEXT CONFIRMATION TITLE
    ---------------------------------------------------------------------------]]
    local confirmationPanelTitle = vgui.Create("DLabel", confirmationPanelFrame)
    confirmationPanelTitle:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(30))
    confirmationPanelTitle:SetSize(StarnixMusic.RespX(280), StarnixMusic.RespY(30))
    confirmationPanelTitle:SetFont("StarMusic_Title")
    confirmationPanelTitle:SetText(language.GetPhrase("music.menu.confirmationDelete"))
    confirmationPanelTitle:SetTextColor(color_white)
    confirmationPanelTitle:SizeToContents()
    confirmationPanelTitle:CenterHorizontal()
    confirmationPanelTitle.Paint = function(self,w,h)
    end

    --[[-------------------------------------------------------------------------]
    SUBPANEL CONTAINING THE TEXT EXPLAINING THE PLAYER'S ACTION
    ---------------------------------------------------------------------------]]
    local panelSubConfirmation = vgui.Create("DPanel", confirmationPanelFrame)
    panelSubConfirmation:SetPos(StarnixMusic.RespX(25), StarnixMusic.RespY(70))
    panelSubConfirmation:SetSize(StarnixMusic.RespX(465), StarnixMusic.RespY(170))
    panelSubConfirmation.Paint = function(self,w,h)
    end

    --[[-------------------------------------------------------------------------]
    TEXT CONFIRMATION
    ---------------------------------------------------------------------------]]
    local textToFormat = language.GetPhrase("music.menu.confirmationDeleteText")
    local confirmationPanelText = vgui.Create("DLabel", panelSubConfirmation)
    confirmationPanelText:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(0))
    confirmationPanelText:SetFont("StarMusic_Text")
    confirmationPanelText:SetText(string.format(textToFormat, target:Nick()))
    confirmationPanelText:SetTextColor(color_white)
    confirmationPanelText:SizeToContents()
    confirmationPanelText.Paint = function(self,w,h)
    end

    --[[-------------------------------------------------------------------------]
    BUTTONS CONFIRMATION YES
    ---------------------------------------------------------------------------]]
    local confirmationPanelButtonYesColor = StarnixMusic.colors["darkblue"]
    local confirmationPanelButtonYes = vgui.Create("DButton", panelSubConfirmation)
    confirmationPanelButtonYes:SetPos(StarnixMusic.RespX(70), StarnixMusic.RespY(50))
    confirmationPanelButtonYes:SetSize(StarnixMusic.RespX(100), StarnixMusic.RespY(25))
    confirmationPanelButtonYes:SetText(language.GetPhrase("music.menu.confirmationYes"))
    confirmationPanelButtonYes:SetFont("StarMusic_Text")
    confirmationPanelButtonYes:SetTextColor(color_white)
    confirmationPanelButtonYes.Paint = function(self,w,h)
        surface.SetDrawColor(confirmationPanelButtonYesColor)
        surface.DrawRect(0,0,w,h)
    end
    confirmationPanelButtonYes.DoClick = function()
        LocalPlayer():PrintMessage(HUD_PRINTTALK, "You have removed " .. target:Nick() .. " from the whitelist.")
        confirmationPanelFrame:Close()
        net.Start("Music_MenuWLRemovePlayer")
            net.WriteEntity(target)
        net.SendToServer()
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
    local confirmationPanelButtonNo = vgui.Create("DButton", panelSubConfirmation)
    confirmationPanelButtonNo:SetPos(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    confirmationPanelButtonNo:SetSize(StarnixMusic.RespX(100), StarnixMusic.RespY(25))
    confirmationPanelButtonNo:SetText(language.GetPhrase("music.menu.confirmationNo"))
    confirmationPanelButtonNo:SetFont("StarMusic_Text")
    confirmationPanelButtonNo:SetTextColor(color_white)
    confirmationPanelButtonNo.Paint = function(self,w,h)
        surface.SetDrawColor(confirmationPanelButtonNoColor)
        surface.DrawRect(0,0,w,h)
    end
    confirmationPanelButtonNo.DoClick = function()
        confirmationPanel:Close()
    end
    -- If confirmationPanelButtonYes is hovered, we change the color of the text
    confirmationPanelButtonNo.OnCursorEntered = function()
        confirmationPanelButtonNoColor = StarnixMusic.colors["red"]
    end
    confirmationPanelButtonNo.OnCursorExited = function()
        confirmationPanelButtonNoColor = StarnixMusic.colors["darkblue"]
    end

    --[[-------------------------------------------------------------------------]
    CLOSE BUTTON
    ---------------------------------------------------------------------------]]
    local closeButton = vgui.Create( "DImageButton", confirmationPanelFrame)
	closeButton:SetPos(StarnixMusic.RespX(360), StarnixMusic.RespY(5))
	closeButton:SetImage(iconClose)
	closeButton:SizeToContents()
	closeButton.DoClick = function()
		confirmationPanelFrame:Close()
	end
end

--[[-------------------------------------------------------------------------]
Function to refresh the content of the panel (list of whitelisted users)
---------------------------------------------------------------------------]]
local function refreshList(usergroupsPanel, panelList, combobox)
    -- We check if the panel is created, if not, we create it
    if not usergroupsPanel or not GLocalMusic.IsCreated() or not panelList or not combobox then return end
    -- We remove all the elements of the panel
    panelList:Clear()
    combobox:Clear()
    -- We recreate all the updated elements.
    for k, v in pairs(tableWhitelistedPly) do
        --[[-------------------------------------------------------------------------]
        The Panel containing all the children elements (Avatar, Name, Group, Remove button)
        ---------------------------------------------------------------------------]]
        local pListPanel = panelList:Add( "DPanel" )
        pListPanel:Dock( TOP )
        pListPanel:SetSize( 0, 50)
        pListPanel:DockMargin( 0, 0, 0, 5 )
        local pListPanelColor = StarnixMusic.colors["darkgrey"]
        pListPanel.Paint = function(self,w,h)
            surface.SetDrawColor(pListPanelColor)
            surface.DrawRect(0,0,w-10,h)
        end

        -- If pListPanel is hovered, we change the color of the text
        pListPanel.OnCursorEntered = function()
            pListPanelColor = StarnixMusic.colors["darkblue"]
        end
        pListPanel.OnCursorExited = function()
            pListPanelColor = StarnixMusic.colors["darkgrey"]
        end

        -- We repaint the scrollbar
        local sbar = panelList:GetVBar()
        sbar:SetHideButtons(true)
        -- By using sbar, create a beautiful scrollbar
        function sbar:Paint( w, h )
            draw.RoundedBox( 0, 0, 0, w, h, StarnixMusic.colors["grey"] )
        end
        function sbar.btnGrip:Paint( w, h )
            draw.RoundedBox( 0, 0, 0, w, h, StarnixMusic.colors["darkblue"])
        end

        --[[-------------------------------------------------------------------------]
        AVATAR OF THE PLAYER
        ---------------------------------------------------------------------------]]
        local Avatar = vgui.Create( "AvatarImage", pListPanel )
        Avatar:SetSize( 32, 32 )
        Avatar:SetPlayer( k, 32 )
        Avatar:SetPos(StarnixMusic.RespX(10), 0)
        Avatar:CenterVertical()

        --[[-------------------------------------------------------------------------]
        NAME OF THE PLAYER
        ---------------------------------------------------------------------------]]
        local pListPanelLabelName = vgui.Create("DLabel", pListPanel)
        pListPanelLabelName:SetPos(StarnixMusic.RespX(50), 0)
        pListPanelLabelName:SetSize(StarnixMusic.RespX(280), StarnixMusic.RespY(30))
        pListPanelLabelName:SetFont("StarMusic_Text")
        pListPanelLabelName:SetText(k:Nick())
        pListPanelLabelName:SetTextColor(color_white)
        local pListPanelLabelGroup = vgui.Create("DLabel", pListPanel)
        pListPanelLabelGroup:SetPos(StarnixMusic.RespX(50), StarnixMusic.RespX(20))
        pListPanelLabelGroup:SetSize(StarnixMusic.RespX(280), StarnixMusic.RespY(30))
        pListPanelLabelGroup:SetFont("StarMusic_Text")
        pListPanelLabelGroup:SetText(k:GetUserGroup())
        pListPanelLabelGroup:SetTextColor(color_white)


        --[[-------------------------------------------------------------------------]
        REMOVE FROM THE WL BUTTON
        ---------------------------------------------------------------------------]]
        if k ~= LocalPlayer() then
            local pListPanelButtonRemove = vgui.Create("DButton", pListPanel)
            pListPanelButtonRemove:SetPos(StarnixMusic.RespX(550), 0)
            pListPanelButtonRemove:SetSize(StarnixMusic.RespX(100), StarnixMusic.RespY(25))
            pListPanelButtonRemove:CenterVertical()
            pListPanelButtonRemove:SetText(language.GetPhrase("music.menu.wl.remove"))
            pListPanelButtonRemove:SetFont("StarMusic_Text")
            pListPanelButtonRemove:SetTextColor(color_white)
            pListPanelButtonRemove.DoClick = function()
                confirmationPanel(k, refreshList) -- We call a pop-up to confirm the player's action
            end
            pListPanelButtonRemove.Paint = function(self,w,h)
                surface.SetDrawColor(StarnixMusic.colors["red"])
                surface.DrawRect(0,0,w,h)
            end
            -- If pListPanelButtonRemove is hovered, we change the color of the text
            pListPanelButtonRemove.OnCursorEntered = function()
                pListPanelColor = StarnixMusic.colors["darkblue"]
            end
            pListPanelButtonRemove.OnCursorExited = function()
                pListPanelColor = StarnixMusic.colors["darkgrey"]
            end
        end
    end

    -- We add all the players who are not in the whitelist to the combobox
    for k,v in pairs(player.GetAll()) do
        -- We add the player to the combobox only if he is not the local player and if he is not already whitelisted
        if v != LocalPlayer() and not tableWhitelistedPly[v] then
            combobox:AddChoice(v:Nick(), v)
        end
    end
end

--[[-------------------------------------------------------------------------]
Function to draw the main panel containing the list of whitelisted users
---------------------------------------------------------------------------]]
function StarnixMusic.drawGroups()
    if usergroupsPanel then return end
    if not GLocalMusic.IsCreated() then return end

    local boolForceAdded = false -- Will the player be forced to the whitelist?
    local index_startPos = 0
    local index_endPos = 10
    local isStaff = StarnixMusic.adminGroups[LocalPlayer():GetUserGroup()] or false
    local creator = GLocalMusic.GetCreator() == LocalPlayer()


    --[[-------------------------------------------------------------------------]
    PANEL CONTAINING THE LIST OF WHITELISTED USERS
    ---------------------------------------------------------------------------]]
    local usergroupsPanel = vgui.Create( "DFrame" )
    usergroupsPanel:SetPos( ScrW()/2, ScrH()/2) -- Set the position of the panel
    usergroupsPanel:SetSize(StarnixMusic.RespX(800), StarnixMusic.RespY(800)) -- Set the size of the panel
    usergroupsPanel:SetVisible(true)
    usergroupsPanel:SetDraggable(false)
    usergroupsPanel:ShowCloseButton(false)
    usergroupsPanel:SetTitle("")
    usergroupsPanel.Paint = function(self,w,h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(frameBase)
        surface.DrawTexturedRect(0,0,w,h)
    end
    usergroupsPanel:Center()
    usergroupsPanel:MakePopup()

    --[[-------------------------------------------------------------------------]
    PANEL CONTAINING THE TITLE
    ---------------------------------------------------------------------------]]
    local titlePanel = vgui.Create("DPanel", usergroupsPanel)
    titlePanel:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(0))
    titlePanel:SetSize(StarnixMusic.RespX(860), StarnixMusic.RespY(80))
    titlePanel.Paint = function(self,w,h)
    end

    --[[-------------------------------------------------------------------------]
    TITLE
    ---------------------------------------------------------------------------]]
    local usersPanelTitle = vgui.Create("DLabel", titlePanel)
    usersPanelTitle:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(30))
    usersPanelTitle:SetSize(StarnixMusic.RespX(280), StarnixMusic.RespY(30))
    usersPanelTitle:SetFont("StarMusic_Title")
    usersPanelTitle:SetText(language.GetPhrase("music.menu.usersTitle"))
    usersPanelTitle:SetTextColor(color_white)
    usersPanelTitle:SizeToContents()
    usersPanelTitle:Center()
    usersPanelTitle.Paint = function(self,w,h)
    end

    --[[-------------------------------------------------------------------------]
    CLOSE BUTTON
    ---------------------------------------------------------------------------]]
    local closeButton = vgui.Create( "DImageButton", usergroupsPanel)
	closeButton:SetPos(StarnixMusic.RespX(760), StarnixMusic.RespY(5))
	closeButton:SetImage(iconClose)
	closeButton:SizeToContents()
	closeButton.DoClick = function()
		usergroupsPanel:Close()
	end

    --[[-------------------------------------------------------------------------]
    PANEL CONTAINING THE LIST OF WHITELISTED USERS
    ---------------------------------------------------------------------------]]
    local panelList = vgui.Create("DScrollPanel", usergroupsPanel)
    panelList:SetPos(StarnixMusic.RespX(70), StarnixMusic.RespY(300))
    panelList:SetSize(StarnixMusic.RespX(700), StarnixMusic.RespY(480))
    panelList.Paint = function(self,w,h)
    end

    --[[-------------------------------------------------------------------------]
    COMBO BOX TO SELECT A CONNECTED PLAYER
    ---------------------------------------------------------------------------]]
    local combobox = vgui.Create( "DComboBox", usergroupsPanel )
    combobox:SetPos(StarnixMusic.RespX(70), StarnixMusic.RespY(100))
    combobox:SetSize(StarnixMusic.RespX(700), StarnixMusic.RespY(30))
    combobox:SetValue( language.GetPhrase("music.menu.wl.selectPly") )
    combobox:SetFont("StarMusic_Text")
    combobox:SetTextColor(color_white)
    combobox.Paint = function(self,w,h)
        surface.SetDrawColor(StarnixMusic.colors["darkgrey"])
        surface.DrawRect(0,0,w,h)
    end
    
    --[[-------------------------------------------------------------------------]
    BUTTON TO ADD A PLAYER TO THE WHITELIST
    ---------------------------------------------------------------------------]]
    local pListPanelButtonAdd = vgui.Create("DButton", usergroupsPanel)
    pListPanelButtonAdd:SetPos(StarnixMusic.RespX(60), StarnixMusic.RespY(150))
    pListPanelButtonAdd:SetSize(StarnixMusic.RespX(350), StarnixMusic.RespY(30))
    pListPanelButtonAdd:SetText(language.GetPhrase("music.menu.wl.add"))
    pListPanelButtonAdd:SetFont("StarMusic_Text")
    pListPanelButtonAdd:SetTextColor(color_white)
    pListPanelButtonAdd.DoClick = function()
        local _, data = combobox:GetSelected()
        if not data or not IsEntity(data) or not data:IsPlayer() then return end
        net.Start("Music_MenuWLAddPlayer")
            net.WriteEntity(data) -- Send the player to the server
            net.WriteBool(boolForceAdded) -- Send if the player is force added
        net.SendToServer()
    end
    pListPanelButtonAdd.Paint = function(self,w,h)
        surface.SetDrawColor(StarnixMusic.colors["red"])
        surface.DrawRect(0,0,w,h)
    end
    -- If pListPanelButtonRemove is hovered, we change the color of the text
    pListPanelButtonAdd.OnCursorEntered = function()
        pListPanelColor = StarnixMusic.colors["darkblue"]
    end
    pListPanelButtonAdd.OnCursorExited = function()
        pListPanelColor = StarnixMusic.colors["darkgrey"]
    end

    --[[-------------------------------------------------------------------------]
    BUTTON TO ADD ALL CONNECTED PLAYERS TO THE WHITELIST
    ---------------------------------------------------------------------------]]
    local pListPanelButtonAddAll = vgui.Create("DButton", usergroupsPanel)
    pListPanelButtonAddAll:SetPos(StarnixMusic.RespX(430), StarnixMusic.RespY(150))
    pListPanelButtonAddAll:SetSize(StarnixMusic.RespX(350), StarnixMusic.RespY(30))
    pListPanelButtonAddAll:SetText(language.GetPhrase("music.menu.wl.addall"))
    pListPanelButtonAddAll:SetFont("StarMusic_Text")
    pListPanelButtonAddAll:SetTextColor(color_white)
    pListPanelButtonAddAll.DoClick = function()
        net.Start("Music_MenuWLAddAllPlayer")
        net.SendToServer()
    end
    pListPanelButtonAddAll.Paint = function(self,w,h)
        surface.SetDrawColor(StarnixMusic.colors["red"])
        surface.DrawRect(0,0,w,h)
    end
    -- If pListPanelButtonRemove is hovered, we change the color of the text
    pListPanelButtonAddAll.OnCursorEntered = function()
        pListPanelColor = StarnixMusic.colors["darkblue"]
    end
    pListPanelButtonAddAll.OnCursorExited = function()
        pListPanelColor = StarnixMusic.colors["darkgrey"]
    end

    --[[-------------------------------------------------------------------------]
    Image Button to force add a player to the whitelist
    ---------------------------------------------------------------------------]]
    local pListPanelButtonAddForce = vgui.Create("DImageButton", usergroupsPanel)
    pListPanelButtonAddForce:SetPos(StarnixMusic.RespX(70), StarnixMusic.RespY(200))
    pListPanelButtonAddForce:SetSize(32, 32)
    pListPanelButtonAddForce:SetMaterial(materialButtonNo)
    pListPanelButtonAddForce.DoClick = function()
        boolForceAdded = !boolForceAdded
        if boolForceAdded then
            pListPanelButtonAddForce:SetMaterial(materialButtonYes)
        else
            pListPanelButtonAddForce:SetMaterial(materialButtonNo)
        end
    end

    --[[-------------------------------------------------------------------------]
    Text inside the Button
    ---------------------------------------------------------------------------]]
    local pListPanelButtonAddForceText = vgui.Create("DLabel", usergroupsPanel)
    pListPanelButtonAddForceText:SetPos(pListPanelButtonAddForce:GetX() + pListPanelButtonAddForce:GetTall() + StarnixMusic.RespX(10), pListPanelButtonAddForce:GetY())
    pListPanelButtonAddForceText:SetText(language.GetPhrase("music.menu.admin.force"))
    pListPanelButtonAddForceText:SetFont("StarMusic_Text")
    pListPanelButtonAddForceText:SetTextColor(color_white)
    pListPanelButtonAddForceText:SizeToContents()

    if not isStaff then
        pListPanelButtonAddForce:SetVisible(false)
        pListPanelButtonAddForceText:SetVisible(false)
    end

    --[[-------------------------------------------------------------------------]
    PREVIOUS BUTTON
    ---------------------------------------------------------------------------]]
    local pListPanelButtonPrevious = vgui.Create("DImageButton", usergroupsPanel)
    pListPanelButtonPrevious:SetPos(StarnixMusic.RespX(70), StarnixMusic.RespY(250))
    pListPanelButtonPrevious:SetSize(StarnixMusic.RespX(32), StarnixMusic.RespY(32))
    pListPanelButtonPrevious:SetMaterial(materialButtonPrevious)
    pListPanelButtonPrevious.DoClick = function()
        if index_startPos <= 0 then return end
        index_startPos = index_startPos - 10
        index_endPos = index_endPos - 10
        requestUpdate(index_startPos, index_endPos)
    end

    --[[-------------------------------------------------------------------------]
    NEXT BUTTON
    ---------------------------------------------------------------------------]]
    local pListPanelButtonNext = vgui.Create("DImageButton", usergroupsPanel)
    pListPanelButtonNext:SetPos(StarnixMusic.RespX(730), StarnixMusic.RespY(250))
    pListPanelButtonNext:SetSize(StarnixMusic.RespX(32), StarnixMusic.RespY(32))
    pListPanelButtonNext:SetMaterial(materialButtonNext)
    pListPanelButtonNext.DoClick = function()
        if index_endPos >= maxPlayersWhitelisted then return end
        index_startPos = index_startPos + 10
        index_endPos = index_endPos + 10
        requestUpdate(index_startPos, index_endPos)
    end


    --[[-------------------------------------------------------------------------]
    NETWORKING IN ORDER TO UPDATE THE WHITELISTED PLAYERS LIST (SEND)
    ---------------------------------------------------------------------------]]
    requestUpdate(index_startPos, index_endPos)
    --[[-------------------------------------------------------------------------]
    NETWORKING IN ORDER TO UPDATE THE WHITELISTED PLAYERS LIST (RECEIVE)
    ---------------------------------------------------------------------------]]
    net.Receive("Music_MenuGetWhitelisted", function()
        tableWhitelistedPly = net.ReadTable()
        maxPlayersWhitelisted = net.ReadUInt(8)
        refreshList(usergroupsPanel, panelList, combobox, maxPlayersWhitelisted)
    end)
end