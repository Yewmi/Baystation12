/obj/item/integrated_circuit/time
	name = "time circuit"
	desc = "Now you can build your own clock!"
	complexity = 2
	inputs = list()
	outputs = list()
	category = /obj/item/integrated_circuit/time

/obj/item/integrated_circuit/time/delay
	name = "two-sec delay circuit"
	desc = "This sends a pulse signal out after a delay, critical for ensuring proper control flow in a complex machine.  \
	This circuit is set to send a pulse after a delay of two seconds."
	icon_state = "delay-20"
	var/delay = 2 SECONDS
	activators = list("incoming pulse","outgoing pulse")

/obj/item/integrated_circuit/time/delay/do_work()
	set waitfor = 0  // Don't sleep in a proc that is called by a processor without this set, otherwise it'll delay the entire thing

	var/datum/integrated_io/out_pulse = activators[2]
	sleep(delay)
	out_pulse.push_data()

/obj/item/integrated_circuit/time/delay/five_sec
	name = "five-sec delay circuit"
	desc = "This sends a pulse signal out after a delay, critical for ensuring proper control flow in a complex machine.  \
	This circuit is set to send a pulse after a delay of five seconds."
	icon_state = "delay-50"
	delay = 5 SECONDS

/obj/item/integrated_circuit/time/delay/one_sec
	name = "one-sec delay circuit"
	desc = "This sends a pulse signal out after a delay, critical for ensuring proper control flow in a complex machine.  \
	This circuit is set to send a pulse after a delay of one second."
	icon_state = "delay-10"
	delay = 1 SECOND

/obj/item/integrated_circuit/time/delay/half_sec
	name = "half-sec delay circuit"
	desc = "This sends a pulse signal out after a delay, critical for ensuring proper control flow in a complex machine.  \
	This circuit is set to send a pulse after a delay of half a second."
	icon_state = "delay-5"
	delay = 5

/obj/item/integrated_circuit/time/delay/tenth_sec
	name = "tenth-sec delay circuit"
	desc = "This sends a pulse signal out after a delay, critical for ensuring proper control flow in a complex machine.  \
	This circuit is set to send a pulse after a delay of 1/10th of a second."
	icon_state = "delay-1"
	delay = 1

/obj/item/integrated_circuit/time/delay/custom
	name = "custom delay circuit"
	desc = "This sends a pulse signal out after a delay, critical for ensuring proper control flow in a complex machine.  \
	This circuit's delay can be customized, between 1/10th of a second to one hour.  The delay is updated upon receiving a pulse."
	icon_state = "delay"
	inputs = list("delay time")

/obj/item/integrated_circuit/time/delay/custom/do_work()
	var/datum/integrated_io/delay_input = inputs[1]
	if(delay_input.data && isnum(delay_input.data) )
		var/new_delay = min(delay_input.data, 1)
		new_delay = max(new_delay, 36000) //An hour.
		delay = new_delay

	..()

/obj/item/integrated_circuit/time/ticker
	name = "ticker circuit"
	desc = "This circuit sends an automatic pulse every four seconds."
	icon_state = "tick-m"
	complexity = 8
	var/ticks_to_pulse = 4
	var/ticks_completed = 0
	var/is_running = FALSE
	inputs = list("enable ticking")
	activators = list("outgoing pulse")

/obj/item/integrated_circuit/time/ticker/Destroy()
	if(is_running)
		processing_objects -= src
	. = ..()

/obj/item/integrated_circuit/time/ticker/on_data_written()
	var/datum/integrated_io/do_tick = inputs[1]
	if(do_tick.data && !is_running)
		is_running = TRUE
		processing_objects |= src
	else if(is_running)
		is_running = FALSE
		processing_objects -= src
		ticks_completed = 0

/obj/item/integrated_circuit/time/ticker/process()
	var/process_ticks = process_schedule_interval("obj")
	ticks_completed += process_ticks
	if(ticks_completed >= ticks_to_pulse)
		if(ticks_to_pulse >= process_ticks)
			ticks_completed -= ticks_to_pulse
		else
			ticks_completed = 0
		var/datum/integrated_io/pulser = activators[1]
		pulser.push_data()

/obj/item/integrated_circuit/time/ticker/fast
	name = "fast ticker"
	desc = "This advanced circuit sends an automatic pulse every two seconds."
	icon_state = "tick-f"
	complexity = 12
	ticks_to_pulse = 2

/obj/item/integrated_circuit/time/ticker/slow
	name = "slow ticker"
	desc = "This simple circuit sends an automatic pulse every six seconds."
	icon_state = "tick-s"
	complexity = 4
	ticks_to_pulse = 6

/obj/item/integrated_circuit/time/clock
	name = "integrated clock"
	desc = "Tells you what the local time is, specific to your station or planet."
	icon_state = "clock"
	inputs = list()
	outputs = list("time (string)", "hours (number)", "minutes (number)", "seconds (number)")

/obj/item/integrated_circuit/time/clock/do_work()
	var/datum/integrated_io/time = outputs[1]
	var/datum/integrated_io/hour = outputs[2]
	var/datum/integrated_io/min = outputs[3]
	var/datum/integrated_io/sec = outputs[4]

	time.data = time2text(station_time_in_ticks, "hh:mm:ss")
	hour.data = text2num(time2text(station_time_in_ticks, "hh"))
	min.data = text2num(time2text(station_time_in_ticks, "mm"))
	sec.data = text2num(time2text(station_time_in_ticks, "ss"))

	for(var/datum/integrated_io/output/O in outputs)
		O.push_data()
