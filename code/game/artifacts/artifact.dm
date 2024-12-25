/obj/artifact
	name = "artifact"
	icon = 'icons/obj/artifacts/artifact.dmi'
	icon_state = "default"
	desc = "what the fuck?"
	verb_say = "vibrates"
	verb_yell = "emanates"
	max_integrity = 200
	pressure_resistance = 35
	layer = BELOW_OBJ_LAYER
	flags_ricochet = RICOCHET_HARD
	receive_ricochet_chance_mod = 0.6
	density = TRUE

/obj/artifact/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anomalous_item)

/datum/armor/artifact
	melee = 95
	bullet = 95
	laser = 95
	fire = 100
	acid = 80

