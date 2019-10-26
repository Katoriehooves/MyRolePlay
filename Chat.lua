--[[
    MyRolePlay 4 (C) 2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
    Licensed under GNU General Public Licence version 2 or, at your option, any later version
    Chat.lua - Additions to the chat box, such as detection of certain phrases and patterns for colouring.
]]

--- Note: The color codes in this file use |C and |R (uppercase) pairs as
--        they are specially handled.
--
--        |C is the same as |c, but will push the color onto a stack. The
--        |R escape will pop the top of the stack and restore the previous
--        color, or will emit a normal |r escape if no colors exist.

local characterName = UnitName("player")

local rpChats = {
    ["CHAT_MSG_WHISPER"] = true,
    ["CHAT_MSG_WHISPER_INFORM"] = true,
    ["CHAT_MSG_PARTY"] = true,
    ["CHAT_MSG_PARTY_LEADER"] = true,
    ["CHAT_MSG_GUILD"] = true,
    ["CHAT_MSG_RAID"] = true,
    ["CHAT_MSG_RAID_LEADER"] = true,
    ["CHAT_MSG_SAY"] = true,
    ["CHAT_MSG_YELL"] = true,
    ["CHAT_MSG_EMOTE"] = true,
    ["CHAT_MSG_TEXT_EMOTE"] = true
}

--- Strips all |c and |r markup from the given text.
local function mrp_StripColorMarkup(text)
    return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");
end

--- Highlights the given text in special |C and |R pairs to represent
--  OOC chat.
--
--  Any standard color markup within the given text will be stripped.
local function mrp_HighlightOOCText(text)
    return "|Cffaaaaaa" .. mrp_StripColorMarkup(text)  .. "|R";
end

--- Highlights the given text in special |C and |R pairs to represent
--  an emote.
--
--  Any standard color markup within the given text will be stripped.
local function mrp_HighlightEmoteText(text)
    return "|Cffff7e40" .. mrp_StripColorMarkup(text)  .. "|R";
end

local function mrp_HighlightNameInMessage(message, name)
    -- Uppercase the input message and build a pattern to match
    -- an uppercased variant of the name.
    local upperMessage = string.upper(message);
    local namePattern = string.format("()(%s)", string.upper(name));

    -- Stores indices of found instances of name.
    local t = {};

    -- Loop over the input message until we reach the end of it.
    local offset = 1;
    while #message > offset do
        -- Find the next occurence of the name in the message.
        local loc, match = string.match(upperMessage, namePattern, offset);
        if not loc then
            break;
        end

        -- Put the message segment before the name into the table.
        table.insert(t, string.sub(message, offset, loc - 1));

        -- Sort out the name and append it next.
        local originalName = string.sub(message, loc, loc + #match - 1);
        local nameColour
        if(msp.my["NA"]:find("|cff")) then -- If we have a custom coloured name, use it.
            nameColour = msp.my["NA"]:match("^|c(%x%x%x%x%x%x%x%x)");
        else
            nameColour = RAID_CLASS_COLORS[ ( select( 2, UnitClass("player") ) ) ]["colorStr"]
        end
        table.insert(t, string.format("|C%s%s|R", nameColour, originalName));

        -- Move our offset to after the name match.
        offset = loc + #match;
    end
    -- Put the remainder of the message into the table before yielding the
    -- formatted string.
    table.insert(t, string.sub(message, offset));
    return table.concat(t);
end

local mrp_ProcessColorSequences;

do
    -- Pattern for matching markup in the string. This should match
    -- |C and |R markup, along with an optional 8 byte hexadecimal color.
    local MARKUP_PATTERN = "([^|]?)|([CR])(%x?%x?%x?%x?%x?%x?%x?%x?)";

    -- Stack of colors. This table is reset on each call to
    -- mrp_ProcessColorSequences.
    local colors = {};

    -- Replacement function that operates on MARKUP_PATTERN to process
    -- |C and |R markup.
    local function replaceMarkup(prefix, code, color)
        if code == "C" and #color == 8 then
            -- A |C escape means we're starting a color. Push it onto the
            -- stack and yield a |c sequence.
            table.insert(colors, color);
            return strjoin("", prefix, "|c", color);
        elseif code == "R" then
            -- A |R escape means we're done with the current color, so pop it
            -- and restore any previous (via |c) or reset entirely (|r).
            table.remove(colors);

            -- We need to join the "color" as the last bit because it's
            -- actually potentially a segment of text after the |R token.
            local previousColor = colors[#colors];
            if previousColor then
                return strjoin("", prefix, "|c", previousColor, color);
            else
                return strjoin("", prefix, "|r", color);
            end
        end
    end

    --- Processes custom |C and |R markup sequences in the given text,
    --  converting them to standard |c and |r markup as appropriate.
    function mrp_ProcessColorSequences(text)
        text = string.gsub(text, MARKUP_PATTERN, replaceMarkup);
        table.wipe(colors);
        return text;
    end
end

local function mrp_ChatFilter(self, eventName, message, ...)
    if(mrpSaved.Options.HighlightOOC == true) then
        message = message:gsub("%b()", mrp_HighlightOOCText) -- Grey out OOC parts of text within (())
    end
    if(mrpSaved.Options.HighlightEmotes == true) then
        message = message:gsub("%b**", mrp_HighlightEmoteText) -- Colour orange emotes in text within **.
    end
    message = mrp_HighlightNameInMessage(message, characterName) -- Highlight player name in messages.
    message = mrp_ProcessColorSequences(message)
    return false, message, ...
end

for k, v in pairs(rpChats) do
    if(rpChats[k] == true) then
        ChatFrame_AddMessageEventFilter(k, mrp_ChatFilter)
    end
end
