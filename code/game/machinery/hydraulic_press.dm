

/obj/machinery/hydraulic_press

	name = "hydraulic press"
	desc = "A large crushing machine using the power of liquid to flatten anything in its path, an echo of an older age."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "grinder-o0"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/hydraulic_press
	var/icon_name = "grinder-o"
	///handles the iconstate, becomes bloody if it crushes a humanoid.
	var/bloody = FALSE
	///how much damage does this do to a mob?
	var/crush_damage = 100
	///sound to make when whirring up for a crush.
	var/crushing_whirr_up_sound = 'sound/items/tools/welder.ogg'
	///sound to make when the press plate falls.
	var/crushing_machine_sound = 'sound/items/tools/welder.ogg'
	///prevents crushing if it's a living, emag act disables this.
	var/safety_override = FALSE

	/obj/machinery/hydraulic_press/examine(mob/user)
	. = ..()
	. += {"The power light is [(machine_stat & NOPOWER) ? "off" : "on"].
	The safety-mode light is [safety_override ? "on" : "off"].
	The safety-sensors status light is [obj_flags & EMAGGED ? "off" : "on"]."}

/obj/machinery/recycler/attackby(obj/item/some_item, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", some_item))
		return

	if(default_pry_open(some_item, close_after_pry = TRUE))
		return

	if(default_deconstruction_crowbar(some_item))
		return
	return ..()

/obj/machinery/hydraulic_press/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	if(safety_override)
		safety_override = FALSE
		update_appearance()
	playsound(src, SFX_SPARKS, 75, TRUE, SILENCED_SOUND_EXTRARANGE)
	balloon_alert(user, "safety override enabled!")
	return FALSE

/obj/machinery/hydraulic_press/update_icon_state()
	var/is_powered = !(machine_stat & (BROKEN|NOPOWER))
	icon_state = icon_name + "[is_powered]" + "[(bloody ? "bld" : "")]" // add the blood tag at the end
	return ..()

/obj/machinery/hydraulic_press/proc/button_pressed()
	whirr_up()
	use_energy(idle_power_usage)

/obj/machinery/hydraulic_press/proc/perform_check()
	for(var/mob/living/living_mob in pickup_zone)
		if(!(obj_flags & EMAGGED) && isliving(living_mob)) //Can only squish living when emagged.
			playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 25)
			say("Living matter detected, operation aborted.")
			return TRUE
	return FALSE

/obj/machinery/hydraulic_press/proc/whirr_up()
	playsound(src, crushing_whirr_up_sound, 25)
	addtimer(CALLBACK(src, PROC_REF(squish), aggressive), 1.2 SECONDS)

/obj/machinery/hydraulic_press/proc/squish
	if(perform_check())
		return
	playsound(src, crushing_machine_sound, 25)
	for(var/atom/movable/movable_atom in pickup_zone)
		if(isliving(movable_atom))
			var/mob/living/fucked_up_thing = movable_atom
			fucked_up_thing.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
			fucked_up_thing.gib(DROP_ALL_REMAINS)
		if(isitem(movable_atom) && !(movable_atom.resistance_flags & INDESTRUCTIBLE))
			qdel(movable_atom)
		if(!isobj(movable_atom))
			continue
