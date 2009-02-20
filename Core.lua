
local dropDownMenu, db
local red, green, blue

local uClock = LibStub("AceAddon-3.0"):NewAddon("uClock", 'AceTimer-3.0')
local uClockBlock = LibStub("LibDataBroker-1.1"):NewDataObject("uClock", {
	type = "data source",
	icon = "Interface\\Icons\\INV_Misc_PocketWatch_02",

	OnClick = function(self, button)
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				if GroupCalendar then GroupCalendar.ToggleCalendarDisplay()
				else ToggleCalendar() end
			else
				ToggleTimeManager()
			end
		elseif button == "RightButton" then
			GameTooltip:Hide()
			ToggleDropDownMenu(1, nil, dropDownMenu, "cursor")
		end
	end,

	OnTooltipShow = function(tooltip)
		tooltip:AddDoubleLine("Server Time", uClock:GetTimeString(GetGameTime()))
		tooltip:AddDoubleLine("Today's Date", date("%A, %B %d, %Y"))
		tooltip:AddLine(" ")
		tooltip:AddLine("|cffeda55fClick|r to toggle the Time Manager.", 0.2, 1, 0.2)
		tooltip:AddLine("|cffeda55fShift-Click|r to toggle the Calendar.", 0.2, 1, 0.2)
		tooltip:AddLine("|cffeda55fRight-Click|r for options.", 0.2, 1, 0.2)
	end,
})


function uClock:OnEnable()
	self.db = LibStub("AceDB-3.0"):New("uClockDB", { profile = { twentyFour = true, showSeconds = false, r = 1, g = 1, b = 1 }}, "Default")
	db = self.db.profile

	dropDownMenu = CreateFrame("Frame")
	dropDownMenu.displayMode = "MENU"
	dropDownMenu.info = {}
	dropDownMenu.levelAdjust = 0
	dropDownMenu.initialize = function(self, level, value)
		if not level then return end

		local info = self.info
		wipe(info)

		if level == 1 then
			info.isTitle = 1
			info.text = "uClock"
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)

			info.disabled = nil
			info.isTitle = nil
			info.notCheckable = nil
			info.keepShownOnClick = 1

			info.text = "24 Hour Mode"
			info.func = function() db.twentyFour = not db.twentyFour uClock:UpdateText() end
			info.checked = function() return db.twentyFour end
			UIDropDownMenu_AddButton(info, level)

			info.text = "Show Seconds"
			info.func = function() db.showSeconds = not db.showSeconds uClock:UpdateText() end
			info.checked = function() return db.showSeconds end
			UIDropDownMenu_AddButton(info, level)

			info.text = "Colour of Text"
			info.func = nil
			info.checked = nil
			info.notClickable = true
			info.hasColorSwatch = true
			info.swatchFunc = function() db.r, db.g, db.b = ColorPickerFrame:GetColorRGB() uClock:UpdateText() end
			info.cancelFunc = function(previous) db.r, db.g, db.b = previous.r, previous.g, previous.b uClock:UpdateText() end
			info.r, info.g, info.b = db.r, db.g, db.b
			UIDropDownMenu_AddButton(info, level)

			wipe(info)

			info.disabled = 1
			info.text = nil
			info.func = nil
			UIDropDownMenu_AddButton(info, level)

			info.disabled = nil
			info.text = CLOSE
			info.func = function() if UIDROPDOWNMENU_OPEN_MENU == dropDownMenu then CloseDropDownMenus() end end
			UIDropDownMenu_AddButton(info, level)
		end
	end

	self:ScheduleRepeatingTimer("UpdateText", 1)
end


function uClock:UpdateText()
	uClockBlock.text = self:GetTimeString(date("%H"), date("%M"), true)
end

function uClock:GetTimeString(hour, minute, color)
	local time, pm

	if not self.db.profile.twentyFour then
		pm = floor(hour / 12) == 1
		hour = mod(hour, 12)

		if hour == 0 then hour = 12 end
	end

	time = ("%d:%02d"):format(hour, minute)

	if self.db.profile.showSeconds then
		time = time..date(":%S")
	end

	if not self.db.profile.twentyFour then
		time = time..(pm and " PM" or " AM")
	end

	if color then
		return ("|cff%02x%02x%02x%s|r"):format(db.r*255, db.g*255, db.b*255, time)
	else
		return time
	end
end
