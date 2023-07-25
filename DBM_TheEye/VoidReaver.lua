local VoidReaver = DBM:NewBossMod("VoidReaver", DBM_VOIDREAVER_NAME, DBM_VOIDREAVER_DESCRIPTION, DBM_TEMPEST_KEEP, DBM_EYE_TAB, 2);

VoidReaver.Version		= "1.0";
VoidReaver.Author		= "Tandanu";

VoidReaver:RegisterEvents(
	"UNIT_SPELLCAST_CHANNEL_START",
	"SPELL_CAST_SUCCESS",
	"CHAT_MSG_MONSTER_YELL"
);

VoidReaver:RegisterCombat("YELL", {"Alert! You are marked for extermination."});

VoidReaver:AddOption("WarnPounding", true, DBM_VOIDREAVER_OPTION_WARN_POUNDING);

VoidReaver:AddBarOption("Enrage")
VoidReaver:AddBarOption("Next Pounding")
VoidReaver:AddBarOption("Pounding")

function VoidReaver:OnCombatStart(delay)

	self:StartStatusBarTimer(600 - delay, "Enrage", "Interface\\Icons\\Spell_Shadow_UnholyFrenzy");
	self:StartStatusBarTimer(8 - delay, "Next Pounding", "Interface\\Icons\\Ability_ThunderClap");
end

function VoidReaver:OnEvent(event, arg1)
	if event == "UNIT_SPELLCAST_CHANNEL_START" and type(arg1) == "string" and UnitName(arg1) == DBM_VOIDREAVER_NAME then
		if UnitChannelInfo(arg1) == DBM_VOIDREAVER_POUNDING then
			self:SendSync("Pounding");
		end
	end
end

function VoidReaver:OnSync(msg)
	if msg == "Pounding" then
		self:StartStatusBarTimer(13, "Next Pounding", "Interface\\Icons\\Ability_ThunderClap");
		self:StartStatusBarTimer(3, "Pounding", "Interface\\Icons\\Ability_ThunderClap");
		if self.Options.WarnPounding then
			self:Announce(DBM_VOIDREAVER_WARN_POUNDING, 3);
		end
	end
end
