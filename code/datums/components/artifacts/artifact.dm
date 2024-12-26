/**
 * Component applied to artifacts for their effects
 * This can be applied to any other atom to give them anomalous effects too.
 */

/datum/component/artifact
	var/datum/artifact_effect/active/active_effect
	var/datum/artifact_effect/passive/passive_effect
	var/active = FALSE
	var/obj/obj_owner

/datum/component/artifact/Initialize(...)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	obj_owner = parent
	START_PROCESSING(SSobj, src)
	if(prob(70))
		active_effect = new pick(subtypesof(/datum/artifact_effect/active))(src)
	passive_effect = new pick(subtypesof(/datum/artifact_effect/passive))(src)
	return ..()

/datum/component/artifact/Destroy(force)
	. = ..()
	obj_owner = null
	QDEL_NULL(active_effect)
	QDEL_NULL(passive_effect)

/datum/component/artifact/proc/Activate()
	if(active)
		return
	active_effect?.Activated()
	passive_effect?.Activated()

/datum/component/artifact/proc/Deactivate()
	if(!active)
		return
	active_effect?.Deactivated()
	passive_effect?.Deactivated()

/datum/component/artifact/process(seconds_per_tick)
	if(!active)
		return
	active_effect?.process(seconds_per_tick)
	passive_effect?.process(seconds_per_tick)
