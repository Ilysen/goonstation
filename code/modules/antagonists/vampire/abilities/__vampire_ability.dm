// Notes:
// - If an ability isn't available from the beginning, add an unlock_message to notify the player of unlocks.
// - Vampire abilities are logged. Please keep it that way when you make additions.
// - Add this snippet at the bottom of cast() if the ability isn't free. Optional but basic feedback for the player.
//		var/datum/abilityHolder/vampire/H = holder
//		if (istype(H)) H.blood_tracking_output(src.pointCost)
//		- You should also call the proc if you make the player pay for an interrupted attempt to use the ability, for
//		  instance when employing do_mob() checks.

/datum/targetable/vampire
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "vampire-template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/vampire
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = FALSE
	var/unlock_message = null

	New()
		var/atom/movable/screen/ability/topBar/vampire/B = new /atom/movable/screen/ability/topBar/vampire(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	onAttach(datum/abilityHolder/H)
		..() // Start_on_cooldown check.
		if (src.unlock_message && src.holder && src.holder.owner)
			boutput(src.holder.owner, "<span class='notice'><h3>[src.unlock_message]</h3></span>")
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/vampire()
			object.icon = src.icon
			object.owner = src
		if (src.last_cast > world.time)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state
		return

	proc/incapacitation_check(stunned_only_is_okay = 0)
		if (!holder)
			return FALSE

		var/mob/living/M = holder.owner
		if (!M || !ismob(M))
			return FALSE

		switch (stunned_only_is_okay)
			if (0)
				if (!isalive(M) || M.getStatusDuration("stunned") > 0 || M.getStatusDuration("paralysis") > 0 || M.getStatusDuration("weakened"))
					return FALSE
				else
					return TRUE
			if (1)
				if (!isalive(M) || M.getStatusDuration("paralysis") > 0)
					return FALSE
				else
					return TRUE
			else
				return TRUE

	castcheck()
		if (!holder)
			return FALSE

		var/mob/living/M = holder.owner

		if(isobj(M)) //Exception for VampTEG and Sentient Objects...
			return TRUE

		if (!(ishuman(M) || ismobcritter(M)))
			boutput(M, "<span class='alert'>You cannot use any powers in your current form.</span>")
			return FALSE

		if (M.transforming)
			boutput(M, "<span class='alert'>You can't use any powers right now.</span>")
			return FALSE

		if (incapacitation_check(src.when_stunned) != TRUE)
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return FALSE

		if (src.not_when_handcuffed == TRUE && M.restrained())
			boutput(M, "<span class='alert'>You can't use this ability when restrained!</span>")
			return FALSE

		if (istype(get_area(M), /area/station/chapel) && M.check_vampire_power(3) != TRUE)
			boutput(M, "<span class='alert'>Your powers do not work in this holy place!</span>")
			return FALSE

		return TRUE

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return
