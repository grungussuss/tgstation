#define ATTACKBY_BLOCKING TRUE
#define ATTACKBY_CONTINUE FALSE

#define HANDOVER_ANIMATION_INTERRUPT TRUE
#define HANDOVER_ANIMATION_PROCEED FALSE

/datum/offer_effects
	var/mob/living/offerer
	var/mob/living/offered_to
	var/obj/offered_item
	var/obj/offered_item_typepath
	var/obj/effect/temp_visual/offered_item_effect/parent

	var/override_drop = FALSE

/datum/offer_effects/proc/on_creation(parent, obj/item/offered_thing, mob/living/offerer, mob/living/offered_to)
	src.parent = parent
	RegisterSignal(offerer, COMSIG_QDELETING, PROC_REF(something_deleted))
	RegisterSignal(offered_to, COMSIG_QDELETING, PROC_REF(something_deleted))
	RegisterSignal(offered_item, COMSIG_QDELETING, PROC_REF(something_deleted))
	offered_item_typepath = offered_item.type
	if(isnull(parent) || isnull(offerer) || isnull(offered_to) || isnull(offered_item))
		stack_trace("offer effects not given full args")

	RegisterSignal(offerer, COMSIG_MOVABLE_MOVED, PROC_REF(someone_moved))
	RegisterSignal(offered_to, COMSIG_MOVABLE_MOVED, PROC_REF(someone_moved))
	RegisterSignal(offerer, COMSIG_LIVING_STOPPED_OFFERING_ITEM, PROC_REF(stopped_offering))
	RegisterSignal(offered_thing, COMSIG_OBJ_HANDED_OVER, PROC_REF(on_handover))
	RegisterSignal(offered_thing, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	addtimer(CALLBACK(src, PROC_REF(fade_out)), time_out_time)

	calculate_offset()

/datum/offer_effects/on_drop()
	qdel(parent)

/datum/offer_effects/proc/something_deleted(datum/source)
	qdel(parent)

/datum/offer_effects/Destroy(force)
	. = ..()
	stop_offering()
	unregister_offer_signals()
	UnregisterSignal(offerer, COMSIG_QDELETING)
	UnregisterSignal(offered_to, COMSIG_QDELETING)
	UnregisterSignal(offered_item, COMSIG_QDELETING)
	fade_out()

/datum/offer_effects/proc/fade_out()
	on_fade()
	parent.fade_out()

/datum/offer_effects/proc/unregister_offer_signals()
	UnregisterSignal(offerer, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_STOPPED_OFFERING_ITEM))
	UnregisterSignal(offered_to, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(offered_item, COMSIG_OBJ_HANDED_OVER)

/datum/offer_effects/proc/on_fade()
	unregister_offer_signals()

/datum/offer_effects/proc/moved_out_of_range()
	stop_offering()

/datum/offer_effects/proc/stop_offering()
	offerer?.cancel_offering_item()
	fade_out()

/datum/offer_effects/proc/someone_moved()
	if(!offerer.Adjacent(offered_to) && !(offerer.pulling == offered_to))
		moved_out_of_range()
		return

	calculate_offset()

/datum/offer_effects/proc/calculate_offset()
	var/w_displace = (offered_to.x - offerer.x) * 16
	var/z_displace = (offered_to.y - offerer.y) * 16 + 4

	animate(src, pixel_w = w_displace, pixel_z = z_displace, time = world.tick_lag * 2, transform = matrix() * 1)

/datum/offer_effects/proc/try_accept(mob/living/taker)
	if(istype(taker))
		return

	if(before_handover(taker))
		return FALSE

	taker.try_accept_offered_item(offerer, offered_item)

/datum/offer_effects/proc/before_handover(mob/taker)
	return

/datum/offer_effects/proc/on_handover(mob/taker)
	animate(parent, transform = matrix() * 0, alpha = 0, pixel_w = 0, pixel_z = 0, time = HANDOVER_TIME)
	QDEL_IN(parent, HANDOVER_TIME)

/datum/offer_effects/proc/attackby(obj/item/I, mob/living/user, params)
	offerer.attackby(arglist(args))

