ArrayList<Wall> walls;

NicheBreeder rb ;

// Stuff used for our local visualization
ArrayList<Roomba> roombas;
int frames = 0;
int visualization_length = 2500;
boolean currently_rendering_visualization = false;

void setup() {
   randomSeed(42+1);
   size(800, 600); 
   
   // Add some furniture to our simulation
   walls = new ArrayList<Wall>();   
   walls.add(new Wall(0, 200, 200, 200));
   walls.add(new Wall(200, 200, 200, 30));
   walls.add(new Wall(600, 200, 200, 30));
   walls.add(new Wall(0, 200+270, 50, 50));
   walls.add(new Wall(150, 200+270, 50, 50));
   walls.add(new Wall(150, 0, 50, 130));
   
   // Just the borders
   walls.add(new Wall(-10, -10, 10, height + 10));
   walls.add(new Wall(-10, -10, width + 10, 10));
   walls.add(new Wall(width, - 10, 10, height + 10));
   walls.add(new Wall(0, height , width + 10, 10));
   
   
   background(0);
   rb = search_niches(40, 20, 500);
   //rb = search_niches(4, 5);

   ArrayList<NeuralNetwork> best_of_gen =rb.create_next_generation();
   best_of_gen.add(rb.best_roomba);
   visualize_generation(best_of_gen);
}

// Search through N random solutions in the search space, find peak with a genetic algorithm,
// and take the one that scores the best.
// TODO: Implement distancing so we don't get too close.
NicheBreeder search_niches(int num_to_search, int num_bad_cycles_to_break, int max_cycles) {
  // Start by picking a random spot in the search space and finding it's nearest peak
   NicheBreeder rb1 = new NicheBreeder(walls);
   rb1.initialize_genetic_algorithm();
   rb1.optimize_niche(num_bad_cycles_to_break, max_cycles);

   print("Niche 0 had a max score of " + Float.toString(rb1.best_score) + "\n");
   // Then for however many times was specified, we'll pick a random spot, find it's peak, and compare
   for (int i = 0; i < num_to_search-1; i++) {
     NicheBreeder rb2 = new NicheBreeder(walls);
     rb2.initialize_genetic_algorithm();
     rb2.optimize_niche(num_bad_cycles_to_break, max_cycles);
     //rb2.fast_forward(num_gens);
     print("Niche " + Integer.toString(i+1) + " had a max score of " + Float.toString(rb2.best_score) + "\n");

     // If it's better, he becomes the new world champion
    if (rb2.best_score > rb1.best_score) {
      rb1 = rb2;
      print("  Newest best roomba found!\n");
    }
   }
   return rb1;
}

NicheBreeder search_niches_threaded(int num_threads) {
  NicheBreeder[] niches = new NicheBreeder[num_threads];
  for (int i = 0; i < num_threads; i++) {
    niches[i] = new NicheBreeder(walls);
    niches[i].start();
    System.out.println("Started new thread!");
  }
  
  while (niches[num_threads-1].isAlive())
    System.out.print(".");
  
  NicheBreeder best_niche = niches[0];
  float best_score = 0;
  for (NicheBreeder i : niches) {
    if (i.best_score > best_score) {
      best_score = i.best_score;
      best_niche = i;
    }
  }
  
  return best_niche;
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
  else frames ++;
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
    int score_sum = 0;
    int walls_banged_sum = 0;
    for (Roomba r : roombas) { 
      score_sum += r.get_dust_eaten();
      walls_banged_sum += r.num_collisions;
    }
    print("Avg Roomba Collected: ");
    print( score_sum / roombas.size() );
    print("\nAvg Roomba Banged Into The Wall For: ");
    print( walls_banged_sum / roombas.size() );
    print("\n");
    roombas = new ArrayList<Roomba>();
    currently_rendering_visualization = false;
  }
}
  
  
