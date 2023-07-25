local Curator = DBM:NewBossMod("Curator", DBM_CURA_NAME, DBM_CURA_DESCRIPTION, DBM_KARAZHAN, DBM_KARAZHAN_TAB, 8);

Curator.Version			= "1.0";
Curator.Author			= "Tandanu";

Curator:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_SUCCESS",
	"SPELL_CAST_START"
);

Curator:RegisterCombat("YELL", DBM_CURA_YELL_PULL);

Curator:AddBarOption("Evocation")
Curator:AddBarOption("Next Evocation")
Curator:AddBarOption("Next Astral Flare")

Curator:AddOption("RangeCheck", true, DBM_MOV_OPTION_1, function()
	DBM:GetMod("Curator").Options.RangeCheck = not DBM:GetMod("Curator").Options.RangeCheck;

	if DBM:GetMod("Curator").Options.RangeCheck and DBM:GetMod("Curator").InCombat then
		DBM_Gui_DistanceFrame_Show();
	elseif not DBM:GetMod("Curator").Options.RangeCheck and DBM:GetMod("Curator").InCombat then
		DBM_Gui_DistanceFrame_Hide();
	end
end);

function Curator:OnCombatStart()
	self:StartStatusBarTimer(102, "Next Evocation", "Interface\\Icons\\Spell_Nature_Purge");
	self:ScheduleSelf(97, "EvoWarn", "soon");
	self:ScheduleSelf(0, "BeginAstralFlares");

	if self.Options.RangeCheck then
		DBM_Gui_DistanceFrame_Show();
	end
end

function Curator:OnCombatEnd()
	if self.Options.RangeCheck then
		DBM_Gui_DistanceFrame_Hide();
	end
end

function Curator:OnEvent(event, arg1)
	if event == "CHAT_MSG_MONSTER_YELL" then
		if arg1 == DBM_CURA_YELL_OOM then
			self:StartStatusBarTimer(122, "Next Evocation", "Interface\\Icons\\Spell_Nature_Purge");
			self:StartStatusBarTimer(20, "Evocation", "Interface\\Icons\\Spell_Nature_Purge");
			self:Announce(DBM_CURA_EVO_NOW, 3);
			self:UnScheduleSelf("EvoWarn", "soon");
			self:ScheduleSelf(112, "EvoWarn", "soon");
			self:ScheduleSelf(20, "BeginAstralFlares");
		end
	elseif event == "EvoWarn" then
		self:Announce(DBM_CURA_EVO_SOON, 2);
	elseif event == "BeginAstralFlares" then
		self.astralFlareCount = 0
		self:StartStatusBarTimer(10, "Next Astral Flare", "Interface\\Icons\\Spell_Arcane_Arcane04");
		self:ScheduleSelf(10, "AstralFlare");
	elseif event == "AstralFlare" then
		self.astralFlareCount = self.astralFlareCount + 1
		self:Announce("Astral Flare "..self.astralFlareCount.." of 10", 3);
		if self.astralFlareCount <= 9 then
			self:StartStatusBarTimer(10, "Next Astral Flare", "Interface\\Icons\\Spell_Arcane_Arcane04");
			self:ScheduleSelf(10, "AstralFlare");
		end
	end
end
