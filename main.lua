local frame = CreateFrame("Frame")
local version = "05202023a"
local playing = false

SLASH_safety1 = "/safety"

SlashCmdList["safety"] = function(msg)
	cmd(msg)
end

function cmd(msg)
	if msg == "update" then
		print("force updating health:", settings["maxhp"], "is now", UnitHealthMax("player"))
		settings["maxhp"] = UnitHealthMax("player")
	elseif msg == "play" then
		if not playing then
			print("playing")
			_, playing = PlaySoundFile("Interface\\AddOns\\safety\\soil.ogg", "Effects", true, "soil")
		elseif playing then
			print("stopping")
			StopSound(playing)
			playing = false
		end
	elseif msg == "stop" and playing then
		print("stopping")
		StopSound(playing)
		playing = false
	elseif msg == "purge" then
		print("safety: purged")
		settings = {}
	end
end

function handler(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "safety" then
		if not settings or settings["version"] ~= version then
			settings = {}
			settings["version"] = version
			settings["maxhp"] = UnitHealthMax("player")
			settings["threshold"] = 0.95
		end
	elseif event == "UNIT_HEALTH" and arg1 == "player" and InCombatLockdown() then
		health = UnitHealth(arg1) / settings["maxhp"]
		if health < settings["threshold"] and not playing then
			_, playing = PlaySoundFile("Interface\\AddOns\\safety\\soil.ogg", "Effects")
		end
	elseif event == "UNIT_MAXHEALTH" and arg1 == "player" then
		settings["maxhp"] = UnitHealthMax("player")
	elseif event == "PLAYER_REGEN_ENABLED" then
		StopSound(playing, 1000)
		playing = false
	elseif event == "PLAYER_LEVEL_UP" then
		settings["maxhp"] = UnitHealthMax("player")
	end
end

--[[function options_load(panel)
	InterfaceOptions_AddCategory(panel);
end]]

--	--[[ Create a frame to use as the panel ]] --
local panel = CreateFrame("FRAME", "options");
panel.name = "safe!!";
--
--	-- [[ When the player clicks okay, set the original value to the current setting ]] --
panel.okay = function(self)
	-- self.originalValue = MY_VARIABLE;
end
--
--	-- [[ When the player clicks cancel, set the current setting to the original value ]] --
panel.cancel = function(self)
	-- MY_VARIABLE = self.originalValue;
end

panel.default = function(self)
end
--
--	-- [[ Add the panel to the Interface Options ]] --
InterfaceOptions_AddCategory(panel);

local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
btn:SetPoint("TOPLEFT", panel, 0, -40)
btn:SetText("Click me")
btn:SetWidth(100)
btn:SetScript("OnClick", function()
	print("You clicked me!")
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:SetScript("OnEvent", handler)
