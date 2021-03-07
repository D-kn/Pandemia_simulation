
/***
* Name: rolvy
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
	int current_hour update: (time / #hour) mod 24;
	int min_work_start <- 1;
	int max_work_start <- 2;
	int min_work_end <- 3;
	int max_work_end <- 4;
	//geometry shape <- envelope(envelope(shape_file_workingPlace) + envelope(shape_file_hobby));
	geometry shape <- envelope(shape_file_roads) + 50.0;
	graph road_lines;
	int nb_doctor <- 35;
	int nb_personne <- 100;
	int nb_virus <- 3;

	init {
		create road from: shape_file_roads;
		road_lines <- as_edge_graph(road);
		create housing from: shape_file_housing;
		create workingPlace from: shape_file_workingPlace;
		create studingPlace from: shape_file_studingPlace;
		create hobby from: shape_file_hobby;
		create hospital from: shape_file_hospital;
		create personnes number: nb_personne {
			location <- any_location_in(one_of(housing));
			start_work <- min_work_start + rnd(max_work_start - min_work_start);
			end_work <- min_work_end + rnd(max_work_end - min_work_end);
		}

		create doctor number: nb_doctor {
			location <- any_location_in(one_of(hospital));
		}

		ask nb_virus among list(personnes) {
			set state <- 'malade';
		}

	}

	reflex stop_simulation {
		if (length(list(personnes where (each.state = 'bonne_sante'))) = 0) {
			do pause;
		}

	}

}

species road {
	rgb color <- #black;

	aspect geom {
		draw shape color: color;
	}

}

species personnes skills: [moving] control: fsm {
	rgb color <- rgb(0, 255, 0);
	int age <- rnd(75);
	float size <- 6.0;
	int stay_time <- int(2 #mn);
	//float speed_person <- 2.0;
	point target <- nil;
	int contanimation_distance <- int(2 #m);
	float speed_person <- 1.5 + rnd(3) #km / #h;
	//	float expos_enfant <- 0.001;
	//	float expos_adulte <- 0.005;
	//	float expos_ages <- 0.009;
	int start_work;
	int end_work;

	aspect basic {
		draw circle(size) color: color;
	}

	reflex busy_or_pass_time when: (target = nil and current_hour = start_work) {
		if flip(0.005) {
			target <- any_location_in(one_of(workingPlace) + one_of(studingPlace) + one_of(hobby));
		}
	
	
	 
	}

	state bonne_sante initial: true {
		color <- rgb(0, 255, 0);
	}

	state malade {
		color <- #red;
	}

	reflex move when: target != nil and state = 'bonne_sante' {
		do goto target: target on: road_lines speed: speed_person;
		if (location = target and current_hour = end_work) {
		target <- any_location_in(one_of(housing));
		}

	}

	reflex go_to_hospital when: state = 'malade' {
		if (location != target) {
			do goto target: target on: road_lines speed: speed_person;
		}

	}

	reflex propager when: state = 'malade' {
		if flip(0.9) {
			target <- any_location_in(hospital with_min_of (each distance_to self));
			ask personnes where (each.state = 'bonne_sante') at_distance contanimation_distance {
				set state <- 'malade';
				write "contamine";
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
//	float speed_person <- 1.5 + rnd(3) #km / #h;
	output {
		display map {
			species personnes aspect: basic;
			species doctor aspect: basic;
			species housing aspect: geom;
			species workingPlace aspect: geom;
			species studingPlace aspect: geom;
			species hobby aspect: geom;
			species hospital aspect: basic;
			species road aspect: geom;
			
		} display chart_display refresh: every(5 #cycles){
chart "Disease spreading" type: series {
	
	
}
	}
}
}
