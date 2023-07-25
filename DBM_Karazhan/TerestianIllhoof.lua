local TerestianIllhoof = DBM:NewBossMod("TerestianIllhoof", DBM_TI_NAME, DBM_TI_DESCRIPTION, DBM_KARAZHAN, DBM_KARAZHAN_TAB, 9);

TerestianIllhoof.Version			= "1.0";
TerestianIllhoof.Author			= "Tandanu";

TerestianIllhoof:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"CHAT_MSG_MONSTER_EMOTE"
);

TerestianIllhoof:RegisterCombat("YELL", DBM_TI_YELL_PULL);

TerestianIllhoof:AddBarOption("Sacrifice")
TerestianIllhoof:AddBarOption("Kil'rek Respawns")

function TerestianIllhoof:OnCombatStart(delay)
	self:StartStatusBarTimer(20, "Sacrifice", "Interface\\Icons\\Spell_Shadow_AntiMagicShell");
end

function TerestianIllhoof:OnEvent(event, arg1)
	if event == "SacrificeWarning" then
		self:Announce(DBM_TI_SACRIFICE_SOON, 2);
	elseif event == "CHAT_MSG_MONSTER_EMOTE" then
		if arg1 == DBM_TI_EMOTE_IMP then
			self:StartStatusBarTimer(30, "Kil'rek Respawns", "Interface\\Icons\\Spell_Shadow_Summonimp");
		end
	elseif event == "SPELL_AURA_APPLIED" then
		if arg1.spellId == 30115 then
			local target = arg1.destName
			if target then
				self:Announce(string.format(DBM_TI_SACRIFICE_WARN, target), 3);
				self:StartStatusBarTimer(41, "Sacrifice", "Interface\\Icons\\Spell_Shadow_AntiMagicShell");
			end
		end
	end
end
