StarnixMusic = StarnixMusic or {}
function StarnixMusic.infoMenu(panelContent)
    local textTitle = vgui.Create("DLabel", panelContent)
    textTitle:SetText("Credits:")
    textTitle:SetFont("StarMusic_Title")
    textTitle:SizeToContents()
    textTitle:SetPos(StarnixMusic.RespX(20), StarnixMusic.RespY(20))
    textTitle:CenterHorizontal()
    textTitle:SetColor(color_white)
    
    local textCreatorSubTitle1 = vgui.Create("DLabel", panelContent)
    textCreatorSubTitle1:SetText("Development:")
    textCreatorSubTitle1:SetFont("StarMusic_SubTitle")
    textCreatorSubTitle1:SizeToContents()
    textCreatorSubTitle1:SetPos(StarnixMusic.RespX(20), StarnixMusic.RespY(70))
    textCreatorSubTitle1:CenterHorizontal()
    textCreatorSubTitle1:SetColor(color_white)

    local textCreator1 = vgui.Create("DLabel", panelContent)
    textCreator1:SetText("Thanks to Starnix")
    textCreator1:SetFont("StarMusic_Text")
    textCreator1:SizeToContents()
    textCreator1:SetPos(StarnixMusic.RespX(20), StarnixMusic.RespY(120))
    textCreator1:SetColor(color_white)

    local textCreatorSubTitle2 = vgui.Create("DLabel", panelContent)
    textCreatorSubTitle2:SetText("Artists:")
    textCreatorSubTitle2:SetFont("StarMusic_SubTitle")
    textCreatorSubTitle2:SizeToContents()
    textCreatorSubTitle2:SetPos(StarnixMusic.RespX(20), StarnixMusic.RespY(170))
    textCreatorSubTitle2:CenterHorizontal()
    textCreatorSubTitle2:SetColor(color_white)

    local textCreator2 = vgui.Create("DLabel", panelContent)
    textCreator2:SetText("Thanks to Flaticon, juicy_fish, Ian June, Freepik, srip, SBTS2018, bahuraksa-font, dancing-script-font, alegreya-sans-font, DinosoftLabs, IYAHICON.")
    textCreator2:SetFont("StarMusic_Text")
    textCreator2:SetSize(panelContent:GetWide()-20, 100)
    textCreator2:SetPos(StarnixMusic.RespX(20), StarnixMusic.RespY(200))
    textCreator2:SetWrap(true)
    textCreator2:SetColor(color_white)

    local gitHubLinkLabel = vgui.Create("DButton", panelContent)
    gitHubLinkLabel:SetText("GitHub Link")
    gitHubLinkLabel:SetFont("StarMusic_SubTitle")
    gitHubLinkLabel:SetColor(color_white)
    gitHubLinkLabel:SetPos(StarnixMusic.RespX(20), StarnixMusic.RespY(300))
    gitHubLinkLabel.DoClick = function()
        gui.OpenURL("https://github.com/TheStarnix/GMusic")
    end
    gitHubLinkLabel:SetSize(StarnixMusic.RespX(115), StarnixMusic.RespY(30))
    gitHubLinkLabel.Paint = nil
    gitHubLinkLabel:CenterHorizontal()
    
end