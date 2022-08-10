/// Speak a message using an entered voice. Can also mimic a worn headset.
/datum/targetable/changeling/mimic_voice
	name = "Mimic Voice"
	desc = "Speak an entered sentence using another voice. This ability can mimic a worn headset, as well."
	icon_state = "mimicvoice"
	cooldown = 0
	targeted = FALSE
	target_anything = FALSE
	human_only = TRUE
	can_use_in_container = TRUE
	interrupt_action_bars = FALSE
	var/last_mimiced_name = ""
	var/list/frequency_mimics = list(
		"Command" = "head",
		"Security Officer" = "sec",
		"Engineer" = "eng",
		"Scientist" = "sci",
		"Medical Doctor" = "med", 
		"Quartermaster" = "qm",
		"Civilian" = "civ",
		"Captain" = "cap",
		"Research Director" = "rd",
		"Medical Director" = "md",
		"Chief Engineer" = "ce",
		"Head of Personnel" = "hop",
		"Head of Security" = "hos",
		"Clown" = "clown"
	)

	cast(atom/target)
		if (..())
			return TRUE
		var/mimic_name = html_encode(input("Enter a name to mimic.", src.name, last_mimiced_name) as null|text)
		if (!mimic_name)
			return TRUE
		if(mimic_name != last_mimiced_name)
			phrase_log.log_phrase("voice-mimic", mimic_name, no_duplicates = TRUE)
		last_mimiced_name = mimic_name //A little qol, probably.

		var/mimic_message = html_encode(input("Choose something to say.", src.name, "") as null|text)

		if (!mimic_message)
			return TRUE

		var/mob/living/carbon/human/H
		if (ishuman(holder.owner))
			H = holder.owner

		if (H?.ears && istype(H.ears, /obj/item/device/radio/headset))
			var/obj/item/device/radio/headset/headset = H.ears
			if (headset.icon_override && findtext(mimic_message,";") || findtext(mimic_message,":"))
				var/radio_override = input("Optionally, select a headset. Our message will appear as if we are wearing that headset.", 
					src.name, null, null) as null|anything in frequency_mimics
				if (frequency_mimics[radio_override])
					headset.icon_override = frequency_mimics[radio_override]

		logTheThing("say", holder.owner, mimic_name, "[mimic_message] (<b>Mimicing ([constructTarget(mimic_name,"say")])</b>)")
		var/original_name = holder.owner.real_name
		holder.owner.real_name = copytext(mimic_name, 1, MOB_NAME_MAX_LENGTH)
		holder.owner.say(mimic_message)
		holder.owner.real_name = original_name

		if (H?.ears && istype(H.ears, /obj/item/device/radio/headset))
			var/obj/item/device/radio/headset/headset = H.ears
			if (headset.icon_override)
				headset.icon_override = initial(headset.icon_override)

		return FALSE
