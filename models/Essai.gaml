/***
* Name: Essai
* Author: rolvy-dicken
* Description: 
* Tags: Tag1, Tag2, TagN
***/

//model Essai
//
//global {
//	/** Insert the global definitions, variables and actions here */
//}
//
//experiment Essai type: gui {
//	/** Insert here the definition of the input and output of the model */
//	output {
//	}
//}
model model4

global {
	int nb_people <- 200;
	int nb_infected_init <- 5;
	//float step <- 5 #mn;
	file roads_shapefile <- file("../includes/Routes.shp");
	file buildings_shapefile <- file("../includes/Housing.shp");
	file shape_file_workingPlace <- file("../includes/working_place.shp");
	file shape_file_studingPlace <- file("../includes/Studing_place.shp");
	file shape_file_hobby <- file("../includes/Loisirs.shp");
	file shape_file_hospital <- file("../includes/Hopital.shp");
	geometry shape <- envelope(roads_shapefile);
	graph road_lines;
	int nb_doctor <- 4;
	int nb_people_infected <- nb_infected_init update: people count (each.is_infected);
	int nb_people_not_infected <- nb_people - nb_infected_init update: nb_people - nb_people_infected;
	float infected_rate update: nb_people_infected / nb_people;

	init {
		create road from: roads_shapefile;
		road_lines <- as_edge_graph(road);
		create building from: buildings_shapefile;
		create workingPlace from: shape_file_workingPlace;
		create studingPlace from: shape_file_studingPlace;
		create hobby from: shape_file_hobby;
		create hospital from: shape_file_hospital;
		create people number: nb_people {
			location <- any_location_in(one_of(building));
		}

		create doctor number: nb_doctor {
			location <- any_location_in(one_of(hospital));
		}

		ask nb_infected_init among people {
			is_infected <- true;
		}

	}

	reflex end_simulation when: infected_rate = 1.0 {
		do pause;
	}

}

species people skills: [moving] {
	float speed_person <- (1 + rnd(3)) #km / #h;
	bool is_infected <- false;
	point target;
	//hospital goal;
	int contanimation_distance <- int(10 #m);

	reflex busy_or_pass_time when: (target = nil ) {
		if flip(0.005) {
			target <- any_location_in(one_of(building) + one_of(workingPlace) + one_of(studingPlace) + one_of(hobby));
		}
	}

	reflex move when: target != nil {
		do goto target: target on: road_lines speed: speed_person;
		if (location = target) {
			target <- nil;
		}
		
	}

	reflex propagation when: is_infected {
		ask people at_distance contanimation_distance {
			if flip(0.005) {
				is_infected <- true;
				target <- any_location_in(hospital with_min_of (self distance_to each));
								do goto target: target speed: speed_person;
			}

		}

	}

	aspect circle {
		draw circle(10) color: is_infected ? #red : #green;
	}

}

species road {

	aspect geom {
		draw shape color: #black;
	}

}

species building {

	aspect geom {
		draw shape color: #gray;
	}

}

species doctor {
	rgb color <- rgb(10 + rnd(120), 50, 90);
	//rgb(255, 100, 50);
	aspect basic {
		draw circle(10) color: color;
	}

}

species workingPlace {
	string type;
	rgb color <- #cyan;

	aspect basic {
		draw shape color: color;
	}

}

species studingPlace {
	string type;
	rgb color <- #blue;

	aspect basic {
		draw shape color: color;
	}

}

species hobby {
	string type;
	rgb color <- #yellow;

	aspect basic {
		draw shape color: color;
	}

}

species hospital {
	string type;
	rgb color <- rgb(255, 126, 0);
	//rgb(50, 100, 60);
	aspect basic {
		draw shape color: color;
	}

}

experiment modele_1 type: gui {
//	parameter "Nb people infected at init" var: nb_infected_init min: 1 max: 2147;
	output {
	//		monitor "Infected people rate" value: infected_rate;
		display map {
			species road aspect: geom;
			species building aspect: geom;
			species people aspect: circle;
			species workingPlace aspect: basic;
			species studingPlace aspect: basic;
			species hobby aspect: basic;
			species hospital aspect: basic;
			species doctor aspect: basic;
		}

						display chart_display refresh: every(10 #cycles) {
							chart "Disease spreading" type: series {
								data "susceptible" value: nb_people_not_infected color: #green;
								data "infected" value: nb_people_infected color: #red;
							}
				
						}

	}

}