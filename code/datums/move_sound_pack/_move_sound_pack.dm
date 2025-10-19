/datum/move_sound_pack
	abstract_type = /datum/move_sound_pack
	/// how often on trigger it will play the sound.
	var/periodicity = 2 // every 2 moves (step once, step a second time and the sound plays.)
	/// the current "step", goes up by one every trigger and is reset back to 0 on sound play
	var/current_step = 0
	/// extra range for the sound to play
	var/extra_range = 0
	/// volume to play at
	var/volume = 50

	/// assoc list of move sound type to var name
	var/static/sound_type_map = list(
		MOVE_SOUND_TYPE_WOOD = "wood_sounds",
		MOVE_SOUND_TYPE_FLOOR = "floor_sounds",
		MOVE_SOUND_TYPE_PLATING = "plating_sounds",
		MOVE_SOUND_TYPE_CARPET = "carpet_sounds",
		MOVE_SOUND_TYPE_SAND = "sand_sounds",
		MOVE_SOUND_TYPE_GRASS = "grass_sounds",
		MOVE_SOUND_TYPE_WATER = "water_sounds",
		MOVE_SOUND_TYPE_LAVA = "lava_sounds",
		MOVE_SOUND_TYPE_MEAT = "meat_sounds",
		MOVE_SOUND_TYPE_CATWALK = "catwalk_sounds",
	)

	var/wood_sounds = list(
		'sound/effects/footstep/woodbarefoot1.ogg',
		'sound/effects/footstep/woodbarefoot2.ogg',
		'sound/effects/footstep/woodbarefoot3.ogg',
		'sound/effects/footstep/woodbarefoot4.ogg',
		'sound/effects/footstep/woodbarefoot5.ogg',
	)

	var/floor_sounds = list(
		'sound/effects/footstep/hardbarefoot1.ogg',
		'sound/effects/footstep/hardbarefoot2.ogg',
		'sound/effects/footstep/hardbarefoot3.ogg',
		'sound/effects/footstep/hardbarefoot4.ogg',
		'sound/effects/footstep/hardbarefoot5.ogg',
	)

	var/plating_sounds = list(
		'sound/effects/footstep/hardbarefoot1.ogg',
		'sound/effects/footstep/hardbarefoot2.ogg',
		'sound/effects/footstep/hardbarefoot3.ogg',
		'sound/effects/footstep/hardbarefoot4.ogg',
		'sound/effects/footstep/hardbarefoot5.ogg',
	)

	var/carpet_sounds = list(
		'sound/effects/footstep/carpetbarefoot1.ogg',
		'sound/effects/footstep/carpetbarefoot2.ogg',
		'sound/effects/footstep/carpetbarefoot3.ogg',
		'sound/effects/footstep/carpetbarefoot4.ogg',
		'sound/effects/footstep/carpetbarefoot5.ogg',
	)

	var/sand_sounds = list(
		'sound/effects/footstep/asteroid1.ogg',
		'sound/effects/footstep/asteroid2.ogg',
		'sound/effects/footstep/asteroid3.ogg',
		'sound/effects/footstep/asteroid4.ogg',
		'sound/effects/footstep/asteroid5.ogg',
	)

	var/grass_sounds = list(
		'sound/effects/footstep/grass1.ogg',
		'sound/effects/footstep/grass2.ogg',
		'sound/effects/footstep/grass3.ogg',
		'sound/effects/footstep/grass4.ogg',
	)

	var/water_sounds = list(
		'sound/effects/footstep/water/water1.ogg',
		'sound/effects/footstep/water/water2.ogg',
		'sound/effects/footstep/water/water3.ogg',
		'sound/effects/footstep/water/water4.ogg',
	)

	var/lava_sounds = list(
		'sound/effects/footstep/lava1.ogg',
		'sound/effects/footstep/lava2.ogg',
		'sound/effects/footstep/lava3.ogg',
	)

	var/meat_sounds = list(
		'sound/effects/meatslap.ogg'
	)

	var/catwalk_sounds = list(
		'sound/effects/footstep/catwalk1.ogg',
		'sound/effects/footstep/catwalk2.ogg',
		'sound/effects/footstep/catwalk3.ogg',
		'sound/effects/footstep/catwalk4.ogg',
		'sound/effects/footstep/catwalk5.ogg',
	)

/datum/move_sound_pack/proc/trigger(turf/moved_to)
	if(!istype(moved_to))
		return

	current_step++

	if(current_step >= periodicity)
		play_footstep(moved_to)

/datum/move_sound_pack/proc/play_footstep(turf/moved_to)
