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

local progressLevel = 50 -- We store the duration of the music
local maxTime = 63 -- We store where the player is in the music

local border_image = Material(StarnixMusic.materialspath .. "frame_bordered.png")
local Materialbutton_pause = Material(StarnixMusic.materialspath .. "icon_pause.png")
local Materialbutton_play = Material(StarnixMusic.materialspath .. "icon_play.png")
local Materialbutton_time = Material(StarnixMusic.materialspath .. "icon_time.png")
local Materialbutton_user = Material(StarnixMusic.materialspath .. "icon_users.png")
local Materialbutton_volume = Material(StarnixMusic.materialspath .. "icon_sound.png")
local frameButtonImage = StarnixMusic.materialspath .. "frame_combobox.png"
local frameBase = Material(StarnixMusic.materialspath .. "frame_base.png")
local iconClose = StarnixMusic.materialspath .. "icon_close.png"
local Materialmenu_bar = Material(StarnixMusic.materialspath .. "menu_bar.png")

--[[-------------------------------------------------------------------------]
We create the circle used in drawTimePanel. We create once to avoid performance loss.
---------------------------------------------------------------------------]]
local radius = 10 -- rayon du cercle
local segments = 10 -- nombre de segments pour dessiner le cercle
local x, y = 0, 10 -- position du centre du cercle

local circle = {}
table.insert(circle, {x = x, y = y}) -- ajouter le centre du cercle comme premier point
for i = 0, segments do
    local a = math.rad((i / segments) * -360)
    local px = x + math.sin(a) * radius
    local py = y + math.cos(a) * radius
    table.insert(circle, {x = px, y = py})
end

--[[-------------------------------------------------------------------------]
We create a function to draw the panel of the volume change.
---------------------------------------------------------------------------]]
local function drawVolumePanel()
    if soundPanel then 
        soundPanel:Remove() end
    if not GLocalMusic.IsValidSong() then return end
    local soundPanel = vgui.Create( "DFrame" )
    soundPanel:SetPos( ScrW()/2, ScrH()/2) -- Set the position of the panel
    soundPanel:SetSize(StarnixMusic.RespX(500), StarnixMusic.RespY(200)) -- Set the size of the panel
    soundPanel:SetVisible(true)
    soundPanel:SetDraggable(false)
    soundPanel:ShowCloseButton(false)
    soundPanel:SetTitle("")
    soundPanel.Paint = function(self,w,h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(frameBase)
        surface.DrawTexturedRect(0,0,w,h)
    end
    soundPanel:Center()

    local soundPanelTitle = vgui.Create("DLabel", soundPanel)
    soundPanelTitle:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(30))
    soundPanelTitle:SetSize(StarnixMusic.RespX(280), StarnixMusic.RespY(30))
    soundPanelTitle:SetFont("StarMusic_Title")
    soundPanelTitle:SetText(StarnixMusic.Language["music.menu.changeVolume"])
    soundPanelTitle:SetTextColor(color_white)
    soundPanelTitle:SizeToContents()
    soundPanelTitle:CenterHorizontal()

    local sliderPanel = vgui.Create("DPanel", soundPanel)
    sliderPanel:SetPos(StarnixMusic.RespX(25), StarnixMusic.RespY(100))
    sliderPanel:SetSize(soundPanel:GetWide(), StarnixMusic.RespY(40))
    sliderPanel.Paint = function(self, w, h)
    end

   -- Créer la barre de progression
    local slider = vgui.Create("DNumSlider", sliderPanel)
    slider:SetPos(0, 0)
    slider:SetSize(StarnixMusic.RespX(350), StarnixMusic.RespY(50))
    slider:SetMin(0)
    slider:SetMax(3)
    slider:SetDecimals(2)
    slider:SetValue(GLocalMusic.GetVolume())
    slider:CenterVertical()

    -- Modifier l'apparence de la barre de progression
    slider.Slider.Knob:DockMargin(0, 0, 0, 0)
    slider.Slider.Knob:SetSize(16, 16)
    slider.Slider.Knob.Paint = function(self, w, h)
        -- Dessiner un bouton bleu circulaire au centre de la barre de progression
        surface.SetDrawColor(StarnixMusic.colors["green"])
        draw.NoTexture()
        surface.DrawPoly(circle)
    end

    local buttonValidate = vgui.Create("DImageButton", soundPanel)
    buttonValidate:SetPos(0, StarnixMusic.RespY(140))
    buttonValidate:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    buttonValidate:SetImage(frameButtonImage)
    buttonValidate.DoClick = function()
        GLocalMusic.SetVolume(slider:GetValue())
    end
    buttonValidate:CenterHorizontal()

    local labelButtonRequest = vgui.Create("DLabel", buttonValidate)
    labelButtonRequest:SetPos(0,0)
    labelButtonRequest:SetText(StarnixMusic.Language["music.menu.change"])
    labelButtonRequest:SetFont("StarMusic_SubTitle")
    labelButtonRequest:SetTextColor(color_white)
    labelButtonRequest:SizeToContents()
    labelButtonRequest:Center()

    local closeButton = vgui.Create( "DImageButton", soundPanel)
	closeButton:SetPos(StarnixMusic.RespX(460), StarnixMusic.RespY(5))
	closeButton:SetImage(iconClose)
	closeButton:SizeToContents()
	closeButton.DoClick = function()
		soundPanel:Close()
	end

    
end

--[[-------------------------------------------------------------------------]
We create a function to draw the panel of the timing change request.
---------------------------------------------------------------------------]]
local function drawTimePanel()
    if timePanel then timePanel:Remove() end
    if not GLocalMusic.IsValidSong() then return end
    local timePanel = vgui.Create( "DFrame" )
    timePanel:SetPos( ScrW()/2, ScrH()/2) -- Set the position of the panel
    timePanel:SetSize(StarnixMusic.RespX(500), StarnixMusic.RespY(200)) -- Set the size of the panel
    timePanel:SetVisible(true)
    timePanel:SetDraggable(false)
    timePanel:ShowCloseButton(false)
    timePanel:SetTitle("")
    timePanel.Paint = function(self,w,h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(frameBase)
        surface.DrawTexturedRect(0,0,w,h)
    end
    timePanel:Center()

    local timePanelTitle = vgui.Create("DLabel", timePanel)
    timePanelTitle:SetPos(StarnixMusic.RespX(0), StarnixMusic.RespY(30))
    timePanelTitle:SetSize(StarnixMusic.RespX(280), StarnixMusic.RespY(30))
    timePanelTitle:SetFont("StarMusic_Title")
    timePanelTitle:SetText(StarnixMusic.Language["music.hud.time"])
    timePanelTitle:SetTextColor(color_white)
    timePanelTitle:SizeToContents()
    timePanelTitle:CenterHorizontal()

    local secondsLabel = vgui.Create("DLabel", timePanel)
    secondsLabel:SetPos(0, StarnixMusic.RespY(70))
    secondsLabel:SetSize(StarnixMusic.RespX(280), StarnixMusic.RespY(100))
    secondsLabel:SetFont("StarMusic_SubTitle")
    secondsLabel:SetText("")
    secondsLabel:SetTextColor(color_white)
    secondsLabel:SizeToContents()
    secondsLabel:CenterHorizontal()


    local sliderPanel = vgui.Create("DPanel", timePanel)
    sliderPanel:SetPos(StarnixMusic.RespX(25), StarnixMusic.RespY(100))
    sliderPanel:SetSize(timePanel:GetWide(), StarnixMusic.RespY(40))
    sliderPanel.Paint = function(self, w, h)
    end

   -- Créer la barre de progression
    local slider = vgui.Create("DNumSlider", sliderPanel)
    slider:SetPos(0, 0)
    slider:SetSize(StarnixMusic.RespX(350), StarnixMusic.RespY(50))
    slider:SetMin(0)
    slider:SetMax(GLocalMusic.GetDuration())
    slider:SetDecimals(0)
    slider:SetValue(GLocalMusic.GetTime())
    slider:CenterVertical()

    -- Modifier l'apparence de la barre de progression
    slider.Slider.Knob:DockMargin(0, 0, 0, 0)
    slider.Slider.Knob:SetSize(16, 16)
    slider.Slider.Knob.Paint = function(self, w, h)
        -- Dessiner un bouton bleu circulaire au centre de la barre de progression
        surface.SetDrawColor(StarnixMusic.colors["green"])
        draw.NoTexture()
        surface.DrawPoly(circle)
    end

    slider.OnValueChanged = function( self, value )
        secondsLabel:SetText(string.ToMinutesSeconds(value))
        secondsLabel:SizeToContents()
        secondsLabel:CenterHorizontal()
    end

    local buttonValidate = vgui.Create("DImageButton", timePanel)
    buttonValidate:SetPos(0, StarnixMusic.RespY(140))
    buttonValidate:SetSize(StarnixMusic.RespX(200), StarnixMusic.RespY(50))
    buttonValidate:SetImage(frameButtonImage)
    buttonValidate.DoClick = function()
        net.Start("Music_ChangeTime") -- Send the request to the server
            net.WriteFloat(slider:GetValue())
        net.SendToServer()
    end
    buttonValidate:CenterHorizontal()

    local labelButtonRequest = vgui.Create("DLabel", buttonValidate)
    labelButtonRequest:SetPos(0,0)
    labelButtonRequest:SetText(StarnixMusic.Language["music.menu.change"])
    labelButtonRequest:SetFont("StarMusic_SubTitle")
    labelButtonRequest:SetTextColor(color_white)
    labelButtonRequest:SizeToContents()
    labelButtonRequest:Center()

    local closeButton = vgui.Create( "DImageButton", timePanel )
	closeButton:SetPos(StarnixMusic.RespX(460), StarnixMusic.RespY(5))
	closeButton:SetImage(iconClose)
	closeButton:SizeToContents()
	closeButton.DoClick = function()
		timePanel:Close()
	end

    
end

local function changeMaterialButton(state, button)
    if state then
        button:SetMaterial(Materialbutton_play)
    else
        button:SetMaterial(Materialbutton_pause)
    end
    
end

--[[-------------------------------------------------------------------------
We create a function to draw the music player.
---------------------------------------------------------------------------]]
function StarnixMusic.drawHUD()
    if not GLocalMusic.IsValidSong() then return end
    local isStaff = StarnixMusic.adminGroups[LocalPlayer():GetUserGroup()] or false
    local creator = GLocalMusic.GetCreator() == LocalPlayer()

    local reduced = false

    local pauseState = GLocalMusic.IsPaused()

    frameHudMusic = vgui.Create( "DFrame" )
    frameHudMusic:SetPos( ScrW()-StarnixMusic.RespX(340), 20) -- Set the position of the panel
    frameHudMusic:SetSize( StarnixMusic.RespX(320), StarnixMusic.RespY(200)) -- Set the size of the panel
    frameHudMusic:SetVisible(true)
    frameHudMusic:SetDraggable(false)
    frameHudMusic:ShowCloseButton(false)
    frameHudMusic:SetTitle("")


    -- Draw a button to pause the music
    local pauseButton = vgui.Create("DImageButton", frameHudMusic)
    pauseButton:SetPos(StarnixMusic.RespX(48), StarnixMusic.RespY(120))
    pauseButton:SetSize(32, 32)
    pauseButton:SetVisible(true)
    pauseButton.DoClick = function()
        if GLocalMusic.IsValidSong() then
            pauseState = not pauseState
            changeMaterialButton(pauseState, pauseButton)
            net.Start("Music_PauseSong")
            net.SendToServer()
        end
    end
    changeMaterialButton(pauseState, pauseButton)

    -- Draw a button to change the time of the music
    local timeButton = vgui.Create("DImageButton", frameHudMusic)
    timeButton:SetPos(StarnixMusic.RespX(98), StarnixMusic.RespY(120))
    timeButton:SetSize(32, 32)
    timeButton:SetVisible(true)
    timeButton:SetMaterial(Materialbutton_time)
    timeButton.DoClick = function()
        if GLocalMusic.IsValidSong() then
            drawTimePanel()
        end
    end

    -- Draw a button to readjust the volume of the music
    local volumeButton = vgui.Create("DImageButton", frameHudMusic)
    volumeButton:SetPos(StarnixMusic.RespX(158), StarnixMusic.RespY(120))
    volumeButton:SetSize(32, 32)
    volumeButton:SetVisible(true)
    volumeButton:SetMaterial(Materialbutton_volume)
    volumeButton.DoClick = function()
        if GLocalMusic.IsValidSong() then
            drawVolumePanel()
        end
    end

    -- Draw a button to handle the users systems
    local userButton = vgui.Create("DImageButton", frameHudMusic)
    userButton:SetPos(StarnixMusic.RespX(218), StarnixMusic.RespY(120))
    userButton:SetSize(32, 32)
    userButton:SetVisible(true)
    userButton:SetMaterial(Materialbutton_user)
    userButton.DoClick = function()
        if GLocalMusic.IsValidSong() then
            StarnixMusic.drawGroups()
        end
    end
    if creator or isStaff then
        userButton:SetVisible(true)
    else
        userButton:SetVisible(false)
    end

    local reduceFrame = vgui.Create("DImageButton", frameHudMusic)
    reduceFrame:SetPos(StarnixMusic.RespX(278), StarnixMusic.RespY(150))
    reduceFrame:SetSize(32, 32)
    reduceFrame:SetVisible(true)
    reduceFrame:SetMaterial(Materialmenu_bar)
    reduceFrame.DoClick = function()
        reduced = not reduced
        if reduced then
            reduceFrame:SetPos(StarnixMusic.RespX(278), StarnixMusic.RespY(5))
            frameHudMusic:SetSize( StarnixMusic.RespX(320), StarnixMusic.RespY(100)) -- Set the size of the panel
        else
            reduceFrame:SetPos(StarnixMusic.RespX(278), StarnixMusic.RespY(150))
            frameHudMusic:SetSize( StarnixMusic.RespX(320), StarnixMusic.RespY(200)) -- Set the size of the panel
        end
    end


    frameHudMusic.Paint = function(self, w, h)
        if not GLocalMusic.IsValidSong() then 
            frameHudMusic:Close()
        end
        local creatorNick = "???"
        local getCreator = GLocalMusic.GetCreator()
        if IsValid(getCreator) then
            creatorNick = getCreator:Nick()
        end
        -- Draw the background of the music player
        surface.SetDrawColor(color_white)
        surface.SetMaterial(border_image)
        surface.DrawTexturedRect(0, 0, w, h)

        -- Draw the title of the music player
        draw.DrawText(StarnixMusic.Language["music.hud.music"], "StarMusic_Title", w/2, StarnixMusic.RespY(20), color_white, TEXT_ALIGN_CENTER )

        -- Draw the title of the music
        draw.DrawText(GLocalMusic.GetTitle(), "StarMusic_SubTitle_Bold", w/2, StarnixMusic.RespY(60), color_white, TEXT_ALIGN_CENTER )

        -- Draw a progress bar showing the duration of the music and the actual time of the music by using GLocalMusic.GetTime()
        surface.SetDrawColor(StarnixMusic.colors["grey"])
        surface.DrawRect(w/6, StarnixMusic.RespY(100), 200, 10)
        if GLocalMusic.IsPaused() then
            surface.SetDrawColor(StarnixMusic.colors["orange"])
        else
            surface.SetDrawColor(StarnixMusic.colors["green"])
        end
        
        surface.DrawRect(w/6, StarnixMusic.RespY(100), (GLocalMusic.GetTime() / GLocalMusic.GetDuration()) * 200, 10)
        
        -- Draw the time of the music juste after the progress bar
        draw.DrawText(string.ToMinutesSeconds(math.Round(GLocalMusic.GetTime())) .. " / " .. string.ToMinutesSeconds(math.Round(GLocalMusic.GetDuration())), "StarMusic_Text", w/2, StarnixMusic.RespY(90), color_white, TEXT_ALIGN_CENTER)

        -- Draw text showing who choosed the music
        draw.DrawText(StarnixMusic.Language["music.hud.choosenBy"] ..creatorNick, "StarMusic_Text", w/2, StarnixMusic.RespY(150), color_white, TEXT_ALIGN_CENTER )

    end
end

hook.Add("Think", "StarnixMusic_HUDDisplay", function()
    if IsValid(frameHudMusic) then return end
    if GLocalMusic.IsValidSong() then 
        StarnixMusic.drawHUD()
    end
end)

concommand.Add( "gmusic_panic", function( ply, cmd, args )
    if GLocalMusic.IsValidSong() then
        GLocalMusic.Stop()
    else
        RunConsoleCommand("stopsound")
    end
    if IsValid(frameHudMusic) then
        frameHudMusic:Close()
    end
end )