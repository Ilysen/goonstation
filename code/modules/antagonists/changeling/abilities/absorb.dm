/datum/action/bar/icon/abominationDevour
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "abom_devour"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	bar_icon_state = "bar-changeling"
	border_icon_state = "border-changeling"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/datum/targetable/changeling/devour/devour

	New(Target, Devour)
		target = Target
		devour = Devour
		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		var/obj/item/grab/G = ownerMob.equipped()

		if (!istype(G) || G.affecting != target || G.state == GRAB_PASSIVE)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		ownerMob.show_message("<span class='notice'>We must hold still for a moment...</span>", 1)

	onEnd()
		..()

		var/mob/ownerMob = owner
		if(owner && ownerMob && target && BOUNDS_DIST(owner, target) == 0 && devour)
			var/datum/abilityHolder/changeling/C = devour.holder
			if (istype(C))
				C.addDna(target)
			boutput(ownerMob, "<span class='notice'>We devour [target]!</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] hungrily devours [target]!</B></span>"))
			playsound(ownerMob.loc, 'sound/voice/burp_alien.ogg', 50, 1)
			logTheThing("combat", ownerMob, target, "devours [constructTarget(target,"combat")] as a changeling in horror form [log_loc(owner)].")

			target.ghostize()
			qdel(target)

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Our feasting on [target] has been interrupted!</span>")

/datum/targetable/changeling/devour
	name = "Devour"
	desc = "Almost instantly devour a human for DNA."
	icon_state = "devour"
	abomination_only = 1
	cooldown = 0
	targeted = 0
	target_anything = 0
	restricted_area_check = 2

	cast(atom/target)
		if (..())
			return 1
		var/mob/living/C = holder.owner

		var/obj/item/grab/G = src.grab_check(null, 1, 1)
		if (!G || !istype(G))
			return 1
		var/mob/living/carbon/human/T = G.affecting

		if (!istype(T))
			boutput(C, "<span class='alert'>This creature is not compatible with our biology.</span>")
			return 1
		if (isnpcmonkey(T))
			boutput(C, "<span class='alert'>Our hunger will not be satisfied by this lesser being.</span>")
			return 1
		if (T.bioHolder.HasEffect("husk"))
			boutput(usr, "<span class='alert'>This creature has already been drained...</span>")
			return 1

		actions.start(new/datum/action/bar/icon/abominationDevour(T, src), C)
		return 0

/datum/action/bar/private/icon/changelingAbsorb
	duration = 25 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "change_absorb"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	bar_icon_state = "bar-changeling"
	border_icon_state = "border-changeling"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/datum/targetable/changeling/absorb/devour
	var/last_complete = 0

	New(new_target, new_ability)
		src.target = new_target
		src.devour = new_ability
		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour?.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/living/ownerMob = owner
		var/obj/item/grab/G = ownerMob.equipped()

		if (!istype(G) || G.affecting != target || G.state < GRAB_CHOKE)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/done = TIME - started
		var/complete = clamp((done / duration), 0, 1)
		if (complete >= 0.2 && last_complete < 0.2)
			ownerMob.visible_message("<span class='alert'><b>[ownerMob] extends a proboscis!</b></span>",
				"<span class='notice'>We extend a proboscis.</span>")

		if (complete > 0.6 && last_complete <= 0.6)
			ownerMob.tri_message(target,
				"<span class='alert'><b>[ownerMob] stabs [target] with the proboscis!</b></span>",
				"<span class='notice'>We stab [target] with the proboscis and begin draining their fluids.</span>",
				"<span class='alert'><b>[ownerMob] stabs you with the proboscis and begins draining your fluids! [pick("FUCK", "OH JESUS", "AAAH", "HOLY FUCK", "OW OW OW")]!!")
			random_brute_damage(target, 40)

		if (complete > 0.6)
			target.blood_volume = max(0, target.blood_volume - 20)
			target.make_jittery(100)
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				if (H.sims) // we're having our fluids drained!
					H.sims.affectMotive("Thirst", -10)
			if (ishuman(ownerMob))
				var/mob/living/carbon/human/H = ownerMob
				if (H.sims) // we're draining their fluids!
					H.sims.affectMotive("Hunger", 5)
					H.sims.affectMotive("Thirst", 5)

		last_complete = complete

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour?.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		if (isliving(target))
			var/mob/living/L
			L.was_harmed(owner, special = "ling")

		devour.add_dna_data(target)

	onEnd()
		..()

		var/mob/ownerMob = owner
		if(owner && ownerMob && target && BOUNDS_DIST(owner, target) == 0 && devour)
			/*var/datum/abilityHolder/changeling/C = devour.holder
			if (istype(C))
				C.addDna(target)*/
			ownerMob.visible_message("<span class='alert'><b>[ownerMob] sucks the fluids out of [target]!</b></span>",
				"<span class='notice'>We have absorbed [target]!</span>")
			logTheThing("combat", ownerMob, target, "absorbs [constructTarget(target,"combat")] as a changeling [log_loc(owner)].")

			target.dna_to_absorb = FALSE
			target.death(FALSE)
			target.disfigured = TRUE
			target.UpdateName()
			target.bioHolder.AddEffect("husk")
			target.bioHolder.mobAppearance.flavor_text = "A desiccated husk."
			target.blood_volume = 0

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Our absorption of [target] has been interrupted!</span>")

/datum/targetable/changeling/absorb
	name = "Absorb DNA"
	desc = "Suck the DNA out of a human or changeling and incorporate it into our genetic structure. We need to be grabbing a target by the neck for this to work; the process is extremely obvious will take some time."
	icon_state = "absorb"
	human_only = TRUE
	cooldown = 0
	targeted = FALSE
	target_anything = FALSE
	restricted_area_check = 2

	cast(atom/target)
		if (..())
			return TRUE
		var/mob/living/C = holder.owner

		var/obj/item/grab/G = src.grab_check(null, 3, 1)
		if (!G || !istype(G))
			return TRUE
		var/mob/living/carbon/human/T = G.affecting

		if (!istype(T))
			boutput(C, "<span class='alert'>This creature is not compatible with our biology.</span>")
			return TRUE
		if (isnpcmonkey(T))
			boutput(C, "<span class='alert'>Our hunger will not be satisfied by this lesser being.</span>")
			return TRUE
		if (isnpc(T))
			var/datum/antagonist/changeling/C = src.get_changeling()
			boutput(C, "<span class='alert'>Our hunger will not be satisfied by this lesser being[!C?.absorbed_dna[T.real_name] ? ", but we sample its genome for later use" : ""].</span>")
			add_dna_data(T)
			return TRUE
		if (T.bioHolder.HasEffect("husk"))
			boutput(usr, "<span class='alert'>This creature has already been drained.</span>")
			return TRUE

		actions.start(new/datum/action/bar/private/icon/changelingAbsorb(T, src), C)
		return FALSE

	proc/add_dna_data(var/mob/living/T)
		var/datum/antagonist/changeling/C = src.get_changeling()
		var/mob/living/owner_mob = src.holder.owner
		if (!C?.absorbed_dna[T.real_name])
			var/datum/bioHolder/BH = new /datum/bioHolder(T)
			BH.CopyOther(T.bioHolder)
			C.absorbed_dna[T.real_name] = BH
			boutput(owner_mob, "<span class='notice'>We can now transform into [T.real_name].</span>")
