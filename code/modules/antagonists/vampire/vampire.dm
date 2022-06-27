#define VAMPIRE_LEVEL_1 5
#define VAMPIRE_LEVEL_2 300
#define VAMPIRE_LEVEL_3 600
#define VAMPIRE_LEVEL_4 900
#define VAMPIRE_LEVEL_5 1400
#define VAMPIRE_LEVEL_6 1800
#define MAX_BLOOD_PER_MOB 250

/datum/antagonist/traitor
	id = ROLE_VAMPIRE
	display_name = "vampire"
	
	/// The amount of blood that this vampire currently has.
	var/current_blood = 0
	/// The total amount of blood that this vampire has consumed over time.
	var/total_blood = 0
	/// If TRUE, messages will be shown when the vampire gains or loses blood
	var/blood_tracking = TRUE
	/// The power level of this vampire. Increases with blood gained.
	var/power_level = 0
	/// Vampires can only take a certain amount of blood from a single mob; this list tracks that.
	var/list/blood_tally

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE
		var/mob/living/carbon/human/H = src.owner.current
		var/datum/abilityHolder/vampire/V = H.get_ability_holder(/datum/abilityHolder/vampire)
		if (V && istype(V))
			return FALSE
		V = H.add_ability_holder(/datum/abilityHolder/vampire)
		V.addAbility(/datum/targetable/vampire/vampire_bite)
		V.addAbility(/datum/targetable/vampire/blood_steal)
		V.addAbility(/datum/targetable/vampire/blood_tracking)
		V.addAbility(/datum/targetable/vampire/cancel_stuns)
		V.addAbility(/datum/targetable/vampire/glare)
		V.addAbility(/datum/targetable/vampire/hypnotize)
		return TRUE

	remove_equipment()
		src.owner.current.remove_ability_holder(/datum/abilityHolder/vampire)
		REMOVE_ATOM_PROPERTY(src.owner.current, PROP_MOB_THERMALVISION_MK2, src)
		return TRUE

	proc/can_bite(mob/living/carbon/human/victim)
		var/mob/living/user = owner.current
		if (victim == user)
			boutput(user, "<span class='alert'>Why would you want to bite yourself?</span>")
			return FALSE
		if (!ishuman(victim))
			boutput(user, "<span class='alert'>You can't seem to find any blood vessels.</span>")
			return FALSE
		else
			if (istype(victim.mutantrace, /datum/mutantrace/vampiric_thrall))
				boutput(user, "<span class='alert'>You cannot drain the blood of a thrall.</span>")
				return FALSE
			else if (!victim.blood_volume)
				boutput(user, "<span class='alert'>[victim]'s body is completely void of blood. Wow!</span>")
				return FALSE
		if (ismobcritter(user))
			boutput(M, "<span class='alert'>Critter mobs currently don't have to worry about blood. Lucky you.</span>")
			return FALSE
		if (is_pointblank && victim.head && victim.head.c_flags & (BLOCKCHOKE))
			boutput(user, "<span class='alert'>You need to remove their headgear first.</span>")
			return FALSE
		if (check_victim_immunity(victim))
			user.tri_message(M,
				"<span class='alert'><b>[user] bites [victim], but fails to even pierce [his_or_her(victim)] skin!</b></span>",
				"<span class='alert'><b>You bite [victim], but fail to even pierce [his_or_her(victim)] skin!</b></span>",
				"<span class='alert'><b>[owner] bites you, but fails to even pierce your skin!</b></span>"
			)
			return FALSE
		if (isnpcmonkey(victim))
			boutput(user, "<span class='alert'>Drink monkey blood?! That's disgusting!</span>")
			return FALSE
		if (!can_take_blood_from(victim))
			return FALSE
		return TRUE

	proc/can_take_blood_from(mob/living/carbon/human/victim)
		if (blood_tally[victim] <= MAX_BLOOD_PER_MOB)
			boutput(owner.current, "<span class='alert'>[victim]'s blood is dry and thin from repeated draining. You can't extract any more usable blood from [him_or_her(victim)].")
			return FALSE
		return TRUE
	
	proc/tally_blood_for(mob/living/carbon/human/victim, amt)
		blood_tally[victim] = Clamp(blood_tally[victim] + amt, 0, MAX_BLOOD_PER_MOB)

	proc/adjust_blood(amt)
		if (amt == 0)
			return
		current_blood = max(0, current_blood + amt)
		total_blood = max(0, total_blood + max(0, amt)) // Only adjust total if we're gaining blood
		if (blood_tracking)
			boutput(src.owner, "<span class='notice'>You [amt > 0 ? "have accumulated" : "used"] [amt] units of blood, and have [src.current_blood] remaining.</span>")
		adjust_tier()
		return TRUE

	proc/adjust_tier()
		if (power_level <= 0 && total_blood >= VAMPIRE_LEVEL_1)
			power_level++
			V.addAbility(/datum/targetable/vampire/phaseshift_vampire)
			V.addAbility(/datum/targetable/vampire/enthrall)
			V.addAbility(/datum/targetable/vampire/speak_thrall)
		else if (power_level <= 1 && total_blood >= VAMPIRE_LEVEL_2)	
			power_level++
			APPLY_ATOM_PROPERTY(src.owner.current, PROP_MOB_THERMALVISION_MK2, src)
			boutput(src.owner.current, "<span class='notice'><h3>Your vampiric vision has improved (thermal)!</h3></span>")
			V.addAbility(/datum/targetable/vampire/mark_coffin)
			VALID_MOB.addAbility(/datum/targetable/vampire/coffin_escape)
		else if (power_level <= 2 && total_blood >= VAMPIRE_LEVEL_3)
			power_level++
			V.addAbility(/datum/targetable/vampire/call_bats)
			V.addAbility(/datum/targetable/vampire/vampire_scream)
		else if (power_level <= 3 && total_blood >= VAMPIRE_LEVEL_4)
			power_level++
			V.removeAbility(/datum/targetable/vampire/phaseshift_vampire)
			V.addAbility(/datum/targetable/vampire/phaseshift_vampire/mk2)
			V.addAbility(/datum/targetable/vampire/plague_touch)
		else if (power_level <= 4 && total_blood >= VAMPIRE_LEVEL_5)
			power_level++
			V.removeAbility(/datum/targetable/vampire/vampire_scream)
			V.addAbility(/datum/targetable/vampire/vampire_scream/mk2)
		else if (power_level <= 5 && total_blood <= VAMPIRE_LEVEL_6)
			power_level++
			boutput(src.owner, "<span class='notice'><h3>You have attained full power and are now too powerful to be harmed or stopped by the chapel's aura.</h3></span>")

#undef VAMPIRE_LEVEL_1
#undef VAMPIRE_LEVEL_2 
#undef VAMPIRE_LEVEL_3
#undef VAMPIRE_LEVEL_4
#undef VAMPIRE_LEVEL_5
#undef VAMPIRE_LEVEL_6
#undef MAX_BLOOD_PER_MOB
