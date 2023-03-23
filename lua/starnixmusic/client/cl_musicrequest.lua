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
local frameNoLoop = StarnixMusic.materialspath.."frame_remove.png"
local frameLoop = StarnixMusic.materialspath.."frame_check.png"
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

function hideEditMusicButtons(buttonStop, buttonPause, sliderVolume, buttonValidate, labelButtonRequest)
    buttonStop:SetVisible(false)
    buttonPause:SetVisible(false)
    sliderVolume:SetVisible(false)
    buttonValidate:SetVisible(false)
    labelButtonRequest:SetText(language.GetPhrase("music.menu.request"))
    labelButtonRequest:SizeToContents()
    labelButtonRequest:Center()
end

--[[-------------------------------------------------------------------------
Function called to fill the music select menu.
-------------------------------------------------------------------------]]--
function StarnixMusic.RequestMenu(panelContent)
    local buttonLoopState = true
    local canEveryonePauseMusic = true
    local isStaff = StarnixMusic.adminGroups[LocalPlayer():GetUserGroup()] or false

    --[[-------------------------------------------------------------------------
    TextEntry to enter the URL of the music
    -------------------------------------------------------------------------]]--
    labelUrl = vgui.Create("DLabel", panelContent)
    labelUrl:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(20))
    labelUrl:SetText(language.GetPhrase("music.menu.urlLabel"))
    labelUrl:SetTextColor(color_white)
    labelUrl:SetFont("StarMusic_SubTitle")
    labelUrl:SizeToContents()
    labelUrl:CenterHorizontal()

    local textImageUrl = vgui.Create("DImage", panelContent)
	textImageUrl:SetPos(0, StarnixMusic.RespY(60))
	textImageUrl:SetSize(500,30)
	textImageUrl:SetImage(materialTextEntry)
    textImageUrl:CenterHorizontal()

    local textEntryUrl = vgui.Create("DTextEntry", panelContent)
    textEntryUrl:SetSize(500, 30)
    textEntryUrl:SetPos(0, StarnixMusic.RespY(60))
    textEntryUrl:SetPlaceholderText(string.rep(" ",15)..language.GetPhrase("music.menu.urlPlaceholder")) -- Need to add spaces because the icon on the image hide the text.
    textEntryUrl:CenterHorizontal()
    textEntryUrl:SetDrawBackground(false)
    textEntryUrl:SetFontInternal("StarMusic_Text")
    textEntryUrl:SetTextColor(color_white)

    --[[-------------------------------------------------------------------------
    TextEntry to enter the title of the music
    -------------------------------------------------------------------------]]--
    local textImageTitle = vgui.Create("DImage", panelContent)
    textImageTitle:SetPos(0, StarnixMusic.RespY(140))
    textImageTitle:SetSize(500,30)
    textImageTitle:SetImage(materialTextEntry)
    textImageTitle:CenterHorizontal()

    labelTitle = vgui.Create("DLabel", panelContent)
    labelTitle:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(100))
    labelTitle:SetText(language.GetPhrase("music.menu.titleMusic"))
    labelTitle:SetTextColor(Color(255, 255, 255))
    labelTitle:SetFont("StarMusic_SubTitle")
    labelTitle:SizeToContents()
    labelTitle:CenterHorizontal()

    local textEntryTitle = vgui.Create("DTextEntry", panelContent)
    textEntryTitle:SetSize(500, 30)
    textEntryTitle:SetPos(0, StarnixMusic.RespY(140))
    textEntryTitle:SetPlaceholderText(string.rep(" ",15).."Shi No Yume") -- Need to add spaces because the icon on the image hide the text.
    textEntryTitle:CenterHorizontal()
    textEntryTitle:SetDrawBackground(false)
    textEntryTitle:SetFontInternal("StarMusic_Text")
    textEntryTitle:SetTextColor(color_white)

    --[[-------------------------------------------------------------------------
    Checkbox to loop the music
    -------------------------------------------------------------------------]]--
    local imageButtonLoop = vgui.Create("DImageButton", panelContent) -- Create the checkbox
    imageButtonLoop:SetPos(0,StarnixMusic.RespY(190))
    imageButtonLoop:SetSize(StarnixMusic.RespX(270), StarnixMusic.RespY(30))
    imageButtonLoop:SetImage(frameLoop)
    imageButtonLoop.DoClick = function()
        if buttonLoopState then
            imageButtonLoop:SetImage(frameNoLoop)
            if labelLoop then
                labelLoop:SetText(language.GetPhrase("music.menu.loopLabelNo"))
                labelLoop:SizeToContents()
                labelLoop:Center()
                labelLoop:SetTextColor(color_black)
            end
        else
            imageButtonLoop:SetImage(frameLoop)
            if labelLoop then
                labelLoop:SetText(language.GetPhrase("music.menu.loopLabelYes"))
                labelLoop:SizeToContents()
                labelLoop:Center()
                labelLoop:SetTextColor(color_white)
            end
        end
        buttonLoopState = not buttonLoopState
    end
    imageButtonLoop:CenterHorizontal()
        
    local labelLoop = vgui.Create("DLabel", imageButtonLoop)
    labelLoop:SetPos(0,0)
    labelLoop:SetText(language.GetPhrase("music.menu.loopLabelYes"))
    labelLoop:SetTextColor(color_white)
    labelLoop:SetFont("StarMusic_SubTitle")
    labelLoop:SizeToContents()
    labelLoop:Center()

    --[[-------------------------------------------------------------------------]
    Image Button to remove the possibility of everyone pausing the music
    ---------------------------------------------------------------------------]]
    if isStaff then
        local buttonEveryonePause = vgui.Create("DImageButton", panelContent)
        buttonEveryonePause:SetPos(StarnixMusic.RespX(70), StarnixMusic.RespY(190))
        buttonEveryonePause:SetSize(StarnixMusic.RespX(32), StarnixMusic.RespY(32))
        buttonEveryonePause.DoClick = function()
            canEveryonePauseMusic = !canEveryonePauseMusic
            changeButton(buttonEveryonePause, canEveryonePauseMusic)
        end
        changeButton(buttonEveryonePause, canEveryonePauseMusic)

        --[[-------------------------------------------------------------------------]
        Text inside the Button
        ---------------------------------------------------------------------------]]
        local buttonEveryonePauseText = vgui.Create("DLabel", panelContent)
        buttonEveryonePauseText:SetPos(buttonEveryonePause:GetX() + buttonEveryonePause:GetTall() + StarnixMusic.RespX(10), buttonEveryonePause:GetY())
        buttonEveryonePauseText:SetText(language.GetPhrase("music.menu.admin.pauseperm"))
        buttonEveryonePauseText:SetFont("StarMusic_Text")
        buttonEveryonePauseText:SetTextColor(color_white)
        buttonEveryonePauseText:SizeToContents()
        imageButtonLoop:SetPos(StarnixMusic.RespX(570),StarnixMusic.RespY(190))
    end

    --[[-------------------------------------------------------------------------
    Button to send the request
    -------------------------------------------------------------------------]]--
    
    local buttonRequest = vgui.Create("DImageButton", panelContent)
    buttonRequest:SetPos(0, StarnixMusic.RespY(240))
    buttonRequest:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    buttonRequest:SetImage(frameButtonImage)
    buttonRequest.DoClick = function()
        if textEntryUrl:GetValue() == "" then -- TODO: Create a better menu.
            Derma_Message(language.GetPhrase("music.menu.urlError"), language.GetPhrase("music.menu.Error"), language.GetPhrase("music.menu.Understood"))
        else
            net.Start("Music_SendSong") -- Send the request to the server
                net.WriteString(textEntryUrl:GetValue()) -- Send the URL
                net.WriteString(textEntryTitle:GetValue()) -- Send the title
                net.WriteBool(buttonLoopState) -- Send the loop checkbox state
                net.WriteBool(canEveryonePauseMusic)
            net.SendToServer()
        end
    end
    buttonRequest:CenterHorizontal()

    local labelButtonRequest = vgui.Create("DLabel", buttonRequest)
    labelButtonRequest:SetPos(0,0)
    labelButtonRequest:SetText(language.GetPhrase("music.menu.request"))
    labelButtonRequest:SetFont("StarMusic_SubTitle")
    labelButtonRequest:SetTextColor(color_white)
    labelButtonRequest:SizeToContents()
    labelButtonRequest:Center()

    --[[-------------------------------------------------------------------------
    Button to pause the music
    -------------------------------------------------------------------------]]--
    local buttonPause = vgui.Create("DImageButton", panelContent)
    buttonPause:SetPos(0, StarnixMusic.RespY(320))
    buttonPause:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    buttonPause:SetImage(frameButtonImage)
    buttonPause.DoClick = function()
        net.Start("Music_PauseSong")
        net.SendToServer()
    end
    buttonPause:CenterHorizontal(0.75)

    local labelButtonPause = vgui.Create("DLabel", buttonPause)
    labelButtonPause:SetPos(0,0)
    labelButtonPause:SetText(language.GetPhrase("music.menu.pause"))
    labelButtonPause:SetFont("StarMusic_SubTitle")
    labelButtonPause:SetTextColor(color_orange)
    labelButtonPause:SizeToContents()
    labelButtonPause:Center()

    --[[-------------------------------------------------------------------------
    Change the volume of the music
    -------------------------------------------------------------------------]]--
    local containerSlider = vgui.Create("DPanel", panelContent)
    containerSlider:SetPos(0, StarnixMusic.RespY(400))
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
            LocalPlayer():ChatPrint(language.GetPhrase("music.menu.cooldownChange")..math.Round(volumeCooldownTimer - CurTime()).."s.")
        end
        
    end
    buttonValidate:CenterVertical()
    local labelVolume = vgui.Create("DLabel", buttonValidate)
    labelVolume:SetPos(0, 0)
    labelVolume:SetText(language.GetPhrase("music.menu.changeVolume"))
    labelVolume:SetFont("StarMusic_SubTitle")
    labelVolume:SetTextColor(color_white)
    labelVolume:SizeToContents()
    labelVolume:CenterHorizontal()

    containerSlider:CenterHorizontal()

    --[[-------------------------------------------------------------------------
    Button to stop the music
    -------------------------------------------------------------------------]]--
    local buttonStop = vgui.Create("DImageButton", panelContent)
    buttonStop:SetPos(0, StarnixMusic.RespY(320))
    buttonStop:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    buttonStop:SetImage(frameButtonImage)
    buttonStop.DoClick = function()
        hideEditMusicButtons(buttonStop, buttonPause, sliderVolume, buttonValidate, labelButtonRequest)
        net.Start("Music_StopSong")
        net.SendToServer()
    end
    buttonStop:CenterHorizontal(0.25)

    local labelButtonStop = vgui.Create("DLabel", buttonStop)
    labelButtonStop:SetPos(0,0)
    labelButtonStop:SetText(language.GetPhrase("music.menu.stop"))
    labelButtonStop:SetFont("StarMusic_SubTitle")
    labelButtonStop:SetTextColor(color_red)
    labelButtonStop:SizeToContents()
    labelButtonStop:Center()

    --[[-------------------------------------------------------------------------
    Hide stop button, pause button and change button if the player is not listening music.
    -------------------------------------------------------------------------]]--
    if not GLocalMusic.IsCreated() then
        hideEditMusicButtons(buttonStop, buttonPause, sliderVolume, buttonValidate, labelButtonRequest)
    elseif GLocalMusic.IsCreated() and labelButtonRequest:GetText() == language.GetPhrase("music.menu.request") then
        labelButtonRequest:SetText(language.GetPhrase("music.menu.change"))
        labelButtonRequest:SizeToContents()
        labelButtonRequest:Center()
    end
end