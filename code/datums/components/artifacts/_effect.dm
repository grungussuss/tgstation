/datum/artifact_effect
	var/name = "parent type"
	var/volatility = 0
	var/datum/component/artifact/artifact

/datum/artifact_effect/New(datum/component/artifact/artifact)
	. = ..()
	src.artifact = artifact

/datum/artifact_effect/Destroy(force)
	. = ..()
	artifact = null

/datum/artifact_effect/proc/Activated()

/datum/artifact_effect/proc/Deactivated()
