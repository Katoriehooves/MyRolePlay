--[[
    MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
    Licensed under GNU General Public Licence version 2 or, at your option, any later version

    EquipSet.lua - Automatic profile changing when you change equipment sets
]]

-- Equipment set functionality is disabled on Classic.
if mrp:IsClassicClient() then
    return;
end

local strtrim, type, tostring = strtrim, type, tostring

local function mrp_DoEquipSet( setID )
    local setName
    if type(setID) == "number" then -- We need to check if we're sent a number or string because Outfitter still sends the string name of the set, and Blizzard uses integer setID.
        setName = C_EquipmentSet.GetEquipmentSetInfo(setID) -- Need to use names since MRP compares it with the profile name so if they use Blizzard style, get setName from ID.
    else
        setName = setID -- Otherwise, we're passed the name as setID, just set setName to what we receive.
    end
    if mrpSaved.Options.EquipSetAutoChange and type( mrpSaved.Profiles[ setName ] ) == "table" then
        mrp:DebugSpam( "DoEquipSet: %s", setName )
        mrp:SetCurrentProfile( setName )
    end
end

local function mrp_EquipSetEvent( this, event, completed, setID )
    mrp:DebugSpam( "EquipSet: '%s'", tostring( setID or "<nil>" ) )
    if event == "EQUIPMENT_SWAP_FINISHED" and completed then
        mrp_DoEquipSet( setID )
    end
end

local df = CreateFrame("Frame")
df:SetScript( "OnEvent", mrp_EquipSetEvent )

-- ItemRack support. Nice and easy.
local function mrp_ItemRackSwap()
    mrp:DebugSpam( "EquipSet (ItemRack): '%s'", tostring( ItemRackUser.CurrentSet or "<nil>" ) )
    mrp_DoEquipSet( strtrim( tostring( ItemRackUser.CurrentSet ) ) )
end

--[[
    Outfitter support: Unfortunately this was the sanest way I found to do it. The EventLib is nice, but unfortunately
    Outfitter.CurrentOutfit:GetName() doesn't work if you're outside Outfitter, and returns the outfit table instead.
    Note we HAVE to post-hook Outfitter:WearOutfit or it won't have pushed it on the end of the stack yet. The event is too early.
]]
local function mrp_OutfitterSwap()
    mrp:DebugSpam( "EquipSet (Outfitter): '%s'", tostring( Outfitter.Settings.RecentCompleteOutfits[ #Outfitter.Settings.RecentCompleteOutfits ] or "<nil>" ) )
    mrp_DoEquipSet( strtrim( tostring( Outfitter.Settings.RecentCompleteOutfits[ #Outfitter.Settings.RecentCompleteOutfits ] ) ) )
end

function mrp:HookEquipSet()
    df:RegisterEvent( "EQUIPMENT_SWAP_FINISHED" )
    if ItemRack then
        hooksecurefunc( ItemRack, "EndSetSwap", mrp_ItemRackSwap )
    end
    if Outfitter then
        hooksecurefunc( Outfitter, "WearOutfit", mrp_OutfitterSwap )
    end
end

function mrp:UnhookEquipSet()
    df:UnregisterEvent( "EQUIPMENT_SWAP_FINISHED" )
end
