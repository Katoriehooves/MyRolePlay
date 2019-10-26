--[[
    MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
    Licensed under GNU General Public Licence version 2 or, at your option, any later version

    Update.lua - Notify the player (only once per session) if someone else has a later release build of MyRolePlay

    Dislike the update notifications? Simply delete this file.
]]

local L = mrp.L
local strmatch, tonumber = strmatch, tonumber

function mrp_MSPUpdateCallback( player )
    if not mrp.UpdateNotificationShown and tonumber( strmatch( msp.char[ player ].field.VA, "MyRolePlay/%d+%.%d+%.%d+%.(%d+)" ) or "-1" ) > mrp.Build then
        local testbuild = strmatch( msp.char[ player ].field.VA, "MyRolePlay/%d+%.%d+%.%d+%.%d+([ab])" )
        if not testbuild then
            local text;

            if(tonumber( strmatch( msp.char[ player ].field.VA, "MyRolePlay/%d+%.%d+%.%d+%.(%d+)" ) - mrp.Build) > 2) then
                text = L["Your version of MyRolePlay is |cffFF0000*extremely*|r out of date, and may cause compatibility issues. |cffc878e0%s|r is the current version. You are running |cffc878e0%s|r. Please update to ensure the best experience."];
                if mrp:IsClassicClient() then
                    text = L["Your version of MyRolePlay Classic is |cffFF0000*extremely*|r out of date, and may cause compatibility issues. |cffc878e0%s|r is the current version. You are running |cffc878e0%s|r. Please update to ensure the best experience."];
                end
            else
                text = L["Your version of MyRolePlay is out of date. Please visit CurseForge or make sure your Twitch app has fetched the latest version, |cffc878e0%s|r."];
                if mrp:IsClassicClient() then
                    text = L["Your version of MyRolePlay Classic is out of date. Please visit CurseForge or make sure your Twitch app has fetched the latest version, |cffc878e0%s|r."];
                end
            end

            mrp:Print( text, strmatch( msp.char[ player ].field.VA, "MyRolePlay/(%d+%.%d+%.%d+%.%d+)" ), mrp.Version )
            mrp.UpdateNotificationShown = true
        end
    end
end
