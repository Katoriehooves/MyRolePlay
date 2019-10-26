--[[
    MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
    Edited for music support from IconSelector.lua, credits where due for creation of that file.

    Licensed under GNU General Public Licence version 2 or, at your option, any later version

    UI_MusicSelector.lua - Music selection frame, and support functions. Uses TRP's music database for compatibility with permission.


Usage:
    mrp_musicselector_show(callback_func, [current_music] or nil)
        callback_func: should be a function that accepts 1 argument,
            which is nil if "clear music" is pressed, or the
            selected track if okay is pressed.
        current_music:
            if the user already set an music, pass this to the
            function to scroll the list to where the already
            selected music is.
    mrp_musicselector_hide();
        will reset and hide the music picker.
]]

local L = mrp.L

-- Imports
local tinsert = table.insert;
local pcall = pcall;
local type = type;
local pairs = pairs;
local CreateFrame = CreateFrame;
local FSF_GetOffset = FauxScrollFrame_GetOffset;
local FSF_Update = FauxScrollFrame_Update;
local FSF_OnVerticalScroll = FauxScrollFrame_OnVerticalScroll;

local LibRPMedia = LibStub:GetLibrary("LibRPMedia-1.0");
local tooltipTable = {}


-- Constants
local NUM_COLUMNS = 1;
local NUM_ROWS = 10;
local NUM_MUSICS = NUM_ROWS;

local ICON_SIZE = 36;
local ICON_PADDING = 4;

local BTN_IDOKAY = 1;
local BTN_IDCANCEL = 2;
local BTN_IDCLEAR = 3;
local BTN_IDPREVIEW = 4;
local BTN_IDSTOP = 5;

local TXT_OKAY = OKAY;
local TXT_CANCEL = CANCEL;
local TXT_CLEAR = L["editor_clearmusic"];
local TXT_PREVIEW = L["editor_play"];
local TXT_STOP = L["editor_stop"];


-- Variables
local frame = nil;
local musicFilenames = { };
local musicFilenames_count = 0;
local savedMaxSliderSize = 124380
local soundHandle = 0


local init_filenames = function(refresh)
    if(musicFilenames_count > 0 and not refresh) then return; end;

    musicFilenames = { };

    -- Fix up the list, fileid will be "number" type
    for k,v in pairs(musicFilenames) do
        local num = tonumber(v);
        if(num) then
            musicFilenames[k] = num;
        else
            musicFilenames[k] = v;
        end
    end

    for _, _, name in LibRPMedia:FindAllMusicFiles() do
        tinsert(musicFilenames, name);
    end

    -- Save music count.
    musicFilenames_count = #musicFilenames;
end


local scroll_update = function(this)
    local offset = FSF_GetOffset(this.scrollframe);
    local index;
    local text;
    local button;

    table.wipe(tooltipTable)

    for i = 1, NUM_MUSICS, 1 do
        index = (offset) + i;
        text = musicFilenames[index]
        button = this.music_buttons[i];

        if(text ~= nil) then
            tooltipTable[i] = {};
            tooltipTable[i]["title"] = text
            tooltipTable[i]["duration"] = LibRPMedia:GetMusicFileDuration(LibRPMedia:GetMusicFileByName(text))
        end

        if((index <= musicFilenames_count)) then
            button:SetText(text)
            button:Show();

            button:SetScript( "OnEnter", function(self)
                GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
                if(tooltipTable[i]["title"] ~= nil and tooltipTable[i]["duration"] ~= nil) then
                    GameTooltip:SetText( tooltipTable[i]["title"], 1, 1, 1 )
                    GameTooltip:AddLine(string.format("Duration: %.0f seconds", tooltipTable[i]["duration"]), 1.0, 0.8, 0.06)
                    GameTooltip:Show()
                end
            end )
            button:SetScript( "OnLeave", GameTooltip_Hide )


        else
            button:Hide();
        end

        if((this.selected_music == index) or (this.selected_music_file == text)) then
            button:SetChecked(true);
        else
            button:SetChecked(false);
        end
    end


    FSF_Update(this.scrollframe, math.ceil(musicFilenames_count) + 1, NUM_ROWS, ICON_SIZE);
end

local onscroll = function(this)
    scroll_update(this:GetParent());
end

local setchoice = function(this, index)
    local music = musicFilenames[index];

    this.selected_music = index;
    this.selected_music_file = music;

    scroll_update(this);
end

local musicbutton_onclick = function(this)
    local parent = this:GetParent();
    local scrollframe = parent.scrollframe;
    local music_index = this:GetID() + (FSF_GetOffset(scrollframe) * NUM_COLUMNS);

    setchoice(parent, music_index);
end

local function search_update()

    if(MRPMusicSelect.search_box:HasFocus() == false) then
        return;
    end

    musicFilenames = { };

    local searchBoxContents = MRPMusicSelect.search_box:GetText():upper()

    -- Fix up the list, fileid will be "number" type
    for k,v in pairs(musicFilenames) do
        local num = tonumber(v);
        if(num) then
            musicFilenames[k] = num;
        else
            musicFilenames[k] = v;
        end
    end

    for _, _, name in LibRPMedia:FindAllMusicFiles() do
        if(name:upper():find(searchBoxContents, 1, true)) then
            tinsert(musicFilenames, name);
        end
    end

    -- Save music count.
    musicFilenames_count = #musicFilenames;

    MRPMusicSelect.search_count_label:SetText(#musicFilenames .. L["editor_matches"]);

    FSF_Update(MRPMusicSelect.scrollframe, math.ceil(musicFilenames_count / NUM_COLUMNS) + 1, NUM_ROWS, ICON_SIZE);

    FSF_OnVerticalScroll(MRPMusicSelect.scrollframe, 1, ICON_SIZE, onscroll);

end

local choice_onclick = function(this)
    local choice = this:GetID();
    local parent = this:GetParent();

    if(choice == BTN_IDOKAY) then
        if(type(parent.callback) == "function") then
            if(type(parent.selected_music_file) == "string") then
                -- Convert path to ID
                pcall(parent.callback, LibRPMedia:GetMusicFileByName(parent.selected_music_file));
            else
                -- not a string, should be a numerical fileid
                pcall(parent.callback, parent.selected_music_file);
            end
        end
        if(soundHandle ~= 0) then
            StopSound(soundHandle)
            soundHandle = 0
        end
        parent:Hide();
    elseif(choice == BTN_IDCLEAR) then
        if(type(parent.callback) == "function") then
            pcall(parent.callback, nil);
        end
        if(soundHandle ~= 0) then
            StopSound(soundHandle)
            soundHandle = 0
        end
        parent:Hide();
    elseif(choice == BTN_IDPREVIEW) then
        if(soundHandle ~= 0) then
            StopSound(soundHandle)
        end

        local musicFileID = parent.selected_music_file;
        if(type(musicFileID) == "string") then
            -- Convert path to ID
            musicFileID = LibRPMedia:GetMusicFileByName(musicFileID);
        end

        soundHandle = select(2, PlaySoundFile(LibRPMedia:GetNativeMusicFile(musicFileID), "Master"))
    elseif(choice == BTN_IDSTOP) then
        if(soundHandle ~= 0) then
            StopSound(soundHandle)
            soundHandle = 0
        end
    elseif(choice == BTN_IDCANCEL) then
        if(soundHandle ~= 0) then
            StopSound(soundHandle)
            soundHandle = 0
        end
        parent:Hide();
    end
    if(soundHandle == nil) then -- Prevent errors, due to some tracks not providing a soundHandle.
        soundHandle = 0
    end
end

local function Reset_Searchbox_Text()
    MRPMusicSelect.search_box:SetText("")
end

local create = function()
    local f = CreateFrame("Frame", "MRPMusicSelect", UIParent, nil);


    -- Set inital member variables
    f.selected_music = 1;
    f.callback = nil;


    -- Setup the frame.
    f:SetToplevel(true);
    f:SetFrameStrata("DIALOG");
    f:SetMovable(true);
    f:EnableMouse(true);
    f:Hide();
    f:ClearAllPoints();
    f:SetSize(400, 500);
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


    -- scroll frame
    f.scrollframe = CreateFrame("ScrollFrame", nil, f, "FauxScrollFrameTemplate");
    f.scrollframe:ClearAllPoints();
    f.scrollframe:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -8);
    f.scrollframe:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -32, 8);
    f.scrollframe:SetScript("OnVerticalScroll", function(this, offset) FSF_OnVerticalScroll(this, offset, ICON_SIZE, onscroll); end);


    -- Ok button
    f.okay_button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
    f.okay_button:SetID(BTN_IDOKAY);
    f.okay_button:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -32, 8);
    f.okay_button:SetSize(128, 32);
    f.okay_button:SetText(TXT_OKAY);
    f.okay_button:SetScript("OnClick", choice_onclick);

    -- Cancel Button
    f.cancel_button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
    f.cancel_button:SetID(BTN_IDCANCEL);
    f.cancel_button:SetPoint("BOTTOMRIGHT", f.okay_button, "BOTTOMLEFT", -1, 0);
    f.cancel_button:SetSize(128, 32);
    f.cancel_button:SetText(TXT_CANCEL);
    f.cancel_button:SetScript("OnClick", choice_onclick);

    -- Clear Button
    f.clear_button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
    f.clear_button:SetID(BTN_IDCLEAR);
    f.clear_button:SetPoint("BOTTOMLEFT", f.cancel_button, "TOPLEFT", 0, 1);
    f.clear_button:SetSize(128, 32);
    f.clear_button:SetText(TXT_CLEAR);
    f.clear_button:SetScript("OnClick", choice_onclick);

    -- Preview Button
    f.preview_button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
    f.preview_button:SetID(BTN_IDPREVIEW);
    f.preview_button:SetPoint("RIGHT", f.clear_button, "LEFT", -45, 0);
    f.preview_button:SetSize(50, 32);
    f.preview_button:SetText(TXT_PREVIEW);
    f.preview_button:SetScript("OnClick", choice_onclick);

    -- Stop Button
    f.stop_button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
    f.stop_button:SetID(BTN_IDSTOP);
    f.stop_button:SetPoint("RIGHT", f.cancel_button, "LEFT", -45, 0);
    f.stop_button:SetSize(50, 32);
    f.stop_button:SetText(TXT_STOP);
    f.stop_button:SetScript("OnClick", choice_onclick);

    -- Search box
    f.search_box = CreateFrame( "EditBox", "MRPMusicSelectSearchBox", f )
    f.search_box:SetBackdrop(	{
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 5, right = 3, top = 3, bottom = 3	},
    } )
    f.search_box:SetPoint( "LEFT", f.clear_button, "RIGHT", 0, 2 )
    f.search_box:SetHeight( 25 )
    f.search_box:SetWidth( 128 )
    f.search_box:SetTextInsets( 7, 7, 0, 0 )
    f.search_box:EnableMouse(true)
    f.search_box:SetAutoFocus(false)
    f.search_box:SetMultiLine(false)
    f.search_box:SetFontObject( "GameFontHighlight" )
    f.search_box:SetScript("OnTextChanged", search_update)
    f.search_box_label = f:CreateFontString();
    f.search_box_label:ClearAllPoints();
    f.search_box_label:SetSize(96, 16);
    f.search_box_label:SetPoint("BOTTOMLEFT", f.search_box, "TOPLEFT", -10, 0);
    f.search_box_label:SetFontObject(GameFontNormal);
    f.search_box_label:SetText(L["editor_search"]);

    f.search_box:SetScript( "OnEscapePressed", EditBox_ClearFocus )

    -- Search count label
    f.search_count_label = f:CreateFontString();
    f.search_count_label:ClearAllPoints();
    f.search_count_label:SetSize(150, 16);
    f.search_count_label:SetPoint("BOTTOM", f.clear_button, "TOP", 0, 0);
    f.search_count_label:SetFontObject(GameFontNormal);


    -- Setup script handlers
    f:SetScript("OnShow", function(this) scroll_update(this); end);
    f:SetScript("OnHide", function(this) this.callback = nil; Reset_Searchbox_Text(); end);



    -- Set up all the music buttons.
    f.music_buttons = { };

    local n_frame;
    local x;
    local y;

    for i = 1, NUM_MUSICS, 1 do
        x = (16 + (((i - 1) % NUM_COLUMNS) * (ICON_SIZE + ICON_PADDING)));
        y = (16 + ((math.floor((i - 1) / NUM_COLUMNS)) * (ICON_SIZE + ICON_PADDING))) * -1;
        n_frame = CreateFrame("CheckButton", nil, f, "UIMenuButtonStretchTemplate");
        n_frame:SetSize(350, 35);
        n_frame:SetScript("OnClick", musicbutton_onclick);
        n_frame:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
        n_frame:SetCheckedTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
        n_frame:SetID(i);
        n_frame:SetPoint("TOPLEFT", f, "TOPLEFT", x, y);
        tinsert(f.music_buttons, n_frame);
    end


    -- Select the first button on creation.
    musicbutton_onclick(f.music_buttons[1]);

    return f;
end

local init = function()
    init_filenames();
    frame = create();
end

local show = function(callback, current_music)
    init_filenames(true)
    MRPMusicSelect.search_count_label:SetText(#musicFilenames .. L["editor_matches"]);
    if(type(callback) ~= "function") then
        error("mrp_musicselector_show: Usage: mrp_musicselector_show(callback_function, [current_music]);");
        return;
    end

    local music_found = false;

    if(type(current_music) ~= "nil") then
        if type(current_music) == "number" then -- Convert ID to path so we can find it.
            current_music = tostring(LibRPMedia:GetMusicNameByFile(current_music))
        end

        for k,v in pairs(musicFilenames) do
            if(current_music == v) then
                local sel_music_offset = (k / musicFilenames_count);
                --local sel_music_offset = math.floor(k / 10) / math.ceil(musicFilenames_count / 10);
                local _, slider_max = frame.scrollframe.ScrollBar:GetMinMaxValues();
                if(slider_max > savedMaxSliderSize) then
                    savedMaxSliderSize = slider_max
                end
                local slider_offset = sel_music_offset * savedMaxSliderSize;

                FSF_OnVerticalScroll(frame.scrollframe, slider_offset, ICON_SIZE, onscroll);
                setchoice(frame, k);
                music_found = true;
                break;
            end
        end
    end

    if(music_found == false) then
        setchoice(frame, 1);
        FSF_OnVerticalScroll(frame.scrollframe, 0, ICON_SIZE, onscroll);
    end

    frame.callback = callback;
    frame:Show();
end

local hide = function()
    frame:Hide();
end


-- Finish by initializing everything.
init();


-- global API exports
_G["mrp_musicselector_show"] = show;
_G["mrp_musicselector_hide"] = hide;
