/datum/antagonist/changeling
	id = ROLE_CHANGELING
	display_name = "changeling"

	/// A list of DNA that we have absorbed over our lifetime.
	var/list/absorbed_dna = list()
	/// The ability holder of this changeling, containing their respective abilities.
	var/datum/abilityHolder/changeling_new/ability_holder

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		var/mob/living/carbon/human/H = owner.current
		H.blood_id = "bloodc"
		var/datum/abilityHolder/changeling_new/C = src.owner.current.get_ability_holder(/datum/abilityHolder/changeling_new)
		if (!C)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/changeling_new)
		else
			src.ability_holder = C
		src.ability_holder.changeling_datum = src
		var/datum/bioHolder/original = new /datum/bioHolder(H)
		original.CopyOther(H.bioHolder)
		src.absorbed_dna = list("[H.name]" = original)
		src.ability_holder.addAbility(/datum/targetable/changeling/absorb)
		src.ability_holder.addAbility(/datum/targetable/changeling/transform)
		src.ability_holder.addAbility(/datum/targetable/changeling/monkey)
		src.ability_holder.addAbility(/datum/targetable/changeling/mimic_voice)

	remove_equipment()
		var/mob/living/carbon/human/H = owner.current
		H.blood_id = initial(H.blood_id)

	assign_objectives()
		new /datum/objective_set/changeling(src.owner)

	handle_round_end(log_data)
		var/list/dat = ..()
		if (length(dat))
			var/absorbed_total
			var/absorbed_identities
			if (!ishuman(owner.current))
				absorbed_total = "N/A (body destroyed)"
			else
				absorbed_total = max(0, length(absorbed_total))
				for (var/V in src.absorbed_dna)
					absorbed_identities += V
			if (absorbed_total)
				dat.Insert(2, "<b>Absorbed DNA:</b> [absorbed_total]")
			if (absorbed_identities)
				dat.Insert(3, "<b>Absorbed identities:</b> [english_list(absorbed_identities)]")
		return dat

	proc/get_dna(mob/living/carbon/human/victim)
		return src.absorbed_dna[victim.real_name]

	proc/add_dna(mob/living/carbon/human/victim, silent = FALSE)
		if (!src.get_dna(victim))
			var/datum/bioHolder/BH = new /datum/bioHolder(victim)
			BH.CopyOther(victim.bioHolder)
			src.absorbed_dna[victim.real_name] = BH
			if (!silent)
				boutput(src.owner.current, "<span class='notice'>We can now transform into [victim.real_name].</span>")
