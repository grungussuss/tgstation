/datum/offer_effects/high_five
	var/list/datum/weakref/attempters_assoc = list()

/datum/offer_effects/high_five/proc/get_attempt_count(mob/attempter)
	var/attempt_count = 1
	var/found = FALSE
	for(var/datum/weakref/mob_weakref in attempters_assoc)
		if(mob_weakref.resolve() == attempter)
			attempters_assoc[mob_weakref] += 1
			attempt_count = attempters_assoc[mob_weakref]
			found = TRUE
			break

	if(!found)
		attempters_assoc[WEAKREF(attempter)] += 1

	return attempt_count

/datum/offer_effects/high_five/try_accept(mob/taker)
	var/attempt_count = get_attempt_count(taker)
	var/string = ""

	for(var/i in 1 to min(attempt_count, 3))
		string += "?"

	parent.balloon_alert(taker, string)

	if(attempt_count >= 3)
		to_chat(taker, span_danger("Maybe I should form a palm and slap their hand..."))

	return TRUE

/datum/offer_effects/high_five/attackby(mob/attacker, obj/attacking_thing)
	if(!istype(attacking_thing, /obj/item/hand_item/slapper))
		return FALSE

	unregister_offer_signals()

	high_five(arglist(args))

	to_chat(world, span_notice("attackby success"))

	return TRUE

/datum/offer_effects/high_five/proc/high_five(mob/attacker, obj/attacking_thing)

	playsound(attacker, 'sound/items/weapons/slap.ogg', 100, TRUE, 1)

	offerer.do_attack_animation(attacker)
	attacker.do_attack_animation(parent)

	var/mob/living/taker = attacker

	var/obj/effect/slap_effect = new(attacker)
	slap_effect.vis_flags = VIS_INHERIT_LAYER|VIS_INHERIT_PLANE|VIS_UNDERLAY

	attacker.vis_contents += slap_effect
	slap_effect.appearance = attacking_thing.appearance
	slap_effect.transform *= 0

	var/w_displace = (taker.x - offerer.x) * 16
	var/z_displace = (taker.y - offerer.y) * 16 + 4

	animate(src, pixel_w = w_displace, pixel_z = z_displace, time = 0.5 SECONDS, transform = matrix(), easing = JUMP_EASING)

	var/open_hands_taker = 0
	var/slappers_giver = 0
	// see how many hands the taker has open for high'ing
	for(var/hand in taker.held_items)
		if(isnull(hand))
			open_hands_taker++

	// see how many hands the offerer is using for high'ing
	for(var/obj/item/slap_check in offerer.held_items)
		if(slap_check.item_flags & HAND_ITEM)
			slappers_giver++

	var/high_ten = (slappers_giver >= 2)
	var/descriptor = "high-[high_ten ? "ten" : "five"]"

	if(open_hands_taker <= 0)
		to_chat(taker, span_warning("You can't [descriptor] [offerer] with no open hands!"))
		taker.add_mood_event(descriptor, /datum/mood_event/high_five_full_hand) // not so successful now!
		return COMPONENT_OFFER_INTERRUPT

	playsound(offerer, 'sound/items/weapons/slap.ogg', min(50 * slappers_giver, 300), TRUE, 1)
	offerer.add_mob_memory(/datum/memory/high_five, deuteragonist = taker, high_five_type = descriptor, high_ten = high_ten)
	taker.add_mob_memory(/datum/memory/high_five, deuteragonist = offerer, high_five_type = descriptor, high_ten = high_ten)

	if(high_ten)
		to_chat(taker, span_nicegreen("You give high-tenning [offerer] your all!"))
		offerer.visible_message(
			span_notice("[taker] enthusiastically high-tens [offerer]!"),
			span_nicegreen("Wow! You're high-tenned [taker]!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
			ignored_mobs = taker,
		)

		offerer.add_mood_event(descriptor, /datum/mood_event/high_ten)
		taker.add_mood_event(descriptor, /datum/mood_event/high_ten)
	else
		to_chat(taker, span_nicegreen("You high-five [offerer]!"))
		offerer.visible_message(
			span_notice("[taker] high-fives [offerer]!"),
			span_nicegreen("All right! You're high-fived by [taker]!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
			ignored_mobs = taker,
		)

		offerer.add_mood_event(descriptor, /datum/mood_event/high_five)
		taker.add_mood_event(descriptor, /datum/mood_event/high_five)

	addtimer(CALLBACK(parent, PROC_REF(fade_out)), 0.5 SECONDS)

/datum/offer_effects/high_five/on_handover(mob/taker)
	to_chat(world, span_notice("handover success"))
	return TRUE
