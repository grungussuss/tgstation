

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
	var/bloody = FALSE
	var/crush_damage = 100
	///Sound to make when initialising crushing sequence
	var/crushing_initialize_sound = 'sound/items/tools/welder.ogg'
	///Stops crushing for a bit if it's a mob, emag act disables this.
	var/safety_override = FALSE

	/obj/machinery/hydraulic_press/examine(mob/user)
	. = ..()
	. += {"The power light is [(machine_stat & NOPOWER) ? "off" : "on"].
	The safety-mode light is [safety_override ? "on" : "off"].
	The safety-sensors status light is [obj_flags & EMAGGED ? "off" : "on"]."}

/obj/machinery/recycler/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		return

	if(default_pry_open(I, close_after_pry = TRUE))
		return

	if(default_deconstruction_crowbar(I))
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

/obj/machinery/recycler/update_icon_state()
	var/is_powered = !(machine_stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = FALSE
	icon_state = icon_name + "[is_powered]" + "[(bloody ? "bld" : "")]" // add the blood tag at the end
	return ..()
