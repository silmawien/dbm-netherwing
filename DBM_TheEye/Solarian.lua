local Solarian = DBM:NewBossMod("Solarian", DBM_SOLARIAN_NAME, DBM_SOLARIAN_DESCRIPTION, DBM_TEMPEST_KEEP, DBM_EYE_TAB, 3);

Solarian.Version	= "1.0";
Solarian.Author		= "Tandanu";

local warnPhase = false
local split = false
local wrathCount = 0

Solarian:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"CHAT_MSG_MONSTER_YELL"
);

Solarian:RegisterCombat("YELL", {"Tal anu'men no sin'dorei!"});

Solarian:AddOption("WarnWrath", true, DBM_SOLARIAN_OPTION_WARN_WRATH);
Solarian:AddOption("IconWrath", true, DBM_SOLARIAN_OPTION_ICON_WRATH);
Solarian:AddOption("SpecWrath", true, DBM_SOLARIAN_OPTION_SPECWARN_WRATH);
Solarian:AddOption("SoundWarning", false, DBM_SOLARIAN_OPTION_SOUND);
Solarian:AddOption("WhisperWrath", true, DBM_SOLARIAN_OPTION_WHISPER_WRATH);

Solarian:AddBarOption("Next Wrath")
Solarian:AddBarOption("Split")
Solarian:AddBarOption("Agents")
Solarian:AddBarOption("Priests & Solarian")

function Solarian:OnCombatStart(delay)
	warnPhase = false
	split = false
	wrathCount = 0
	self:ScheduleSelf(15, "CheckBack"); -- to prevent bugs if you are using an unsupported client language...
	self:StartStatusBarTimer(50 - delay, "Split", "Interface\\Icons\\Spell_Holy_SummonLightwell")
	self:StartStatusBarTimer(23 - delay, "Next Wrath", "Interface\\Icons\\Spell_Arcane_ArcaneTorrent")
end

function Solarian:OnCombatEnd()
	split = false
end

function Solarian:OnEvent(event, arg1)
	if event == "SPELL_AURA_APPLIED" then
		if arg1.spellId == 33045 then
			self:SendSync("Wrath"..tostring(arg1.destName));
		end
	elseif event == "SPELL_CAST_START" then
		if arg1.spellId == 33040 then
			wrathCount = wrathCount + 1
			--if odd, then 45
			--if even then 24?
			if wrathCount == 1 then
				self:StartStatusBarTimer(52, "Next Wrath", "Interface\\Icons\\Spell_Arcane_ArcaneTorrent")
			elseif wrathCount % 2 == 0 then
				self:StartStatusBarTimer(45, "Next Wrath", "Interface\\Icons\\Spell_Arcane_ArcaneTorrent")
			else
				self:StartStatusBarTimer(47, "Next Wrath", "Interface\\Icons\\Spell_Arcane_ArcaneTorrent")
			end
		end
	elseif event == "CheckBack" then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == DBM_SOLARIAN_NAME and UnitAffectingCombat("raid"..i.."target") then -- to prevent false positives after wipes
				warnPhase = true;
				break;
			end
		end
	elseif event == "ResetSplit" then
		split = false
	end
end

function Solarian:OnSync(msg)
	if string.sub(msg, 1, 5) == "Wrath" then
		local target = string.sub(msg, 6);
		if target then
			if target == UnitName("player") then
			   if self.Options.SpecWrath then 
				  self:AddSpecialWarning(DBM_SOLARIAN_SPECWARN_WRATH); 
			   end 
			   if self.Options.SoundWarning then 
				  PlaySoundFile("Sound\\Spells\\PVPFlagTaken.wav"); 
				  PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav");
			   end
			end
			if self.Options.WarnWrath then
				self:Announce(string.format(DBM_SOLARIAN_ANNOUNCE_WRATH, target), 1);
			end
			if self.Options.IconWrath then
				self:SetIcon(target, 6);
			end
			if self.Options.WhisperWrath then
				self:SendHiddenWhisper(DBM_SOLARIAN_SPECWARN_WRATH, target)
			end
		end
	elseif msg == "Split" then
		split = true
		self:StartStatusBarTimer(90, "Split", "Interface\\Icons\\Spell_Holy_SummonLightwell");
		self:StartStatusBarTimer(19, "Priests & Solarian", "Interface\\Icons\\Spell_Holy_Renew");
		self:StartStatusBarTimer(4.5, "Agents", "Interface\\Icons\\Spell_Holy_AuraMastery");
		self:ScheduleEvent(50, "ResetSplit")
	end
end

function Solarian:OnUpdate(elapsed) -- this can be used to detect the phase if nobody was in range after her teleport
	if not split and self.InCombat then
		local foundIt;
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == DBM_SOLARIAN_NAME then
				foundIt = true;
				break;
			end
		end
		if not foundIt and warnPhase then
			self:SendSync("Split");
			warnPhase = false;
			self:ScheduleSelf(45, "CheckBack");
		end
	end
end
