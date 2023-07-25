local Alar = DBM:NewBossMod("Alar", DBM_ALAR_NAME, DBM_ALAR_DESCRIPTION, DBM_TEMPEST_KEEP, DBM_EYE_TAB, 1);

Alar.Version	= "1.0";
Alar.Author		= "Tandanu";

local phase2	= false;
local lastAdd	= 0;
local flying	= false;
local pulled    = 0;

Alar:RegisterEvents(
	"SPELL_DAMAGE",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_START"
);

Alar:RegisterCombat("COMBAT");

Alar:AddOption("WarnArmor", true, DBM_ALAR_OPTION_MELTARMOR);
Alar:AddOption("Meteor", true, DBM_ALAR_OPTION_METEOR);

Alar:AddBarOption("Enrage")
Alar:AddBarOption("Meteor")
Alar:AddBarOption("Melt Expires: (.*)")
Alar:AddBarOption("Next Melt Armor")

function Alar:OnCombatStart(delay)	
	phase2	= false;
	lastAdd	= 0;
	flying = false;
	pulled = GetTime();
	self:StartStatusBarTimer(36 - delay, "Next Platform", "Interface\\AddOns\\DBM_API\\Textures\\CryptFiendUnBurrow");
end

function Alar:OnEvent(event, arg1)
	if event == "SPELL_DAMAGE" and arg1.spellId == 35181 then
		self:SendSync("Divebomb");
	elseif event == "SPELL_AURA_APPLIED" then
		if arg1.spellId == 35383 and arg1.destName == UnitName("player") then
			self:AddSpecialWarning(DBM_ALAR_WARN_FIRE);
		elseif arg1.spellId == 35410 then
			self:SendSync("MeltArmor"..tostring(arg1.destName));
		end
	elseif event == "SPELL_CAST_START" then
		if arg1.spellId == 34342 then
			self:SendSync("Rebirth");
		end
	end
end

function Alar:OnSync(msg)
	if msg == "Rebirth" and not self:IsWipe() and self.InCombat then
		self:Announce(DBM_ALAR_WARN_REBIRTH, 2);
		phase2 = GetTime();
		self:EndStatusBarTimer("Next Platform");
		self:StartStatusBarTimer(32, "Meteor", "Interface\\Icons\\Spell_Fire_Fireball02");
		self:StartStatusBarTimer(600, "Enrage", "Interface\\Icons\\Spell_Shadow_UnholyFrenzy");
	elseif msg == "Divebomb" then
		self:StartStatusBarTimer(44, "Meteor", "Interface\\Icons\\Spell_Fire_Fireball02");
	elseif string.sub(msg, 0, 9) == "MeltArmor" then
		local target = string.sub(msg, 10);
		if target then
			if self:GetStatusBarTimerTimeLeft("Melt Expires: "..target) then
				self:UpdateStatusBarTimer("Melt Expires: "..target, 0, 60);
			else
				self:StartStatusBarTimer(60, "Melt Expires: "..target, "Interface\\Icons\\Spell_Fire_Immolation");
				self:StartStatusBarTimer(79, "Next Melt Armor", "Interface\\Icons\\Spell_Fire_Immolation");
			end
			if self.Options.WarnArmor then
				self:Announce(DBM_ALAR_WARN_MELTARMOR:format(target), 1);
			end
		end
	elseif msg == "AddInc" and (GetTime() - lastAdd) > 15 and self.InCombat then
		lastAdd = GetTime();
		flying = true;
		self:EndStatusBarTimer("Next Platform");
		self:Announce(DBM_ALAR_WARN_ADD, 2);
	elseif msg == "Meteor" and self.InCombat then
		if self.Options.Meteor then
			self:Announce(DBM_ALAR_WARN_METEOR, 3);
		end
		self:StartStatusBarTimer(52, "Meteor", "Interface\\Icons\\Spell_Fire_Fireball02");
	elseif msg == "NextPlatform" and self.InCombat then
		flying = false;
		self:StartStatusBarTimer(35, "Next Platform", "Interface\\AddOns\\DBM_API\\Textures\\CryptFiendUnBurrow");
	end
end

function Alar:OnUpdate(elapsed)
	local time_since_pull = GetTime() - pulled
	if self.InCombat and not self:IsWipe() and time_since_pull > 10 then
		local foundIt;
		local target;
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == DBM_ALAR_NAME then
				foundIt = true;
				target = UnitName("raid"..i.."targettarget");
				if not target and UnitCastingInfo("raid"..i.."target") == DBM_ALAR_FLAME_BUFFET then
					target = "Dummy";
				end
				break;
			end
		end

		if foundIt and not target and not phase2 then
			self:SendSync("AddInc");
		elseif target and flying then
			self:SendSync("NextPlatform");
		end
	end
end
