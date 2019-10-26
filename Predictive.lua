--[[
    MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
    Licensed under GNU General Public Licence version 2 or, at your option, any later version

    Predictive.lua - Predictively request tooltip data for players in proximity
]]

local GetTime = GetTime
local random = math.random

local nextupdate = 0
local df = CreateFrame( "Frame", "MyRolePlayDummyPredictiveFrame" )

-- Fastest queue implementation in Lua: local integer-indexed incrementing table.

local namequeue = { }
local startqueue = 1
local endqueue = 1

local function mrp_PredictiveUpdate( )
    if GetTime() < nextupdate or not namequeue[ startqueue ] then return end
    if msp.char[ namequeue[ startqueue ] ].supported == nil then
        msp:Request( namequeue[ startqueue ] )
    end
    namequeue[ startqueue ] = nil
    startqueue = startqueue + 1
    if namequeue[ startqueue ] then
        nextupdate = GetTime() + ( random( 500, 2000 ) / 1000 )
    else
        df:SetScript( "OnUpdate", nil )
    end
end

local function mrp_PredictiveEvent( this, event, message, sender )
    if sender and sender ~= "" and msp.char[ sender ].supported == nil then
        if not namequeue[ startqueue ] then
            nextupdate = GetTime() + ( random( 100, 2000 ) / 1000 )
            df:SetScript( "OnUpdate", mrp_PredictiveUpdate )
        end
        namequeue[ endqueue ] = sender
        endqueue = endqueue + 1
    end
end

df:SetScript( "OnEvent", mrp_PredictiveEvent )

function mrp:HookPredictive()
    df:RegisterEvent( "CHAT_MSG_SAY" )
    df:RegisterEvent( "CHAT_MSG_EMOTE" )
    df:RegisterEvent( "CHAT_MSG_TEXT_EMOTE" )
    df:RegisterEvent( "CHAT_MSG_YELL" )
    df:RegisterEvent( "CHAT_MSG_PARTY_LEADER" )
    df:RegisterEvent( "CHAT_MSG_PARTY" )
    df:RegisterEvent( "CHAT_MSG_RAID" )
end

function mrp:UnhookPredictive()
    df:UnregisterEvent( "CHAT_MSG_SAY" )
    df:UnregisterEvent( "CHAT_MSG_EMOTE" )
    df:UnregisterEvent( "CHAT_MSG_TEXT_EMOTE" )
    df:UnregisterEvent( "CHAT_MSG_YELL" )
    df:UnregisterEvent( "CHAT_MSG_PARTY_LEADER" )
    df:UnregisterEvent( "CHAT_MSG_PARTY" )
    df:UnregisterEvent( "CHAT_MSG_RAID" )
end
