--[[
    MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
    Licensed under GNU General Public Licence version 2 or, at your option, any later version

    Options.lua - Functions for handling base options, and version conversion
]]

local L = mrp.L
local strtrim = strtrim

local LibRPMedia = LibStub:GetLibrary("LibRPMedia-1.0");

mrp.DefaultOptions = {
    Enabled = true,
    ShowButton = true,
    ShowBiographyInBrowser = true,
    ShowTraitsInBrowser = true,
    HeightUnit = L["option_HeightUnit"],
    WeightUnit = L["option_WeightUnit"],
    FormAutoChange = true,
    AllowColours = true,
    TooltipClassColours = true,
    IncreaseColourContrast = false,
    ClassNames = true,
    ShowOOC = true,
    ShowTarget = true,
    ShowVersion = true,
    ShowFullVersionText = false,
    HideTTInEncounters = false,
    ShowIconInTT = true,
    ShowGuildNames = true,
    ShowGlancePreview = true,
    MaxLinesSlider = 1,
    EquipSetAutoChange = true,
    GlancePosition = 0,
    TooltipStyle = 2,
    DEFontSize = 2,
    RPChatSay = true,
    RPChatWhisper = true,
    RPChatEmote = true,
    RPChatYell = true,
    RPChatParty = false,
    RPChatRaid = false,
    RPChatGuild = false,
    HighlightEmotes = true,
    HighlightOOC = true,
    ShowIconsInChat = false,
    AutoplayMusic = false,
}

function mrp:UpgradeSaved( build )
    build = build or 0
    if (mrp:IsMainlineClient() and build < 51) then
        -- Kill old temp unused options
        mrpSaved.Options.ImperialHeight = nil
        mrpSaved.Options.ImperialWeight = nil
        mrpSaved.Options.ShowInCombat = nil
        mrpSaved.Options.DisableInCombat = nil
        mrpSaved.Options.ShowInInstance = nil
        mrpSaved.Options.DisableInInstance = nil
        mrpSaved.Options.RelativeLevels = nil
        -- Set the new options to defaults
        mrpSaved.Options.Enabled = mrp.DefaultOptions.Enabled
        mrpSaved.Options.HeightUnit = mrp.DefaultOptions.HeightUnit
        mrpSaved.Options.WeightUnit = mrp.DefaultOptions.WeightUnit
    end
    if (mrp:IsMainlineClient() and build < 52) then
        for name, profile in pairs( mrpSaved.Profiles ) do
            -- Strip spaces
            for field, contents in pairs( profile ) do
                profile[ field ] = strtrim( contents )
            end
             -- Deal with people who put 01 in FR or FC
            if tonumber( profile.FR ) then
                profile.FR = tostring( tonumber( profile.FR ) )
            end
            if tonumber( profile.FC ) then
                profile.FC = tostring( tonumber( profile.FC ) )
            end
            -- RA should be blank if you aren't overriding, otherwise it messes up your race's localisation for other players
            if profile.RA == UnitRace("player") or profile.RA == select( 2, UnitRace("player") ) then
                profile.RA = ""
            end
            -- RC should be blank if you aren't overriding, otherwise it messes up your class' localisation for other players
            if profile.RC == UnitClass("player") or profile.RC ==  UnitClass("player") then
                profile.RC = ""
            end
        end
    end
    if (mrp:IsMainlineClient() and build < 58) then
        mrpSaved.Options.FormAutoChange = mrp.DefaultOptions.FormAutoChange
    end
    if (mrp:IsMainlineClient() and build < 59) then
        mrpSaved.Options.EquipSetAutoChange = mrp.DefaultOptions.EquipSetAutoChange
    end
    if (mrp:IsMainlineClient() and build < 70) then
        mrpSaved.PreviousProfileAuto = nil
        mrpSaved.HumanForm = nil
    end
    if (mrp:IsMainlineClient() and build < 73) then
        mrpSaved.Options.MRPButtonMoved = nil
        mrpSaved.Positions = {}
    end
    if (mrp:IsMainlineClient() and build < 82) then
        if mrpSaved.Options.ShowTooltip then
            mrpSaved.Options.TooltipStyle = 2
        else
            mrpSaved.Options.TooltipStyle = 0
        end
        mrpSaved.Options.ShowTooltip = nil
    end
    if (mrp:IsMainlineClient() and build < 86) then
        mrpSaved.Options.ShowRPNamesInChat = mrp.DefaultOptions.ShowRPNamesInChat
    end
    if (mrp:IsMainlineClient() and build < 420) then
        mrpSaved.Options.TooltipStyle = 2;
        mrpSaved.Options.AllowColours = true;
        mrpSaved.Options.ClassNames = true;
        mrpSaved.Options.ShowOOC = true;
        mrpSaved.Options.ShowTarget = false;
        mrpSaved.Options.ShowVersion = true;
        mrpSaved.Options.ShowGuildNames = true;
        mrpSaved.Options.HideTTInEncounters = false;
        mrpSaved.Options.MaxLinesSlider = 1;
    end
    if (mrp:IsMainlineClient() and build < 421) then
        mrpSaved.Options.ShowIconInTT = true;
    end
    if (mrp:IsMainlineClient() and build < 422) then
        mrpSaved.Options.TooltipStyle = 2;
    end
    if (mrp:IsMainlineClient() and build < 423) then
        mrpSaved.Options.ShowGlancePreview = true;
    end
    if (mrp:IsMainlineClient() and build < 424) then
        if(type(mrpNotes) ~= "table") then
            mrpNotes = {}
        end
    end
    if (mrp:IsMainlineClient() and build < 428) then
        mrpSaved.Options.AutoplayMusic = false;
        mrpSaved.Options.RPChatSay = true;
        mrpSaved.Options.RPChatWhisper = true;
        mrpSaved.Options.RPChatEmote = true;
        mrpSaved.Options.RPChatYell = true;
        mrpSaved.Options.RPChatParty = false;
        mrpSaved.Options.RPChatRaid = false;
    end
    if (mrp:IsMainlineClient() and build < 432) then
        mrpSaved.Options.ShowTraitsInBrowser = true;
        mrpSaved.Options.TooltipClassColours = true;
    end
    if (mrp:IsMainlineClient() and build < 436) then
        mrpSaved.Options.GlancePosition = 0;
    end
    if (mrp:IsMainlineClient() and build < 437) or (mrp:IsClassicClient() and build < 443) then
        mrpSaved.Options.ShowIconsInChat = false;
        mrpSaved.Options.ShowFullVersionText = false;
        mrpSaved.Options.RPChatGuild = false;
        mrpSaved.Options.HighlightEmotes = true;
        mrpSaved.Options.HighlightOOC = true;
        mrpSaved.Options.IncreaseColourContrast = false;

        for k, v in pairs(mrpSaved.Profiles) do
            if type(mrpSaved.Profiles[k]["MU"]) == "string" then -- Update old paths to IDs with new system.
                local fileID = LibRPMedia:GetMusicFileByName(mrpSaved.Profiles[k]["MU"])
                if fileID then
                    mrp:Print("Converted " .. mrpSaved.Profiles[k]["MU"] .. " to " .. fileID)
                    mrpSaved.Profiles[k]["MU"] = fileID
                else
                    mrp:Print("Could not convert your profile music to the new system - please reset your music manually.")
                end
            end
        end
    end
end
