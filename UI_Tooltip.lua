--[[
    MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
    Licensed under GNU General Public Licence version 2 or, at your option, any later version

    UI_Tooltip.lua - Functions to handle the MRP tooltips
]]

local L = mrp.L

-- Tooltip is shown from an unknown/default context, like mousing over a unit.
mrp.TOOLTIP_CONTEXT_DEFAULT = "mrp:default";
-- Tooltip is shown by the MRP helper button.
mrp.TOOLTIP_CONTEXT_BUTTON = "mrp:button";

-- Maximum length of the player name before we truncate it.
local TOOLTIP_MAX_PLAYER_NAME_LENGTH = 30;
-- Maximum length of the target name before we strip the player's title.
local TOOLTIP_MAX_TARGET_NAME_LENGTH = 9;

-- Default format strings for icons in tooltips.
local TOOLTIP_PLAYER_ICON_FORMAT = [[|TInterface\Icons\%s:22:22:0:-2|t]];
local TOOLTIP_DEFAULT_ICON_FORMAT = [[|TInterface\Icons\%s:17:17:0:-2|t]];

-- Preformatted strings for icons in tooltips.
local TOOLTIP_TARGET_ICON = format(TOOLTIP_DEFAULT_ICON_FORMAT, "Ability_Hunter_SniperShot");
local TOOLTIP_RELATIONSHIP_TAKEN_ICON = format(TOOLTIP_DEFAULT_ICON_FORMAT,
    mrp:IsMainlineClient() and "petbattle_health" or "INV_ValentinesBoxOfChocolates02");
local TOOLTIP_RELATIONSHIP_MARRIED_ICON = format(TOOLTIP_DEFAULT_ICON_FORMAT,
    mrp:IsMainlineClient() and "petbattle_health" or "INV_ValentinesBoxOfChocolates02");
local TOOLTIP_NOTES_ICON = "|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:17:17:0:-2|t";

-- Color constants used when rendering enhanced tooltips.
local TOOLTIP_FACTION_ALLIANCE_COLOR = CreateColor(0.4, 0.5, 0.9);
local TOOLTIP_FACTION_HORDE_COLOR = CreateColor(0.8, 0.3, 0.3);
local TOOLTIP_FACTION_NEUTRAL_COLOR = CreateColor(0.4, 0.9, 0.4);
local TOOLTIP_FIELD_NH_COLOR = CreateColor(0.4, 0.6, 0.7);
local TOOLTIP_FIELD_NI_COLOR = CreateColor(0.6, 0.7, 0.9);
local TOOLTIP_FIELD_NT_COLOR = CreateColor(0.6, 0.7, 0.9);
local TOOLTIP_FIELD_TR_COLOR = CreateColor(0.2, 1, 0.26);
local TOOLTIP_GUILDMASTER_COLOR = CreateColor(1, 0.93, 0.67);
local TOOLTIP_RP_STATUS_DEFAULT_COLOR = CreateColor(0.5, 0.5, 0.5);
local TOOLTIP_RP_STATUS_IC_COLOR = CreateColor(0.4, 0.7, 0.5);
local TOOLTIP_RP_STATUS_LFC_COLOR = CreateColor(0.6, 0.7, 0.8);
local TOOLTIP_RP_STATUS_OOC_COLOR = CreateColor(0.6, 0.1, 0.06);
local TOOLTIP_RP_STATUS_STORYTELLER_COLOR = CreateColor(0.9, 0.8, 0.7);
local TOOLTIP_TARGET_COLOR = CreateColor(1, 0.82, 0.01);
local TOOLTIP_CURRENTLY_COLOR = CreateColor(0.6, 0.7, 0.9);
local TOOLTIP_OOC_COLOR = CreateColor(0.6, 0.7, 0.9);
local TOOLTIP_VERSION_COLOR = CreateColor(1, 0.82, 0.01);
local TOOLTIP_GUID_COLOR = CreateColor(0.4, 0.5, 0.6);
local TOOLTIP_PHASE_COLOR = CreateColor(0.4, 0.7, 0.7);
local TOOLTIP_DEVELOPER_COLOR = CreateColor(1.0, 0.7, 1.0);

local function emptynil( x ) return x ~= "" and x or nil end

local function mrp_MouseoverEvent( this, event, addon )
    if event == "UPDATE_MOUSEOVER_UNIT" then
        if not mrpSaved.Options.Enabled then
            return true
        end
        if UnitIsUnit( "player", "mouseover" ) then
            mrp:UpdateTooltip( UnitName("player"), "player" )
        elseif UnitIsPlayer("mouseover") then
            msp:Request( mrp:UnitNameWithRealm("mouseover"), {'TT', 'PE'} )
            mrp:UpdateTooltip( mrp:UnitNameWithRealm("mouseover"), "mouseover" )
        else
            mrp.TTShown = nil
        end
        return true
    end
end

local tooltipFrame = CreateFrame("Frame")
tooltipFrame:SetScript( "OnEvent", mrp_MouseoverEvent )

-- Disable TT during combat.

local function mrp_EncounterStartEnd(this, event, encounterID, encounterName, difficultyID, groupSize, success)
    if(mrpSaved.Options.HideTTInEncounters and mrpSaved.Options.HideTTInEncounters == true) then
        if(event == "PLAYER_REGEN_DISABLED") then
            mrp:UnhookTooltip()
        elseif(event == "PLAYER_REGEN_ENABLED") then
            mrp:HookTooltip()
        end
    end
end

--

local encounterFrame = CreateFrame("Frame")
encounterFrame:SetScript( "OnEvent", mrp_EncounterStartEnd )
encounterFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
encounterFrame:RegisterEvent("PLAYER_REGEN_DISABLED");

function mrp:HookTooltip()
    tooltipFrame:RegisterEvent( "UPDATE_MOUSEOVER_UNIT" )
    -- also hook GameTooltip:SetUnit()
end

function mrp:UnhookTooltip()
    tooltipFrame:UnregisterEvent( "UPDATE_MOUSEOVER_UNIT" )
    -- also unhook GameTooltip:SetUnit()
end

local GetClassIconString = function(class, icon_size) -- Function to get the correct icon string for a race.
    local classLookupTable = {
            ["Warrior"]       = "WARRIOR",
            ["Paladin"]       = "PALADIN",
            ["Hunter"]        = "HUNTER",
            ["Rogue"]         = "ROGUE",
            ["Priest"]        = "PRIEST",
            ["Death Knight"]  = "DEATHKNIGHT",
            ["Shaman"]        = "SHAMAN",
            ["Mage"]          = "MAGE",
            ["Warlock"]       = "WARLOCK",
            ["Monk"]          = "MONK",
            ["Druid"]         = "DRUID",
            ["Demon Hunter"]  = "DEMONHUNTER",
    };

    local classIconStrings = {
        ["WARRIOR"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:0:16:0:16|t",
        ["MAGE"]    = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:16:32:0:16|t",
        ["ROGUE"]   = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:32:48:0:16|t",
        ["DRUID"]   = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:47:64:0:16|t",
        ["HUNTER"]  = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:0:16:16:32|t",
        ["SHAMAN"]  = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:16:32:16:32|t",
        ["PRIEST"]  = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:32:48:16:32|t",
        ["WARLOCK"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:48:64:16:32|t",
        ["PALADIN"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-1.7:64:64:0:16:32:48|t",
        ["DEATHKNIGHT"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:16:32:32:48|t",
        ["MONK"]    = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:32:48:32:48|t",
        ["DEMONHUNTER"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:48:64:32:48|t",
    };

    if((classLookupTable[class] == nil)) then
        return tostring(class);
    else
        return string.format(classIconStrings[classLookupTable[class]], icon_size or 17, icon_size or 17);
    end
end

local function CommonTooltip_ResetToUnit(tooltip, unit)
    GameTooltip_SetDefaultAnchor(tooltip, UIParent);
    tooltip:SetUnit(unit);
    tooltip.mrpNumLines = nil;
end

local function CommonTooltip_GetLineFontStrings(tooltip, lineIndex)
    local name = tooltip:GetName();

    -- Grab the fontstrings by their global names.
    local left = _G[strjoin("", name, "TextLeft", tostring(lineIndex))];
    local right = _G[strjoin("", name, "TextRight", tostring(lineIndex))];

    return left, right;
end

local function CommonTooltip_AddColoredLine(tooltip, text, color, wrap)
    local lineIndex = tooltip.mrpNumLines or 1;
    if lineIndex > tooltip:NumLines() then
        -- We're adding a new line.
        GameTooltip_AddColoredLine(tooltip, text, color, wrap);
    else
        -- We're replacing an existing line.
        local left, right = CommonTooltip_GetLineFontStrings(tooltip, lineIndex);
        if left then
            left:SetText(text);
            left:SetTextColor(color:GetRGB());
            -- Wrapping recycled lines isn't supported.
            left:Show();
        end

        if right then
            right:Hide();
        end
    end

    tooltip.mrpNumLines = lineIndex + 1;
end

local function CommonTooltip_AddDoubleLine(tooltip, leftText, leftColor, rightText, rightColor)
    local lineIndex = tooltip.mrpNumLines or 1;
    if lineIndex > tooltip:NumLines() then
        -- We're adding a new line.
        tooltip:AddDoubleLine(
            leftText,
            rightText,
            leftColor.r, leftColor.g, leftColor.b,
            rightColor.r, rightColor.g, rightColor.b
        );
    else
        -- We're replacing an existing line.
        local left, right = CommonTooltip_GetLineFontStrings(tooltip, lineIndex);
        if left then
            left:SetText(leftText);
            left:SetTextColor(leftColor:GetRGB());
            -- Wrapping recycled lines isn't supported.
            left:Show();
        end

        if right then
            right:SetText(rightText);
            right:SetTextColor(rightColor:GetRGB());
            -- Wrapping recycled lines isn't supported.
            right:Show();
        end
    end

    tooltip.mrpNumLines = lineIndex + 1;
end

local function CommonTooltip_AddBlankLine(tooltip)
    -- Don't add a blank line if using compact tooltip mode.
    if mrpSaved.Options.TooltipStyle ~= 3 then
        CommonTooltip_AddColoredLine(tooltip, " ", TOOLTIP_DEFAULT_COLOR)
    end
end

local function CommonTooltip_AddDeveloperLine(tooltip, player, unit)
    local guid = UnitGUID(unit);
    if not guid then
        -- Unit doesn't have a GUID.
        return;
    end

    local id = mrp.id[guid];
    if not id or id.project ~= WOW_PROJECT_ID then
        -- GUID isn't on the list, or it is but it doesn't correspond to the
        -- active game version being played.
        return;
    end

    -- Get the realm of the unit in question.
    local _, unitRealm = UnitName(unit);
    if not unitRealm then
        unitRealm = GetRealmName();
    end

    -- Verify that the GUID and realm match.
    if id.realm ~= unitRealm then
        -- GUID collision on the wrong realm.
        return;
    end

    -- Prefix the label with an icon.
    local text = id.text;
    if id.icon then
        text = strjoin("  ", id.icon, id.text);
    end

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1);
    GameTooltip_AddColoredLine(tooltip, text, TOOLTIP_DEVELOPER_COLOR);
end

local function BasicTooltip_AddNameLine(tooltip, player, unit)
    -- Default the name we'll display to the full title/player name.
    local displayName = UnitPVPName(unit) or UnitName(unit);

    local profile = msp.char[player];
    if emptynil(profile.field.NA) then
        -- A custom name exists, so use that.
        displayName = mrp.DisplayTooltip.NA(profile.field.NA);
        displayName = mrp:IncreaseColourContrast(displayName);
    end

    -- We assume this is called first, and thus will replace the first line.
    local unitColor = CreateColor(mrp:UnitColour(unit));
    CommonTooltip_AddColoredLine(tooltip, displayName, unitColor);
end

local function BasicTooltip_AddNicknameLine(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported then
        -- Player doesn't have a profile, so don't add any line.
        return;
    end

    local nickname = profile.field.NT;
    local nicknameText = mrp.DisplayTooltip.NT(nickname);
    if not emptynil(nickname) then
        -- Player has no nickname.
        return;
    end

    -- Explicitly add a new line rather than replace any existing.
    local text = format("|cffcec185“|cfffef1b5%s|cffcec185”", nicknameText);
    GameTooltip_AddColoredLine(tooltip, text, TOOLTIP_DEFAULT_COLOR);
end

local function BasicTooltip_AddRoleplayStatusStyleLine(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported then
        -- Player doesn't have a profile, so don't add any line.
        return;
    end

    -- Grab the status and style data.
    local style = emptynil(profile.field.FR);
    local styleText;
    if style and style ~= "0" then
        styleText = format("|cffeebb55%s|cffcc9933", mrp.DisplayTooltip.FR(style));
    end

    local status = emptynil(profile.field.FC);
    local statusText;
    if status and status ~= "0" then
        statusText = format("|cffeebb55%s|cffcc9933", mrp.DisplayTooltip.FC(status));
    end

    -- Render the line appropriately, separating the fields by commas if
    -- both are present or not at all if only one is present.
    local line;
    if styleText and statusText then
        line = format("|cffcc9933<%s, %s>", styleText, statusText);
    elseif styleText or statusText then
        line = format("|cffcc9933<%s>", styleText or statusText);
    else
        -- If neither is available, show the version field. Old behaviour.
        line = format("|cff44aaaa[|cff66dddd%s|cff44aaaa]", mrp.DisplayTooltip.VA(profile.field.VA));
    end

    -- Explicitly add a new line rather than replace any existing.
    GameTooltip_AddColoredLine(tooltip, line, TOOLTIP_DEFAULT_COLOR);
end

local function EnhancedTooltip_AddNameLine(tooltip, player, unit)
    -- Grab a name and appropriate color for this unit.
    local unitName = UnitName(unit);
    local unitColor = CreateColor(mrp:UnitColour(unit));

    local profile = msp.char[player];
    if not profile.supported then
        -- They don't have an MSP profile, so we'll just put in a name.
        CommonTooltip_AddColoredLine(tooltip, unitName, unitColor);
        return;
    end

    -- Grab the name from the profile.
    local profileName = emptynil(mrp.DisplayTooltip.NA(profile.field.NA));
    if not profileName then
        profileName = unitName;
    else
        -- The custom name might contain a color, so fix contrast.
        profileName = mrp:IncreaseColourContrast(profileName);
    end

    -- Prefix should be an icon if enabled.
    local prefix = "";
    if emptynil(profile.field.IC) and mrpSaved.Options.ShowIconInTT then
        prefix = format(TOOLTIP_PLAYER_ICON_FORMAT, profile.field.IC) .. " ";
    end

    -- The suffix should be any AFK/DND markers.
    local suffix = "";
    if UnitIsAFK(unit) then
		if(mrp:IsClassicClient()) then
			suffix = L[" |cffff9933<AFK>|r"];
		else
			suffix = L[" |cffff9933<Away>|r"];
		end
    elseif UnitIsDND(unit) then
		if(mrp:IsClassicClient()) then
			suffix = L[" |cff994d4d<DND>|r"];
		else
			suffix = L[" |cff994d4d<Busy>|r"];
		end
    end

    local text = strjoin("", prefix, profileName, suffix);
    CommonTooltip_AddColoredLine(tooltip, text, unitColor);
end

local function EnhancedTooltip_AddTrialMarkerLine(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported then
        -- Player doesn't have a profile, so don't add any line.
        return;
    end

    if profile.field.TR == "1" or profile.field.TR == "2" then
        CommonTooltip_AddColoredLine(tooltip, L["<Trial Account>"], TOOLTIP_FIELD_TR_COLOR);
    end
end

local function EnhancedTooltip_AddTitleLine(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported then
        -- Player doesn't have a profile, so don't add any line.
        return;
    end

    local title = emptynil(profile.field.NT);
    if not title then
        -- Player has no custom title.
        return;
    end

    local text = mrp.DisplayTooltip.NT(title);
    CommonTooltip_AddColoredLine(tooltip, text, TOOLTIP_FIELD_NT_COLOR);
end

local function EnhancedTooltip_AddNicknameLine(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported then
        -- Player doesn't have a profile, so don't add any line.
        return;
    end

    local nickname = emptynil(profile.field.NI);
    if not nickname then
        -- Player has no custom nickname.
        return;
    end

    local text = format("|cff6070a0" .. L["NI"] .. ":|r %s", mrp.DisplayTooltip.NI(nickname));
    CommonTooltip_AddColoredLine(tooltip, text, TOOLTIP_FIELD_NI_COLOR);
end

local function EnhancedTooltip_AddHouseLine(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported then
        -- Player doesn't have a profile, so don't add any line.
        return;
    end

    local house = emptynil(profile.field.NH);
    if not house then
        -- Player has no custom house.
        return;
    end

    local text = mrp.DisplayTooltip.NH(house);
    CommonTooltip_AddColoredLine(tooltip, text, TOOLTIP_FIELD_NH_COLOR);
end

local function EnhancedTooltip_AddGuildLine(tooltip, player, unit)
    local guild, rank, rankIndex = GetGuildInfo(unit);
    if not guild then
        -- Unit isn't in a guild.
        return;
    end

    -- Show guild ranks or not?
    if mrpSaved.Options.ShowGuildNames then
        if rankIndex == 0 then
            -- Color the guildmaster rank text itself.
            rank = TOOLTIP_GUILDMASTER_COLOR:WrapTextInColorCode(rank);
        end

        local text = format(L["%s of <%s>"], rank, guild);
        CommonTooltip_AddColoredLine(tooltip, text, TOOLTIP_DEFAULT_COLOR);
    else
        -- No ranking, but color the guild itself if they're the GM.
        local text = format("<%s>", guild);
        if rankIndex == 0 then
            text = TOOLTIP_GUILDMASTER_COLOR:WrapTextInColorCode(text);
        end

        CommonTooltip_AddColoredLine(tooltip, text, TOOLTIP_DEFAULT_COLOR);
    end
end

local function EnhancedTooltip_AddPlayerTargetLine(tooltip, player, unit)
    local _, otherrealm = UnitName(unit);
    local nameWithTitle = UnitPVPName(unit) or UnitName(unit);
    local class = UnitClass(unit);
    local faction = UnitFactionGroup(unit);

    -- Change color of the left side based on faction.
    local factionColor = TOOLTIP_FACTION_NEUTRAL_COLOR;
    if faction == "Alliance" then
        factionColor = TOOLTIP_FACTION_ALLIANCE_COLOR;
    elseif faction == "Horde" then
        factionColor = TOOLTIP_FACTION_HORDE_COLOR;
    end

    -- Reduce name with title string length if too long to avoid bloating our tooltip.
    if nameWithTitle and #nameWithTitle > TOOLTIP_MAX_PLAYER_NAME_LENGTH then
        nameWithTitle = strsub(nameWithTitle, 1, TOOLTIP_MAX_PLAYER_NAME_LENGTH - 1) .. "…";
    end

    -- The line will be formatted with the player information on the
    -- left, and the target on the right. The left info can be prefixed
    -- with an icon for class, and suffixed by a realm name.
    local leftPrefix = GetClassIconString(class);
    local leftSuffix = "";
    if emptynil(otherrealm) then
        -- Player is from another realm.
        leftSuffix = format("[%s]", otherrealm);
    end

    local targetUnit = unit .. "target";
    if UnitExists(targetUnit) and mrpSaved.Options.ShowTarget then
        -- Unit has a target, and we want to show it.
        local _, targetClassToken = UnitClass(targetUnit);
        local targetName = UnitName(targetUnit);
        local targetColor = RAID_CLASS_COLORS[targetClassToken] or TOOLTIP_TARGET_COLOR;

        -- If the target has a long name, strip our rank information.
        if #targetName > TOOLTIP_MAX_TARGET_NAME_LENGTH then
            nameWithTitle = UnitName(unit);
        end

        -- Draw as as double line.
        local leftText = strjoin(" ", leftPrefix, nameWithTitle, leftSuffix);
        local rightText = strjoin(" ", TOOLTIP_TARGET_ICON, targetName);

        CommonTooltip_AddDoubleLine(tooltip, leftText, factionColor, rightText, targetColor);
    else
        -- Unit doesn't have a target, so format as one line.
        local leftText = strjoin(" ", leftPrefix, nameWithTitle, leftSuffix);
        CommonTooltip_AddColoredLine(tooltip, leftText, factionColor);
    end
end

local function EnhancedTooltip_AddClassLevelRaceLine(tooltip, player, unit)
    -- Obtain class and race information.
    local unitClass, unitClassToken = UnitClass(unit);
    local unitClassColor = RAID_CLASS_COLORS[unitClassToken];
    local unitRace = UnitRace(unit) or "";

    -- Format the level information.
    local level = UnitLevel(unit);
    local levelText;
    if level ~= nil and level < 0 then
        levelText = L["|cffffffff(Boss)"];
    else
        levelText = format("|cffffffff%s %d", L["level"], level);
    end

    -- Grab the profile.
    local profile = msp.char[player];
    if not profile.supported then
        -- Player doesn't have a profile; we'll put in basic information.
        local text = strjoin(" ", levelText, unitRace, "|r" .. unitClass);
        CommonTooltip_AddColoredLine(tooltip, text, unitClassColor);
        return;
    end

    -- Grab the data from the profile.
    local profileClass = emptynil(profile.field.RC);
    if not profileClass or not mrpSaved.Options.ClassNames then
        -- No custom class or the user doesn't want to show them.
        profileClass = unitClass;
    end

    local profileRace = emptynil(mrp.DisplayTooltip.RA(profile.field.RA));
    if not profileRace then
        -- No custom race.
        profileRace = unitRace;
    end

    if not mrpSaved.Options.AllowColours or not mrpSaved.Options.TooltipClassColours then
        -- Strip class colouring information.
        profileClass = profileClass:gsub("^|c%x%x%x%x%x%x%x%x", "");
    else
        -- Increase the contrast if present.
        profileClass = mrp:IncreaseColourContrast(profileClass);
    end

    -- Ensure class names aren't crazy long.
    profileClass = mrp:TruncateField(profileClass, 20);

    local text = strjoin(" ", levelText, profileRace, "|r" .. profileClass);
    CommonTooltip_AddColoredLine(tooltip, text, unitClassColor);
end

local function EnhancedTooltip_AddRoleplayStyleStatusLine(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported then
        -- Player doesn't have a profile, so don't add any line.
        return;
    end

    local style = emptynil(profile.field.FR);
    if style == "0" then
        -- Exclude a literal "0" for this field.
        style = nil;
    end

    local status = emptynil(profile.field.FC);
    if status == "0" then
        -- Exclude a literal "0" for this field.
        status = nil;
    end

    -- If we don't have anything at all, ignore the line.
    if not style and not status then
        return;
    end

    -- Convert things into text.
    local styleText = style and mrp.DisplayTooltip.FR(style) or " ";
    local statusText = status and mrp.DisplayTooltip.FC(status) or " ";

    local color = TOOLTIP_DEFAULT_COLOR;
    if status == "0" then
        color = TOOLTIP_RP_STATUS_DEFAULT_COLOR;
    elseif status == "1" then
        color = TOOLTIP_RP_STATUS_OOC_COLOR;
    elseif status == "2" then
        color = TOOLTIP_RP_STATUS_IC_COLOR;
    elseif status == "3" then
        color = TOOLTIP_RP_STATUS_LFC_COLOR;
    elseif status == "4" then
        color = TOOLTIP_RP_STATUS_STORYTELLER_COLOR;
    end

    -- Add a spacing line before the actual content.
    CommonTooltip_AddBlankLine(tooltip)
    CommonTooltip_AddDoubleLine(tooltip, styleText, color, statusText, color);
end

local function EnhancedTooltip_AddCurrentlyText(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported then
        -- Player doesn't have a profile, so don't add any line.
        return;
    end

    local currently = mrp.DisplayTooltip.CU(profile.field.CU);
    if not emptynil(currently) then
        -- No data for this field.
        return;
    end

    local text = format("|cffFFD304" .. L["CU"] .. ":|r %s", currently);

    -- Ensure the lines wrap.
    CommonTooltip_AddBlankLine(tooltip);
    CommonTooltip_AddColoredLine(tooltip, text, TOOLTIP_CURRENTLY_COLOR, true);
end

local function EnhancedTooltip_AddOOCText(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported or not mrpSaved.Options.ShowOOC then
        -- Player doesn't have a profile, or OOC is disabled.
        return;
    end

    local ooc = mrp.DisplayTooltip.CO(profile.field.CO);
    if not emptynil(ooc) then
        -- No data for this field.
        return;
    end

    local text = format("|cffFFD304" .. L["COabb"] .. ":|r %s", ooc);

    -- Ensure the lines wrap.
    CommonTooltip_AddBlankLine(tooltip);
    CommonTooltip_AddColoredLine(tooltip, text, TOOLTIP_OOC_COLOR, true);
end

local function EnhancedTooltip_AddVersionLine(tooltip, player, unit)
    local profile = msp.char[player];
    if not profile.supported or not mrpSaved.Options.ShowVersion then
        -- Player doesn't have a profile, or we've been told to not show versions.
        return;
    end

    -- The version line actually includes a left column with icons for
    -- things like relationship status, notes, etc.
    local relationship = emptynil(profile.field.RS);
    local relationshipIcon = "";

    if relationship and (relationship == "2" or relationship == "3") then
        if relationship == "2" then
            relationshipIcon = TOOLTIP_RELATIONSHIP_TAKEN_ICON;
        elseif relationship == "3" then
            relationshipIcon = TOOLTIP_RELATIONSHIP_MARRIED_ICON;
        end
    end

    -- Notes require us to look up the table with the unit name/realm.
    local unitName, unitRealm = UnitName(unit);
    if not unitRealm then
        unitRealm = GetRealmName();
    end

    local notesRealm = unitRealm:gsub(" ", ""):upper();
    local notesName = unitName:upper();

    local notesIcon = "";
    if mrpNotes[notesRealm] and mrpNotes[notesRealm][notesName] then
        notesIcon = TOOLTIP_NOTES_ICON;
    end

    -- Join up all the icons to form the left side of the tooltip.
    local leftText = strjoin("", relationshipIcon, notesIcon);
    if leftText ==  "" then
        leftText = " ";
    end

    local rightText = mrp.DisplayTooltip.VA(profile.field.VA);
    local color = TOOLTIP_VERSION_COLOR;

    CommonTooltip_AddBlankLine(tooltip);
    CommonTooltip_AddDoubleLine(tooltip, leftText, color, rightText, color);
end

local function EnhancedTooltip_AddUnitGUIDLine(tooltip, player, unit)
    -- Only show GUIDs in debug mode or if explicitly configured.
    if not mrp.Debug and not mrp.ShowGUID then
        return;
    end

    local text = format(L["GUID: %s"], UnitGUID(unit) or "<nil>");
    CommonTooltip_AddColoredLine(tooltip, text, TOOLTIP_GUID_COLOR);
end

local function EnhancedTooltip_AddPhaseLine(tooltip, player, unit)
    if UnitInPhase(unit) then
        -- Do nothing if the unit is in the same phase.
        return;
    end

    CommonTooltip_AddBlankLine(tooltip);
    CommonTooltip_AddColoredLine(tooltip, L["<Out of Phase>"], TOOLTIP_PHASE_COLOR);
end

-- Tooltip updating
function mrp:UpdateTooltip(player, unit, context)
    local tooltipStyle = mrpSaved.Options.TooltipStyle;

    -- If no player was specified, default to the last one shown,
    player = player or mrp.TTShown
    if not emptynil(player) or tooltipStyle == 0 then
        -- Player name is invalid or user doesn't want tooltip customization.
        return false;
    end

    -- Fix up the unit if not specified to something more appropriate.
    if not unit then
        if mrp:UnitNameWithRealm("mouseover") == player or UnitName("mouseover") == player then
            unit = "mouseover";
        elseif player == UnitName("player") then
            unit = "player";
        else
            -- Can't deduce the unit.
            return false;
        end
    end

    -- Additional verification on the player; reject unknown units or things
    -- that aren't actual players.
    if player == UNKNOWNOBJECT or not UnitIsPlayer(unit) then
        return false;
    end

    -- Default the context if not given.
    if not context then
        context = self.TOOLTIP_CONTEXT_DEFAULT;
    end

    -- Otherwise we're good to go. Record this as the current tooltip player.
    mrp.TTShown = player;

    -- Initialize the tooltip frame and draw it in the proper style.
    local tooltip = GameTooltip;
    CommonTooltip_ResetToUnit(tooltip, unit);

    if tooltipStyle == 1 then
        -- Basic/Flag-style tooltip.
        BasicTooltip_AddNameLine(tooltip, player, unit);
        BasicTooltip_AddNicknameLine(tooltip, player, unit);
        BasicTooltip_AddRoleplayStatusStyleLine(tooltip, player, unit);
    else
        -- Enhanced tooltip.
        EnhancedTooltip_AddNameLine(tooltip, player, unit);
        EnhancedTooltip_AddTrialMarkerLine(tooltip, player, unit);
        EnhancedTooltip_AddTitleLine(tooltip, player, unit);
        EnhancedTooltip_AddNicknameLine(tooltip, player, unit);
        EnhancedTooltip_AddHouseLine(tooltip, player, unit);
        EnhancedTooltip_AddGuildLine(tooltip, player, unit);
        EnhancedTooltip_AddPlayerTargetLine(tooltip, player, unit);
        EnhancedTooltip_AddClassLevelRaceLine(tooltip, player, unit);
        EnhancedTooltip_AddCurrentlyText(tooltip, player, unit);
        EnhancedTooltip_AddOOCText(tooltip, player, unit);
        EnhancedTooltip_AddRoleplayStyleStatusLine(tooltip, player, unit);
        EnhancedTooltip_AddVersionLine(tooltip, player, unit);
        EnhancedTooltip_AddUnitGUIDLine(tooltip, player, unit);
        EnhancedTooltip_AddPhaseLine(tooltip, player, unit);
    end

    -- Tooltips of both styles will have developer GUIDs flagged.
    CommonTooltip_AddDeveloperLine(tooltip, player, unit);

    -- If this is the button context, we'll add the additional lines to point
    -- out that clicking does cool things.
    if context == self.TOOLTIP_CONTEXT_BUTTON then
        CommonTooltip_AddBlankLine(tooltip);
        CommonTooltip_AddColoredLine(tooltip, L["button_click_to_show"], TOOLTIP_DEFAULT_COLOR);

        if mrp.ButtonMovable then
            CommonTooltip_AddColoredLine(tooltip, L["button_rightclick_to_lock"], TOOLTIP_DEFAULT_COLOR);
        else
            CommonTooltip_AddColoredLine(tooltip, L["button_rightclick_to_unlock"], TOOLTIP_DEFAULT_COLOR);
        end
    end

    -- Show the tooltip to recalculate its size and make things work.
    tooltip:Show();
    return true;
end

-- As found in GameTooltip.lua, but collapsed, and we want a bit more nuance.
function mrp:UnitColour(unit)
    if ( UnitPlayerControlled(unit) ) then
        if ( (strsub( UnitName(unit),1,4 )=="<GM>" ) ) then
            -- Woah, it's a <GM>!
            return 0.0, 0.7, 1.0
        elseif ( UnitCanAttack(unit, "player") ) then
            -- Hostile players are red
            if ( not UnitCanAttack("player", unit) ) then
                return 1.0, 1.0, 1.0
            else
                return FACTION_BAR_COLORS[2].r, FACTION_BAR_COLORS[2].g, FACTION_BAR_COLORS[2].b
            end
        elseif ( UnitCanAttack("player", unit) ) then
            -- Players we can attack but which are not hostile are yellow
            return FACTION_BAR_COLORS[4].r, FACTION_BAR_COLORS[4].g, FACTION_BAR_COLORS[4].b
        --elseif ( IsReferAFriendLinked(unit) ) then [8.2.5 changed RAF, this no longer works. FIX ME]
           -- return FACTION_BAR_COLORS[8].r, FACTION_BAR_COLORS[8].g, FACTION_BAR_COLORS[8].b
        elseif ( UnitIsInMyGuild(unit) ) then
            return FACTION_BAR_COLORS[7].r, FACTION_BAR_COLORS[7].g, FACTION_BAR_COLORS[7].b
        elseif ( UnitIsPVP(unit) ) then
            -- Players we can assist but are PvP flagged are green
            return FACTION_BAR_COLORS[6].r, FACTION_BAR_COLORS[6].g, FACTION_BAR_COLORS[6].b
        else
            -- All other players are blue (the usual state on the "blue" server)
            return 0.5, 0.5, 1.0
        end
    else
        local reaction = UnitReaction(unit, "player");
        if ( reaction ) then
            return FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b
        else
            return 1.0, 1.0, 1.0
        end
    end
end

function mrp_MSPTooltipCallback( player )
    if player == mrp.TTShown then
        mrp:UpdateTooltip( player )
    end
end
