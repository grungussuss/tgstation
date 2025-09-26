#define HANDOVER_TIME 0.5 SECONDS
#define STOP_OFFER_TIME 0.7 SECONDS

/obj/effect/temp_visual/offered_item_effect
	duration = 11 SECONDS
	var/time_out_time = 10 SECONDS
	var/fade_time = 0.5 SECONDS
	var/datum/weakref/offerer_weak_ref
	var/datum/weakref/offered_to_weak_ref
	var/datum/weakref/offered_thing_weak_ref
	var/datum/offer_effects/offer_effects
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON
	var/fading_out = FALSE

/obj/effect/temp_visual/offered_item_effect/proc/fade_out()
	unregister_signals()
	var/mob/living/offerer = offerer_weak_ref.resolve()
	offerer?.stop_offering_item()

	fading_out = TRUE

	animate(src, time = fade_time, alpha = 0)
	QDEL_IN(src, fade_time)

/obj/effect/temp_visual/offered_item_effect/Initialize(mapload, obj/item/offered_thing, mob/living/offerer, mob/living/offered_to)
	. = ..()
	icon = offered_thing.icon
	icon_state = offered_thing.icon_state
	appearance = offered_thing.appearance
	transform = matrix() * 0
	alpha = 200
	offered_thing_weak_ref = WEAKREF(offered_thing)
	offerer_weak_ref = WEAKREF(offerer)
	offered_to_weak_ref = WEAKREF(offered_to)

	offer_effects = offered_thing.offer_effects

	if(offer_effects)
		offer_effects = new offer_effects()

	offer_effects?.on_creation(src, offerer, offered_to, offered_thing)

	RegisterSignal(offerer, COMSIG_MOVABLE_MOVED, PROC_REF(someone_moved))
	RegisterSignal(offered_to, COMSIG_MOVABLE_MOVED, PROC_REF(someone_moved))
	RegisterSignal(offerer, COMSIG_LIVING_STOPPED_OFFERING_ITEM, PROC_REF(stopped_offering))
	RegisterSignal(offered_thing, COMSIG_LIVING_ACCEPTED_ITEM, PROC_REF(handover))
	RegisterSignal(offerer, COMSIG_QDELETING, PROC_REF(fade_out))
	addtimer(CALLBACK(src, PROC_REF(fade_out)), time_out_time)
	calculate_offset()

/obj/effect/temp_visual/offered_item_effect/Destroy()
	. = ..()
	var/mob/living/offerer = offerer_weak_ref.resolve()

	offerer?.stop_offering_item()

	QDEL_NULL(offer_effects)

/obj/effect/temp_visual/offered_item_effect/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(I == offered_thing_weak_ref.resolve())
		user.cancel_offering_item()
		return

	if(offer_effects?.attackby(user, I))
		return

	var/mob/living/offerer = offerer_weak_ref.resolve()
	offerer?.attackby(arglist(args))

// not including qdel because we still want that
/obj/effect/temp_visual/offered_item_effect/proc/unregister_signals()
	var/mob/living/offered_to = offered_to_weak_ref.resolve()
	var/mob/living/offerer = offerer_weak_ref.resolve()
	var/obj/offered_thing = offered_thing_weak_ref.resolve()
	if(offerer)
		UnregisterSignal(offerer, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_STOPPED_OFFERING_ITEM))
	if(offered_to)
		UnregisterSignal(offered_to, COMSIG_MOVABLE_MOVED)
	if(offered_thing)
		UnregisterSignal(offered_thing, COMSIG_LIVING_ACCEPTED_ITEM)

/obj/effect/temp_visual/offered_item_effect/proc/stopped_offering(mob/living/offerer)
	SIGNAL_HANDLER

	unregister_signals()

	if((x != offerer.x) || (y != offerer.y))
		Move(get_turf(offerer))

	animate(src, transform = matrix() * 0, alpha = 0, pixel_w = 0, pixel_z = 0, time = STOP_OFFER_TIME)
	QDEL_IN(src, STOP_OFFER_TIME)


/obj/effect/temp_visual/offered_item_effect/proc/handover(obj/handed_thing, mob/living/taker, mob/living/offerer)
	SIGNAL_HANDLER

	unregister_signals()

	if(offer_effects?.on_handover(taker))
		return

	animate(src, transform = matrix() * 0, alpha = 0, pixel_w = 0, pixel_z = 0, time = HANDOVER_TIME)
	Move(get_turf(taker))
	QDEL_IN(src, HANDOVER_TIME)

/obj/effect/temp_visual/offered_item_effect/proc/someone_moved(mob/mover)
	SIGNAL_HANDLER

	if(QDELETED(src))
		return

	var/mob/living/offerer = offerer_weak_ref.resolve()
	var/mob/living/offered_to = offered_to_weak_ref.resolve()

	if(isnull(offerer) || isnull(offered_to))
		qdel(src)
		return

	if(!offerer.Adjacent(offered_to))
		offerer.cancel_offering_item()
		fade_out()
		return

	calculate_offset()

/obj/effect/temp_visual/offered_item_effect/proc/calculate_offset()
	if(QDELETED(src))
		return

	var/mob/living/offerer = offerer_weak_ref.resolve()
	var/mob/living/offered_to = offered_to_weak_ref.resolve()

	if(isnull(offerer) || isnull(offered_to))
		qdel(src)
		return

	if((x != offerer.x) || (y != offerer.y))
		Move(get_turf(offerer))

	var/w_displace = (offered_to.x - offerer.x) * 16
	var/z_displace = (offered_to.y - offerer.y) * 16 + 4

	animate(src, pixel_w = w_displace, pixel_z = z_displace, time = 0.2 SECONDS, transform = matrix() * 1)

/obj/effect/temp_visual/offered_item_effect/attack_hand(mob/living/user)
	. = ..()
	var/mob/living/offerer = offerer_weak_ref.resolve()
	var/obj/offered_thing = offered_thing_weak_ref.resolve()
	if(isnull(offered_thing) || isnull(offerer))
		return

	if(fading_out)
		return

	if(user == offerer)
		offerer.cancel_offering_item()
		return

	if(user.combat_mode == TRUE)
		offerer.attack_hand(arglist(args))
		// user.changeNext_move(CLICK_CD_MELEE) // this sux
		return

	user.try_accept_offered_item(offerer, offered_thing)

#undef HANDOVER_TIME
#undef STOP_OFFER_TIME
