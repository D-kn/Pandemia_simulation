/***
* Name: Model100
* Author: rolvy-dicken
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model Model100

global {
	file shape_file_housing <- file("../includes/Housing.shp");
	file shape_file_workingPlace <- file("../includes/working_place.shp");
	file shape_file_studingPlace <- file("../includes/Studing_place.shp");
	file shape_file_hobby <- file("../includes/Loisirs.shp");
	file shape_file_hospital <- file("../includes/Hopital.shp");
	file shape_file_roads <- file("../includes/Road.shp");
	geometry
	shape <- envelope(envelope(shape_file_housing) + envelope(shape_file_studingPlace) + envelope(shape_file_hobby) 
		+ envelope(shape_file_hospital)
	);
	int nb_personne <- 1000;

	init {
		create housing from: shape_file_housing;
		create workingPlace from: shape_file_workingPlace;
		create studingPlace from: shape_file_studingPlace;
		create hobby from: shape_file_hobby;
		create hospital from: shape_file_hospital;
		create road from: shape_file_roads;
		create personnes number: nb_personne {
			location <- any_location_in(one_of(housing));
		}

	}

}

species personnes skills: [moving] {
	rgb color <- rgb(0, 255, 0);
	int age <- 2 + rnd(75);
	float size <- 0.02 #mm;

	aspect basic {
		draw circle(size) color: color;
	}

}

species housing {
	string type;
	rgb color <- #grey;

	aspect basic {
		draw shape color: color;
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
	rgb color <- #purple;

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
	rgb color <- #orange;

	aspect basic {
		draw shape color: color;
	}

}

species road {
	rgb color <- #black;

	aspect basic {
		draw shape color: color;
	}

}

experiment Model100 type: gui {
//parameter "Number of Persons" var: nb_personne category: "Personnes";

//	parameter "Shapefile for housing:" var: shape_file_housing category: "GIS";
//	parameter "Shapefile for workkingPlace :" var: shape_file_workingPlace category: "GIS";
//	parameter "Shapefile for studingPlace :" var: shape_file_studingPlace category: "GIS";
//	parameter "Shapefile for hobbies :" var: shape_file_hobby category: "GIS";
//	parameter "Shapefile for roads :" var: shape_file_roads category: "GIS";
	output {
		display Brazzaville_display type: opengl {
			species personnes aspect: basic;
			species housing aspect: basic;
			species workingPlace aspect: basic;
			species studingPlace aspect: basic;
			species hobby aspect: basic;
			species hospital aspect: basic;
			species road aspect: basic;
		}

		display age_repartitoin {
			chart "td-digramme" type: pie {
				data "less than 16 years" value: length(list(personnes) where (each.age < 16)) color: #cyan;
				data "between 16 and 45 years" value: length(list(personnes) where (each.age >= 16 and each.size <= 45)) color: #orange;
				data "over than 45 years" value: length(list(personnes) where (each.age > 45)) color: rgb(0, 245, 50);
			}

		}

	}

}
