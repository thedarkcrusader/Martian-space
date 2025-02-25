/datum/mob_spawner
	var/interval = 0 //interval to spawn mobs on (in seconds)
	var/next_spawn_time = 0 //internal
	var/variation = 0 //random variation added to the interval (in seconds)
	var/spawn_count = 0 //how many mobs to spawn (0 is infinite)
	var/radius = 0 //radius from around the selected origin to spawn mobs (0 is no radius)
	var/turf/center //center turf, used when selecting a turf and radius > 0
	var/area/area //area where mobs will spawn
	var/list/mob/living/mobs = list()
	var/list/messages = list() //messages spawner will pick from to display alongside spawning mobs
	var/message_class = "none" //the span class applied to the chosen message
	var/paused = TRUE


/datum/mob_spawner/proc/copy()
	var/list/contents = list()

	contents["mobs"] = mobs
	contents["interval"] = interval
	contents["variation"] = variation
	contents["message"] = messages
	contents["message_class"] = message_class
	contents["radius"] = radius
	contents["spawn_count"] = spawn_count
	contents["paused"] = paused

	return contents

/datum/mob_spawner/proc/paste(list/contents)
	if(contents.len == 0)
		return

	mobs = contents["mobs"]
	interval = contents["interval"]
	variation = contents["variation"]
	messages = contents["message"]
	message_class = contents["message_class"]
	radius = contents["radius"]
	spawn_count = contents["spawn_count"]
	paused = contents["paused"]


/datum/mob_spawner/Process()
	if (interval == 0 && spawn_count >= 0)
		interval = 10

	if (mobs.len > 0 && next_spawn_time < world.time)
		var/turf/T
		var/mob/living/M
		for (var/i = 1; i <= 10; i++)
			if (radius == -1)
				T = pick_area_turf(area)
			else
				var/list/turfs = trange(radius, center)
				T = pick(turfs)

			M = pick(mobs)

			if (!T.is_wall() && !T.density)
				break

		if (T.is_wall() || T.density)
			return

		M = new M(T)

		if (messages.len > 0)
			if (message_class != "none")
				M.visible_message("<span class='[message_class]'>[pick(messages)]</span>")
			else
				M.visible_message(pick(messages))



		if (spawn_count > 0)
			spawn_count--

			if (spawn_count <= 0)
				log_debug("Mob spawner at [area] finished spawning.")
				qdel(src) //delete spawner once we're done spawning mobs

		next_spawn_time = world.time + interval + rand(0, variation)

/datum/mob_spawner/Destroy()
	STOP_PROCESSING(SSprocessing, src)

	GLOB.mob_spawners.Remove(center)

	area = null
	center = null

	mobs.Cut()

	. = ..()
