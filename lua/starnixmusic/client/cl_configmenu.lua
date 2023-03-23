StarnixMusic = StarnixMusic or {}
local materialButtonYes = nil
local materialButtonNo = nil

local function changeButton(button, condition)
    if condition then
        button:SetMaterial(materialButtonYes)
    else
        button:SetMaterial(materialButtonNo)
    end
end

function StarnixMusic.ConfigMenu(panelContent)
    if not materialButtonNo then
        materialButtonNo = Material(StarnixMusic.materialspath .. "checkmark_no.png")
    end
    if not materialButtonYes then
        materialButtonYes = Material(StarnixMusic.materialspath .. "checkmark_ok.png")
    end
    local isAcceptingMusic = GetConVar("starnixmusic_acceptMusic")
    local isAcceptingMusicBool = isAcceptingMusic:GetBool()
    --[[-------------------------------------------------------------------------]
    Image Button to refuse all songs request
    ---------------------------------------------------------------------------]]
    local pConfigRequestMusicButton = vgui.Create("DImageButton", panelContent)
    pConfigRequestMusicButton:SetPos(StarnixMusic.RespX(70), StarnixMusic.RespY(50))
    pConfigRequestMusicButton:SetSize(StarnixMusic.RespX(32), StarnixMusic.RespY(32))
    pConfigRequestMusicButton:SetMaterial(materialButtonNo)
    pConfigRequestMusicButton.DoClick = function()
        isAcceptingMusicBool = !isAcceptingMusicBool
        isAcceptingMusic:SetBool(isAcceptingMusicBool)
        changeButton(pConfigRequestMusicButton, isAcceptingMusicBool)
    end
    changeButton(pConfigRequestMusicButton, isAcceptingMusicBool)

    --[[-------------------------------------------------------------------------]
    Text inside the Button
    ---------------------------------------------------------------------------]]
    local pConfigRequestMusicText = vgui.Create("DLabel", panelContent)
    pConfigRequestMusicText:SetPos(pConfigRequestMusicButton:GetX() + pConfigRequestMusicButton:GetTall() + StarnixMusic.RespX(10), pConfigRequestMusicButton:GetY())
    pConfigRequestMusicText:SetText(language.GetPhrase("music.config.AcceptMusics"))
    pConfigRequestMusicText:SetFont("StarMusic_Text")
    pConfigRequestMusicText:SetTextColor(color_white)
    pConfigRequestMusicText:SizeToContents()
end