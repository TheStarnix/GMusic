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

local frameTextEntry = Material("starnixmusic/frame_textentry.png")
local frameButtonImage = StarnixMusic.materialspath .. "frame_combobox.png"
local frameNoCheckbox = StarnixMusic.materialspath.."frame_remove.png"
local frameYesCheckbox = StarnixMusic.materialspath.."frame_check.png"
local materialTextEntry = StarnixMusic.materialspath .. "frame_textentry.png"
local color_red = Color(255, 0, 0)
local color_orange = Color(255, 165, 0)
--Cooldown to prevent spamming net messages.
local volumeCooldown = 4
local volumeCooldownTimer = 0
local materialButtonNo = Material(StarnixMusic.materialspath .. "checkmark_no.png")
local materialButtonYes = Material(StarnixMusic.materialspath .. "checkmark_ok.png")


local function changeButton(button, condition)
    if condition then
        button:SetMaterial(materialButtonYes)
    else
        button:SetMaterial(materialButtonNo)
    end
end

function hideEditMusicButtons(...)
    for _, v in ipairs({...}) do
        v:SetVisible(false)
    end
end

local function createCheckbox(parentPanel, posY, labelTitle, variable)

    local checkBox = vgui.Create("DImageButton", parentPanel)
    checkBox:SetPos(parentPanel:GetWide()/2-StarnixMusic.RespX(330), posY)
    checkBox:SetSize(32, 32)
    checkBox.DoClick = function()
        variable = !variable
        changeButton(checkBox, variable)
    end
    changeButton(checkBox, variable)

    --[[-------------------------------------------------------------------------]
    Text inside the Button
    ---------------------------------------------------------------------------]]
    local checkBoxLabel = vgui.Create("DLabel", parentPanel)
    checkBoxLabel:SetPos(checkBox:GetX() + checkBox:GetTall() + StarnixMusic.RespX(10), checkBox:GetY())
    checkBoxLabel:SetText(labelTitle)
    checkBoxLabel:SetFont("StarMusic_Text")
    checkBoxLabel:SetTextColor(color_white)
    checkBoxLabel:SizeToContents()
    checkBox:Add(checkBoxLabel)

    return checkBox

end

--[[-------------------------------------------------------------------------
Function called to fill the music select menu.
-------------------------------------------------------------------------]]--
function StarnixMusic.RequestMenu(panelContent)
    local canEveryonePauseMusic = true
    local isStaff = StarnixMusic.adminGroups[LocalPlayer():GetUserGroup()] or false

    local scrollPanel = vgui.Create("DScrollPanel", panelContent)
    scrollPanel:Dock(FILL)
    scrollPanel:SetSize(panelContent:GetWide(), panelContent:GetTall())
    -- We repaint the scrollbar
    local sbar = scrollPanel:GetVBar()
    sbar:SetHideButtons(true)
    -- By using sbar, create a beautiful scrollbar
    function sbar:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, StarnixMusic.colors["grey"] )
    end
    function sbar.btnGrip:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, StarnixMusic.colors["darkblue"])
    end
    local centerXScrollPanel = scrollPanel:GetWide() / 2

    --[[-------------------------------------------------------------------------
    TextEntry to enter the URL of the music
    -------------------------------------------------------------------------]]--
    local labelUrl = vgui.Create("DLabel", scrollPanel)
    labelUrl:SetText(StarnixMusic.Language["music.menu.urlLabel"])
    labelUrl:SetTextColor(color_white)
    labelUrl:SetFont("StarMusic_SubTitle")
    labelUrl:SizeToContents()
    labelUrl:SetPos(centerXScrollPanel-labelUrl:GetWide()/2, StarnixMusic.RespY(20))
    
    local textImageUrl = vgui.Create("DImage", scrollPanel)
	textImageUrl:SetSize(500,30)
	textImageUrl:SetImage(materialTextEntry)
    textImageUrl:SetPos(centerXScrollPanel-textImageUrl:GetWide()/2, StarnixMusic.RespY(60))

    local textEntryUrl = vgui.Create("DTextEntry", scrollPanel)
    textEntryUrl:SetSize(500, 30)
    textEntryUrl:SetPlaceholderText(string.rep(" ",15)..StarnixMusic.Language["music.menu.urlPlaceholder"]) -- Need to add spaces because the icon on the image hide the text.
    textEntryUrl:SetDrawBackground(false)
    textEntryUrl:SetFontInternal("StarMusic_Text")
    textEntryUrl:SetTextColor(color_white)
    textEntryUrl:SetPos(centerXScrollPanel-textEntryUrl:GetWide()/2, StarnixMusic.RespY(60))

    --[[-------------------------------------------------------------------------
    TextEntry to enter the title of the music
    -------------------------------------------------------------------------]]--
    labelTitle = vgui.Create("DLabel", scrollPanel)
    labelTitle:SetText(StarnixMusic.Language["music.menu.titleMusic"])
    labelTitle:SetTextColor(color_white)
    labelTitle:SetFont("StarMusic_SubTitle")
    labelTitle:SizeToContents()
    labelTitle:SetPos(centerXScrollPanel-labelTitle:GetWide()/2, StarnixMusic.RespY(100))

    local textImageTitle = vgui.Create("DImage", scrollPanel)
    textImageTitle:SetSize(500,30)
    textImageTitle:SetImage(materialTextEntry)
    textImageTitle:SetPos(centerXScrollPanel-textImageTitle:GetWide()/2, StarnixMusic.RespY(140))

    local textEntryTitle = vgui.Create("DTextEntry", scrollPanel)
    textEntryTitle:SetSize(500, 30)
    textEntryTitle:SetPlaceholderText(string.rep(" ",15).."Shi No Yume") -- Need to add spaces because the icon on the image hide the text.
    textEntryTitle:SetDrawBackground(false)
    textEntryTitle:SetFontInternal("StarMusic_Text")
    textEntryTitle:SetTextColor(color_white)
    textEntryTitle:SetPos(centerXScrollPanel-textEntryTitle:GetWide()/2, StarnixMusic.RespY(140))

    --[[-------------------------------------------------------------------------
    PERMISSIONS
    -------------------------------------------------------------------------]]--
    local permission_loop = false
    local permission_time = false
    local permission_changeMusic = false
    local permission_changeTitle = false
    local permission_addPlayers = false
    local permission_removePlayers = false
    local permission_pause = false
    local addAllPlayers = false

    local checkBoxLoop = createCheckbox(scrollPanel, StarnixMusic.RespY(190), StarnixMusic.Language["music.menu.perms.loop"], permission_loop)
    local checkBoxTime = createCheckbox(scrollPanel, StarnixMusic.RespY(230), StarnixMusic.Language["music.menu.perms.time"], permission_time)
    local checkBoxChangeMusic = createCheckbox(scrollPanel, StarnixMusic.RespY(270), StarnixMusic.Language["music.menu.perms.changemusic"], permission_changeMusic)
    local checkBoxChangetitle = createCheckbox(scrollPanel, StarnixMusic.RespY(310), StarnixMusic.Language["music.menu.perms.changetitle"], permission_changeTitle)
    local checkBoxAddPly = createCheckbox(scrollPanel, StarnixMusic.RespY(350), StarnixMusic.Language["music.menu.perms.addply"], permission_addPlayers)
    local checkBoxRmPly = createCheckbox(scrollPanel, StarnixMusic.RespY(390), StarnixMusic.Language["music.menu.perms.rmply"], permission_removePlayers)
    local checkBoxPause = createCheckbox(scrollPanel, StarnixMusic.RespY(430), StarnixMusic.Language["music.menu.perms.pause"], permission_pause)
    
    local checkBoxIsStaff = nil
    if isStaff then
        checkBoxIsStaff = createCheckbox(scrollPanel, StarnixMusic.RespY(470), StarnixMusic.Language["music.menu.addallplayers"], addAllPlayers)
    end
        --[[-------------------------------------------------------------------------
    Button to send the request
    -------------------------------------------------------------------------]]--
    
    local buttonRequest = vgui.Create("DImageButton", scrollPanel)
    buttonRequest:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    buttonRequest:SetImage(frameButtonImage)
    buttonRequest.DoClick = function()
        if textEntryUrl:GetValue() == "" then -- TODO: Create a better menu.
            Derma_Message(StarnixMusic.Language["music.menu.urlError"], StarnixMusic.Language["music.menu.Error"], StarnixMusic.Language["music.menu.Understood"])
        else
            net.Start("Music_SendSong") -- Send the request to the server
                net.WriteString(textEntryUrl:GetValue()) -- Send the URL
                net.WriteString(textEntryTitle:GetValue()) -- Send the title
                net.WriteBool(permission_loop)
                net.WriteBool(permission_time)
                net.WriteBool(permission_changeMusic)
                net.WriteBool(permission_changeTitle)
                net.WriteBool(permission_addPlayers)
                net.WriteBool(permission_removePlayers)
                net.WriteBool(permission_pause)
                net.WriteBool(addAllPlayers)
            net.SendToServer()
            if frame then frame:Close() end
        end
    end
    buttonRequest:SetPos(centerXScrollPanel-buttonRequest:GetWide()/2, StarnixMusic.RespY(510))

    local labelButtonRequest = vgui.Create("DLabel", buttonRequest)
    labelButtonRequest:SetPos(0,0)
    labelButtonRequest:SetText(StarnixMusic.Language["music.menu.request"])
    labelButtonRequest:SetFont("StarMusic_SubTitle")
    labelButtonRequest:SetTextColor(color_white)
    labelButtonRequest:SizeToContents()
    labelButtonRequest:Center()

    --[[-------------------------------------------------------------------------
    Button to stop the music
    -------------------------------------------------------------------------]]--
    local buttonStop = vgui.Create("DImageButton", scrollPanel)
    buttonStop:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    buttonStop:SetImage(frameButtonImage)
    buttonStop.DoClick = function()
        hideEditMusicButtons(buttonStop, buttonPause, sliderVolume, buttonValidate)
        labelButtonRequest:SetText(StarnixMusic.Language["music.menu.request"])
        labelButtonRequest:SizeToContents()
        labelButtonRequest:Center()
        buttonRequest:SetPos(StarnixMusic.RespX(200), StarnixMusic.RespY(240))
        buttonRequestAll:SetVisible(true)
        net.Start("Music_StopSong")
        net.SendToServer()
    end
    buttonStop:CenterHorizontal(0.25)
    buttonStop:SetPos(StarnixMusic.RespX(230),StarnixMusic.RespY(300))

    --[[-------------------------------------------------------------------------
    Button to pause the music
    -------------------------------------------------------------------------]]--
    local buttonPause = vgui.Create("DImageButton", scrollPanel)
    
    buttonPause:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    buttonPause:SetImage(frameButtonImage)
    buttonPause.DoClick = function()
        net.Start("Music_PauseSong")
        net.SendToServer()
    end
    buttonPause:SetPos(StarnixMusic.RespX(480), StarnixMusic.RespY(300))

    local labelButtonPause = vgui.Create("DLabel", buttonPause)
    labelButtonPause:SetPos(0,0)
    labelButtonPause:SetText(StarnixMusic.Language["music.menu.pause"])
    labelButtonPause:SetFont("StarMusic_SubTitle")
    labelButtonPause:SetTextColor(color_orange)
    labelButtonPause:SizeToContents()
    labelButtonPause:Center()

    local labelButtonStop = vgui.Create("DLabel", buttonStop)
    labelButtonStop:SetPos(0,0)
    labelButtonStop:SetText(StarnixMusic.Language["music.menu.stop"])
    labelButtonStop:SetFont("StarMusic_SubTitle")
    labelButtonStop:SetTextColor(color_red)
    labelButtonStop:SizeToContents()
    labelButtonStop:Center()

    --[[-------------------------------------------------------------------------
    Change the volume of the music
    -------------------------------------------------------------------------]]--
    local containerSlider = vgui.Create("DPanel", scrollPanel)
    containerSlider:SetSize(StarnixMusic.RespX(360), StarnixMusic.RespY(50))
    containerSlider.Paint = nil


    local sliderVolume = vgui.Create("DNumSlider", containerSlider)
    sliderVolume:SetSize(StarnixMusic.RespX(300), StarnixMusic.RespY(50))
    sliderVolume:SetPos(StarnixMusic.RespX(-130),0)
    sliderVolume:SetMin(0)
    sliderVolume:SetMax(3)
    sliderVolume:SetDecimals(2)
    sliderVolume:SetValue(1)
    sliderVolume:SetText("")
    sliderVolume:CenterVertical()
    

    -- Create a button validate for sliderVolume
    local buttonValidate = vgui.Create("DImageButton", containerSlider)
    buttonValidate:SetPos(sliderVolume:GetX()+290, 0)
    buttonValidate:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(40))
    buttonValidate:SetImage(frameButtonImage)
    buttonValidate.DoClick = function()
        if volumeCooldownTimer < CurTime() then 
            volumeCooldownTimer = CurTime() + volumeCooldown
            net.Start("Music_ChangeVolume")
                net.WriteFloat(sliderVolume:GetValue())
            net.SendToServer()
        else
            LocalPlayer():ChatPrint(StarnixMusic.Language["music.menu.cooldownChange"]..math.Round(volumeCooldownTimer - CurTime()).."s.")
        end
        
    end
    buttonValidate:CenterVertical()
    local labelVolume = vgui.Create("DLabel", buttonValidate)
    labelVolume:SetPos(0, 0)
    labelVolume:SetText(StarnixMusic.Language["music.menu.changeVolume"])
    labelVolume:SetFont("StarMusic_SubTitle")
    labelVolume:SetTextColor(color_white)
    labelVolume:SizeToContents()
    labelVolume:SetSize(labelVolume:GetWide()+StarnixMusic.RespX(55),labelVolume:GetTall())
    labelVolume:CenterHorizontal()

    containerSlider:SetPos(centerXScrollPanel-containerSlider:GetWide()/2, StarnixMusic.RespY(400))
    local width, _ = labelVolume:GetTextSize()
    buttonValidate:SetSize(width+StarnixMusic.RespX(10), StarnixMusic.RespY(50))
    containerSlider:SetSize(width+StarnixMusic.RespX(360), StarnixMusic.RespY(50))

    --[[-------------------------------------------------------------------------
    Hide stop button, pause button and change button if the player is not listening music.
    -------------------------------------------------------------------------]]--
    if not GLocalMusic.IsValidSong() then
        hideEditMusicButtons(buttonStop, buttonPause, sliderVolume, buttonValidate)
        labelButtonRequest:SetText(StarnixMusic.Language["music.menu.request"])
        labelButtonRequest:SizeToContents()
    elseif GLocalMusic.IsValidSong() and labelButtonRequest:GetText() == StarnixMusic.Language["music.menu.request"] then
        hideEditMusicButtons(checkBoxAddPly, checkBoxChangeMusic, checkBoxChangetitle, checkBoxLoop, checkBoxPause, checkBoxRmPly, checkBoxTime, checkBoxIsStaff)
        labelButtonRequest:SetText(StarnixMusic.Language["music.menu.change"])
        labelButtonRequest:SizeToContents()
        buttonRequest:SetPos(centerXScrollPanel-buttonRequest:GetWide()/2, StarnixMusic.RespY(190))
    end

end