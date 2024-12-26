/datum/artifact_effect/passive/emit_light
	name = "Emits Light"
	var/additional_range
	var/additional_power
	var/was_already_on = FALSE

/datum/artifact_effect/passive/emit_light/New(datum/component/artifact/artifact)
	. = ..()
	additional_range = pick(2, 6)
	additional_power = pick(0.6, 2)

/datum/artifact_effect/passive/emit_light/Activate()
	was_already_on = artifact.obj_owner.light_on
	if(was_already_on)
		return
	artifact.obj_owner.set_light(l_range = artifact.obj_owner.light_range + additional_range, l_power = artifact.obj_owner.light_power + additional_power, l_on = TRUE)

/datum/artifact_effect/passive/emit_light/Deactivate()
	if(was_already_on)
		return
	artifact.obj_owner.set_light(l_range = artifact.obj_owner.light_range - additional_range, l_power = artifact.obj_owner.light_power - additional_power, l_on = FALSE)
