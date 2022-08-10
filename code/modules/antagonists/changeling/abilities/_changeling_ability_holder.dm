/// The ability holder used for changelings. Comes with no abilities on its own.
/datum/abilityHolder/changeling_new
	usesPoints = TRUE
	regenRate = 0
	tabName = "Changeling"
	notEnoughPointsMessage = "<span class='alert'>We are not strong enough to do this.</span>"

	/// The changeling datum used by this ability holder. We pull most of our data from here.
	var/datum/antagonist/changeling/changeling_datum

	onAbilityStat()
		..()
		. = list()
		if (src.changeling_datum)
			var/dna_len = length(changeling_datum.absorbed_dna)
			.["DNA:"] = round(src.points)
			.["Total:"] = !isnull(dna_len) ? dna_len : 0
