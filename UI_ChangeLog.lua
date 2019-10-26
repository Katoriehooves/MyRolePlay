--[[
    MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard

    Licensed under GNU General Public Licence version 2 or, at your option, any later version

    UI_ChangeLog.lua - Display patch notes after an update.
]]

local changeLogText = {};

function mrp:FormatChangeLog()
    local changeLogConversionTable = {};
    local changeLogOutput = ""
    for i = 1, #changeLogText, 1 do
        changeLogConversionTable[i] = {};
        changeLogConversionTable[i]["version"] = "{h3:c}|cffFF7700v" .. changeLogText[i]["version"] .. "|r{/h3}\n"
        for l = 1, #changeLogText[i], 1 do
            changeLogConversionTable[i][l] = {}
            if(changeLogText[i][l]["title"] ~= "") then
                changeLogConversionTable[i][l]["title"] = "{h3}" .. changeLogText[i][l]["title"] .. "{/h3}\n"
            else
                changeLogConversionTable[i][l]["title"] = ""
            end
            if(changeLogText[i][l]["text"] ~= "") then
                changeLogConversionTable[i][l]["text"] = changeLogText[i][l]["text"] .. "\n\n"
            else
                changeLogConversionTable[i][l]["text"] = ""
            end
        end
    end
    for i = 1, #changeLogConversionTable, 1 do
        changeLogOutput = changeLogOutput .. changeLogConversionTable[i]["version"]
        for l = 1, #changeLogConversionTable[i], 1 do
            changeLogOutput = changeLogOutput .. changeLogConversionTable[i][l]["title"]
            changeLogOutput = changeLogOutput .. changeLogConversionTable[i][l]["text"]
        end
    end

    changeLogOutput = mrp:CreateURLLink(changeLogOutput);
    changeLogOutput = mrp:ConvertStringToHTML(changeLogOutput);
    MyRolePlayChangeLogHTMLFrame:SetText(changeLogOutput)
end


local f = CreateFrame("Frame", "MyRolePlayChangeLogFrame", UIParent, nil);

-- Setup the frame.
f:SetToplevel(true);
f:SetFrameStrata("HIGH");
f:SetMovable(true);
f:EnableMouse(true);
f:Hide();
f:ClearAllPoints();
f:SetSize(600, 400);
f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);


-- Set backdrop for the picker frame
f:SetBackdrop(
    {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    }
);
f:SetBackdropColor(0.0, 0.0, 0.0, 0.80);

-- Title text
f.title_label = f:CreateFontString();
f.title_label:ClearAllPoints();
f.title_label:SetSize(f:GetWidth(), 40);
f.title_label:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -5);
f.title_label:SetFontObject(GameFontNormalHuge3);
f.title_label:SetText("|cff9955DDMyRolePlay Patch Notes|r");
if mrp:IsClassicClient() then
    f.title_label:SetText("|cff9955DDMyRolePlay Classic |cff9955DDPatch Notes|r");
end

f.sf = CreateFrame( "ScrollFrame", "MyRolePlayChangeLogScrollFrame", f, "UIPanelScrollFrameTemplate" )
f.sf:SetPoint( "TOPLEFT", f.title_label, "BOTTOMLEFT", 12, -5 )
f.sf:SetPoint( "BOTTOMRIGHT", f, "BOTTOMRIGHT", -28, 7 )

f.sf:EnableMouse(true)
f.sf.scrollbarHideable = false

ScrollBar_AdjustAnchors( MyRolePlayChangeLogScrollFrameScrollBar, -1, -1, 1)

f.sf.html = CreateFrame("SimpleHTML", "MyRolePlayChangeLogHTMLFrame", f.sf)
f.sf.html:SetSize(f.sf:GetWidth()-4, f.sf:GetHeight())
f.sf.html:SetFrameStrata("HIGH")
f.sf.html:SetBackdropColor(0, 0, 0, 1)
f.sf.html:SetFontObject( "GameFontHighlight" )
f.sf.html:SetFontObject("p", GameFontHighlight); -- GameFontNormal is gold.
f.sf.html:SetFontObject("h1", GameFontNormalHuge3);
f.sf.html:SetFontObject("h2", GameFontNormalHuge);
f.sf.html:SetFontObject("h3", GameFontNormalLarge);
f.sf.html:SetTextColor("h1", 1, 1, 1);
f.sf.html:SetTextColor("h2", 1, 1, 1);
--f.sf.html:SetTextColor("h3", 1, 1, 1);
f.sf.html:SetScript("OnHyperlinkClick", function(f, link, text, button, ...)
    if(link:match("mrpweblink")) then -- Creates a new hyperlink type to allow for clicking of web links.
        local linkName = link:match("^mrpweblink:(.+)");
        if(linkName) then
            mrp:ShowHyperlinkBox(linkName, linkName);
        end
        return;
    end
end)
f.sf.html:SetScript("OnHyperlinkEnter", function(f, link, text, button, ...)
    if(link:match("mrpweblink")) then
        local linkName = link:match("^mrpweblink:(.+)");
        if(linkName) then
            GameTooltip:SetOwner( f, "ANCHOR_CURSOR" )
            GameTooltip:SetText( text:match("%[.-%]"), 1.0, 1.0, 1.0 )
            GameTooltip:AddLine( linkName, 1.0, 0.8, 0.06)
            GameTooltip:Show()
        end
        return;
    end
end)
f.sf.html:SetScript( "OnHyperlinkLeave", GameTooltip_Hide )
f.sf.html:SetHyperlinksEnabled(1)

f.sf:SetScrollChild( f.sf.html )

f.sf.html:SetScript( "OnUpdate", function(self, elapsed)
    ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
end	)

ScrollFrame_OnScrollRangeChanged(MyRolePlayChangeLogScrollFrame)

-- Close button
f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
f.close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
f.close:SetScript("OnClick", function (self)
    MyRolePlayChangeLogFrame:Hide();
end )

if mrp:IsMainlineClient() then
	changeLogText[1] = {
        ["version"] = "8.2.5.445 (26 Sept 2019)",
		[1] = {
            ["title"] =   "Updates",
            ["text"] =    "- Added 7 new icons and 1 music file from Patch 8.2.5."
        },
		[2] = {
            ["title"] =   "Bug Fixes",
            ["text"] =    "- Fixed an issue preventing profile transfer across BattleNet. This fix requires both users to have updated their RP addon of choice."
        },
    };
	
	changeLogText[2] = {
        ["version"] = "8.2.5.444 (24 Sept 2019)",
		[1] = {
            ["title"] =   "Bug Fixes",
            ["text"] =    "- Fixed some tooltip issues related to changes introduced in retail Patch 8.2.5.\n\n- Fixed an issue which allowed a blank name to be set under certain conditions.\n\n- Fixed an issue causing profile icons above certain dimensions to exceed the boundaries of the preview in the editor.\n\n- Fixed some text alignment issues.\n\n- Fixed an issue causing certain phrases used in the retail version of the game to appear in the Classic version of MRP."
        },
    };
	
    changeLogText[3] = {
        ["version"] = "8.2.0.443 (31 Aug 2019)",
        [1] = {
            ["title"] = "Bug Fixes",
            ["text"] = table.concat({
                "- Updated icon list.",
                "- Fixed several issues with OOC/emote coloring.",
                "- Fixed potential errors when resetting various UI frame positions.",
                "- Fixed an issue with the portrait on the profile editor not reliably displaying custom profile icons.",
            }, "\n\n"),
        },
    };

    changeLogText[4] = {
        ["version"] = "8.2.0.442 (15 Jul 2019)",
        [1] = {
            ["title"] =   "Small Changes",
            ["text"] =    "- Included the in-game character name in the status bar load text, as there was no other indication of this in the profile."
        },
        [2] = {
            ["title"] =   "Bug Fixes",
            ["text"] =    "- Fixed an issue causing the player's tooltip to show up when hovering over the MRP button instead of the target's.\n\n- Fixed an issue where the icon and music buttons were named the same, preventing UI skins from working with MyRolePlay."
        },
    };
	
elseif mrp:IsClassicClient() then
	changeLogText[1] = {
        ["version"] = "1.13.2.445 (26 Sept 2019)",
		[1] = {
            ["title"] =   "Bug Fixes",
            ["text"] =    "- Fixed an issue preventing profile transfer across Battle.net. This fix requires both users to have updated their RP addon of choice."
        },
    };

	changeLogText[2] = {
        ["version"] = "1.13.2.444 (18 Sept 2019)",
		[1] = {
            ["title"] =   "Bug Fixes",
            ["text"] =    "- Fixed an issue which allowed a blank name to be set under certain conditions.\n\n- Fixed an issue causing profile icons above certain dimensions to exceed the boundaries of the preview in the editor.\n\n- Fixed some text alignment issues.\n\n- Fixed an issue causing certain phrases used in the retail version of the game to appear in the Classic version of MRP."
        },
    };
	
    changeLogText[3] = {
        ["version"] = "1.13.2.443 (31 Aug 2019)",
        [1] = {
            ["title"] = "Bug Fixes",
            ["text"] = table.concat({
                "- Updated icon list.",
                "- Fixed several issues with OOC/emote coloring.",
                "- Fixed potential errors when resetting various UI frame positions.",
                "- Fixed issues with the music list displaying files unavailable in the Classic client.",
            }, "\n\n"),
        },
    };

    changeLogText[4] = {
        ["version"] = "1.12.0.1 (8 Aug 2019)",
        [1] = {
            ["title"] =   "Thanks for testing MyRolePlay Classic! PLEASE report bugs!",
            ["text"] =    "|cffFF0000If you encounter a bug, report it on the CurseForge project page, at https://www.curseforge.com/wow/addons/myroleplay-classic/issues\n\nAll features from live should be present in this version, minus a couple that do not function in Vanilla, such as profile switching with gear change.|r"
        },
        [2] = {
            ["title"] =   "Known Issues",
            ["text"] =    "- The music list still includes tracks from later expansions that will not play in Vanilla."
        },
    };
end
