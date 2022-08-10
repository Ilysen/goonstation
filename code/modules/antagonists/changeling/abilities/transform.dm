/datum/targetable/changeling/monkey
	name = "Lesser Form"
	desc = "Become something much less powerful."
	icon_state = "lesser"
	cooldown = 50
	targeted = 0
	target_anything = 0
	can_use_in_container = 1
	var/last_used_name = null

	onAttach(var/datum/abilityHolder/H)
		..()
		if (H?.owner) //Wire note: Fix for Cannot read null.real_name
			last_used_name = H.owner.real_name

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/human/H = holder.owner
		if(!istype(H))
			return 1
		if (H.mutantrace)
			if (ismonkey(H))
				if (tgui_alert(H,"Are we sure?","Exit this lesser form?",list("Yes","No")) != "Yes")
					return 1
				doCooldown()

				H.transforming = 1
				H.canmove = 0
				H.icon = null
				APPLY_ATOM_PROPERTY(H, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)
				var/atom/movable/overlay/animation = new /atom/movable/overlay( usr.loc )
				animation.icon_state = "blank"
				animation.icon = 'icons/mob/mob.dmi'
				animation.master = src
				flick("monkey2h", animation)
				sleep(4.8 SECONDS)
				qdel(animation)
				qdel(H.mutantrace)
				H.set_mutantrace(null)
				H.transforming = 0
				H.canmove = 1
				H.icon = initial(H.icon)
				REMOVE_ATOM_PROPERTY(H, PROP_MOB_INVISIBILITY, "transform")
				H.update_face()
				H.update_body()
				H.update_clothing()
				H.real_name = last_used_name
				H.abilityHolder.updateButtons()
				logTheThing("combat", H, null, "leaves lesser form as a changeling, [log_loc(H)].")
				return 0
			else if (isabomination(H))
				boutput(H, "We cannot transform in this form.")
				return 1
			else
				boutput(H, "We cannot transform in this form.")
				return 1
		else
			if (tgui_alert(H,"Are we sure?","Assume lesser form?",list("Yes","No")) != "Yes")
				return 1
			last_used_name = H.real_name
			if (H.hasStatus("handcuffed"))
				H.handcuffs.drop_handcuffs(H)
			H.monkeyize()
			H.abilityHolder.updateButtons()
			logTheThing("combat", H, null, "enters lesser form as a changeling, [log_loc(H)].")
			return 0

/datum/targetable/changeling/transform
	name = "Transform"
	desc = "Become someone else!"
	icon_state = "transform"
	cooldown = 0
	targeted = FALSE
	target_anything = FALSE
	human_only = TRUE
	can_use_in_container = TRUE
	dont_lock_holder = TRUE
	preferred_holder_type = /datum/abilityHolder/changeling_new 

	cast(atom/target)
		if (..())
			return TRUE

		var/datum/abilityHolder/changeling_new/CN = src.holder
		if (!istype(CN))
			boutput(src.holder.owner, "<span class='alert'>That ability is incompatible with our abilities. We should report this to a coder.</span>")
			return TRUE

		var/datum/antagonist/changeling/C = CN.changeling_datum
		if (length(C.absorbed_dna) < 2)
			boutput(src.holder.owner, "<span class='alert'>We need to absorb more DNA to use this ability.</span>")
			return TRUE

		var/target_name = tgui_input_list(src.holder.owner, "Select the target DNA:", "Target DNA", sortList(C.absorbed_dna))
		if (!target_name)
			boutput(src.holder.owner, "<span class='notice'>We change our mind.</span>")
			return TRUE

		var/mob/living/carbon/human/H = src.holder.owner
		H.visible_message("<span class='alert'><b>[H] transforms!</b></span>",
			"<span class=alert'>We transform into [target_name].</span>")
		src.holder.owner.visible_message(text("<span class='alert'><B>[src.holder.owner] transforms!</B></span>"))
		logTheThing("combat", src.holder.owner, target_name, "transforms into [target_name] as a changeling [log_loc(src.holder.owner)].")
		var/datum/bioHolder/D = C.absorbed_dna[target_name]
		H.bioHolder.CopyOther(D)
		H.real_name = target_name
		H.bioHolder.RemoveEffect("husk")
		H.organHolder.head.UpdateIcon()
		if (H.bioHolder?.mobAppearance?.mutant_race)
			H.set_mutantrace(H.bioHolder.mobAppearance.mutant_race.type)
		else
			H.set_mutantrace(null)

		H.update_face()
		H.update_body()
		H.update_clothing()
		return
