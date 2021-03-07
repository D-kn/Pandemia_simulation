/***
* Name: NewModel
* Author: rolvy-dicken
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model rolvy

global {
	file shape_file_hospital <- file("../includes/Hopital.shp");
	file shape_file_housing <- file("../includes/Housing.shp");
	file shape_file_workingPlace <- file("../includes/working_place.shp");
	file shape_file_studingPlace <- file("../includes/Studing_place.shp");
	file shape_file_hobby <- file("../includes/Loisirs.shp");
	file shape_file_roads <- file("../includes/Routes.shp");

	//geometry shape <- envelope(envelope(shape_file_workingPlace) + envelope(shape_file_hobby));
	geometry shape <- envelope(shape_file_roads) + 50.0;
	graph road_lines;
	int nb_doctor <- 35;
	int nb_people <- 100;
	int people_infected_first <- 3;

	int nb_people_infected <- people_infected_first update: people count (each.state = 'malade');
	int nb_people_not_infected <- nb_people - people_infected_first update: nb_people - nb_people_infected;
	init {
		create road from: shape_file_roads;
		road_lines <- as_edge_graph(road);
		create housing from: shape_file_housing;
		create workingPlace from: shape_file_workingPlace;
		create studingPlace from: shape_file_studingPlace;
		create hobby from: shape_file_hobby;
		create hospital from: shape_file_hospital;
		create people number: nb_people {
			location <- any_location_in(one_of(housing));
			
		}

		create doctor number: nb_doctor {
			location <- any_location_in(one_of(hospital));
		}

		ask people_infected_first among list(people) {
			set state <- 'malade';
		}

	}
	//condition d'arret de la simulation
		reflex stop_simulation {
if( nb_people_not_infected = 0){
	}				do pause;
			}

		

}
//creation des species
species road {
	rgb color <- #black;

	aspect geom {
		draw shape color: color;
	}

}

species people skills: [moving] control: fsm {
	rgb color <- rgb(0, 255, 0);
	int age <- rnd(75);
	float size <- 6.0;
	int healing_time <- 15;
	int killing_time <- 100;
	float prob_infect <- 0.9;
	float prob_mouvement <- 0.005;
	float health_level <- 100.0;
	int contanimation_distance <- int(2 #m);
	//int stay_time <- int(2 #mn);
	//float speed_people <- 2.0;
	point target <- nil;
	float speed_people <- 1.5 + rnd(3) #km / #h;
	//	float expos_enfant <- 0.001;
	//	float expos_adulte <- 0.005;
	//	float expos_ages <- 0.009;
	//	int start_work;
	//	int end_work;
	aspect basic {
		draw circle(size) color: color;
	}

	reflex busy_or_pass_time when: (target = nil) {
		if flip(prob_mouvement) {
			target <- any_location_in(one_of(workingPlace) + one_of(studingPlace) + one_of(hobby));
		}

	}
	//quand la peoplene est en bonne sante
	state bonne_sante initial: true {
		color <- rgb(0, 255, 0);
	}

	state malade {
		color <- #red;
	}

	state dead {
	}

	state healed {
	}

	reflex move when: target != nil and state = 'bonne_sante' {
		do goto target: target on: road_lines speed: speed_people;
		if (location = target) {
			target <- nil;
		}

	}

	reflex go_to_hospital when: state = 'malade' {
		if (location != target) {
			do goto target: target on: road_lines speed: speed_people;
		}
		//target <- any_location_in(hospital with_min_of (self distance_to each));

	}

	reflex propager when: state = 'malade' {
		if flip(prob_infect) {
		//celui qui propage l'infection aussi doit aller a l'hopital le plus proche
			target <- any_location_in(hospital with_min_of (each distance_to self));
			ask people where (each.state = 'bonne_sante') at_distance contanimation_distance {
				set state <- 'malade';
				write "contamine";
				//le malade doit aller a l'hopital le plus proche
				target <- any_location_in(hospital with_min_of (self distance_to each));
			}

		}

	}

}

species doctor {
	rgb color <- rgb(10 + rnd(120), 50, 90);

	aspect basic {
		draw circle(10) color: color;
	}

}

species housing {
	rgb color <- #grey + rgb(rnd(100));

	aspect geom {
		draw shape color: color;
	}

}

species workingPlace {
	rgb color <- #cyan;

	aspect geom {
		draw shape color: color;
	}

}

species studingPlace {
	rgb color <- #blue;

	aspect geom {
		draw shape color: color;
	}

}

species hobby {
	rgb color <- #yellow;

	aspect geom {
		draw shape color: color;
	}

}

species hospital {
	rgb color <- rgb(255, 126, 0);

	aspect basic {
		draw shape color: color;
	}

}

experiment cococo type: gui {
//	float speed_people <- 1.5 + rnd(3) #km / #h;
	output {
		display map {
			species people aspect: basic;
			species doctor aspect: basic;
			species housing aspect: geom;
			species workingPlace aspect: geom;
			species studingPlace aspect: geom;
			species hobby aspect: geom;
			species hospital aspect: basic;
			species road aspect: geom;
		}

		display chart_display refresh: every(10 #cycles) {
			chart "Disease_evolution" type: series {
				data "people_healthy" value: nb_people_not_infected color: #green;
				data "people_infected" value: nb_people_infected color: #red;
			}

		}

	}

}
