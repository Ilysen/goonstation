/// Mimic the appearance of a human that the changeling has sampled.
/datum/targetable/changeling/transform
	name = "Transform"
	desc = "Take on the appearance of a human we have absorbed or sampled.<br><br>\
	Transformation is instant, but obvious to everyone nearby. Our appearance will perfectly match the individual, including appearance, voice, \
	fingerprints, and DNA. Clothing and other equipment will not be replicated."
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
