//These circuits do filtering
/obj/item/integrated_circuit/filter
	name = "filter"
	desc = "You shall not pass!"
	complexity = 1
	inputs = list("input")
	outputs = list("output")
	activators = list("filter")
	category = /obj/item/integrated_circuit/filter

/obj/item/integrated_circuit/filter/do_work()
	var/datum/integrated_io/I = inputs[1]
	var/datum/integrated_io/O = outputs[1]

	if(may_pass(I.data))
		O.data = I.data
		O.push_data()

/obj/item/integrated_circuit/filter/proc/may_pass(var/input)
	return FALSE

/obj/item/integrated_circuit/filter/ref
	extended_desc = "Uses heuristics and complex algoritms to match incoming data against its filtering parameters and occasionally produces both false positives and negatives."
	complexity = 10
	category = /obj/item/integrated_circuit/filter/ref
	var/filter_type

/obj/item/integrated_circuit/filter/ref/may_pass(var/weakref/data)
	if(!(filter_type && isweakref(data)))
		return FALSE
	return istype(data.resolve(), filter_type)

/obj/item/integrated_circuit/filter/ref/mob
	name = "life filter"
	desc = "Only allow refs belonging to more complex, currently or formerly, living but not necessarily biological entities through"
	complexity = 15
	icon_state = "filter_mob"
	filter_type = /mob/living

/obj/item/integrated_circuit/filter/ref/mob/humanoid
	name = "humanoid filter"
	desc = "Only allow refs belonging to humanoids (dead or alive) through"
	complexity = 25
	icon_state = "filter_humanoid"
	filter_type = /mob/living/carbon/human

/obj/item/integrated_circuit/filter/ref/obj
	name = "object filter"
	desc = "Allows most kinds of refs to pass, as long as they are not considered (once) living entities."
	icon_state = "filter_obj"
	filter_type = /obj

/obj/item/integrated_circuit/filter/ref/obj/item
	name = "item filter"
	desc = "Only allow refs belonging to minor items through, typically hand-held such."
	icon_state = "filter_item"
	filter_type = /obj/item

/obj/item/integrated_circuit/filter/ref/obj/machinery
	name = "machinery filter"
	desc = "Only allow refs belonging machinery or complex objects through, such as computers and consoles."
	complexity = 15
	icon_state = "filter_machinery"
	filter_type = /obj/machinery

/obj/item/integrated_circuit/filter/ref/object/structure
	name = "machinery filter"
	desc = "Only allow refs belonging larger objects and structures through, such as closets and beds."
	complexity = 15
	icon_state = "filter_structure"
	filter_type = /obj/structure

/obj/item/integrated_circuit/filter/ref/custom
	name = "custom filter"
	desc = "Allows custom filtering. Apply the circuit to the type of object to filter on before assembly."
	complexity = 20
	size = 2
	icon_state = "filter_custom"

/obj/item/integrated_circuit/filter/ref/custom/may_pass(var/weakref/data)
	if(!filter_type)
		return FALSE
	if(!isweakref(data))
		return FALSE
	return istype(data.resolve(), filter_type)

/obj/item/integrated_circuit/filter/ref/custom/resolve_attackby(atom/A, mob/user, click_params)
	add_fingerprint(user)
	filter_type = A.type
	extended_desc = "[initial(extended_desc)] - This circuit strictly filters on types heuristically determined to be [filter_type]."
	to_chat(user, "<span class='notice'>You change the filtering parameter of \the [src] to [filter_type].</span>")
	return 1
