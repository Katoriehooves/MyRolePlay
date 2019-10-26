--[[
    MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
    Licensed under GNU General Public Licence version 2 or, at your option, any later version

    ID.lua - A list of users to specially identify i.e. debug/beta/dev users
]]

local L = mrp.L

-- Each GUID is a table containing keys realm, text, icon. These will be formatted in UI_Tooltip.lua.
local ICON_DEVELOPER = CreateAtlasMarkup("groupfinder-icon-leader", 17, 12);
local ICON_ASSISTANT = CreateTextureMarkup([[Interface\AddOns\MyRolePlay\Artwork\devcrown-silver]], 16, 16, 17, 12, 0, 0.8125, 0, 0.5625, 0, 0);

mrp.id = {
    -- Mainline/Retail
	
		-- North American Realms --
		
    ["Player-3675-06C390B1"] = { -- Katorie
        realm = "Moon Guard",
        text = L["MyRolePlay Lead Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_MAINLINE,
    },

    ["Player-3675-072C0877"] = { -- Kisara (Katorie alt)
        realm = "Moon Guard",
        text = L["MyRolePlay Lead Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_MAINLINE,
    },

    ["Player-3675-08185F8D"] = { -- Mystra / Wakmagic
        realm = "Moon Guard",
        text = L["MyRolePlay Contributor"],
        icon = ICON_ASSISTANT,
        project = WOW_PROJECT_MAINLINE,
    },

    ["Player-3675-08728809"] = { -- Laurna (Meorawr)
        realm = "Moon Guard",
        text = L["MyRolePlay Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_MAINLINE,
    },
	
		-- European Realms --

    ["Player-3702-0620D165"] = { -- Etarna (Etarna Moonshyne)
        realm = "Argent Dawn",
        text = L["MyRolePlay Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_MAINLINE,
    },

    ["Player-3702-061DACE6"] = { -- Dulcamara (Etarna Moonshyne)
        realm = "Argent Dawn",
        text = L["MyRolePlay Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_MAINLINE,
    },

    ["Player-3702-0626211B"] = { -- Sylandru (Etarna Moonshyne)
        realm = "Argent Dawn",
        text = L["MyRolePlay Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_MAINLINE,
    },

    ["Player-3702-061DE226"] = { -- Mimetia (Etarna Moonshyne)
        realm = "Argent Dawn",
        text = L["MyRolePlay Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_MAINLINE,
    },

    -- Classic
	
		-- North American Realms --
	
	["Player-4648-0078CB54"] = { -- Kisara (Katorie)
        realm = "Bloodsail Buccaneers",
        text = L["MyRolePlay Lead Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_CLASSIC,
    },
	
	["Player-4648-0000367C"] = { -- Mystra (Wakmagic)
        realm = "Bloodsail Buccaneers",
        text = L["MyRolePlay Contributor"],
        icon = ICON_ASSISTANT,
        project = WOW_PROJECT_CLASSIC,
    },

    ["Player-4678-012B667C"] = { -- Maellia (Meorawr)
        realm = "Hydraxian Waterlords",
        text = L["MyRolePlay Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_CLASSIC,
    },
	
		-- European Realms --

    ["Player-4678-0006FCE5"] = { -- Etarna (Etarna Moonshyne)
        realm = "Hydraxian Waterlords",
        text = L["MyRolePlay Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_CLASSIC,
    },

    ["Player-4678-0006CD68"] = { -- Elandru (Etarna Moonshyne)
        realm = "Hydraxian Waterlords",
        text = L["MyRolePlay Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_CLASSIC,
    },

    ["Player-4678-0007E509"] = { -- Dulcamara (Etarna Moonshyne)
        realm = "Hydraxian Waterlords",
        text = L["MyRolePlay Developer"],
        icon = ICON_DEVELOPER,
        project = WOW_PROJECT_CLASSIC,
    },
}
