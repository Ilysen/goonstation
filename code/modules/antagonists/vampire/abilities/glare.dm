/datum/targetable/vampire/glare
	name = "Glare"
	desc = "Stuns one target for a short time. Can only be used in close range, and is blocked by eye protection."
	icon_state = "glare"
	targeted = TRUE
	target_nodamage_check = TRUE
	max_range = 2
	cooldown = 60 SECONDS
	pointCost = 0
	when_stunned = TRUE
	not_when_handcuffed = FALSE
	sticky = TRUE

	cast(mob/target)
		var/mob/living/M = holder.owner

		if (!target || !ismob(target))
			return TRUE

		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to stun yourself?</span>")
			return TRUE

		if (get_dist(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return TRUE

		if (isdead(target))
			boutput(M, "<span class='alert'>It would be a waste of time to stun the dead.</span>")
			return TRUE

		if (istype(M) && !M.sight_check(TRUE))
			boutput(M, "<span class='alert'>How do you expect this to work? You can't use your eyes right now.</span>")
			M.visible_message("<span class='alert'>What was that? There's something odd about [M]'s eyes.</span>")
			return FALSE // Cooldown because spam is bad.

		M.tri_message(target,
			"<span class='alert'><b>[M]'s eyes emit a blinding flash at [target]!</b></span>",
			"<span class='alert'><b>Your eyes emit a blinding flash at [target]!</b></span>",
			"<span class='alert'><b>[M]'s eyes emit a blinding flash!</b></span>"
		)

		var/obj/itemspecialeffect/glare/E = new /obj/itemspecialeffect/glare
		E.color = "#FFFFFF"
		E.setup(M.loc)
		playsound(M.loc, "sound/effects/glare.ogg", 50, 1, pitch = 1, extrarange = -4)

		SPAWN(1 DECI SECOND)
			var/obj/itemspecialeffect/glare/EE = new /obj/itemspecialeffect/glare
			EE.color = "#FFFFFF"
			EE.setup(target.loc)
			playsound(target.loc,"sound/effects/glare.ogg", 50, 1, pitch = 0.8, extrarange = -4)

		if (target.bioHolder && target.traitHolder.hasTrait("training_chaplain"))
			JOB_XP(target, "Chaplain", 2)
			M.tri_message(target,
				"<span class='alert'><b>[target] glares right back at [M]!</b></span>",
				"<span class='alert'><b>[target] glares right back at you. FUCK.</b></span>",
				"<span class='notice'>[M]'s foul gaze falters as it stares upon your righteousness!</span>"
			)
		else
			target.apply_flash(30, 15, stamina_damage = 350)

		if (isliving(target))
			var/mob/living/L = target
			L.was_harmed(M, special = "vamp")

		logTheThing("combat", M, target, "uses glare on [constructTarget(target,"combat")] at [log_loc(M)].")
		return FALSE
