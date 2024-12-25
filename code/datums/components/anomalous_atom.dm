/**
 * Component applied to artifacts for their effects
 * This can be applied to any other atom to give them anomalous effects too.
 */

/datum/component/anomalous_item

/datum/component/anomalous_item/Initialize(...)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	return ..()
