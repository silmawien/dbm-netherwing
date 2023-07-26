local Council = DBM:NewBossMod("Council", DBM_COUNCIL_NAME, DBM_COUNCIL_DESCRIPTION, DBM_BLACK_TEMPLE, DBM_BT_TAB, 8)

Council.Version		= "1.0"
Council.Author		= "Tandanu"

Council:RegisterCombat("YELL", {DBM_COUNCIL_YELL_PULL1, DBM_COUNCIL_YELL_PULL2, DBM_COUNCIL_YELL_PULL3, DBM_COUNCIL_YELL_PULL4}, DBM_COUNCIL_MOB_GATHIOS, DBM_COUNCIL_NAME, DBM_COUNCIL_MOB_GATHIOS)

Council:AddOption("WarnCoH", true, DBM_COUNCIL_OPTION_COH)
Council:AddOption("WarnDP", true, DBM_COUNCIL_OPTION_DP)
Council:AddOption("WarnDW", false, DBM_COUNCIL_OPTION_DW)
Council:AddOption("WarnFS", false, "Flamestrike Incoming!")
Council:AddOption("WarnConc", false, "Consecration")
Council:AddOption("WarnVanish", true, DBM_COUNCIL_OPTION_VANISH)
Council:AddOption("WarnVanishFade", true, DBM_COUNCIL_OPTION_VANISHFADED)
Council:AddOption("WarnVanishFadeSoon", true, DBM_COUNCIL_OPTION_VANISHFADESOON)
Council:AddOption("WarnShieldNormal", true, DBM_COUNCIL_OPTION_SN)
Council:AddOption("WarnShieldSpell", true, DBM_COUNCIL_OPTION_SS)
Council:AddOption("WarnShieldMelee", true, DBM_COUNCIL_OPTION_SM)
Council:AddOption("WarnDevAura", true, DBM_COUNCIL_OPTION_DEVAURA)
Council:AddOption("WarnResAura", true, DBM_COUNCIL_OPTION_RESAURA)

Council:AddBarOption("Enrage")
Council:AddBarOption("Circle of Healing")
Council:AddBarOption("Next Circle of Healing")
Council:AddBarOption("Flamestrike Incoming")
Council:AddBarOption("Next Consecration")
Council:AddBarOption("Divine Wrath") 
Council:AddBarOption("Reflective Shield")
Council:AddBarOption("Vanish")
Council:AddBarOption("Devotion Aura")
Council:AddBarOption("Resistance Aura")
Council:AddBarOption("Spell Shield: (.*)")
Council:AddBarOption("Melee Shield: (.*)")

Council:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_HEAL",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED"
)

function Council:OnCombatStart(delay)
	self:StartStatusBarTimer(600 - delay, "Enrage", "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")	
end

function Council:OnEvent(event, args)
	if event == "SPELL_CAST_START" then
		if args.spellId == 41455 then
			self:SendSync("CoHCast")
		elseif args.spellId == 41472 then
			self:SendSync("DWCast")
		elseif args.spellId == 41481 then
			self:SendSync("FSCast")
		end
	elseif event == "SPELL_CAST_SUCCESS" then
		if args.spellId == 41541 then
			self:SendSync("ConcCast")
		end
	elseif event == "SPELL_HEAL" then
		if args.spellId == 41455 then
			self:SendSync("CoHHeal")
		end
	elseif event == "SPELL_INTERRUPT" then
		if args.extraSpellId == 41455 then
			self:SendSync("CoHInterrupt")
		end
	elseif event == "SPELL_AURA_APPLIED" then
		if args.spellId == 41485 then
			self:SendSync("DP"..tostring(args.destName))
		elseif args.spellId == 41472 then
			self:SendSync("DW"..tostring(args.destName))
		elseif args.spellId == 41476 then
			self:SendSync("Vanish")
		elseif args.spellId == 41475 then
			self:SendSync("ShieldNormal")
		elseif args.spellId == 41452 then
			self:SendSync("DevAura")
		elseif args.spellId == 41453 then
			self:SendSync("ResAura")
		elseif args.spellId == 41451 then
			local target = args.destName
			if target == DBM_COUNCIL_MOB_GATHIOS then
				target = DBM_COUNCIL_MOB_GATHIOS_EN
			elseif target == DBM_COUNCIL_MOB_MALANDE then
				target = DBM_COUNCIL_MOB_MALANDE_EN
			elseif target == DBM_COUNCIL_MOB_ZEREVOR then
				target = DBM_COUNCIL_MOB_ZEREVOR_EN
			elseif target == DBM_COUNCIL_MOB_VERAS then
				target = DBM_COUNCIL_MOB_VERAS_EN
			else
				return
			end
			self:SendSync("Spellward"..target)
		elseif args.spellId == 41450 then
			local target = args.destName
			if target == DBM_COUNCIL_MOB_GATHIOS then
				target = DBM_COUNCIL_MOB_GATHIOS_EN
			elseif target == DBM_COUNCIL_MOB_MALANDE then
				target = DBM_COUNCIL_MOB_MALANDE_EN
			elseif target == DBM_COUNCIL_MOB_ZEREVOR then
				target = DBM_COUNCIL_MOB_ZEREVOR_EN
			elseif target == DBM_COUNCIL_MOB_VERAS then
				target = DBM_COUNCIL_MOB_VERAS_EN
			else
				return
			end
			self:SendSync("Protection"..target)
		end
	elseif event == "SPELL_AURA_REMOVED" then
		if args.spellId == 41476 then
			self:SendSync("FadeVanish")
		end
	elseif event == "VanishFadeSoon" then
		if self.Options.WarnVanishFadeSoon then
			self:Announce(DBM_COUNCIL_WARN_VANISHFADE_SOON, 3)
		end
	end
end

function Council:OnSync(msg)
	if msg:sub(0, 9) == "Spellward" then
		msg = msg:sub(10)
		self:StartStatusBarTimer(15, "Spell Shield: "..msg, "Interface\\Icons\\Spell_Holy_SealOfRighteousness")
		
		if self.Options.WarnShieldSpell then
			if GetLocale():sub(0, 2) ~= "en" then
				if msg == DBM_COUNCIL_MOB_GATHIOS_EN then
					msg = DBM_COUNCIL_MOB_GATHIOS
				elseif msg == DBM_COUNCIL_MOB_MALANDE_EN then
					msg = DBM_COUNCIL_MOB_MALANDE
				elseif msg == DBM_COUNCIL_MOB_ZEREVOR_EN then
					msg = DBM_COUNCIL_MOB_ZEREVOR
				elseif msg == DBM_COUNCIL_MOB_VERAS_EN then
					msg = DBM_COUNCIL_MOB_VERAS
				end
			end
			self:Announce(DBM_COUNCIL_WARN_SHIELD_SPELL:format(msg), 2)
		end
		
	elseif msg == "DWCast" then
		self:StartStatusBarTimer(2, "Divine Wrath", "Interface\\Icons\\Spell_Holy_SearingLight")

	elseif msg:sub(0, 10) == "Protection" and self.InCombat then
		msg = msg:sub(11)
		self:StartStatusBarTimer(15, "Melee Shield: "..msg, "Interface\\Icons\\Spell_Holy_SealOfProtection")
		if self.Options.WarnShieldMelee then
			if GetLocale():sub(0, 2) ~= "en" then
				if msg == DBM_COUNCIL_MOB_GATHIOS_EN then
					msg = DBM_COUNCIL_MOB_GATHIOS
				elseif msg == DBM_COUNCIL_MOB_MALANDE_EN then
					msg = DBM_COUNCIL_MOB_MALANDE
				elseif msg == DBM_COUNCIL_MOB_ZEREVOR_EN then
					msg = DBM_COUNCIL_MOB_ZEREVOR
				elseif msg == DBM_COUNCIL_MOB_VERAS_EN then
					msg = DBM_COUNCIL_MOB_VERAS
				end
			end
			self:Announce(DBM_COUNCIL_WARN_SHIELD_MELEE:format(msg), 2)
		end
	elseif msg == "CoHCast" then
		if self.Options.WarnCoH then
			self:Announce(DBM_COUNCIL_WARN_CAST_COH, 4)
		end
		self:StartStatusBarTimer(2.5, "Circle of Healing", "Interface\\Icons\\Spell_Holy_CircleOfRenewal")
	elseif msg == "CoHHeal" then
		self:StartStatusBarTimer(19.5, "Next Circle of Healing", "Interface\\Icons\\Spell_Holy_CircleOfRenewal")
	elseif msg == "CoHInterrupt" then
		self:StartStatusBarTimer(14.5, "Next Circle of Healing", "Interface\\Icons\\Spell_Holy_CircleOfRenewal")
	elseif msg == "FSCast" then
		if self.Options.WarnFS then
			self:Announce("Flamestrike Incoming!", 1.5)
		end
		self:StartStatusBarTimer(1.4, "Flamestrike Incoming", "Interface\\Icons\\Spell_Fire_SelfDestruct")
	elseif msg == "ConcCast" then
		if self.Options.WarnConc then
			self:Announce("Consecration", 3)
		end
		self:StartStatusBarTimer(30, "Next Consecration", "Interface\\Icons\\Spell_Holy_InnerFire")
	elseif msg:sub(0, 2) == "DP" and self.InCombat then
		msg = msg:sub(3)
		if self.Options.WarnDP then
			self:Announce(DBM_COUNCIL_WARN_POISON:format(msg), 2)
		end
	elseif msg:sub(0, 2) == "DW" then
		msg = msg:sub(3)
		if self.Options.WarnDW then
			self:Announce(DBM_COUNCIL_WARN_WRATH:format(msg), 1)
		end
	elseif msg == "ShieldNormal" then
		if self.Options.WarnShieldNormal then
			self:Announce(DBM_COUNCIL_WARN_SHIELD_NORMAL, 3)
		end
		self:StartStatusBarTimer(20, "Reflective Shield", "Interface\\Icons\\Spell_Holy_PowerWordShield")

	elseif msg == "Vanish" then
		if self.Options.WarnVanish then
			self:Announce(DBM_COUNCIL_WARN_VANISH, 1)
		end
		self:StartStatusBarTimer(31, "Vanish", "Interface\\Icons\\Ability_Vanish")
		self:ScheduleEvent(26, "VanishFadeSoon")
	elseif msg == "FadeVanish" and self.Options.WarnVanishFade then
		self:Announce(DBM_COUNCIL_WARN_VANISH_FADED, 4)
	elseif msg == "DevAura" then
		if self.Options.WarnDevAura then
			self:Announce(DBM_COUNCIL_WARN_AURA_DEV, 1)
		end
		self:StartStatusBarTimer(30, "Devotion Aura", "Interface\\Icons\\Spell_Holy_SealOfProtection")
	elseif msg == "ResAura" then
		if self.Options.WarnResAura then
			self:Announce(DBM_COUNCIL_WARN_AURA_RES, 1)
		end
		self:StartStatusBarTimer(30, "Resistance Aura", "Interface\\Icons\\Spell_Frost_WizardMark")
	end
end
