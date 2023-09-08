ArrayList<Wall> walls;

NicheBreeder rb ;

// Stuff used for our local visualization
ArrayList<Roomba> roombas;
int frames = 0;
int visualization_length = 0;
boolean currently_rendering_visualization = false;

void setup() {
   randomSeed(42);
   size(800, 600); 
   // Add some furniture to our simulation
   walls = new ArrayList<Wall>();   
   walls.add(new Wall(100, 200, 200, 200));
   walls.add(new Wall(450, 250, 50, 50));
   walls.add(new Wall(-10, -10, 10, height + 10));
   walls.add(new Wall(-10, -10, width + 10, 10));
   walls.add(new Wall(width, - 10, 10, height + 10));
   walls.add(new Wall(0, height , width + 10, 10));
   
   rb = search_niches(4, 400);
   
   

   ArrayList<NeuralNetwork> best_of_gen = new ArrayList<NeuralNetwork>();
   best_of_gen.add(rb.best_roomba);
   visualize_generation(best_of_gen);
}

// Search through N random solutions in the search space, find peak with a genetic algorithm,
// and take the one that scores the best.
// TODO: Implement distancing so we don't get too close.
NicheBreeder search_niches(int num_to_search, int num_gens) {
  // Start by picking a random spot in the search space and finding it's nearest peak
   NicheBreeder rb1 = new NicheBreeder(walls, 0.1f);
   rb1.initialize_genetic_algorithm();
   rb1.fast_forward(num_gens);
   // Then for however many times was specified, we'll pick a random spot, find it's peak, and compare
   for (int i = 0; i < num_to_search-1; i++) {
     NicheBreeder rb2 = new NicheBreeder(walls, 0.1f);
     rb2.initialize_genetic_algorithm();
     rb2.optimize_niche(num_gens);
     //rb2.fast_forward(num_gens);

     // If it's better, he becomes the new world champion
    if (rb2.best_score > rb1.best_score)
      rb1 = rb2;
      print("New best niche found!\n");
   }
   return rb1;
}
void visualize_generation(ArrayList<NeuralNetwork> solutions) {
   frames = 0;
   roombas = new ArrayList<Roomba>();
   for (NeuralNetwork instincts : solutions) 
     roombas.add( new Roomba(400, 300, 40, rb.walls, rb.dusts, ControlMode.INSTINCT, instincts) );
   currently_rendering_visualization = true;
}

  
void draw() {
  if (keyPressed)
    visualize_generation(rb.current_generation);
  
  if (! currently_rendering_visualization ) return;
  background(255);
  
  // Draw our walls
  for (Wall wall : walls)
    wall.draw();
  
  // Draw dust particles
  for (Dust d : rb.dusts)
    d.draw();
  
  // Draw and tick our roombas
  for (Roomba chumly : roombas) {
    chumly.draw();
    chumly.forward();
  }
  
  
  // Until the simulation ends, then erase them all :c
  if (frames >= visualization_length & visualization_length > 0) {
    roombas = new ArrayList<Roomba>();
    currently_rendering_visualization = false;
  }
}
  
  
