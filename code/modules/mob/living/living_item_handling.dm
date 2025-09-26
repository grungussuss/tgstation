// Throwing stuff
/mob/living/proc/toggle_throw_mode()
	if(stat)
		return
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		return
	if(throw_mode)
		throw_mode_off(THROW_MODE_TOGGLE)
	else
		throw_mode_on(THROW_MODE_TOGGLE)


/mob/living/proc/throw_mode_off(method)
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		return
	if(throw_mode > method) //A toggle doesnt affect a hold
		return
	throw_mode = THROW_MODE_DISABLED
	if(hud_used)
		hud_used.throw_icon.icon_state = "act_throw"
	SEND_SIGNAL(src, COMSIG_LIVING_THROW_MODE_TOGGLE, throw_mode)


/mob/living/proc/throw_mode_on(mode = THROW_MODE_TOGGLE)
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		return
	throw_mode = mode
	if(hud_used)
		hud_used.throw_icon.icon_state = "act_throw_on"
	SEND_SIGNAL(src, COMSIG_LIVING_THROW_MODE_TOGGLE, throw_mode)

/mob/proc/throw_item(atom/target)
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		return FALSE
	SEND_SIGNAL(src, COMSIG_MOB_THROW, target)
	return TRUE

/mob/living/throw_item(atom/target)
	. = ..()
	throw_mode_off(THROW_MODE_TOGGLE)
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		stack_trace("[src] tried to throw [target], but they shouldn't be able to throw things")
		return FALSE
	if(!target || !isturf(loc))
		return FALSE
	if(istype(target, /atom/movable/screen))
		return FALSE
	var/atom/movable/thrown_thing
	var/obj/item/held_item = get_active_held_item()
	var/verb_text = pick("throw", "toss", "hurl", "chuck", "fling")
	if(prob(0.5))
		verb_text = "yeet"
	var/neckgrab_throw = FALSE // we can't check for if it's a neckgrab throw when totaling up power_throw since we've already stopped pulling them by then, so get it early
	var/frequency_number = 1 //We assign a default frequency number for the sound of the throw.
	if(!held_item)
		if(pulling && isliving(pulling) && grab_state >= GRAB_AGGRESSIVE)
			var/mob/living/throwable_mob = pulling
			if(!throwable_mob.buckled)
				thrown_thing = throwable_mob
				if(grab_state >= GRAB_NECK)
					neckgrab_throw = TRUE
				stop_pulling()
				if(HAS_TRAIT(src, TRAIT_PACIFISM) || HAS_TRAIT(src, TRAIT_NO_THROWING))
					to_chat(src, span_notice("You gently let go of [throwable_mob]."))
					return FALSE
	else
		thrown_thing = held_item.on_thrown(src, target)
	if(!thrown_thing)
		return FALSE
	if(isliving(thrown_thing))
		var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
		var/turf/end_T = get_turf(target)
		if(start_T && end_T)
			log_combat(src, thrown_thing, "thrown", addition="grab from tile in [AREACOORD(start_T)] towards tile at [AREACOORD(end_T)]")
	var/power_throw = 0
	var/extra_throw_range = HAS_TRAIT(src, TRAIT_THROWINGARM) ? 2 : 0

	var/obj/item/organ/cyberimp/chest/spine/potential_spine = get_organ_slot(ORGAN_SLOT_SPINE)
	if(istype(potential_spine))
		power_throw += potential_spine.added_throw_speed
		extra_throw_range += potential_spine.added_throw_range

	if(HAS_TRAIT(src, TRAIT_HULK))
		power_throw++
	if(HAS_TRAIT(src, TRAIT_DWARF))
		power_throw--
	if(HAS_TRAIT(thrown_thing, TRAIT_DWARF))
		power_throw++
	if(neckgrab_throw)
		power_throw++
	if(HAS_TRAIT(src, TRAIT_TOSS_GUN_HARD) && isgun(thrown_thing))
		power_throw++
	if(isitem(thrown_thing))
		var/obj/item/thrown_item = thrown_thing
		frequency_number = 1-(thrown_item.w_class-3)/8 //At normal weight, the frequency is at 1. For tiny, it is 1.25. For huge, it is 0.75.
		if(thrown_item.throw_verb)
			verb_text = thrown_item.throw_verb
	do_attack_animation(target, no_effect = 1)
	var/sound/throwsound = 'sound/items/weapons/throw.ogg'
	var/power_throw_text = "."
	if(power_throw > 0) //If we have anything that boosts our throw power like hulk, we use the rougher heavier variant.
		throwsound = 'sound/items/weapons/throwhard.ogg'
		power_throw_text = " really hard!"
	if(power_throw < 0) //if we have anything that weakens our throw power like dward, we use a slower variant.
		throwsound = 'sound/items/weapons/throwsoft.ogg'
		power_throw_text = " flimsily."
	frequency_number = frequency_number + (rand(-5,5)/100); //Adds a bit of randomness in the frequency to not sound exactly the same.
	//The volume of the sound takes the minimum between the distance thrown or the max range an item, but no more than 50. Short throws are quieter. A fast throwing speed also makes the noise sharper.
	playsound(src, throwsound, clamp(8*min(get_dist(loc,target),thrown_thing.throw_range), 10, 50), vary = TRUE, extrarange = -1, frequency = frequency_number)
	visible_message(span_danger("[src] [verb_text][plural_s(verb_text)] [thrown_thing][power_throw_text]"), \
					span_danger("You [verb_text] [thrown_thing][power_throw_text]"))
	log_message("has thrown [thrown_thing] [power_throw_text]", LOG_ATTACK)

	var/drift_force = max(0.5 NEWTONS, 1 NEWTONS + power_throw)
	if (isitem(thrown_thing))
		var/obj/item/thrown_item = thrown_thing
		drift_force *= WEIGHT_TO_NEWTONS(thrown_item.w_class)

	newtonian_move(get_angle(target, src), drift_force = drift_force)
	thrown_thing.safe_throw_at(target, thrown_thing.throw_range + extra_throw_range, max(1,thrown_thing.throw_speed + power_throw), src, null, null, null, move_force)


/mob/living/click_ctrl_shift(mob/user)
	if(HAS_TRAIT(src, TRAIT_CAN_HOLD_ITEMS))
		var/mob/living/living_user = user
		living_user.offer_item(src, living_user.get_active_held_item(living_user))


/mob/living/proc/offer_item(mob/living/offered_to, obj/offered_item)
	if(isnull(offered_to) || isnull(offered_item))
		stack_trace("no offered_to or offered_item in offer_item()")
		return

	if(offered_to == src)
		to_chat(src, span_danger("You can't offer something to yourself!"))
		return FALSE

	var/time_left = COOLDOWN_TIMELEFT(src, offer_cooldown)

	if(time_left)
		to_chat(src, span_danger("I must wait [time_left / 10] seconds before offering again."))
		return FALSE

	offered_item_ref = WEAKREF(offered_item)

	visible_message(
		span_notice("[src] offers [offered_item] to [offered_to] with an outstretched hand."), \
		span_notice("I offer [offered_item] to [offered_to] with an outstretched hand."), \
		vision_distance = COMBAT_MESSAGE_RANGE, \
		ignored_mobs = list(offered_to)
	)
	to_chat(offered_to, span_notice("[offered_to] offers [offered_item] to me..."))

	new /obj/effect/temp_visual/offered_item_effect(get_turf(src), offered_item, src, offered_to)

/mob/living/proc/cancel_offering_item()
	var/obj/offered_item = offered_item_ref?.resolve()
	if(isnull(offered_item))
		stop_offering_item()
		return


	visible_message(
		span_notice("[src] puts their hand back down."), \
		span_notice("I stop offering [offered_item ? offered_item : "the item"]."), \
		vision_distance = COMBAT_MESSAGE_RANGE, \
	)

	stop_offering_item()

/mob/living/proc/stop_offering_item()
	COOLDOWN_START(src, offer_cooldown, 1 SECONDS)
	SEND_SIGNAL(src, COMSIG_LIVING_STOPPED_OFFERING_ITEM)
	offered_item_ref = null

/mob/living/proc/try_accept_offered_item(mob/living/offerer, obj/offered_item)
	if(get_active_held_item())
		to_chat(src, span_warning("I need a free hand to take it!"))
		return FALSE

	accept_offered_item(offerer, offered_item)
	return TRUE

/mob/living/proc/accept_offered_item(mob/living/offerer, obj/offered_item)
	transferItemToLoc(offered_item, src)
	put_in_active_hand(offered_item)

	to_chat(offerer, span_notice("[src] takes [offered_item] from my outstretched hand."))
	visible_message(
		span_warning("[src] takes [offered_item] from [offerer]'s outstretched hand!"), \
		span_notice("I take [offered_item] from [offerer]'s outstretched hand."), \
		vision_distance = COMBAT_MESSAGE_RANGE, \
		ignored_mobs = list(offerer)
	)

	SEND_SIGNAL(offered_item, COMSIG_LIVING_ACCEPTED_ITEM, src, offerer)
	offerer.stop_offering_item()

