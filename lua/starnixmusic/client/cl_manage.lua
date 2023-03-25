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
local frameButtonImage = StarnixMusic.materialspath .. "frame_combobox.png"
local materialButtonNext = Material(StarnixMusic.materialspath .. "next_arrow.png")
local frameNoLoop = StarnixMusic.materialspath.."frame_remove.png"
local frameLoop = StarnixMusic.materialspath.."frame_check.png"
local materialTextEntry = StarnixMusic.materialspath .. "frame_textentry.png"
local tableWhitelistedSongs = {}
local maxSongsWhitelisted = 0

local function requestUpdate(index_startPos, index_endPos)
    net.Start("Music_MenuGetAllSongs")
        net.WriteUInt(index_startPos, 8)
        net.WriteUInt(index_endPos, 8)
    net.SendToServer()
end

--- Return the binary value of a string.
local function b(str)
	return tonumber(str, 2)
end

-- @table tableModifications Table used to store all the modifications that can be done to a music object. (bitflag) (SERVERSIDE)
local tableModifications = { 
    title       = b"0000000001",
    url         = b"0000000010",
    loop        = b"0000000100",
    volume      = b"0000001000",
    whitelisted = b"0000010000",
}

local function changeLoopButton(button, labelLoop,  state)
    if state then
        button:SetImage(frameLoop)
        labelLoop:SetText(language.GetPhrase("music.menu.loopLabelYes"))
        labelLoop:SizeToContents()
        labelLoop:Center()
    else
        button:SetImage(frameNoLoop)
        labelLoop:SetText(language.GetPhrase("music.menu.loopLabelNo"))
        labelLoop:SizeToContents()
        labelLoop:Center()
    end
end

local function editMenu(panelContent, target, editionToMate)
    if editFrame then return end
    local editFrame = vgui.Create("DFrame")
    editFrame:SetSize(ScrW() * 0.3, ScrH() * 0.3)
    editFrame:SetTitle("")
    editFrame.Paint = function(self, w, h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(frameBase)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    editFrame:Center()
    editFrame:ShowCloseButton(false)
    editFrame:MakePopup()

    closeButton = vgui.Create("DImageButton", editFrame)
    closeButton:SetPos(editFrame:GetWide() - 24, StarnixMusic.RespY(5))
    closeButton:SetSize(24, 24)
    closeButton:SetImage(iconClose)
    closeButton.DoClick = function()
        editFrame:Close()
    end

    local editPanel = vgui.Create("DPanel", editFrame)
    editPanel:SetSize(editFrame:GetWide() - StarnixMusic.RespX(33), editFrame:GetTall() - StarnixMusic.RespX(36))
    editPanel:SetPos(StarnixMusic.RespX(33), StarnixMusic.RespY(36))
    editPanel.Paint = nil

    local editTitle = vgui.Create("DLabel", editPanel)
    editTitle:SetPos(0, 0)
    editTitle:SetFont("StarMusic_Title")
    editTitle:SetTextColor(color_white)
    editTitle:SetText(language.GetPhrase("music.menu.admin.edit"))
    editTitle:SizeToContents()
    editTitle:CenterHorizontal()

    local editLabel = vgui.Create("DLabel", editPanel)
    editLabel:SetPos(0, StarnixMusic.RespY(50))
    editLabel:SetFont("StarMusic_Text")
    editLabel:SetTextColor(color_white)

    local editFirstValue = nil
    local editedValue = nil

    if bit.band(editionToMate, tableModifications.loop) ~= 0 then -- If the modification is the loop state
        editLabel:SetText(language.GetPhrase("music.menu.admin.loop"))
        editFirstValue = target.loop -- Variable to store the loop state
        editedValue = target.loop
        --[[-------------------------------------------------------------------------
        Checkbox to loop the music
        -------------------------------------------------------------------------]]--
        local imageButtonLoop = vgui.Create("DImageButton", editPanel) -- Create the checkbox
        local labelLoop = vgui.Create("DLabel", imageButtonLoop)
        imageButtonLoop:SetPos(0,StarnixMusic.RespY(130))
        imageButtonLoop:SetSize(StarnixMusic.RespX(270), StarnixMusic.RespY(30))
        imageButtonLoop.DoClick = function()
            editedValue = not editedValue
            changeLoopButton(imageButtonLoop, labelLoop, editedValue)
        end
        imageButtonLoop:CenterHorizontal()
            
        labelLoop:SetPos(0,0)
        labelLoop:SetTextColor(color_white)
        labelLoop:SetFont("StarMusic_SubTitle")
        labelLoop:SizeToContents()
        labelLoop:Center()
        changeLoopButton(imageButtonLoop, labelLoop, editedValue)
    elseif bit.band(editionToMate, tableModifications.volume) ~= 0 then -- If the modification is the volume
        editLabel:SetText(language.GetPhrase("music.menu.admin.volume"))
        editFirstValue, editedValue = target.volume -- Variable to store the volume
        --[[-------------------------------------------------------------------------
        Change the volume of the music
        -------------------------------------------------------------------------]]--
        local containerSlider = vgui.Create("DPanel", editPanel)
        containerSlider:SetPos(0, StarnixMusic.RespY(100))
        containerSlider:SetSize(editPanel:GetWide(), StarnixMusic.RespY(50))
        containerSlider.Paint = nil
        containerSlider:CenterHorizontal()


        local sliderVolume = vgui.Create("DNumSlider", containerSlider)
        sliderVolume:SetSize(StarnixMusic.RespX(300), StarnixMusic.RespY(50))
        sliderVolume:SetPos(StarnixMusic.RespX(80),0)
        sliderVolume:SetMin(0)
        sliderVolume:SetMax(3)
        sliderVolume:SetDecimals(2)
        sliderVolume:SetValue(editFirstValue)
        sliderVolume:SetText("")

        sliderVolume.OnValueChanged = function(self, value)
            editedValue = value
        end
    elseif bit.band(editionToMate, tableModifications.whitelisted) ~= 0 then -- If the modification is the whitelisted users
        editLabel:SetText(language.GetPhrase("music.menu.admin.countusers"))
        -- TODO: Send a net to the server to get the users.
    else
        if bit.band(editionToMate, tableModifications.url) ~= 0 then -- If the modification is the url
            editLabel:SetText(language.GetPhrase("music.menu.admin.url"))
            editFirstValue, editedValue = target.url -- Variable to store the url
            --[[-------------------------------------------------------------------------
            TextEntry to enter the URL of the music
            -------------------------------------------------------------------------]]--
            local textImageUrl = vgui.Create("DImage", editPanel)
            textImageUrl:SetPos(0, StarnixMusic.RespY(130))
            textImageUrl:SetSize(500,30)
            textImageUrl:SetImage(materialTextEntry)
            textImageUrl:CenterHorizontal()

            local textEntryUrl = vgui.Create("DTextEntry", editPanel)
            textEntryUrl:SetSize(500, 30)
            textEntryUrl:SetPos(0, StarnixMusic.RespY(130))
            textEntryUrl:CenterHorizontal()
            textEntryUrl:SetDrawBackground(false)
            textEntryUrl:SetFontInternal("StarMusic_Text")
            textEntryUrl:SetTextColor(color_white)
            textEntryUrl:SetValue(editFirstValue)
            textEntryUrl.OnChange = function(self)
                editedValue = self:GetValue()
            end
        else
            editLabel:SetText(language.GetPhrase("music.menu.admin.name"))
            editFirstValue, editedValue = target.title -- Variable to store the name  
            --[[-------------------------------------------------------------------------
            TextEntry to enter the title of the music
            -------------------------------------------------------------------------]]--
            local textImageTitle = vgui.Create("DImage", editPanel)
            textImageTitle:SetPos(0, StarnixMusic.RespY(130))
            textImageTitle:SetSize(500,30)
            -- TODO: replace image str by a variable
            textImageTitle:SetImage(materialTextEntry)
            textImageTitle:CenterHorizontal()

            local textEntryTitle = vgui.Create("DTextEntry", editPanel)
            textEntryTitle:SetSize(500, 30)
            textEntryTitle:SetPos(0, StarnixMusic.RespY(130))
            -- TODO: replace string.rep by repositioning the textentry
            textEntryTitle:CenterHorizontal()
            textEntryTitle:SetDrawBackground(false)
            textEntryTitle:SetFontInternal("StarMusic_Text")
            textEntryTitle:SetTextColor(color_white)
            textEntryTitle:SetValue(editFirstValue)
            textEntryTitle.OnChange = function(self)
                editedValue = self:GetValue()
            end
        end
    end
    editLabel:SizeToContents()
    editLabel:CenterHorizontal()
    
    --[[-------------------------------------------------------------------------
    Button to send the request
    -------------------------------------------------------------------------]]--
    local buttonRequest = vgui.Create("DImageButton", editPanel)
    buttonRequest:SetPos(0, StarnixMusic.RespY(200))
    buttonRequest:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    buttonRequest:SetImage(frameButtonImage)
    buttonRequest.DoClick = function()
        if editFirstValue != editedValue then
            if not isstring(editedValue) then
                editedValue = tostring(editedValue)
            end
            net.Start("Music_MenuChangeSongSettings")
                net.WriteEntity(target.creator)
                net.WriteString(editionToMate)
                net.WriteString(editedValue)
            net.SendToServer()
        end
        editFrame:Close()
    end
    buttonRequest:CenterHorizontal()

    local labelButtonRequest = vgui.Create("DLabel", buttonRequest)
    labelButtonRequest:SetPos(0,0)
    labelButtonRequest:SetText(language.GetPhrase("music.menu.change"))
    labelButtonRequest:SetFont("StarMusic_SubTitle")
    labelButtonRequest:SetTextColor(color_white)
    labelButtonRequest:SizeToContents()
    labelButtonRequest:Center()



end

local function informationsMenu(panelContent, target)
    local informationsDerma = DermaMenu(panelContent)
    --[[-------------------------------------------------------------------------
    NAME EDIT
    ---------------------------------------------------------------------------]]
    informationsDerma:AddOption(language.GetPhrase("music.menu.admin.name"), function()
        editMenu(panelContent, target, tableModifications.title)
    end):SetIcon("icon16/page_white_edit.png")
    informationsDerma:AddOption(target.title)
    informationsDerma:AddSpacer()
    --[[-------------------------------------------------------------------------
    URL EDIT
    ---------------------------------------------------------------------------]]
    informationsDerma:AddOption(language.GetPhrase("music.menu.admin.url"), function()
        editMenu(panelContent, target, tableModifications.url)
    end):SetIcon("icon16/music.png")
    informationsDerma:AddOption(target.url)
    informationsDerma:AddSpacer()
    --[[-------------------------------------------------------------------------
    LOOP EDIT
    ---------------------------------------------------------------------------]]
    informationsDerma:AddOption(language.GetPhrase("music.menu.admin.loop"), function()
        editMenu(panelContent, target, tableModifications.loop)
    end):SetIcon("icon16/arrow_refresh.png")
    informationsDerma:AddOption(tostring(target.loop))
    informationsDerma:AddSpacer()
    --[[-------------------------------------------------------------------------
    VOLUME EDIT
    ---------------------------------------------------------------------------]]
    informationsDerma:AddOption(language.GetPhrase("music.menu.admin.volume"), function()
        editMenu(panelContent, target, tableModifications.volume)
    end):SetIcon("icon16/sound.png")
    informationsDerma:AddOption(target.volume)
    informationsDerma:AddSpacer()
    --[[-------------------------------------------------------------------------
    WHITELISTED USERS EDIT
    ---------------------------------------------------------------------------]]
    informationsDerma:AddOption(language.GetPhrase("music.menu.admin.countusers"), function()
        editMenu(panelContent, target, tableModifications.whitelisted)
    end):SetIcon("icon16/group.png")
    informationsDerma:AddOption(target.numberWhitelisted)
    informationsDerma:AddSpacer()
    --[[-------------------------------------------------------------------------
    DELETE THE MUSIC OBJECT FOR ALL PLAYERS
    ---------------------------------------------------------------------------]]
    informationsDerma:AddOption(language.GetPhrase("music.menu.admin.delete"), function()
        net.Start("Music_MenuForceStopSong")
            net.WriteEntity(target.creator)
        net.SendToServer()
    end):SetIcon("icon16/cross.png")
    informationsDerma:SetPos(gui.MouseX(), gui.MouseY())
    informationsDerma:MakePopup()
end

--[[-------------------------------------------------------------------------]
Function to refresh the content of the panel (list of audios)
---------------------------------------------------------------------------]]
local function refreshList(panelContent, panelList)
    -- We check if the panel is created, if not, we create it
    if not panelContent or not panelList then return end
    -- We remove all the elements of the panel
    panelList:Clear()
    -- We recreate all the updated elements.
    for k, v in pairs(tableWhitelistedSongs) do
        --[[-------------------------------------------------------------------------]
        The Panel containing all the children elements (Avatar, Name, Group, Remove button)
        ---------------------------------------------------------------------------]]
        local pListPanel = panelList:Add( "DPanel" )
        pListPanel:Dock( TOP )
        pListPanel:SetSize( panelList:GetWide(), 50)
        pListPanel:DockMargin( 0, 0, 0, 5 )
        local pListPanelColor = StarnixMusic.colors["darkgrey"]
        pListPanel.Paint = function(self,w,h)
            surface.SetDrawColor(pListPanelColor)
            surface.DrawRect(0,0,w,h)
        end

        -- If pListPanel is hovered, we change the color of the text
        pListPanel.OnCursorEntered = function()
            pListPanelColor = StarnixMusic.colors["darkblue"]
        end
        pListPanel.OnCursorExited = function()
            pListPanelColor = StarnixMusic.colors["darkgrey"]
        end

        pListPanel.OnMousePressed = function()
            informationsMenu(panelContent, v)
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
        Avatar:SetPlayer( v.creator, 32 )
        Avatar:SetPos(StarnixMusic.RespX(10), 0)
        Avatar:CenterVertical()

        --[[-------------------------------------------------------------------------]
        NAME OF THE PLAYER
        ---------------------------------------------------------------------------]]
        local pListPanelLabelName = vgui.Create("DLabel", pListPanel)
        pListPanelLabelName:SetPos(StarnixMusic.RespX(50), 0)
        pListPanelLabelName:SetSize(StarnixMusic.RespX(280), StarnixMusic.RespY(30))
        pListPanelLabelName:SetFont("StarMusic_Text")
        PrintTable(v)
        pListPanelLabelName:SetText(v.creator:Nick())
        pListPanelLabelName:SetTextColor(color_white)
        local pListPanelLabelGroup = vgui.Create("DLabel", pListPanel)
        pListPanelLabelGroup:SetPos(StarnixMusic.RespX(50), StarnixMusic.RespX(20))
        pListPanelLabelGroup:SetSize(StarnixMusic.RespX(280), StarnixMusic.RespY(30))
        pListPanelLabelGroup:SetFont("StarMusic_Text")
        pListPanelLabelGroup:SetText(v.creator:GetUserGroup())
        pListPanelLabelGroup:SetTextColor(color_white)
    end
end

--[[-------------------------------------------------------------------------]
Function to draw the main panel containing the list of audios
---------------------------------------------------------------------------]]
function StarnixMusic.drawManage(panelContent)
    if not panelContent then return end
    if titlePanel then return end -- If the panel is already created, we don't create it again

    local boolForceAdded = false -- Will the player be forced to the whitelist?
    local index_startPos = 0
    local index_endPos = 10

    --[[-------------------------------------------------------------------------]
    PANEL CONTAINING THE LIST OF WHITELISTED USERS
    ---------------------------------------------------------------------------]]
    local panelList = vgui.Create("DScrollPanel", panelContent)
    panelList:SetPos(StarnixMusic.RespX(70), StarnixMusic.RespY(160))
    panelList:SetSize(StarnixMusic.RespX(700), panelContent:GetTall()-StarnixMusic.RespY(160))
    panelList.Paint = function(self,w,h)
        surface.SetDrawColor(StarnixMusic.colors["darkgrey"])
        surface.DrawOutlinedRect(0,0,w,h)
    end
    panelList:CenterHorizontal()

    --[[-------------------------------------------------------------------------]
    PREVIOUS BUTTON
    ---------------------------------------------------------------------------]]
    local pListPanelButtonPrevious = vgui.Create("DImageButton", panelContent)
    pListPanelButtonPrevious:SetPos(panelList:GetX(), panelList:GetY()-StarnixMusic.RespX(40))
    pListPanelButtonPrevious:SetSize(StarnixMusic.RespX(32), StarnixMusic.RespY(32))
    pListPanelButtonPrevious:SetMaterial(materialButtonPrevious)
    pListPanelButtonPrevious.DoClick = function()
        if index_startPos <= 0 then return end
        index_startPos = index_startPos - 10
        index_endPos = index_endPos - 10
        requestUpdate(index_startPos, index_endPos)
    end
    if index_startPos <= 0 then 
        pListPanelButtonPrevious:SetVisible(false)
    end

    --[[-------------------------------------------------------------------------]
    NEXT BUTTON
    ---------------------------------------------------------------------------]]
    local pListPanelButtonNext = vgui.Create("DImageButton", panelContent)
    pListPanelButtonNext:SetPos(panelList:GetX()+StarnixMusic.RespX(670), panelList:GetY()-StarnixMusic.RespX(40))
    pListPanelButtonNext:SetSize(StarnixMusic.RespX(32), StarnixMusic.RespY(32))
    pListPanelButtonNext:SetMaterial(materialButtonNext)
    pListPanelButtonNext.DoClick = function()
        if index_endPos >= maxSongsWhitelisted then return end
        index_startPos = index_startPos + 10
        index_endPos = index_endPos + 10
        requestUpdate(index_startPos, index_endPos)
    end

    --[[-------------------------------------------------------------------------]
    TITLE DISPLAY WHEN EMPTY
    ---------------------------------------------------------------------------]]
    local pListPanelTitleEmpty = vgui.Create("DLabel", panelContent)
    pListPanelTitleEmpty:SetPos(StarnixMusic.RespX(70), StarnixMusic.RespY(160))
    pListPanelTitleEmpty:SetSize(StarnixMusic.RespX(700), StarnixMusic.RespY(30))
    pListPanelTitleEmpty:SetFont("StarMusic_SubTitle")
    pListPanelTitleEmpty:SetText(language.GetPhrase("music.menu.admin.empty"))
    pListPanelTitleEmpty:SetTextColor(color_white)
    pListPanelTitleEmpty:SizeToContents()
    pListPanelTitleEmpty:CenterHorizontal()
    pListPanelTitleEmpty:SetVisible(true)

    if index_endPos >= maxSongsWhitelisted then 
        pListPanelButtonNext:SetVisible(false)
        pListPanelTitleEmpty:SetVisible(false)
    end

    --[[-------------------------------------------------------------------------]
    NETWORKING IN ORDER TO UPDATE THE AUDIOS LIST (SEND)
    ---------------------------------------------------------------------------]]
    requestUpdate(index_startPos, index_endPos)
    --[[-------------------------------------------------------------------------]
    NETWORKING IN ORDER TO UPDATE THE AUDIOS LIST (RECEIVE)
    ---------------------------------------------------------------------------]]
    net.Receive("Music_MenuGetAllSongs", function()
        tableWhitelistedSongs = net.ReadTable()
        if not tableWhitelistedSongs then return end
        maxSongsWhitelisted = #tableWhitelistedSongs
        refreshList(panelContent, panelList, maxSongsWhitelisted)
    end)
end