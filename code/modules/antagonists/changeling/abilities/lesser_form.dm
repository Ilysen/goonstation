/// Turns the changeling into a monkey, or back into a human if they're already a monkey.
/datum/targetable/changeling/monkey
	name = "Lesser Form"
	desc = "Transform into a monkey, or back again. Many abilities are unusable while in this form."
	icon_state = "lesser"
	cooldown = 5 SECONDS
	targeted = FALSE
	target_anything = FALSE
	can_use_in_container = TRUE
	var/last_used_name = null

	onAttach(datum/abilityHolder/H)
		..()
		if (H?.owner) //Wire note: Fix for Cannot read null.real_name
			last_used_name = H.owner.real_name

	cast(atom/target)
		if (..())
			return TRUE

		var/mob/living/carbon/human/H = src.holder.owner
		if(!istype(H))
			return TRUE
		if (H.mutantrace)
			if (ismonkey(H))
				if (tgui_alert(H, "Are we sure?", "Exit this lesser form?", list("Yes","No")) != "Yes")
					return TRUE
				H.bioHolder.RemoveEffect("monkey")
				H.abilityHolder.updateButtons()
				logTheThing("combat", H, null, "leaves lesser form as a changeling, [log_loc(H)].")
				return FALSE
			else if (isabomination(H))
				boutput(H, "<span class='alert'>We cannot transform in this form.</span>")
				return TRUE
			else
				boutput(H, "<span class='alert'>We cannot transform in this form.</span>")
				return TRUE
		else
			if (tgui_alert(H,"Are we sure?", "Assume lesser form?", list("Yes","No")) != "Yes")
				return TRUE
			last_used_name = H.real_name
			if (H.hasStatus("handcuffed"))
				H.handcuffs.drop_handcuffs(H)
			H.monkeyize(TRUE)
			H.abilityHolder.updateButtons()
			logTheThing("combat", H, null, "enters lesser form as a changeling, [log_loc(H)].")
			return FALSE
