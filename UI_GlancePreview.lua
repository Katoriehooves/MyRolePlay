--[[
    MyRolePlay 4 (C) 2010-2019 Katorie, Etarna Moonshyne
    Licensed under GNU General Public Licence version 2 or, at your option, any later version

    UI_GlancePreview.lua - MyRolePlayGlanceFrame (the glance preview box), and support functions
]]

local L = mrp.L
local function emptynil( x ) return x ~= "" and x or nil end

-- TODO: Remove this state.
local glances;

function mrp:CreateGlanceFrame()
    if not MyRolePlayGlanceFrame then
        local gf = CreateFrame("Frame", "MyRolePlayGlanceFrame", UIParent, nil);
        gf:SetToplevel(true);
        gf:SetFrameStrata("HIGH");
        gf:SetMovable(true);
        gf:EnableMouse(true);
        gf:Hide();
        gf:ClearAllPoints();
        gf:SetSize(175, 60);
        if mrpSaved.Positions.GlancePreview then
            gf:SetPoint( mrpSaved.Positions.GlancePreview[1], nil, mrpSaved.Positions.GlancePreview[1], mrpSaved.Positions.GlancePreview[2], mrpSaved.Positions.GlancePreview[3] )
            mrp:CheckGlanceFrameBounds()
        else
            gf:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
        end
        gf:SetBackdrop(
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
        gf:SetBackdropColor(0.0, 0.0, 0.0, 0.80);

        gf.Close = CreateFrame("Button", nil, gf, "UIPanelCloseButton")
        gf.Close:SetPoint("TOPRIGHT", gf, "TOPRIGHT", 0, 0)
        gf.Close:SetSize(16, 16)
        gf.Close:SetAlpha( 0.5 )
        gf.Close:SetFrameStrata("DIALOG");
        gf.Close:SetScript("OnClick", function (self)
            mrpSaved.Options.ShowGlancePreview = false;
            gf:Hide();
            StaticPopup_Show("MRP_GLANCE_PREVIEW_HIDDEN")
        end )
        gf.Close:SetScript( "OnEnter", function(self)
            GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
            GameTooltip:SetText( CLOSE, 1.0, 1.0, 1.0 )
            GameTooltip:AddLine( "Hide this box permanently on this character. You can re-enable it in options.", 1.0, 0.8, 0.06, true)
            GameTooltip:Show();
        end )
        gf.Close:SetScript( "OnLeave", GameTooltip_Hide )

        if mrpSaved.Positions.GlancePreview then
            gf:SetPoint( mrpSaved.Positions.GlancePreview[1], nil, mrpSaved.Positions.GlancePreview[1], mrpSaved.Positions.GlancePreview[2], mrpSaved.Positions.GlancePreview[3] )
            mrp:CheckGlanceFrameBounds()
        else
            gf:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
        end

        gf:SetClampedToScreen( true )
        gf:RegisterForDrag("LeftButton")
        gf:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end	)
        gf:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            mrpSaved.Positions.GlancePreview = { select( 3, MyRolePlayGlanceFrame:GetPoint() ) }
        end	)

        gf:EnableDrawLayer( "OVERLAY" )

        gf.title = gf:CreateFontString( "MyRolePlayGlanceFrameTitleText", "OVERLAY", "GameFontNormalLarge" )
        gf.title:SetJustifyH( "CENTER" )
        gf.title:SetPoint("TOP", 0, -10)
        gf.title:SetText("MyRolePlay Glance Frame")
        gf.title:SetSize( gf:GetWidth()-8, 10 )

        gf.ver = gf:CreateFontString( nil, "OVERLAY", "MyRolePlayLittleFont" )
        gf.ver:SetJustifyH( "CENTER" )
        gf.ver:SetPoint( "BOTTOMLEFT", 8, 4		)
        gf:SetAlpha( 0.75 )
        gf.ver:SetSize( gf:GetWidth()-8, 10 )


        gf.Glance1PreviewIcon = CreateFrame("Frame", "Glance1PreviewIcon", gf)
        gf.Glance1PreviewIcon:SetPoint( "TOP", 0, -25 )
        gf.Glance1PreviewIcon:SetHeight(28)
        gf.Glance1PreviewIcon:SetWidth(28)
        gf.Glance1PreviewIconTexture = gf.Glance1PreviewIcon:CreateTexture("Glance1PreviewIconTexture", "ARTWORK")
        gf.Glance1PreviewIconTexture:SetAllPoints(gf.Glance1PreviewIcon)

        gf.Glance2PreviewIcon = CreateFrame("Frame", "Glance2PreviewIcon", gf)
        gf.Glance2PreviewIcon:SetPoint( "RIGHT", gf.Glance1PreviewIcon, "LEFT", -5, 0 )
        gf.Glance2PreviewIcon:SetHeight(28)
        gf.Glance2PreviewIcon:SetWidth(28)
        gf.Glance2PreviewIconTexture = gf.Glance2PreviewIcon:CreateTexture("Glance2PreviewIconTexture", "ARTWORK")
        gf.Glance2PreviewIconTexture:SetAllPoints(gf.Glance2PreviewIcon)

        gf.Glance3PreviewIcon = CreateFrame("Frame", "Glance3PreviewIcon", gf)
        gf.Glance3PreviewIcon:SetPoint( "LEFT", gf.Glance1PreviewIcon, "RIGHT", 5, 0 )
        gf.Glance3PreviewIcon:SetHeight(28)
        gf.Glance3PreviewIcon:SetWidth(28)
        gf.Glance3PreviewIconTexture = gf.Glance3PreviewIcon:CreateTexture("Glance3PreviewIconTexture", "ARTWORK")
        gf.Glance3PreviewIconTexture:SetAllPoints(gf.Glance3PreviewIcon)

        gf.Glance4PreviewIcon = CreateFrame("Frame", "Glance4PreviewIcon", gf)
        gf.Glance4PreviewIcon:SetPoint( "RIGHT", gf.Glance2PreviewIcon, "LEFT", -5, 0 )
        gf.Glance4PreviewIcon:SetHeight(28)
        gf.Glance4PreviewIcon:SetWidth(28)
        gf.Glance4PreviewIconTexture = gf.Glance4PreviewIcon:CreateTexture("Glance4PreviewIconTexture", "ARTWORK")
        gf.Glance4PreviewIconTexture:SetAllPoints(gf.Glance4PreviewIcon)

        gf.Glance5PreviewIcon = CreateFrame("Frame", "Glance5PreviewIcon", gf)
        gf.Glance5PreviewIcon:SetPoint( "LEFT", gf.Glance3PreviewIcon, "RIGHT", 5, 0 )
        gf.Glance5PreviewIcon:SetHeight(28)
        gf.Glance5PreviewIcon:SetWidth(28)
        gf.Glance5PreviewIconTexture = gf.Glance5PreviewIcon:CreateTexture("Glance5PreviewIconTexture", "ARTWORK")
        gf.Glance5PreviewIconTexture:SetAllPoints(gf.Glance5PreviewIcon)

        -- Garbage-collect functions we only need once
        mrp.CreateGlanceFrame = nop
        mrp.CreateGFpfield = nop
    end
end

-- Update the text and so forth in the GlanceFrame
function mrp:UpdateGlanceFrame( player )
    player = player or mrp.GFShown or nil
    if not player or player == "" then
        return false
    end
    mrp.GFShown = player

    local f = msp.char[ player ].field

    MyRolePlayGlanceFrameTitleText:SetText(emptynil(mrp:IncreaseColourContrast(f.NA)) or Ambiguate(player, "short"))

    if(string.len(MyRolePlayGlanceFrameTitleText:GetText():gsub("|c%x%x%x%x%x%x%x%x", "")) > 26) then -- Size down the title text if it's too long so we can fit more on it.
        MyRolePlayGlanceFrameTitleText:SetFontObject("GameFontNormalSmall")
    elseif(string.len(MyRolePlayGlanceFrameTitleText:GetText():gsub("|c%x%x%x%x%x%x%x%x", "")) > 19) then -- Size down the title text if it's too long so we can fit more on it.
        MyRolePlayGlanceFrameTitleText:SetFontObject("GameFontNormal")
    else
        MyRolePlayGlanceFrameTitleText:SetFontObject("GameFontNormalLarge")
    end


    --gf.ver:SetText( mrp.DisplayBrowser.FC( f.FC ) .. " - " .. mrp.DisplayBrowser.FR( f.FR ))

    local data = mrp.DisplayBrowser.PE( f.PE ) .. "\n\n---\n\n";

    glances = {};

    local glancePositionTable = {
        [1] = { -- Number of glances.
            [1] = 1 -- Number of the specific glance, and what position to put it in.
        },
        [2] = {
            [1] = 2,
            [2] = 1
        },
        [3] = {
            [1] = 2,
            [2] = 1,
            [3] = 3
        },
        [4] = {
            [1] = 4,
            [2] = 2,
            [3] = 1,
            [4] = 3
        },
        [5] = {
            [1] = 4,
            [2] = 2,
            [3] = 1,
            [4] = 3,
            [5] = 5
        },
    }
    for icon, title, text in string.gmatch(data, "|T[^\n]+\\([^|:]+).-[\n]*#([^\n]+)[\n]*(.-)[\n]*%-%-%-[\n]*") do
        table.insert(glances, {icon, title, text});
    end

    for i = 1, 5, 1 do
        _G["Glance" .. i .. "PreviewIcon"]:Hide()
    end

    for i = 1, #glances, 1 do
        _G["Glance" .. glancePositionTable[#glances][i] .. "PreviewIconTexture"]:SetTexture("Interface\\Icons\\" .. glances[i][1])
        _G["Glance" .. glancePositionTable[#glances][i] .. "PreviewIcon"]:SetScript( "OnEnter", function(self)
            GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
            GameTooltip:SetText( glances[i][2], 0.97, 0.80, 0.05, nil, true )
            GameTooltip:AddLine( glances[i][3], 1.0, 1.0, 1.0, true )
            GameTooltip:Show()
            _G["Glance" .. i .. "PreviewIcon"]:SetScript( "OnLeave", GameTooltip_Hide )
        end )
        _G["Glance" .. i .. "PreviewIcon"]:Show()
    end
end

-- A list of the fields which appear in the glance frame.
local gffields = { 'VP', 'VA', 'NA', 'FR', 'FC', 'PE' }

-- Make the request to another player to get all of the fields in the glance frame.
function mrp:RequestForGF( player )
    player = player or mrp.GFShown or nil
    if not player or player == "" or player == "Unknown" then
        return false
    end

    msp:Request( player, gffields )
    mrp:UpdateGlanceFrame( player )
end

function mrp_MSPGlancePreviewCallback( player )
    if(mrpSaved.Options.ShowGlancePreview == true) then
        if(mrp.GFShown) then
            if(UnitExists("target") and UnitIsPlayer("target") and player == mrp.GFShown and UnitAffectingCombat("player") == false) then
                if(MyRolePlayGlanceFrame:IsShown() == false and #glances > 0) then
                    MyRolePlayGlanceFrame:Show()
                end
                mrp:UpdateGlanceFrame( player )
            end
        end
    end
end

function mrp:GlanceFrameReset()
    mrpSaved.Positions.GlancePreview = nil
    MyRolePlayGlanceFrame:StopMovingOrSizing()
    MyRolePlayGlanceFrame:ClearAllPoints()
    MyRolePlayGlanceFrame:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
    MyRolePlayGlanceFrame:SetSize( 300, 150 )
end

function mrp:CheckGlanceFrameBounds()
    local gf = MyRolePlayGlanceFrame
    local _, _, w, h = UIParent:GetRect()
    local i, j, k, l = gf:GetRect()
    if i<0 or j<0 or k>w or l>(h-20) then
        mrp:GlanceFrameReset()
        mrp:Print( L["MRP glance frame rescued; automatically reset to default position as it was offscreen."] )
    end
end

local function mrp_ShowHideGlancePreview()
    -- Glance frame may not exist depending upon initialization state.
    if not MyRolePlayGlanceFrame then
        return;
    end

    if(mrpSaved.Options.ShowGlancePreview == true) then
        if(UnitExists("target") and UnitIsPlayer("target") and UnitAffectingCombat("player") == false) then
            if not (msp.char[mrp:UnitNameWithRealm("target")].supported) then
                MyRolePlayGlanceFrame:Hide()
                mrp:RequestForGF( mrp:UnitNameWithRealm("target") )
            else
                mrp:UpdateGlanceFrame( mrp:UnitNameWithRealm("target") )
                mrp:RequestForGF( mrp:UnitNameWithRealm("target") )
                if(#glances > 0) then
                    MyRolePlayGlanceFrame:Show()
                else
                    MyRolePlayGlanceFrame:Hide()
                end
            end
        else
            MyRolePlayGlanceFrame:Hide()
        end
    end
end

StaticPopupDialogs[ "MRP_GLANCE_PREVIEW_HIDDEN" ] = {
    text = "|cffFFDD33MyRolePlay\n|cffFFFFFFGlance preview box hidden. You can always enable it once more in the MRP options panel.|r",
    button1 = OKAY or "OK",
    whileDead = true,
    timeout = 0,
}

local glanceFrame = CreateFrame( "Frame", "MyRolePlayDummyGlanceFrame" )
glanceFrame:SetScript( "OnEvent", mrp_ShowHideGlancePreview )
glanceFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
