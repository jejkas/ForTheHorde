-- Default config function.
-- /script FTH_LoadDefaultSettings()
-- Use this command to reset back to default settings.
function FTH_LoadDefaultSettings()
	FTH_Settings = {};
	FTH_Settings["Enabled"] = true;
	FTH_Settings["OnlyOutOfCombat"] = true;
	FTH_Settings["DisconnectOnDebuff"] = false;
	FTH_Settings["HealthLimit"] = 0.1;
	FTH_Settings["Buffs"] = {};
	FTH_Settings["Debuffs"] = {};
	FTH_Settings["Debuffs"]["polymorph"] = true;
	FTH_Settings["Debuffs"]["freezing trap"] = true;
	FTH_Settings["Debuffs"]["gnomish mind control cap"] = true;
	FTH_Settings["Debuffs"]["reckless charge"] = true;
	FTH_Settings["Debuffs"]["sleep"] = true;
	FTH_Settings["Debuffs"]["seduction"] = true;
	FTH_Settings["Debuffs"]["mind control"] = true;
end



SLASH_FTH1 = "/FTH"

SlashCmdList["FTH"] = function(args)
	if args == "" or args == nil
	then
		-- No args given.
		ChatFrame1:AddMessage("For The Horde! - Automatic 'Alt-F4' addon!");
		ChatFrame1:AddMessage("/fth enabled [true|false] (" .. tostring(FTH_Settings["Enabled"]) .. ")" );
		ChatFrame1:AddMessage("/fth onlyoutofcombat [true|false] (" .. tostring(FTH_Settings["OnlyOutOfCombat"]) .. ")" );
		ChatFrame1:AddMessage("/fth disconnectondebuff [true|false] (" .. tostring(FTH_Settings["DisconnectOnDebuff"]) .. ")" );
		ChatFrame1:AddMessage("/fth healthlimit [number] (" .. tostring(FTH_Settings["HealthLimit"]*100) .. "%)" );
	else
		local args = FTH_strsplit(" ", args);
		FTH_(args);
		if string.lower(args[1]) == "enabled"
		then
			if args[2] ~= nil and args[2] == "false"
			then
				ChatFrame1:AddMessage("For The Horde! Is now off.");
				FTH_Settings["Enabled"] = false;
			else
				ChatFrame1:AddMessage("For The Horde! Is now on.");
				FTH_Settings["Enabled"] = true;
			end
		elseif string.lower(args[1]) == "onlyoutofcombat"
		then
			if args[2] ~= nil and args[2] == "false"
			then
				ChatFrame1:AddMessage("Will activate in combat.");
				FTH_Settings["OnlyOutOfCombat"] = false;
			else
				ChatFrame1:AddMessage("Will NOT activate in combat.");
				FTH_Settings["OnlyOutOfCombat"] = true;
			end
		elseif string.lower(args[1]) == "disconnectondebuff"
		then
			if args[2] ~= nil and args[2] == "true"
			then
				ChatFrame1:AddMessage("Will activate on buff gained.");
				FTH_Settings["DisconnectOnDebuff"] = true;
			else
				ChatFrame1:AddMessage("Will NOT activate on buff gained.");
				FTH_Settings["DisconnectOnDebuff"] = false;
			end
		elseif string.lower(args[1]) == "healthlimit"
		then
			if args[2] ~= nil
			then
				FTH_Settings["HealthLimit"] = tonumber(args[2])/100;
				ChatFrame1:AddMessage("New health limit: " .. FTH_Settings["HealthLimit"]*100);
			end
		end
	end
end

FTH_Battlecry = {
	"For The Horde!"
}

function FTH_RandomBattlecry()
	return FTH_Battlecry[math.random(1,table.getn(FTH_Battlecry))];
end


function FTH_BuffStatus(str)
	return FTH_Settings["Buffs"][string.lower(str)];
end

function FTH_DebuffStatus(str)
	FTH_("Checking: " .. str);
	FTH_(FTH_Settings["Debuffs"][string.lower(str)]);
	return FTH_Settings["Debuffs"][string.lower(str)];
end

function FTH_DoWeHaveCC()
	for buff,doQuit in pairs(FTH_Settings["Buffs"])
	do
		FTH_("Checking buff: " .. buff .. "( ".. tostring(doQuit) .." )");
		if doQuit and FTH_HaveBuff("player", buff)
		then
			return true;
		end
	end
	
	
	for debuff,doQuit in pairs(FTH_Settings["Debuffs"])
	do
		FTH_("Checking debuff: " .. debuff .. "( ".. tostring(doQuit) .." ) " .. tostring(FTH_HaveDebuff("player", debuff)));
		if doQuit and FTH_HaveDebuff("player", debuff)
		then
			return true;
		end
	end
end

FTH_DoneYell = false;

function FTH_PerformQuit(ignoreCombat)
	if FTH_Settings["OnlyOutOfCombat"] and UnitAffectingCombat("player") and ignoreCombat == nil
	then
		FTH_("Unit is in combat, but we only allowed to quit while out of combat.")
		return;
	end
	if not FTH_Settings["Enabled"]
	then
		FTH_("Addon is disabled.")
		return
	end
	
	FTH_("Force quit triggered")
	if not FTH_DoneYell
	then
		SendChatMessage(FTH_RandomBattlecry(), "YELL");
		FTH_DoneYell = true;
	end
	
	ForceQuit();
end

-- Event stuff


FTH_Frame = CreateFrame("FRAME", "FTHFrame");
function FTH_OnUpdateEvent(self, event, ...)
	
end

function FTH_eventHandler()
	FTH_(event)
	FTH_(arg1)
	FTH_(arg2)
	FTH_(arg3)
	if event == "ADDON_LOADED"
	then
		if FTH_Settings == nil
		--or true -- Debugg, always reset our settings.
		then
			FTH_LoadDefaultSettings();
		end
	elseif event == "COMBAT_TEXT_UPDATE"
	then
		if FTH_Settings["HealthLimit"] >= UnitHealth("player")/UnitHealthMax("player")
		then
			FTH_PerformQuit(true);
		end
		if arg1 == "AURA_START_HARMFUL"
		then
			if FTH_Settings["DisconnectOnDebuff"] and FTH_DebuffStatus(arg2)
			then
				FTH_PerformQuit();
			end
		end
	elseif event == "PLAYER_REGEN_ENABLED"
	then
		if FTH_DoWeHaveCC()
		then
			FTH_PerformQuit();
		end
	end
	
end


FTH_Frame:SetScript("OnUpdate", FTH_OnUpdateEvent);
FTH_Frame:SetScript("OnEvent", FTH_eventHandler);
FTH_Frame:RegisterEvent("ADDON_LOADED");
--FTH_Frame:RegisterEvent("PLAYER_REGEN_DISABLED");
FTH_Frame:RegisterEvent("PLAYER_REGEN_ENABLED");
FTH_Frame:RegisterEvent("COMBAT_TEXT_UPDATE");
--FTH_Frame:RegisterEvent("UNIT_AURA");








-- Good stuff to have

function FTH_HaveBuff(targetUnit, str)
	for i=1,40
	do
	
		local buffName = FTH_GetBuffName(targetUnit,i);
		
		if(buffName == nil or str == nil)
		then
			return false;
		end;
		
		--printDebug(buffTexture .. " == ".. str);
		if string.lower(str) == string.lower(buffName)
		then
			return true;
		end;
	end;
end;

function FTH_GetBuffName(unit, nr)
	ForTheHordeTooltip:ClearLines();
	ForTheHordeTooltip:SetUnitBuff(unit,nr);
	local debuff_name = ForTheHordeTooltipTextLeft1:GetText();
	return debuff_name;
end


function FTH_HaveDebuff(targetUnit, str)
	for i=1,40
	do
	
		local buffName, amount = FTH_GetDebuffName(targetUnit,i);
		
		if(buffName == nil or str == nil)
		then
			return false;
		end;
		
		FTH_(string.lower(str) .. " == ".. string.lower(buffName));
		if string.lower(str) == string.lower(buffName)
		then
			return true, amount;
		end;
	end;
end;


function FTH_GetDebuffName(unit, nr)
	ForTheHordeTooltip:ClearLines();
	ForTheHordeTooltip:SetUnitDebuff(unit,nr);
	local debuff_name = ForTheHordeTooltipTextLeft1:GetText();
	local _,amount = UnitDebuff(unit, nr);
	return debuff_name, amount;
end



function FTH_(str)
	if true
	then
		return;
	end;
	
	local c = ChatFrame5
	
	if str == nil
	then
		c:AddMessage('DEBUG: NIL');
	elseif type(str) == "boolean"
	then
		if str == true
		then
			c:AddMessage('DEBUG: true');
		else
			c:AddMessage('DEBUG: false');
		end;
	elseif type(str) == "table"
	then
		c:AddMessage('DEBUG: array');
		FTH_printArray(str);
	else
		c:AddMessage('DEBUG: '..str);
	end;
end;


function FTH_printArray(arr, n)
	if n == nil
	then
		 n = "arr";
	end
	for key,value in pairs(arr)
	do
		if type(arr[key]) == "table"
		then
			FTH_printArray(arr[key], n .. "[\"" .. key .. "\"]");
		else
			if type(arr[key]) == "string"
			then
				FTH_(n .. "[\"" .. key .. "\"] = \"" .. arr[key] .."\"");
			elseif type(arr[key]) == "number" 
			then
				FTH_(n .. "[\"" .. key .. "\"] = " .. arr[key]);
			elseif type(arr[key]) == "boolean" 
			then
				if arr[key]
				then
					FTH_(n .. "[\"" .. key .. "\"] = true");
				else
					FTH_(n .. "[\"" .. key .. "\"] = false");
				end;
			else
				FTH_(n .. "[\"" .. key .. "\"] = " .. type(arr[key]));
				
			end;
		end;
	end
end;

function FTH_strsplit(sep,str)
	local arr = {}
	local tmp = "";
	
	--FTH_(string.len(str));
	local chr;
	for i = 1, string.len(str)
	do
		chr = string.sub(str, i, i);
		if chr == sep
		then
			table.insert(arr,tmp);
			tmp = "";
		else
			tmp = tmp..chr;
		end;
	end
	table.insert(arr,tmp);
	
	return arr
end