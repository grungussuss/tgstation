#define ATTACKBY_BLOCKING TRUE
#define ATTACKBY_CONTINUE FALSE

#define HANDOVER_ANIMATION_INTERRUPT TRUE
#define HANDOVER_ANIMATION_PROCEED FALSE

/datum/offer_effects
	var/datum/weakref/giver_weakref
	var/datum/weakref/taker_weakref
	var/datum/weakref/offered_item_weakref
	var/obj/offered_item_typepath
	var/obj/effect/temp_visual/offered_item_effect/parent

/datum/offer_effects/proc/on_creation(parent, mob/giver, mob/taker, obj/offered_item)
	src.parent = parent
	giver_weakref = WEAKREF(giver)
	taker_weakref = WEAKREF(taker)
	offered_item_weakref = WEAKREF(offered_item)
	offered_item_typepath = offered_item.type

/datum/offer_effects/proc/on_fade()
	return

/datum/offer_effects/proc/moved_out_of_range()
	return

/datum/offer_effects/proc/on_handover(mob/taker)
	return

/datum/offer_effects/proc/attackby(mob/attacker, obj/attacking_thing)
	return

/datum/offer_effects/high_five/attackby(mob/attacker, obj/attacking_thing)
	if(!istype(attacking_thing, /obj/item/hand_item/hand))
		return FALSE
	to_chat(world, span_notice("attackby success"))
	return TRUE

/datum/offer_effects/high_five/on_handover(mob/taker)
	var/mob/living/giver = giver_weakref.resolve()
	if(giver)
		to_chat(world, span_notice("handover success"))
	return TRUE
