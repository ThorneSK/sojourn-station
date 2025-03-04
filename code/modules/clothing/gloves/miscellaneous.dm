/obj/item/clothing/gloves/captain
	desc = "A pair of regal blue gloves with a swanky gold trim."
	name = "premier's gloves"
	icon_state = "captain"
	item_state = "captain"
	armor = list(melee = 25, bullet = 10, energy = 25, bomb = 0, bio = 0, rad = 0)
	price_tag = 250

/obj/item/clothing/gloves/cyborg
	desc = "Beep boop."
	name = "cyborg gloves"
	icon_state = "robohands"
	item_state = "robohands"
	siemens_coefficient = 1

/obj/item/clothing/gloves/insulated
	desc = "A pair of gloves which protect the wearer from electric shocks."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "yellow"
	armor = list(melee = 0, bullet = 0, energy = 15, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	price_tag = 200

/obj/item/clothing/gloves/insulated/cheap                          //Cheap Chinese Crap
	desc = "A pair of cheaply-made insulated gloves. Not known for reliability."
	name = "budget insulated gloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05
	price_tag = 50

/obj/item/clothing/gloves/insulated/cheap/Initialize(mapload, ...)
	. = ..()
	//average of 0.5, somewhat better than regular gloves' 0.75
	siemens_coefficient = pick(0,0.1,0.3,0.5,0.5,0.75,1.35)

/obj/item/clothing/gloves/thick
	desc = "A pair of fire-resistant black work gloves."
	name = "thick gloves"
	icon_state = "black"
	item_state = "black"
	armor = list(melee = 20, bullet = 0, energy = 20, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.5
	permeability_coefficient = 0.05
	price_tag = 100

	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/thick/brown
	desc = "A pair of fire-resistant brown work gloves."
	name = "thick brown gloves"
	icon_state = "germangloves"
	item_state = "germangloves"

/obj/item/clothing/gloves/thick/handmade
	name = "handmade combat gloves"
	desc = "A pair of modified work gloves with some steel."
	icon_state = "hm_combat"
	item_state = "hm_combat"
	armor = list(melee = 25, bullet = 5, energy = 20, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.6
	price_tag = 150

/obj/item/clothing/gloves/thick/swat
	desc = "A pair of fire and impact-resistant security combat gloves."
	name = "combat gloves"
	icon_state = "ihscombat"
	item_state = "ihscombat"
	armor = list(melee = 25, bullet = 20, energy = 20, bomb = 0, bio = 0, rad = 0)
	price_tag = 150

/obj/item/clothing/gloves/thick/ablasive
	name = "ablative gloves"
	desc = "A thick pare of gloves that excels in protecting the wearer against energy projectiles."
	armor = list(melee = 10, bullet = 10, energy = 70, bomb = 30, bio = 10, rad = 0)
	icon_state = "ihscombat"
	item_state = "ihscombat"
	price_tag = 150
	matter = list(MATERIAL_STEEL = 5, MATERIAL_PLASTIC = 10, MATERIAL_PLATINUM = 2)

/obj/item/clothing/gloves/thick/ablasive/iron_lock_security
	name = "outdated gloves"
	desc = "An \"Iron Lock Security\" ablative gloves with plates designed to absorb energy projectiles, even after all this time no one has been able to improve its design by Greyson Positronic."

/obj/item/clothing/gloves/thick/combat //Combined effect of SWAT gloves and insulated gloves
	desc = "A pair of fire, shock-proof, and impact-resistant combat gloves."
	name = "combat gloves"
	icon_state = "black"
	item_state = "black"
	armor = list(melee = 25, bullet = 20, energy = 20, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0
	price_tag = 250

/obj/item/clothing/gloves/evening
	name = "evening gloves"
	initial_name = "evening gloves"
	desc = "A pair of elegant evening gloves."
	icon_state = "evening_gloves"
	item_state = "evening_gloves"

/obj/item/clothing/gloves/ash_evening
	name = "ash evening gloves"
	initial_name = "ash evening gloves"
	desc = "A pair of ash elegant evening gloves."
	icon_state = "ash_evening_gloves"
	item_state = "ash_evening_gloves"

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "A pair of sterile latex gloves."
	icon_state = "latex"
	item_state = "latex"
	siemens_coefficient = 1.0 //thin latex gloves, much more conductive than fabric gloves (basically a capacitor for AC)
	permeability_coefficient = 0.01
	germ_level = 0
	price_tag = 50

/obj/item/clothing/gloves/latex/nitrile
	name = "nitrile gloves"
	desc = "A pair of sterile nitrile gloves."
	icon_state = "nitrile"
	item_state = "nitrile"

/obj/item/clothing/gloves/botanic_leather
	desc = "A pair of leather work gloves that protect against floral dangers such as thorns and barbs."
	name = "botanist's leather gloves"
	icon_state = "leather"
	item_state = "leather"
	permeability_coefficient = 0.05
	siemens_coefficient = 0.50 //thick work gloves
	price_tag = 50

/obj/item/clothing/gloves/aerostatic_gloves
	name = "red designer leather gloves"
	desc = "A pair of elegant leather gloves."
	icon_state = "aerostatic_gloves"
	item_state = "aerostatic_gloves"
	permeability_coefficient = 0.05
	siemens_coefficient = 0.50 //thick work gloves
	price_tag = 50

/obj/item/clothing/gloves/fingerless
	desc = "A pair of gloves modified for species with clawed hands."
	name = "fingerless gloves"
	icon_state = "fingerlessgloves"
	clipped = TRUE
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	price_tag = 10

/obj/item/clothing/gloves/membrane
	name = "scientific gloves"
	desc = "Heavy gloves to keep your hands intact for future experiments."
	icon_state = "science"
	item_state = "science"
	armor = list(melee = 25, bullet = 5, energy = 20, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.5
	permeability_coefficient = 0.05
	germ_level = 0
	price_tag = 50
