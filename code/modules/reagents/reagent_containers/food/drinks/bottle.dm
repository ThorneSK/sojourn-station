///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/weapon/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	force = 5
	var/smash_duration = 5 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

	var/obj/item/weapon/reagent_containers/glass/rag/rag = null
	var/rag_underlay = "rag"
	var/icon_state_full
	var/icon_state_empty

/obj/item/weapon/reagent_containers/food/drinks/bottle/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/bottle/Initialize()
	icon_state_full = "[icon_state]"
	icon_state_empty = "[icon_state]_empty"
	. = ..()
	if(isGlass)
		unacidable = TRUE


/obj/item/weapon/reagent_containers/food/drinks/bottle/Destroy()
	if(rag)
		rag.forceMove(src.loc)
	rag = null
	return ..()

//when thrown on impact, bottles smash and spill their contents
/obj/item/weapon/reagent_containers/food/drinks/bottle/throw_impact(atom/hit_atom, var/speed)
	..()

	var/mob/M = thrower
	if(isGlass && istype(M) && M.a_intent == I_HURT)
		var/throw_dist = get_dist(throw_source, loc)
		if(speed >= throw_speed && smash_check(throw_dist)) //not as reliable as smashing directly
			if(reagents)
				hit_atom.visible_message(SPAN_NOTICE("The contents of \the [src] splash all over [hit_atom]!"))
				reagents.splash(hit_atom, reagents.total_volume)
			src.smash(loc, hit_atom)

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/smash_check(var/distance)
	if(!isGlass || !smash_duration)
		return 0

	var/list/chance_table = list(90, 90, 85, 85, 60, 35, 15) //starting from distance 0
	var/idx = max(distance + 1, 1) //since list indices start at 1
	if(idx > chance_table.len)
		return 0
	return prob(chance_table[idx])

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/smash(var/newloc, atom/against = null)
	if(ismob(loc))
		var/mob/M = loc
		M.drop_from_inventory(src)

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	var/obj/item/weapon/tool/broken_bottle/B = new /obj/item/weapon/tool/broken_bottle(newloc)
	if(prob(33))
		new/obj/item/weapon/material/shard(newloc) // Create a glass shard at the target's location!
	B.icon_state = src.icon_state

	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	if(rag && rag.on_fire && isliving(against))
		rag.forceMove(loc)
		var/mob/living/L = against
		L.IgniteMob()

	playsound(src,'sound/effects/GLASS_Rattle_Many_Fragments_01_stereo.ogg',100,1)
	src.transfer_fingerprints_to(B)

	qdel(src)
	return B

/obj/item/weapon/reagent_containers/food/drinks/bottle/attackby(obj/item/W, mob/user)
	if(!rag && istype(W, /obj/item/weapon/reagent_containers/glass/rag))
		insert_rag(W, user)
		return
	if(rag && istype(W, /obj/item/weapon/flame))
		rag.attackby(W, user)
		return
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/attack_self(mob/user)
	if(rag)
		remove_rag(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/insert_rag(obj/item/weapon/reagent_containers/glass/rag/R, mob/user)
	if(!isGlass || rag) return
	if(user.unEquip(R))
		to_chat(user, SPAN_NOTICE("You stuff [R] into [src]."))
		rag = R
		rag.forceMove(src)
		reagent_flags &= ~OPENCONTAINER
		verbs -= /obj/item/weapon/reagent_containers/food/drinks/proc/gulp_whole
		update_icon()

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/remove_rag(mob/user)
	if(!rag) return
	user.put_in_hands(rag)
	rag = null
	var/was_open_container = initial(reagent_flags) & OPENCONTAINER
	if(was_open_container)
		reagent_flags |= OPENCONTAINER
		verbs += /obj/item/weapon/reagent_containers/food/drinks/proc/gulp_whole
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/bottle/open(mob/user)
	if(rag) return
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/update_icon()
	underlays.Cut()
	if(rag)
		var/underlay_image = image(icon='icons/obj/drinks.dmi', icon_state=rag.on_fire? "[rag_underlay]_lit" : rag_underlay)
		underlays += underlay_image
		set_light(2)
	else
		set_light(0)
		if(reagents.total_volume)
			icon_state = icon_state_full
		else
			icon_state = icon_state_empty

/obj/item/weapon/reagent_containers/food/drinks/bottle/apply_hit_effect(mob/living/target, mob/living/user, var/hit_zone)
	..()

	if(user.a_intent != I_HURT)
		return
	if(!smash_check(1))
		return //won't always break on the first hit

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/weaken_duration = smash_duration + min(0, force - target.getarmor(hit_zone, ARMOR_MELEE) + 10)

	var/mob/living/carbon/human/H = target
	if(istype(H) && H.headcheck(hit_zone))
		var/obj/item/organ/affecting = H.get_organ(hit_zone) //headcheck should ensure that affecting is not null
		user.visible_message(SPAN_DANGER("[user] smashes [src] into [H]'s [affecting.name]!"))
		if(weaken_duration)
			target.apply_effect(min(weaken_duration, 5), WEAKEN, armor_value = target.getarmor(hit_zone, ARMOR_MELEE)) // Never weaken more than a flash!
	else
		user.visible_message(SPAN_DANGER("\The [user] smashes [src] into [target]!"))

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	if(reagents)
		user.visible_message(SPAN_NOTICE("The contents of \the [src] splash all over [target]!"))
		reagents.splash(target, reagents.total_volume)

	//Finally, smash the bottle. This kills (qdel) the bottle.
	var/obj/item/weapon/tool/broken_bottle/B = smash(target.loc, target)
	user.put_in_active_hand(B)

//// Precreated bottles ////

/obj/item/weapon/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	center_of_mass = list("x"=16, "y"=4)
	preloaded_reagents = list("gin" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve Whiskey"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	center_of_mass = list("x"=16, "y"=3)
	preloaded_reagents = list("whiskey" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled Vodka"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	center_of_mass = list("x"=17, "y"=3)
	preloaded_reagents = list("vodka" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla
	name = "Caccavo Guaranteed Quality Tequilla"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequillabottle"
	center_of_mass = list("x"=16, "y"=3)
	preloaded_reagents = list("tequilla" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing"
	icon_state = "bottleofnothing"
	center_of_mass = list("x"=17, "y"=5)
	preloaded_reagents = list("nothing" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron Tequilla"
	desc = "Silver laced tequilla, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("patron" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	center_of_mass = list("x"=16, "y"=8)
	preloaded_reagents = list("rum" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	center_of_mass = list("x"=17, "y"=3)
	preloaded_reagents = list("vermouth" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Kahlua"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	center_of_mass = list("x"=17, "y"=3)
	preloaded_reagents = list("kahlua" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	center_of_mass = list("x"=15, "y"=3)
	preloaded_reagents = list("goldschlager" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("cognac" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	center_of_mass = list("x"=16, "y"=4)
	preloaded_reagents = list("wine" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/ntcahors
	name = "Absolutism Cahors Wine"
	desc = "Ritual drink that cleanses the soul and body."
	icon_state = "ntcahors"
	center_of_mass = list("x"=16, "y"=4)
	preloaded_reagents = list("ntcahors" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe
	name = "Jailbreaker Absinthe"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("absinthe" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/melonliquor
	name = "Emeraldine Melon Liquor"
	desc = "A bottle of 46 proof Emeraldine Melon Liquor. Sweet and light."
	icon_state = "alco-green"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("melonliquor" = 100)
	icon_state_empty = "alco-empty"

/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Miss Blue Curacao"
	desc = "A fruity, exceptionally azure drink. Does not allow the imbiber to use the fifth magic."
	icon_state = "alco-blue"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("bluecuracao" = 100)
	icon_state_empty = "alco-empty"

/obj/item/weapon/reagent_containers/food/drinks/bottle/redcandywine
	name = "Mister Red Candy Liquor"
	desc = "Made from astored sweets, candies and even flowers."
	icon_state = "alco-red"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("redcandyliquor" = 100)
	icon_state_empty = "alco-empty"

/obj/item/weapon/reagent_containers/food/drinks/bottle/nanatsunoumi
	name = "Nanatsunoumi"
	desc = "A harsh salty alcohol that is from Japanese origin."
	icon_state = "alco-white"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("nanatsunoumi" = 100)
	icon_state_empty = "alco-white_empty"

/obj/item/weapon/reagent_containers/food/drinks/bottle/grenadine
	name = "Briar Rose Grenadine Syrup"
	desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
	icon_state = "grenadinebottle"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("grenadine" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cola
	name = "\improper Space Cola"
	desc = "Cola. in space"
	icon_state = "colabottle"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("cola" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/space_up
	name = "\improper Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up_bottle"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("space_up" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/space_mountain_wind
	name = "\improper Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind_bottle"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("spacemountainwind" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine
	name = "Warlock's Velvet"
	desc = "What a delightful packaging for a surely high quality wine! The vintage must be amazing!"
	icon_state = "pwinebottle"
	center_of_mass = list("x"=16, "y"=4)
	preloaded_reagents = list("pwine" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/fernet
	name = "Fernet Bronca"
	desc = "A bottle of pure Fernet Bronca, imported from Cordoba Space Station."
	icon_state = "fernetbottle"
	center_of_mass = list("x"=16, "y"=4)
	preloaded_reagents = list("fernet" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/neulandschnapps
	name = "Neuland Himbeergeist"
	desc = "A kriosan-approved spirits covered in german text, wax stamp on the bottle with the crest of a obscure and minor Castellan Lord. Time to shout 'Prost!' Ja?"
	icon_state = "neulandschnapps"
	center_of_mass = list("x"=16, "y"=6)
	preloaded_reagents = list("schnapps" = 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=7)
	isGlass = 0
	preloaded_reagents = list("orangejuice" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	isGlass = 0
	preloaded_reagents = list("cream" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	isGlass = 0
	preloaded_reagents = list("tomatojuice" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	isGlass = 0
	preloaded_reagents = list("limejuice" = 100)

//Small bottles
/obj/item/weapon/reagent_containers/food/drinks/bottle/small
	volume = 50
	smash_duration = 1
	flags = 0 //starts closed
	rag_underlay = "rag_small"

/obj/item/weapon/reagent_containers/food/drinks/bottle/small/beer
	name = "space beer"
	desc = "Contains only water, malt and hops."
	icon_state = "beer"
	center_of_mass = list("x"=16, "y"=12)
	preloaded_reagents = list("beer" = 30)

/obj/item/weapon/reagent_containers/food/drinks/bottle/small/ale
	name = "\improper Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	item_state = "beer"
	center_of_mass = list("x"=16, "y"=10)
	preloaded_reagents = list("ale" = 30)

/obj/item/weapon/reagent_containers/food/drinks/bottle/small/kvass
	name = "Magpie Kvass"
	desc = "A traditional russian drink. Made with in colony ingredients."
	icon_state = "Kvass_Bottle"
	isGlass = 0
	center_of_mass = list("x"=16, "y"=12)
	preloaded_reagents = list("Kvass" = 30)
